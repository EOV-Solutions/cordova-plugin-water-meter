//
//  WaterMeter.m
//  WaterMeter Cordova Plugin
//
//  iOS plugin implementation for Cordova integration
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#import "WaterMeter.h"
@import WaterMeterSDK;

@interface WaterMeter () <WMCameraScannerDelegate_ObjC>
@property (nonatomic, copy) NSString *scanCallbackId;
@property (nonatomic, strong) WMCameraScanner *currentScanner;
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
        NSInteger maxSideLen = options[@"maxSideLength"] ? [options[@"maxSideLength"] integerValue] : 640;
        
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
              maxSideLength:640 
        detectionThreshold:0.5f 
      recognitionThreshold:0.7f];
    
    NSError *error = nil;
    [[WaterMeterSDK shared] initializeWithBundle:[NSBundle mainBundle]
                                   configuration:config
                                           error:&error];
    
    completion(error);
}

#pragma mark - Camera Scanner

- (void)scan:(CDVInvokedUrlCommand *)command {
    self.scanCallbackId = command.callbackId;
    
    // Parse options
    NSDictionary *options = nil;
    if (command.arguments.count > 0 && [command.arguments[0] isKindOfClass:[NSDictionary class]]) {
        options = command.arguments[0];
    }
    
    NSString *title = options[@"title"] ?: @"Quét đồng hồ nước";
    BOOL autoCapture = options[@"autoCapture"] ? [options[@"autoCapture"] boolValue] : YES;
    float minConfidence = options[@"minConfidence"] ? [options[@"minConfidence"] floatValue] : 0.7f;
    BOOL showCloseButton = options[@"showCloseButton"] ? [options[@"showCloseButton"] boolValue] : YES;
    
    // Image resize options (like Android)
    NSInteger imageMaxWidth = options[@"imageMaxWidth"] ? [options[@"imageMaxWidth"] integerValue] : 0;
    NSInteger imageMaxHeight = options[@"imageMaxHeight"] ? [options[@"imageMaxHeight"] integerValue] : 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Auto-initialize if needed (like Android)
        [self ensureInitializedWithCompletion:^(NSError *initError) {
            if (initError) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                            messageAsString:[NSString stringWithFormat:@"SDK initialization failed: %@", initError.localizedDescription]];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                return;
            }
            
            // Create scanner configuration with image resize options
            WMScannerConfiguration_ObjC *config = [[WMScannerConfiguration_ObjC alloc]
                initWithAutoCapture:autoCapture
                      minConfidence:minConfidence
                       flashEnabled:NO
                    showCloseButton:showCloseButton
                              title:title
                      imageMaxWidth:imageMaxWidth
                     imageMaxHeight:imageMaxHeight];
            
            // Present scanner
            NSError *error = nil;
            [[WaterMeterSDK shared] presentScannerWithConfiguration:config
                                                           delegate:self
                                                               from:self.viewController
                                                              error:&error];
            
            if (error) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                            messageAsString:error.localizedDescription];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    });
}

#pragma mark - WMCameraScannerDelegate_ObjC

- (void)scanner:(WMCameraScanner *)scanner didScanResult:(WMScanResult_ObjC *)result {
    // SDK already dismisses the view controller, so we just send the result directly
    // Do NOT call dismissViewControllerAnimated here - it will cause completion to never fire
    dispatch_async(dispatch_get_main_queue(), ^{
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
        NSLog(@"[WaterMeter Plugin] Scan failed with error: %@", error.localizedDescription);
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:error.localizedDescription];
        [self.commandDelegate sendPluginResult:result callbackId:self.scanCallbackId];
        self.scanCallbackId = nil;
    });
}

- (void)scannerDidCancel:(WMCameraScanner *)scanner {
    // SDK already dismisses the view controller
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[WaterMeter Plugin] User cancelled scan");
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

#pragma mark - Helper Methods

/// Convert OCR result to dictionary matching Android format:
/// {text, confidence, success, imagePath}
- (NSDictionary *)ocrResultToDictionary:(WMOCRScanResult_ObjC *)ocrResult {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Core fields matching Android SDK format
    dict[@"text"] = ocrResult.text ?: @"";
    dict[@"confidence"] = @(ocrResult.confidence);
    dict[@"success"] = @(ocrResult.success);
    
    // Include imagePath if available
    if (ocrResult.imagePath && ocrResult.imagePath.length > 0) {
        dict[@"imagePath"] = ocrResult.imagePath;
    }
    
    // Additional iOS-specific fields (for backward compatibility)
    dict[@"formattedReading"] = ocrResult.formattedReading ?: @"";
    dict[@"isReliable"] = @(ocrResult.isReliable);
    
    return dict;
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
