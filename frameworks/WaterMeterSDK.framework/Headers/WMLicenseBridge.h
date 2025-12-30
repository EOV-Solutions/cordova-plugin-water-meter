//
//  WMLicenseBridge.h
//  WaterMeterSDK
//
//  Objective-C Bridge for C++ License Manager
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// License status constants (must match C++ LicenseStatus enum)
typedef NS_ENUM(NSInteger, WMLicenseStatus) {
    WMLicenseStatusNotInitialized = 0,
    WMLicenseStatusValid = 1,
    WMLicenseStatusExpired = 2,
    WMLicenseStatusGracePeriod = 3,
    WMLicenseStatusInvalid = 4,
    WMLicenseStatusBlocked = 5,
    WMLicenseStatusQuotaExceeded = 6
};

/// Objective-C bridge for C++ license management
/// All methods are class methods (static) since LicenseManager is a singleton
@interface WMLicenseBridge : NSObject

#pragma mark - Secret Key Management

/// Set the secret key for JWT verification
/// Must be called before initLicense
/// @param secretKey The secret key for HMAC-SHA256 verification
+ (void)setSecretKey:(NSString *)secretKey;

#pragma mark - License Initialization

/// Initialize license with offline token
/// @param offlineToken JWT token received from server
/// @param deviceId Current device's unique identifier
/// @return YES if license is valid
+ (BOOL)initLicense:(NSString *)offlineToken deviceId:(NSString *)deviceId;

/// Check if current license is valid
/// @return YES if license is valid and not expired
+ (BOOL)isLicenseValid;

/// Get current license status code
/// @return One of WMLicenseStatus values
+ (WMLicenseStatus)getLicenseStatus;

/// Clear current license data
+ (void)clearLicense;

#pragma mark - Security URLs and Keys

/// Get the hardcoded API base URL from native layer
/// This URL cannot be modified from Swift for security
/// @return The API base URL
+ (NSString *)getBaseUrl;

/// Get the default secret key for JWT verification from native layer
/// This key is hardcoded in native for security
/// @return The default secret key
+ (NSString *)getDefaultSecretKey;

#pragma mark - Quota Management

/// Increment usage counter. If threshold is reached, blocks the SDK
/// @param amount Amount to increment (usually 1)
/// @return YES if SDK is still usable, NO if blocked due to quota
+ (BOOL)incrementUsage:(int)amount;

/// Check if SDK is blocked due to quota threshold exceeded
/// @return YES if blocked
+ (BOOL)isBlockedDueToQuota;

/// Get the quota threshold value (hardcoded in native for security)
/// @return Threshold value
+ (int)getQuotaThreshold;

/// Get current pending usage count
/// @return Pending usage count
+ (int)getPendingUsage;

/// Set blocked state (called after sync attempt)
/// @param blocked YES to block, NO to unblock
+ (void)setBlockedDueToQuota:(BOOL)blocked;

/// Reset pending usage count (called after successful sync)
+ (void)resetPendingUsage;

#pragma mark - Sync Interval Management

/// Update last sync time to current time
/// Call after successful sync
+ (void)updateLastSync;

/// Check if sync is needed based on time interval and quota
/// @return YES if sync should be performed
+ (BOOL)shouldSync;

/// Get the sync interval value (hardcoded in native for security)
/// @return Sync interval in milliseconds
+ (int64_t)getSyncInterval;

/// Set last sync time (called on startup with stored value from UserDefaults)
/// @param timeMs Last sync timestamp in milliseconds
+ (void)setLastSyncTime:(int64_t)timeMs;

@end

NS_ASSUME_NONNULL_END
