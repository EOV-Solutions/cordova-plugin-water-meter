//
//  WaterMeter.m
//  WaterMeter Cordova Plugin
//
//  iOS plugin implementation for Cordova integration
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#import "WaterMeter.h"
@import WaterMeterSDK;
@import AVFoundation;

@interface WaterMeter () <WMCameraScannerDelegate_ObjC>
@property (nonatomic, copy) NSString *scanCallbackId;
@property (nonatomic, strong) WMCameraScanner *currentScanner;
@property (nonatomic, assign) BOOL isScannerPresented;  // Guard against multiple calls
@property (nonatomic, assign) BOOL licenseInitialized;  // Track license status
@end

@implementation WaterMeter

#pragma mark - Plugin Lifecycle

- (void)pluginInitialize {
    [super pluginInitialize];
    // Plugin initialization code here
}

#pragma mark - SDK Initialization

- (void)initialize:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSDictionary *options = nil;
        if (command.arguments.count > 0 && [command.arguments[0] isKindOfClass:[NSDictionary class]]) {
            options = command.arguments[0];
        }
        
        // Parse configuration
        NSInteger threadCount = options[@"threadCount"] ? [options[@"threadCount"] integerValue] : 2;
        BOOL useGPU = options[@"useGPU"] ? [options[@"useGPU"] boolValue] : NO;
        NSInteger maxSideLen = options[@"maxSideLength"] ? [options[@"maxSideLength"] integerValue] : 480;  // Model trained with 480x480
        
        // Create configuration (use ObjC wrapper)
        WMPredictorConfiguration_ObjC *config = [[WMPredictorConfiguration_ObjC alloc] 
            initWithThreadCount:threadCount 
                   cpuPowerMode:1  // Normal 
                         useGPU:useGPU 
                  maxSideLength:maxSideLen 
            detectionThreshold:0.5f 
          recognitionThreshold:0.7f];
        
        // Initialize SDK
        NSError *error = nil;
        [[WaterMeterSDK shared] initializeWithBundle:[NSBundle mainBundle]
                                       configuration:config
                                               error:&error];
        
        CDVPluginResult *result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:error.localizedDescription];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsDictionary:@{
                @"success": @YES,
                @"message": @"SDK initialized successfully",
                @"version": [WaterMeterSDK sdkVersion]
            }];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - License Management

/**
 * Initialize SDK with license key (like Android)
 */
- (void)initializeLicense:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        // Validate arguments
        if (command.arguments.count == 0 || ![command.arguments[0] isKindOfClass:[NSString class]]) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                messageAsDictionary:@{
                @"valid": @NO,
                @"status": @(0),
                @"message": @"License key is required"
            }];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSString *licenseKey = command.arguments[0];
        
        if (licenseKey.length == 0) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                messageAsDictionary:@{
                @"valid": @NO,
                @"status": @(0),
                @"message": @"License key cannot be empty"
            }];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSLog(@"[WaterMeter Plugin] Initializing license...");
        
        // Call SDK's initializeLicense
        [[WaterMeterSDK shared] initializeLicenseWithLicenseKey:licenseKey completion:^(BOOL success, NSString * _Nullable errorMessage) {
            CDVPluginResult *result;
            NSInteger status = [WaterMeterSDK shared].licenseStatus;
            
            if (success) {
                self.licenseInitialized = YES;
                NSLog(@"[WaterMeter Plugin] License initialized successfully");
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                       messageAsDictionary:@{
                    @"valid": @YES,
                    @"status": @(status),
                    @"message": [self statusMessageForCode:status]
                }];
            } else {
                self.licenseInitialized = NO;
                NSString *error = errorMessage ?: @"License activation failed";
                NSLog(@"[WaterMeter Plugin] License error: %@", error);
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsDictionary:@{
                    @"valid": @NO,
                    @"status": @(status),
                    @"message": error
                }];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }];
}

/**
 * Check if license is valid (like Android)
 */
- (void)isLicenseValid:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        BOOL valid = [WaterMeterSDK shared].isLicenseValid;
        NSInteger status = [WaterMeterSDK shared].licenseStatus;
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                               messageAsDictionary:@{
            @"valid": @(valid),
            @"status": @(status),
            @"message": [self statusMessageForCode:status]
        }];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - Recognition Methods

- (void)recognizeBase64:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        // Validate arguments
        if (command.arguments.count == 0 || ![command.arguments[0] isKindOfClass:[NSString class]]) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:@"Missing base64 image data"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSString *base64String = command.arguments[0];
        
        // Remove data URL prefix if present
        if ([base64String containsString:@"base64,"]) {
            NSRange range = [base64String rangeOfString:@"base64,"];
            base64String = [base64String substringFromIndex:NSMaxRange(range)];
        }
        
        // Decode base64
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String
                                                                options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (!imageData) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:@"Invalid base64 data"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        UIImage *image = [UIImage imageWithData:imageData];
        if (!image) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:@"Could not create image from data"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        [self performRecognition:image callbackId:command.callbackId];
    }];
}

- (void)recognizeFile:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        // Validate arguments
        if (command.arguments.count == 0 || ![command.arguments[0] isKindOfClass:[NSString class]]) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:@"Missing file path"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSString *filePath = command.arguments[0];
        
        // Handle various path formats
        if ([filePath hasPrefix:@"file://"]) {
            NSURL *url = [NSURL URLWithString:filePath];
            filePath = url.path;
        } else if ([filePath hasPrefix:@"cdvfile://"]) {
            // Handle Cordova file URLs
            filePath = [self resolveCordovaFilePath:filePath];
        }
        
        // Load image
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (!image) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:[NSString stringWithFormat:@"Could not load image from: %@", filePath]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        [self performRecognition:image callbackId:command.callbackId];
    }];
}

- (void)performRecognition:(UIImage *)image callbackId:(NSString *)callbackId {
    // Auto-initialize if needed (like Android)
    [self ensureInitializedWithCompletion:^(NSError *initError) {
        if (initError) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:[NSString stringWithFormat:@"SDK initialization failed: %@", initError.localizedDescription]];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            return;
        }
        
        // Perform recognition
        NSError *error = nil;
        WMOCRScanResult_ObjC *ocrResult = [[WaterMeterSDK shared] recognizeWithImage:image error:&error];
        
        CDVPluginResult *result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:error.localizedDescription];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsDictionary:[self ocrResultToDictionary:ocrResult]];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }];
}

#pragma mark - Auto Initialize Helper

- (void)ensureInitializedWithCompletion:(void (^)(NSError *error))completion {
    if ([WaterMeterSDK shared].isInitialized) {
        completion(nil);
        return;
    }
    
    // Auto-initialize with default config (like Android)
    WMPredictorConfiguration_ObjC *config = [[WMPredictorConfiguration_ObjC alloc] 
        initWithThreadCount:2 
               cpuPowerMode:1  // Normal 
                     useGPU:NO 
              maxSideLength:480  // Model trained with 480x480 input
        detectionThreshold:0.5f 
      recognitionThreshold:0.7f];
    
    NSError *error = nil;
    [[WaterMeterSDK shared] initializeWithBundle:[NSBundle mainBundle]
                                   configuration:config
                                           error:&error];
    
    completion(error);
}

#pragma mark - Permissions

- (void)checkPermission:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        NSString *statusString;
        BOOL granted = NO;
        
        switch (status) {
            case AVAuthorizationStatusAuthorized:
                statusString = @"granted";
                granted = YES;
                break;
            case AVAuthorizationStatusDenied:
                statusString = @"denied";
                break;
            case AVAuthorizationStatusRestricted:
                statusString = @"restricted";
                break;
            case AVAuthorizationStatusNotDetermined:
                statusString = @"prompt";
                break;
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                               messageAsDictionary:@{
            @"status": statusString,
            @"granted": @(granted)
        }];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

- (void)requestPermission:(CDVInvokedUrlCommand *)command {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                   messageAsDictionary:@{
            @"status": granted ? @"granted" : @"denied",
            @"granted": @(granted)
        }];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - Camera Scanner

- (void)scan:(CDVInvokedUrlCommand *)command {
    // Guard against multiple simultaneous calls
    if (self.isScannerPresented) {
        NSLog(@"[WaterMeter Plugin] scan: IGNORED - scanner already presented");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:@"Scanner already active"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    self.isScannerPresented = YES;
    self.scanCallbackId = command.callbackId;
    NSLog(@"[WaterMeter Plugin] scan: CALLED, isScannerPresented = YES");
    
    // Parse options - only UI-related options, NOT behavior settings
    NSDictionary *options = nil;
    if (command.arguments.count > 0 && [command.arguments[0] isKindOfClass:[NSDictionary class]]) {
        options = command.arguments[0];
    }
    
    // Only read UI options, NOT auto-capture or confidence settings
    // These should come from SDK's WMSettings (UI Settings screen)
    NSString *title = options[@"title"] ?: @"Quét đồng hồ nước";
    BOOL showCloseButton = options[@"showCloseButton"] ? [options[@"showCloseButton"] boolValue] : YES;
    
    // Image resize options (like Android)
    NSInteger imageMaxWidth = options[@"imageMaxWidth"] ? [options[@"imageMaxWidth"] integerValue] : 0;
    NSInteger imageMaxHeight = options[@"imageMaxHeight"] ? [options[@"imageMaxHeight"] integerValue] : 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check if view controller is ready to present
        if (!self.viewController.view.window) {
            NSLog(@"[WaterMeter Plugin] scan: DELAYED - view not in hierarchy, retrying in 0.3s");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentScannerWithOptions:options command:command];
            });
            return;
        }
        
        [self presentScannerWithOptions:options command:command];
    });
}

- (void)presentScannerWithOptions:(NSDictionary *)options command:(CDVInvokedUrlCommand *)command {
    // Only read UI options - behavior settings come from SDK's WMSettings
    NSString *title = options[@"title"] ?: @"Quét đồng hồ nước";
    BOOL showCloseButton = options[@"showCloseButton"] ? [options[@"showCloseButton"] boolValue] : YES;
    NSInteger imageMaxWidth = options[@"imageMaxWidth"] ? [options[@"imageMaxWidth"] integerValue] : 0;
    NSInteger imageMaxHeight = options[@"imageMaxHeight"] ? [options[@"imageMaxHeight"] integerValue] : 0;
    
    NSLog(@"[WaterMeter Plugin] presentScanner - UI options only, behavior from SDK settings");
    NSLog(@"[WaterMeter Plugin] title=%@, showCloseButton=%d", title, showCloseButton);
    
    // Auto-initialize if needed (like Android)
    [self ensureInitializedWithCompletion:^(NSError *initError) {
        if (initError) {
            self.isScannerPresented = NO;
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:[NSString stringWithFormat:@"SDK initialization failed: %@", initError.localizedDescription]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        // Create scanner configuration - NO override for autoCapture/confidence
        // Use -1 for all behavior settings to let SDK use WMSettings values
        WMScannerConfiguration_ObjC *config = [[WMScannerConfiguration_ObjC alloc]
            initWithAutoCaptureSet:-1          // Use SDK settings
                  minConfidenceSet:-1.0f       // Use SDK settings
                   flashEnabled:NO
                showCloseButton:showCloseButton
                          title:title
                  imageMaxWidth:imageMaxWidth
                 imageMaxHeight:imageMaxHeight];
        
        // Present scanner
        NSError *error = nil;
        NSLog(@"[WaterMeter Plugin] presentScanner about to call SDK (using SDK settings for behavior)");
        [[WaterMeterSDK shared] presentScannerWithConfiguration:config
                                                       delegate:self
                                                           from:self.viewController
                                                          error:&error];
        
        if (error) {
            self.isScannerPresented = NO;
            NSLog(@"[WaterMeter Plugin] presentScanner ERROR: %@", error.localizedDescription);
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:error.localizedDescription];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            NSLog(@"[WaterMeter Plugin] presentScanner SUCCESS");
        }
    }];
}

#pragma mark - WMCameraScannerDelegate_ObjC

- (void)scanner:(WMCameraScanner *)scanner didScanResult:(WMScanResult_ObjC *)result {
    // SDK already dismisses the view controller, so we just send the result directly
    // Do NOT call dismissViewControllerAnimated here - it will cause completion to never fire
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isScannerPresented = NO;  // Reset guard flag
        NSLog(@"[WaterMeter Plugin] didScanResult - isScannerPresented = NO");
        
        CDVPluginResult *pluginResult;
        
        // Always return result if we have ocrResult (like Android)
        // Android returns result even when text is empty or confidence is low
        if (result.ocrResult) {
            NSLog(@"[WaterMeter Plugin] Got OCR result: %@, confidence: %f", 
                  result.ocrResult.text, result.ocrResult.confidence);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsDictionary:[self ocrResultToDictionary:result.ocrResult]];
        } else {
            // No OCR result at all
            NSString *statusMessage;
            switch (result.status) {
                case WMScanResultStatusNoMeterDetected:
                    statusMessage = @"No water meter detected";
                    break;
                case WMScanResultStatusLowConfidence:
                    statusMessage = @"Low confidence result";
                    break;
                case WMScanResultStatusError:
                    statusMessage = @"Scan error";
                    break;
                default:
                    statusMessage = @"Scan failed";
                    break;
            }
            NSLog(@"[WaterMeter Plugin] No OCR result, status: %@", statusMessage);
            // Return as success but with empty text (like Android behavior)
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsDictionary:@{
                @"text": @"",
                @"confidence": @(0),
                @"success": @(NO),
                @"message": statusMessage
            }];
        }
        
        NSLog(@"[WaterMeter Plugin] Sending plugin result to JS callback: %@", self.scanCallbackId);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.scanCallbackId];
        self.scanCallbackId = nil;
    });
}

- (void)scanner:(WMCameraScanner *)scanner didFailWithError:(NSError *)error {
    // SDK already dismisses the view controller
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isScannerPresented = NO;  // Reset guard flag
        NSLog(@"[WaterMeter Plugin] didFailWithError - isScannerPresented = NO, error: %@", error.localizedDescription);
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:error.localizedDescription];
        [self.commandDelegate sendPluginResult:result callbackId:self.scanCallbackId];
        self.scanCallbackId = nil;
    });
}

- (void)scannerDidCancel:(WMCameraScanner *)scanner {
    // SDK already dismisses the view controller
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isScannerPresented = NO;  // Reset guard flag
        NSLog(@"[WaterMeter Plugin] scannerDidCancel - isScannerPresented = NO");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:@"User cancelled"];
        [self.commandDelegate sendPluginResult:result callbackId:self.scanCallbackId];
        self.scanCallbackId = nil;
    });
}

#pragma mark - Utility Methods

- (void)getVersion:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsString:[WaterMeterSDK sdkVersion]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)isInitialized:(CDVInvokedUrlCommand *)command {
    BOOL initialized = [WaterMeterSDK shared].isInitialized;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                   messageAsBool:initialized];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)reset:(CDVInvokedUrlCommand *)command {
    [[WaterMeterSDK shared] reset];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsString:@"SDK reset"];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)openSettings:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Present SDK settings view controller
        WMSettingsViewController *settingsVC = [[WMSettingsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        // Add close button
        settingsVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
            target:self
            action:@selector(closeSettings)];
        
        [self.viewController presentViewController:navController animated:YES completion:^{
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                       messageAsString:@"Settings opened"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    });
}

- (void)closeSettings {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods

/// Convert OCR result to dictionary matching Android format:
/// {text, confidence, success, imagePath, imageBase64}
- (NSDictionary *)ocrResultToDictionary:(WMOCRScanResult_ObjC *)ocrResult {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Core fields matching Android SDK format
    dict[@"text"] = ocrResult.text ?: @"";
    dict[@"confidence"] = @(ocrResult.confidence);
    dict[@"success"] = @(ocrResult.success);
    
    // Include imagePath if available
    if (ocrResult.imagePath && ocrResult.imagePath.length > 0) {
        dict[@"imagePath"] = ocrResult.imagePath;
        
        // Also include base64 for WKWebView display
        NSData *imageData = [NSData dataWithContentsOfFile:ocrResult.imagePath];
        if (imageData) {
            NSString *base64String = [imageData base64EncodedStringWithOptions:0];
            dict[@"imageBase64"] = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", base64String];
        }
    }
    
    // Additional iOS-specific fields (for backward compatibility)
    dict[@"formattedReading"] = ocrResult.formattedReading ?: @"";
    dict[@"isReliable"] = @(ocrResult.isReliable);
    
    return dict;
}

/// Convert license status code to human-readable message (match Android format)
- (NSString *)statusMessageForCode:(NSInteger)status {
    switch (status) {
        case 0: return @"SDK not initialized";
        case 1: return @"License is valid";
        case 2: return @"License has expired";
        case 3: return @"License in grace period";
        case 4: return @"Invalid license key";
        case 5: return @"License has been blocked";
        case 6: return @"Quota exceeded, sync required";
        default: return @"Unknown status";
    }
}

- (NSString *)resolveCordovaFilePath:(NSString *)cdvPath {
    // Handle cdvfile:// URLs
    // cdvfile://localhost/persistent/path/to/file
    // cdvfile://localhost/temporary/path/to/file
    
    if ([cdvPath containsString:@"/persistent/"]) {
        NSRange range = [cdvPath rangeOfString:@"/persistent/"];
        NSString *relativePath = [cdvPath substringFromIndex:NSMaxRange(range)];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        return [documentsPath stringByAppendingPathComponent:relativePath];
    } else if ([cdvPath containsString:@"/temporary/"]) {
        NSRange range = [cdvPath rangeOfString:@"/temporary/"];
        NSString *relativePath = [cdvPath substringFromIndex:NSMaxRange(range)];
        return [NSTemporaryDirectory() stringByAppendingPathComponent:relativePath];
    } else if ([cdvPath containsString:@"/cache/"]) {
        NSRange range = [cdvPath rangeOfString:@"/cache/"];
        NSString *relativePath = [cdvPath substringFromIndex:NSMaxRange(range)];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        return [cachePath stringByAppendingPathComponent:relativePath];
    }
    
    return cdvPath;
}

@end
