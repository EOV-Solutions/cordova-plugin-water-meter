//
//  WaterMeter.h
//  WaterMeter Cordova Plugin
//
//  iOS plugin header for Cordova integration
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#import <Cordova/CDV.h>

@interface WaterMeter : CDVPlugin

/// Initialize the SDK with configuration
/// @param command Cordova command with optional config dictionary
- (void)initialize:(CDVInvokedUrlCommand*)command;

/// Initialize SDK with license key (recommended)
/// @param command Cordova command with license key string
- (void)initializeLicense:(CDVInvokedUrlCommand*)command;

/// Check if license is valid
/// @param command Cordova command
- (void)isLicenseValid:(CDVInvokedUrlCommand*)command;

/// Recognize water meter reading from base64 image
/// @param command Cordova command with base64 string
- (void)recognizeBase64:(CDVInvokedUrlCommand*)command;

/// Recognize water meter reading from file path
/// @param command Cordova command with file path string
- (void)recognizeFile:(CDVInvokedUrlCommand*)command;

/// Open camera scanner for real-time recognition
/// @param command Cordova command with scanner options
- (void)scan:(CDVInvokedUrlCommand*)command;

/// Get SDK version string
/// @param command Cordova command
- (void)getVersion:(CDVInvokedUrlCommand*)command;

/// Check if SDK is initialized
/// @param command Cordova command
- (void)isInitialized:(CDVInvokedUrlCommand*)command;

/// Release SDK resources
/// @param command Cordova command
- (void)reset:(CDVInvokedUrlCommand*)command;

@end
