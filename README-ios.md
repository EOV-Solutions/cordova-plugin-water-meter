# 📱 Cordova Plugin Water Meter Scanner - iOS

> Hướng dẫn tích hợp plugin quét đồng hồ nước cho iOS / iOS Integration Guide for Water Meter Scanner Plugin

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://www.apple.com/ios/)
[![iOS](https://img.shields.io/badge/iOS-%3E%3D12.0-blue.svg)](https://www.apple.com/ios/)
[![Cordova](https://img.shields.io/badge/cordova-%3E%3D9.0.0-blue.svg)](https://cordova.apache.org/)
[![License](https://img.shields.io/badge/license-EOV-orange.svg)](LICENSE)

[English](#english) | [Tiếng Việt](#tiếng-việt)

---

## English

### ✨ Features

- 📷 **Real-time camera preview** with AI detection overlay
- 🤖 **AI-powered OCR** using PaddleOCR for accurate meter reading
- 🎯 **Auto-detection** with configurable confidence threshold
- ⚡ **Auto-capture** when meter is properly aligned
- 🔦 **Flash control** - toggle flashlight on/off
- 🔍 **Zoom control** - pinch to zoom for better reading
- 📐 **OBB detection** - oriented bounding box visualization
- 🔒 **Permission handling** - automatic camera permission management
- 📱 **iOS 11.0+** support
- 🎨 **Customizable UI** - settings for detection parameters
- 💾 **Image saving** - captured images saved to app directory
- 🖼️ **Base64 encoding** - images returned as base64 for display in WebView

### 🛠️ Requirements

- iOS 11.0 or later
- Xcode 14.0 or later
- Cordova >= 9.0.0
- cordova-ios >= 6.0.0
- Camera permission in Info.plist

### 🚀 Installation

#### Prerequisites

The plugin includes the pre-built `WaterMeterSDK.framework` in the `frameworks/` directory. No additional downloads needed.

#### Install Plugin

##### Option 1: Local Path (Recommended for development)

```bash
cd YourCordovaApp
cordova plugin add ../cordova-plugin-water-meter
```

##### Option 2: Git Repository

```bash
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

##### Option 3: Private Git Repository

```bash
cordova plugin add git+https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

#### Verify Installation

```bash
cordova plugin list
# Should show: cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"
```

#### Camera Permission Setup

The plugin automatically adds camera permission to `Info.plist`, but you should customize the description:

Edit `platforms/ios/[YourApp]/[YourApp]-Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan water meter readings</string>
```

Or in Vietnamese:

```xml
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần quyền truy cập camera để quét số đồng hồ nước</string>
```

#### Build and Run

```bash
# Prepare iOS platform
cordova prepare ios

# Build for iOS
cordova build ios

# Run on simulator
cordova emulate ios

# Run on device (requires provisioning profile)
cordova run ios --device
```

### 💻 Usage

#### Basic Example

```javascript
// Wait for device ready
document.addEventListener('deviceready', function() {
    // Simple scan - auto closes after successful reading
    WaterMeter.scan(
        function(result) {
            // Success callback
            console.log('✓ Scanned:', result.text);
            console.log('  Confidence:', (result.confidence * 100).toFixed(1) + '%');
            console.log('  Image path:', result.imagePath);
            
            // Display result in your UI
            document.getElementById('meter-value').innerText = result.text;
            document.getElementById('confidence').innerText = 
                (result.confidence * 100).toFixed(1) + '%';
            
            // Display captured image (base64 encoded for iOS)
            if (result.imageBase64) {
                document.getElementById('captured-image').src = result.imageBase64;
            }
        },
        function(error) {
            // Error callback (user cancelled or scan failed)
            console.error('Scan error:', error);
            alert('Scan cancelled: ' + error);
        }
    );
}, false);
```

#### Advanced Example with Options

```javascript
WaterMeter.scan(
    function(result) {
        console.log('Success:', result);
        // result = {
        //   text: "00012345",
        //   confidence: 0.95,
        //   success: true,
        //   imagePath: "/path/to/saved/image.jpg",
        //   imageBase64: "data:image/jpeg;base64,/9j/4AAQ...",
        //   formattedReading: "0.0012345",
        //   isReliable: true
        // }
    },
    function(error) {
        console.error('Error:', error);
    },
    {
        title: 'Quét số đồng hồ nước',    // Custom title
        showCloseButton: true,             // Show X button to close
        imageMaxWidth: 1920,               // Max width for saved image
        imageMaxHeight: 1080               // Max height for saved image
    }
);
```

#### Complete Integration Example

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Water Meter Scanner</title>
    <script src="cordova.js"></script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            padding: 20px;
        }
        button {
            background: #007AFF;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 16px;
            margin: 10px 0;
        }
        #captured-image {
            max-width: 100%;
            height: auto;
            margin-top: 10px;
            border-radius: 8px;
        }
        .result-box {
            background: #f0f0f0;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <h1>📱 Water Meter Scanner</h1>
    
    <button onclick="startScan()">Scan Meter</button>
    <button onclick="checkPermission()">Check Permission</button>
    <button onclick="openSettings()">Open Settings</button>
    
    <div id="result-container" class="result-box" style="display:none;">
        <h2>Result:</h2>
        <p><strong>Meter Value:</strong> <span id="meter-value">-</span></p>
        <p><strong>Confidence:</strong> <span id="confidence">-</span></p>
        <p><strong>Reliable:</strong> <span id="reliable">-</span></p>
        <p><strong>Image Path:</strong> <span id="image-path" style="font-size:12px;">-</span></p>
        <img id="captured-image" style="display:none;" />
    </div>
    
    <script>
        document.addEventListener('deviceready', onDeviceReady, false);
        
        function onDeviceReady() {
            console.log('Device ready - Cordova initialized');
            console.log('WaterMeter plugin:', typeof WaterMeter !== 'undefined' ? 'Available' : 'Not found');
        }
        
        function startScan() {
            WaterMeter.scan(
                function(result) {
                    console.log('Scan result:', result);
                    
                    // Display result
                    document.getElementById('meter-value').innerText = result.text || 'No reading';
                    document.getElementById('confidence').innerText = 
                        (result.confidence * 100).toFixed(1) + '%';
                    document.getElementById('reliable').innerText = 
                        result.isReliable ? 'Yes ✓' : 'No ✗';
                    
                    // Display image path
                    if (result.imagePath) {
                        document.getElementById('image-path').innerText = result.imagePath;
                    }
                    
                    // Display captured image (use base64 for iOS WKWebView)
                    if (result.imageBase64) {
                        var img = document.getElementById('captured-image');
                        img.src = result.imageBase64;
                        img.style.display = 'block';
                    }
                    
                    document.getElementById('result-container').style.display = 'block';
                },
                function(error) {
                    alert('Scan error: ' + error);
                },
                {
                    title: 'Scan Water Meter',
                    showCloseButton: true,
                    imageMaxWidth: 1920,
                    imageMaxHeight: 1080
                }
            );
        }
        
        function checkPermission() {
            WaterMeter.checkPermission(
                function(result) {
                    alert('Camera permission: ' + (result.granted ? 'Granted ✓' : 'Not granted ✗'));
                },
                function(error) {
                    alert('Error checking permission: ' + error);
                }
            );
        }
        
        function openSettings() {
            WaterMeter.openSettings(
                function(result) {
                    console.log('Settings opened:', result);
                },
                function(error) {
                    alert('Error opening settings: ' + error);
                }
            );
        }
    </script>
</body>
</html>
```

### 📖 API Reference

#### `WaterMeter.scan(successCallback, errorCallback, options)`

Open camera scanner to scan water meter number.

**Parameters:**

- `successCallback` (Function) - Called when scan completes successfully
  - Returns object: `{text, confidence, success, imagePath, imageBase64, formattedReading, isReliable}`
- `errorCallback` (Function) - Called on error or user cancellation
- `options` (Object) - Optional configuration
  - `title` (string) - Custom title for scanner screen (default: "Quét đồng hồ nước")
  - `showCloseButton` (boolean) - Show close (X) button (default: true)
  - `imageMaxWidth` (number) - Maximum width for saved image (maintains aspect ratio)
  - `imageMaxHeight` (number) - Maximum height for saved image (maintains aspect ratio)

**Success Result Object:**

```javascript
{
    text: "00123",              // Scanned meter number (empty if failed)
    confidence: 0.95,           // Confidence score 0.0-1.0
    success: true,              // true if text is not empty
    imagePath: "/path/to/image.jpg",  // Full path to saved image
    imageBase64: "data:image/jpeg;base64,...",  // Base64 encoded image (for WebView display)
    formattedReading: "0.0123",       // Formatted meter reading (iOS specific)
    isReliable: true                   // Whether reading is reliable (iOS specific)
}
```

**Example:**

```javascript
WaterMeter.scan(
    function(result) {
        if (result.success) {
            console.log('Meter:', result.text);
            console.log('Image:', result.imagePath);
            
            // Display image in WebView using base64
            if (result.imageBase64) {
                document.getElementById('img').src = result.imageBase64;
            }
        }
    },
    function(error) {
        console.error('Error:', error);
    },
    {
        title: 'Scan Water Meter',
        imageMaxWidth: 1920
    }
);
```

#### `WaterMeter.recognizeBase64(successCallback, errorCallback, base64Image)`

Recognize water meter reading from base64-encoded image.

**Parameters:**

- `successCallback` (Function) - Called with recognition result
- `errorCallback` (Function) - Called on error
- `base64Image` (string) - Base64 encoded image (with or without data URL prefix)

**Example:**

```javascript
// Take photo with camera plugin
navigator.camera.getPicture(
    function(imageData) {
        // Recognize from base64
        WaterMeter.recognizeBase64(
            function(result) {
                console.log('Result:', result.text);
                console.log('Confidence:', result.confidence);
            },
            function(error) {
                console.error('Recognition error:', error);
            },
            'data:image/jpeg;base64,' + imageData
        );
    },
    function(error) {
        console.error('Camera error:', error);
    },
    {
        quality: 80,
        destinationType: Camera.DestinationType.DATA_URL,
        encodingType: Camera.EncodingType.JPEG
    }
);
```

#### `WaterMeter.recognizeFile(successCallback, errorCallback, filePath)`

Recognize water meter reading from image file.

**Parameters:**

- `successCallback` (Function) - Called with recognition result
- `errorCallback` (Function) - Called on error
- `filePath` (string) - Path to image file (supports `file://`, `cdvfile://`, or absolute path)

**Example:**

```javascript
// Use file plugin to select image
window.resolveLocalFileSystemURL(imageUri, 
    function(fileEntry) {
        WaterMeter.recognizeFile(
            function(result) {
                console.log('Result:', result.text);
            },
            function(error) {
                console.error('Error:', error);
            },
            fileEntry.nativeURL
        );
    }
);
```

#### `WaterMeter.checkPermission(successCallback, errorCallback)`

Check if camera permission is granted.

**Parameters:**

- `successCallback` (Function) - Returns `{status: string, granted: boolean}`
  - status values: "granted", "denied", "restricted", "prompt"
- `errorCallback` (Function) - Called on error

**Example:**

```javascript
WaterMeter.checkPermission(
    function(result) {
        console.log('Permission status:', result.status);
        console.log('Granted:', result.granted);
        
        if (result.status === 'denied') {
            alert('Please enable camera permission in Settings');
        }
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

#### `WaterMeter.requestPermission(successCallback, errorCallback)`

Request camera permission from user.

**Parameters:**

- `successCallback` (Function) - Returns `{status: string, granted: boolean}`
- `errorCallback` (Function) - Called if permission denied

**Example:**

```javascript
WaterMeter.requestPermission(
    function(result) {
        if (result.granted) {
            console.log('Permission granted!');
            // Start scanning
            WaterMeter.scan(onSuccess, onError);
        } else {
            alert('Camera permission denied');
        }
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

#### `WaterMeter.openSettings(successCallback, errorCallback)`

Open SDK settings screen (iOS only).

**Parameters:**

- `successCallback` (Function) - Called when settings opened
- `errorCallback` (Function) - Called on error

**Example:**

```javascript
WaterMeter.openSettings(
    function(result) {
        console.log('Settings opened:', result);
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

#### `WaterMeter.getVersion(successCallback, errorCallback)`

Get SDK version string.

**Example:**

```javascript
WaterMeter.getVersion(
    function(version) {
        console.log('SDK Version:', version);
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

#### `WaterMeter.isInitialized(successCallback, errorCallback)`

Check if SDK is initialized.

**Example:**

```javascript
WaterMeter.isInitialized(
    function(initialized) {
        console.log('SDK initialized:', initialized);
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

### ⚙️ Configuration Options

#### Scanner UI Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | "Quét đồng hồ nước" | Title displayed on scanner screen |
| `showCloseButton` | boolean | true | Show X button to close scanner |
| `imageMaxWidth` | number | 0 (original) | Maximum width for saved image (px) |
| `imageMaxHeight` | number | 0 (original) | Maximum height for saved image (px) |

**Note:** Image resize maintains aspect ratio. If both width and height are specified, the image will fit within the bounds.

#### Scanner Behavior Settings

Scanner behavior (auto-capture, confidence threshold) is managed through the SDK Settings screen:

```javascript
// Open settings to configure scanner behavior
WaterMeter.openSettings(
    function() {
        console.log('User can now configure auto-capture, confidence threshold, etc.');
    },
    function(error) {
        console.error('Error opening settings:', error);
    }
);
```

Available settings in SDK Settings screen:
- **Auto Capture**: Enable/disable automatic capture when confidence is high
- **Confidence Threshold**: Minimum confidence required for auto-capture (0.0-1.0)
- **Show Confidence**: Display confidence percentage on screen
- **Enable Flash**: Allow flash toggle button
- **Enable Zoom**: Allow zoom controls

### 🔧 Troubleshooting

#### Plugin Not Found

**Error:** `Cannot read property 'scan' of undefined`

**Solution:**

1. Verify plugin is installed:
   ```bash
   cordova plugin list
   ```
   Should see: `cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"`

2. Make sure `deviceready` event fired:
   ```javascript
   document.addEventListener('deviceready', function() {
       // Now safe to use WaterMeter
       console.log('WaterMeter available:', typeof WaterMeter !== 'undefined');
   }, false);
   ```

3. Check if framework is properly linked in Xcode:
   - Open `platforms/ios/YourApp.xcworkspace` in Xcode
   - Check `Frameworks, Libraries, and Embedded Content`
   - Should see `WaterMeterSDK.framework` and `opencv2.framework`

#### Camera Permission Denied

**Error:** `Camera permission denied`

**Solution:**

1. Check `Info.plist` has camera usage description:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to scan water meters</string>
   ```

2. Request permission before scanning:
   ```javascript
   WaterMeter.requestPermission(function(result) {
       if (result.granted) {
           WaterMeter.scan(onSuccess, onError);
       } else {
           alert('Please enable camera in Settings');
       }
   }, onError);
   ```

3. If permission was denied, user must enable it in Settings:
   ```javascript
   // Open iOS Settings app
   window.open('app-settings:');
   ```

#### Framework Not Found

**Error:** `dyld: Library not loaded: @rpath/WaterMeterSDK.framework/WaterMeterSDK`

**Solution:**

1. Clean and rebuild:
   ```bash
   cordova clean ios
   rm -rf platforms/ios
   cordova platform add ios
   cordova build ios
   ```

2. Check framework path in Xcode:
   - Open `platforms/ios/YourApp.xcworkspace`
   - Select your app target
   - Go to `Build Settings` → `Framework Search Paths`
   - Should include `$(PROJECT_DIR)/YourApp/Plugins/cordova-plugin-water-meter`

3. Verify framework embedding:
   - In Xcode, go to target → `General` → `Frameworks, Libraries, and Embedded Content`
   - `WaterMeterSDK.framework` should be set to "Embed & Sign"

#### Scanner Not Detecting Numbers

**Issue:** Camera opens but doesn't detect meter numbers

**Solution:**

1. Ensure good lighting conditions - tap flash icon if needed
2. Hold device steady over meter display
3. Position meter numbers in the detection overlay box
4. Wait for confidence indicator to reach threshold
5. Check SDK settings for detection parameters:
   ```javascript
   WaterMeter.openSettings(function() {
       // Adjust confidence threshold and other settings
   }, onError);
   ```

#### Build Fails with Framework Error

**Error:** `Framework not found WaterMeterSDK` or `opencv2`

**Solution:**

1. Verify frameworks exist in plugin:
   ```bash
   ls cordova-plugin-water-meter/frameworks/
   # Should show: WaterMeterSDK.framework opencv2.framework
   ```

2. Remove and re-add plugin:
   ```bash
   cordova plugin remove cordova-plugin-water-meter
   cordova plugin add ../cordova-plugin-water-meter
   cordova prepare ios
   ```

3. If still failing, manually copy frameworks:
   ```bash
   cp -R cordova-plugin-water-meter/frameworks/*.framework \
         platforms/ios/YourApp/Plugins/cordova-plugin-water-meter/
   ```

#### Old Plugin Code Running

**Issue:** Code changes not reflected in app

**Solution:**

1. Force plugin refresh:
   ```bash
   cordova plugin remove cordova-plugin-water-meter
   cordova plugin add ../cordova-plugin-water-meter
   cordova clean ios
   cordova build ios
   ```

2. Delete app from simulator/device and reinstall
3. Clean build folder in Xcode: `Product` → `Clean Build Folder`

#### WKWebView Image Display Issues

**Issue:** Captured image doesn't display in `<img>` tag

**Solution:**

Use the `imageBase64` field instead of `imagePath` for WKWebView:

```javascript
WaterMeter.scan(
    function(result) {
        // ✗ Don't use file:// URLs in WKWebView
        // img.src = 'file://' + result.imagePath;
        
        // ✓ Use base64 data URL
        if (result.imageBase64) {
            img.src = result.imageBase64;
        }
    },
    onError
);
```

#### App Crashes on Launch

**Error:** App crashes immediately after launch

**Solution:**

1. Check console logs in Xcode for crash reason
2. Verify all frameworks are properly embedded
3. Check deployment target matches framework requirements (iOS 12.0+)
4. Verify framework architectures match device (arm64)
5. Check for missing dependencies:
   ```bash
   # In Xcode, check linked frameworks:
   # - WaterMeterSDK.framework
   # - opencv2.framework
   # - AVFoundation.framework (should be auto-linked)
   ```

### 📱 iOS-Specific Features

#### Image Handling

iOS returns images in two formats for compatibility:

```javascript
{
    imagePath: "/var/mobile/.../image.jpg",           // File path (native apps)
    imageBase64: "data:image/jpeg;base64,/9j/4AAQ..."  // Base64 (WebView display)
}
```

Use `imageBase64` for displaying in WebView, `imagePath` for file operations.

#### Formatted Reading

iOS SDK provides additional formatting:

```javascript
{
    text: "00012345",              // Raw OCR result
    formattedReading: "0.0012345"  // Formatted with decimal point
}
```

#### Reliability Indicator

iOS SDK includes confidence-based reliability flag:

```javascript
{
    confidence: 0.87,
    isReliable: true  // true if confidence >= 0.7
}
```

#### Settings Screen

iOS SDK includes a native settings screen:

```javascript
WaterMeter.openSettings(
    function() {
        // User can configure:
        // - Auto capture on/off
        // - Confidence threshold (0.5 - 0.95)
        // - Show confidence indicator
        // - Enable flash/zoom controls
    },
    onError
);
```

### 🔒 Privacy & Permissions

#### Info.plist Entries

The plugin automatically adds:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan water meter readings</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save captured images</string>
```

Customize these messages in your `config.xml`:

```xml
<platform name="ios">
    <edit-config target="NSCameraUsageDescription" file="*-Info.plist" mode="merge">
        <string>Ứng dụng cần quyền camera để quét số đồng hồ nước</string>
    </edit-config>
    <edit-config target="NSPhotoLibraryUsageDescription" file="*-Info.plist" mode="merge">
        <string>Ứng dụng cần quyền thư viện ảnh để lưu ảnh đã chụp</string>
    </edit-config>
</platform>
```

#### Permission States

iOS has 4 permission states:

1. **Not Determined** - User hasn't been asked yet (first launch)
2. **Authorized** - Permission granted
3. **Denied** - User explicitly denied permission
4. **Restricted** - Permission blocked by parental controls or MDM

Handle each state appropriately:

```javascript
WaterMeter.checkPermission(function(result) {
    switch(result.status) {
        case 'granted':
            // Start scanning
            WaterMeter.scan(onSuccess, onError);
            break;
        case 'prompt':
            // Request permission
            WaterMeter.requestPermission(onSuccess, onError);
            break;
        case 'denied':
            // Show alert to open Settings
            alert('Please enable camera in Settings app');
            break;
        case 'restricted':
            // Show alert that camera is restricted
            alert('Camera access is restricted on this device');
            break;
    }
}, onError);
```

### 📦 Framework Details

#### Included Frameworks

The plugin bundles these frameworks:

1. **WaterMeterSDK.framework** (~18 MB)
   - Water meter detection and recognition
   - Camera scanner UI
   - Settings screen
   - PaddleLite inference engine
   - ML models (YOLO OBB + PaddleOCR)

2. **opencv2.framework** (~15 MB)
   - Image processing
   - Computer vision utilities

**Total size:** ~33 MB (universal framework includes arm64 + x86_64)

#### Architectures

- **Device (iPhone/iPad):** arm64
- **Simulator:** x86_64 (Intel Mac) / arm64 (Apple Silicon Mac)

Frameworks are built as **Universal XCFrameworks** supporting all architectures.

### 🎯 Performance Considerations

#### Memory Usage

- SDK initialization: ~20 MB
- Camera preview: ~15 MB
- ML model inference: ~50 MB peak
- **Total:** ~85 MB during scanning

Test on real devices, especially older iPhones (iPhone 7, 8).

#### Processing Time

| Operation | Time (iPhone 12) | Time (iPhone 8) |
|-----------|------------------|-----------------|
| SDK init | 1.2s | 2.5s |
| Frame detect | 60ms | 120ms |
| OCR recognize | 200ms | 450ms |
| **Total scan** | **~1.5s** | **~3s** |

#### Battery Usage

Continuous camera + ML inference is battery-intensive:
- Set appropriate auto-capture timeout
- Release scanner when not in use
- Avoid keeping camera open indefinitely

### 📄 License

EOV License - See [LICENSE](LICENSE) file for details.

### 👥 Credits

**EOV Solutions**

- **SDK**: AI-based water meter recognition
- **iOS Framework**: Native iOS implementation
- **Cordova Plugin**: iOS integration wrapper
- **Contact**: [Your contact information]

### 🔗 Links

- [Plugin Repository](https://github.com/EOV-Solutions/cordova-plugin-water-meter)
- [Android README](README.md)
- [English README](README-en.md)
- [Issues](https://github.com/EOV-Solutions/cordova-plugin-water-meter/issues)

---

## Tiếng Việt

### ✨ Tính năng

- 📷 **Xem trước camera thời gian thực** với lớp phủ phát hiện AI
- 🤖 **Nhận diện chữ bằng AI** sử dụng PaddleOCR cho độ chính xác cao
- 🎯 **Tự động phát hiện** với ngưỡng độ tin cậy có thể cấu hình
- ⚡ **Tự động chụp** khi đồng hồ được căn chỉnh đúng
- 🔦 **Điều khiển đèn flash** - bật/tắt đèn pin
- 🔍 **Điều khiển zoom** - pinch để zoom để đọc tốt hơn
- 📐 **Phát hiện OBB** - hiển thị hình hộp bao xoay
- 🔒 **Xử lý quyền** - tự động quản lý quyền camera
- 📱 **Hỗ trợ iOS 12.0+**
- 🎨 **Giao diện tùy chỉnh** - cài đặt các tham số phát hiện
- 💾 **Lưu ảnh** - ảnh chụp được lưu vào thư mục ứng dụng
- 🖼️ **Mã hóa Base64** - ảnh trả về dưới dạng base64 để hiển thị trong WebView

### 🛠️ Yêu cầu

- iOS 12.0 trở lên
- Xcode 14.0 trở lên
- Cordova >= 9.0.0
- cordova-ios >= 6.0.0
- Quyền camera trong Info.plist

### 🚀 Cài đặt

#### Điều kiện tiên quyết

Plugin đã bao gồm `WaterMeterSDK.framework` được build sẵn trong thư mục `frameworks/`. Không cần tải thêm gì.

#### Cài đặt Plugin

##### Cách 1: Đường dẫn cục bộ (Khuyến nghị cho phát triển)

```bash
cd YourCordovaApp
cordova plugin add ../cordova-plugin-water-meter
```

##### Cách 2: Git Repository

```bash
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

##### Cách 3: Private Git Repository

```bash
cordova plugin add git+https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

#### Kiểm tra cài đặt

```bash
cordova plugin list
# Phải thấy: cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"
```

#### Thiết lập quyền Camera

Plugin tự động thêm quyền camera vào `Info.plist`, nhưng bạn nên tùy chỉnh mô tả:

Chỉnh sửa `platforms/ios/[YourApp]/[YourApp]-Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần quyền truy cập camera để quét số đồng hồ nước</string>
```

#### Build và chạy

```bash
# Chuẩn bị platform iOS
cordova prepare ios

# Build cho iOS
cordova build ios

# Chạy trên simulator
cordova emulate ios

# Chạy trên thiết bị (cần provisioning profile)
cordova run ios --device
```

### 💻 Sử dụng

#### Ví dụ cơ bản

```javascript
// Đợi device ready
document.addEventListener('deviceready', function() {
    // Quét đơn giản - tự động đóng sau khi quét thành công
    WaterMeter.scan(
        function(result) {
            // Callback thành công
            console.log('✓ Đã quét:', result.text);
            console.log('  Độ tin cậy:', (result.confidence * 100).toFixed(1) + '%');
            console.log('  Đường dẫn ảnh:', result.imagePath);
            
            // Hiển thị kết quả trong UI
            document.getElementById('meter-value').innerText = result.text;
            document.getElementById('confidence').innerText = 
                (result.confidence * 100).toFixed(1) + '%';
            
            // Hiển thị ảnh đã chụp (mã hóa base64 cho iOS)
            if (result.imageBase64) {
                document.getElementById('captured-image').src = result.imageBase64;
            }
        },
        function(error) {
            // Callback lỗi (người dùng hủy hoặc quét thất bại)
            console.error('Lỗi quét:', error);
            alert('Đã hủy quét: ' + error);
        }
    );
}, false);
```

#### Ví dụ nâng cao với tùy chọn

```javascript
WaterMeter.scan(
    function(result) {
        console.log('Thành công:', result);
        // result = {
        //   text: "00012345",
        //   confidence: 0.95,
        //   success: true,
        //   imagePath: "/path/to/saved/image.jpg",
        //   imageBase64: "data:image/jpeg;base64,/9j/4AAQ...",
        //   formattedReading: "0.0012345",
        //   isReliable: true
        // }
    },
    function(error) {
        console.error('Lỗi:', error);
    },
    {
        title: 'Quét số đồng hồ nước',     // Tiêu đề tùy chỉnh
        showCloseButton: true,             // Hiện nút X để đóng
        imageMaxWidth: 1920,               // Chiều rộng tối đa cho ảnh lưu
        imageMaxHeight: 1080               // Chiều cao tối đa cho ảnh lưu
    }
);
```

### 📖 Tham khảo API

Xem phần [API Reference](#-api-reference) ở trên để biết chi tiết đầy đủ về tất cả các phương thức có sẵn.

### ⚙️ Tùy chọn cấu hình

#### Tùy chọn giao diện Scanner

| Tùy chọn | Kiểu | Mặc định | Mô tả |
|----------|------|----------|-------|
| `title` | string | "Quét đồng hồ nước" | Tiêu đề hiển thị trên màn hình quét |
| `showCloseButton` | boolean | true | Hiện nút X để đóng scanner |
| `imageMaxWidth` | number | 0 (gốc) | Chiều rộng tối đa cho ảnh lưu (px) |
| `imageMaxHeight` | number | 0 (gốc) | Chiều cao tối đa cho ảnh lưu (px) |

**Lưu ý:** Resize ảnh giữ nguyên tỷ lệ khung hình. Nếu cả width và height được chỉ định, ảnh sẽ vừa trong khung giới hạn.

#### Cài đặt hành vi Scanner

Hành vi scanner (tự động chụp, ngưỡng độ tin cậy) được quản lý qua màn hình SDK Settings:

```javascript
// Mở settings để cấu hình hành vi scanner
WaterMeter.openSettings(
    function() {
        console.log('Người dùng có thể cấu hình tự động chụp, ngưỡng độ tin cậy, v.v.');
    },
    function(error) {
        console.error('Lỗi khi mở settings:', error);
    }
);
```

Các cài đặt có sẵn trong màn hình SDK Settings:
- **Tự động chụp**: Bật/tắt chụp tự động khi độ tin cậy cao
- **Ngưỡng độ tin cậy**: Độ tin cậy tối thiểu cho tự động chụp (0.0-1.0)
- **Hiện độ tin cậy**: Hiển thị phần trăm độ tin cậy trên màn hình
- **Bật đèn flash**: Cho phép nút bật/tắt đèn flash
- **Bật zoom**: Cho phép điều khiển zoom

### 🔧 Khắc phục sự cố

Xem phần [Troubleshooting](#-troubleshooting) ở trên để biết chi tiết đầy đủ về cách khắc phục các vấn đề thường gặp trên iOS.

### 📱 Tính năng đặc biệt của iOS

#### Xử lý ảnh

iOS trả về ảnh ở 2 định dạng để tương thích:

```javascript
{
    imagePath: "/var/mobile/.../image.jpg",           // Đường dẫn file (ứng dụng native)
    imageBase64: "data:image/jpeg;base64,/9j/4AAQ..."  // Base64 (hiển thị WebView)
}
```

Dùng `imageBase64` để hiển thị trong WebView, `imagePath` cho thao tác file.

#### Định dạng số đọc

iOS SDK cung cấp định dạng bổ sung:

```javascript
{
    text: "00012345",              // Kết quả OCR thô
    formattedReading: "0.0012345"  // Định dạng với dấu thập phân
}
```

#### Chỉ báo độ tin cậy

iOS SDK bao gồm cờ độ tin cậy dựa trên confidence:

```javascript
{
    confidence: 0.87,
    isReliable: true  // true nếu confidence >= 0.7
}
```

### 📄 Giấy phép

Giấy phép EOV - Xem file [LICENSE](LICENSE) để biết chi tiết.

### 👥 Tác giả

**EOV Solutions**

- **SDK**: Nhận diện đồng hồ nước dựa trên AI
- **iOS Framework**: Triển khai native iOS
- **Cordova Plugin**: Wrapper tích hợp iOS
- **Liên hệ**: [Thông tin liên hệ của bạn]

---

**Được tạo bởi EOV Solutions** ❤️
