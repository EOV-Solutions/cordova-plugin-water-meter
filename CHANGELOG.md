# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2025-11-11

### 🎨 New Features

#### Image Resize on Save
- ✅ **Flexible resize options**: Specify `imageMaxWidth` or `imageMaxHeight` when scanning
- ✅ **Auto aspect ratio**: Only need to specify one dimension - other calculated automatically
- ✅ **Fit within bounds**: Specify both dimensions to fit image within bounds
- ✅ **Memory efficient**: Auto-recycles resized bitmap to prevent memory leaks
- ✅ **Optional feature**: Default behavior (no resize) unchanged

#### JavaScript API
```javascript
// Resize by width (height auto-calculated)
WaterMeter.scan(success, error, { imageMaxWidth: 1920 });

// Resize by height (width auto-calculated)
WaterMeter.scan(success, error, { imageMaxHeight: 1080 });

// Fit within bounds
WaterMeter.scan(success, error, { 
    imageMaxWidth: 1920, 
    imageMaxHeight: 1080 
});
```

#### Native API
```java
// Using WaterMeterSDK builder
new WaterMeterSDK.CameraScanBuilder()
    .setImageMaxWidth(1920)
    .setImageMaxHeight(1080)
    
// Or directly via Intent
intent.putExtra(CameraScanActivity.EXTRA_IMAGE_MAX_WIDTH, 1920);
```

#### Technical Changes
- Added `CameraScanActivity.EXTRA_IMAGE_MAX_WIDTH` constant
- Added `CameraScanActivity.EXTRA_IMAGE_MAX_HEIGHT` constant
- Added `resizeBitmapIfNeeded()` method with smart scaling logic
- Updated `saveImageToFile()` to resize before saving
- Added setters in `WaterMeterSDK.CameraScanBuilder`
- Updated `WaterMeterPlugin` to pass resize options from JavaScript
- Updated `WaterMeter.js` with new options

#### Documentation
- Added [IMAGE_RESIZE_FEATURE.md](./IMAGE_RESIZE_FEATURE.md) with examples
- Updated README with resize usage examples
- Added API reference for new parameters

#### Use Cases
- 📱 Mobile upload optimization (reduce bandwidth)
- 🖼️ Thumbnail generation
- 💾 Storage space management
- 🚀 Faster image processing

---

## [1.1.1] - 2025-11-10

### 🔧 Critical Bug Fixes

#### Fixed Manifest Merger Conflict
- ✅ **Removed FileProvider from SDK**: Eliminated manifest merger conflicts when integrating with Cordova apps
- ✅ **Cleaner integration**: SDK no longer declares its own FileProvider
- ✅ **Host app compatibility**: Cordova apps manage their own FileProvider configuration
- ✅ **No breaking changes**: Image saving still works via app-scoped storage

#### Technical Details
- **File modified**: `Water_SDK/app/src/main/AndroidManifest.xml`
- **Change**: Removed `<provider>` declaration for FileProvider
- **Reason**: SDK uses `getExternalFilesDir()` which doesn't require FileProvider
- **Impact**: Eliminates "Manifest merger failed" errors in external apps
- **Backwards compatible**: Existing apps continue to work without changes

#### Migration Notes
- ✅ **For new integrations**: No action needed - works out of the box
- ✅ **For existing apps with conflicts**: Update plugin to v1.1.1 or later
- ℹ️ **For manual workarounds**: Can now remove `tools:replace` attributes

See [MANIFEST_CONFLICT_FIX.md](./MANIFEST_CONFLICT_FIX.md) for detailed explanation.

---

## [1.1.0] - 2025-11-03

### 🎯 New Features

#### Image Capture & Save
- ✅ **Auto-save captured images**: SDK now automatically saves captured images to device storage
- ✅ **Image path in result**: Added `imagePath` field to success callback result
- ✅ **Organized storage**: Images saved to `/storage/emulated/0/Android/data/[package]/files/Pictures/WaterMeter/`
- ✅ **Timestamped filenames**: Format `[timestamp].jpg` (e.g. `1730626822456.jpg`)
- ✅ **High quality**: JPEG compression at 90% quality
- ✅ **No extra permissions**: Uses app-scoped storage (Android 6.0+)

#### Technical Changes
- Updated `CameraScanActivity.java`:
  - Added `EXTRA_RESULT_IMAGE_PATH` constant
  - Added `saveImageToFile()` method to save bitmap to JPEG
  - Modified `returnResult()` to include image path
  - Images saved before returning result to ensure availability
- Updated `WaterMeterPlugin.java`:
  - Added `imagePath` field to JSON result object
  - Forward image path from Activity result to JavaScript callback
- Updated documentation:
  - README.md: Added `imagePath` field to API reference
  - Examples updated to show image display

#### Result Object (Updated)
```javascript
{
    text: "00123",                              // Meter number
    confidence: 0.95,                           // Confidence score (0.0-1.0)
    success: true,                              // true if text not empty
    imagePath: "/path/to/water_meter_....jpg"  // 🆕 Absolute path to saved image
}
```

## [1.0.0] - 2025-10-24

### 🎉 Initial Release

#### Added
- ✅ Cordova plugin structure with plugin.xml and package.json
- ✅ JavaScript API (WaterMeter.js) with 3 main methods:
  - `scan()` - Open camera to scan water meter
  - `checkPermission()` - Check camera permission status
  - `requestPermission()` - Request camera permission
- ✅ Java bridge (WaterMeterPlugin.java) for Android platform
- ✅ Android build configuration (build.gradle)
- ✅ Water Meter SDK AAR integration (28MB)
- ✅ Auto-return result feature after successful scan
- ✅ Permission handling automation
- ✅ Comprehensive documentation:
  - README.md (English, 12KB)
  - HUONG_DAN_TICH_HOP.md (Vietnamese, 11KB)
  - QUICKSTART.md (Quick start guide, 2KB)
  - PLUGIN_SUMMARY.md (Overview, 8KB)
  - EXAMPLE_INSTALLATION.md (Examples, 6KB)
  - COMPLETION_REPORT.md (Completion summary)
  - CHANGELOG.md (This file)
- ✅ Auto test app creation script (create-test-app.sh)
- ✅ MIT License
- ✅ .gitignore configuration

#### Features
- 📷 Real-time camera preview with AI detection
- 🤖 AI-powered OCR for water meter reading
- ⚡ Auto-return results after scan completion
- 🎯 Simple 3-line JavaScript API
- 🔒 Built-in camera permission management
- 📱 Android 6.0+ support (API 23+)
- 🌍 Bilingual documentation (English + Vietnamese)

#### Technical Details
- **Platform:** Android only
- **Min SDK:** 23 (Android 6.0)
- **Target SDK:** 29 (Android 10)
- **Cordova:** >= 9.0.0
- **Dependencies:**
  - AndroidX AppCompat 1.3.1
  - ConstraintLayout 2.1.0
  - Camera2 API
  - OpenCV 4.2.0 (embedded in SDK)
  - PaddleLite 2.10 (embedded in SDK)

#### Files
```
Total: 15 files
- Code files: 4 (JS, Java, Gradle, XML)
- Documentation: 8 markdown files
- Tools: 1 script
- Config: 2 files (package.json, .gitignore)
Total size: 29MB (SDK AAR: 28MB)
```

#### JavaScript API Example
```javascript
WaterMeter.scan(
    function(result) { 
        console.log('Meter number:', result.text);
        console.log('Confidence:', result.confidence);
    },
    function(error) { 
        console.error('Error:', error);
    },
    {
        title: 'Scan Water Meter',
        autoCloseOnResult: true
    }
);
```

#### Known Limitations
- Android platform only (iOS not supported)
- Requires ARM64 device for optimal performance
- Minimum Android 6.0 (API 23)
- SDK AAR size is large (~28MB)

### Notes
This is the initial release of the Cordova plugin for Water Meter OCR scanning using AI camera preview. The plugin wraps the native Android SDK and provides a simple JavaScript interface for Cordova/PhoneGap applications.

---

## Future Roadmap (Potential)

### [1.1.0] - Future
- [ ] iOS platform support
- [ ] Reduce SDK size with compression
- [ ] Add image result in callback
- [ ] Support custom OCR models
- [ ] Add batch scanning mode
- [ ] Offline mode optimization

### [1.2.0] - Future
- [ ] Add scan history API
- [ ] Support barcode/QR code scanning
- [ ] Real-time validation options
- [ ] Custom UI theming
- [ ] Analytics integration

---

**Note:** This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.
