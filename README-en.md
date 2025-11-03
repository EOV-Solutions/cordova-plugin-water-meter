# 📱 Cordova Plugin Water Meter Scanner

> AI-powered OCR plugin for scanning water meter readings in Cordova/PhoneGap applications.

[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://www.android.com/)
[![Cordova](https://img.shields.io/badge/cordova-%3E%3D9.0.0-blue.svg)](https://cordova.apache.org/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

## ✨ Features

- 📷 **Real-time camera preview** with live AI detection overlay
- 🤖 **AI-powered OCR** using AI for accurate meter reading
- 🎯 **Auto-detection** with confidence threshold and IoU filtering
- ⚡ **Auto-capture** when meter is properly aligned in frame
- 🔦 **Flash control** - toggle flashlight on/off
- 🔍 **Zoom control** - manual and auto-zoom for optimal reading
- 📐 **OBB detection** - oriented bounding box visualization
- 🔒 **Permission handling** - automatic camera permission management
- 📱 **Android support** - Android 6.0+ (API 23+)
- 🎨 **Customizable UI** - settings for detection parameters

## 🛠️ Requirements

- Cordova >= 9.0.0
- cordova-android >= 9.0.0
- Android SDK API Level >= 23 (Android 6.0)
- Camera permission

## 🚀 Installation

### Prerequisites

Make sure the Water Meter SDK AAR file is available in `libs/water_meter_sdk.aar`:

```bash
# The AAR file should be at:
# cordova-plugin-water-meter/libs/water_meter_sdk.aar
```

### Install Plugin

#### Option 1: Local Path (Recommended for development)

```bash
cd YourCordovaApp
cordova plugin add /path/to/cordova-plugin-water-meter
```

#### Option 2: Git Repository (For team sharing)

```bash
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

#### Option 3: Private Git Repository

```bash
cordova plugin add git+https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

### Verify Installation

```bash
cordova plugin list
# Should show: cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"
```

### Build and Run

```bash
cordova prepare
cordova build android
cordova run android
```

## 💻 Usage

### Basic Example

```javascript
// Simple scan - auto closes after successful reading
WaterMeter.scan(
    function(result) {
        // Success callback
        console.log('✓ Scanned:', result.text);
        console.log('  Confidence:', (result.confidence * 100).toFixed(1) + '%');
        
        // Display result in your UI
        document.getElementById('meter-value').innerText = result.text;
        document.getElementById('confidence').innerText = (result.confidence * 100).toFixed(1) + '%';
    },
    function(error) {
        // Error callback (user cancelled or scan failed)
        console.error('Scan error:', error);
        alert('Scan cancelled: ' + error);
    }
);
```

### Advanced Example with Options

```javascript
WaterMeter.scan(
    function(result) {
        console.log('Success:', result);
        // result = {
        //   text: "00012345",
        //   confidence: 0.95
        // }
    },
    function(error) {
        console.error('Error:', error);
    },
    {
        title: 'Quét số đồng hồ nước',      // Custom title (Vietnamese example)
        showCloseButton: true,               // Show X button to close
        autoCloseOnResult: true              // Auto close after successful scan (default: true)
    }
);
```

### Complete Integration Example

```html
<!DOCTYPE html>
<html>
<head>
    <title>Water Meter Scanner</title>
    <script type="text/javascript" src="cordova.js"></script>
</head>
<body>
    <h1>Water Meter Scanner</h1>
    
    <button onclick="startScan()">Scan Meter</button>
    
    <div id="result-container" style="display:none;">
        <h2>Result:</h2>
        <p>Meter Value: <strong id="meter-value">-</strong></p>
        <p>Confidence: <strong id="confidence">-</strong></p>
    </div>
    
    <script>
        function startScan() {
            WaterMeter.scan(
                function(result) {
                    // Success
                    document.getElementById('meter-value').innerText = result.text;
                    document.getElementById('confidence').innerText = 
                        (result.confidence * 100).toFixed(1) + '%';
                    document.getElementById('result-container').style.display = 'block';
                },
                function(error) {
                    // Error
                    alert('Scan failed: ' + error);
                },
                {
                    title: 'Scan Water Meter',
                    showCloseButton: true,
                    autoCloseOnResult: true
                }
            );
        }
    </script>
</body>
</html>
```

## 📖 API Reference

### `WaterMeter.scan(successCallback, errorCallback, options)`

Open camera scanner to scan water meter number.

**Parameters:**

- `successCallback` (Function) - Called when scan completes successfully
  - Returns object: `{text: string, confidence: number, success: boolean}`
- `errorCallback` (Function) - Called on error or user cancellation
- `options` (Object) - Optional configuration
  - `title` (string) - Custom title for scanner screen (default: "Quét số đồng hồ")
  - `showCloseButton` (boolean) - Show close (X) button (default: true)
  - `autoCloseOnResult` (boolean) - Auto close after scan (default: true)

**Success Result Object:**

```javascript
{
    text: "00123",        // Scanned meter number (empty string if failed)
    confidence: 1.0,      // Confidence score 0.0-1.0
    success: true,         // true if text is not empty
    imagePath: "/storage/emulated/0/Android/data/com.example.app/files/Pictures/WaterMeter/water_meter_20251103_150122.jpg"  // 🆕 Path to saved image
}
```

**Example:**

```javascript
WaterMeter.scan(
    function(result) {
        if (result.success) {
            alert('Meter number: ' + result.text);
            console.log('Image saved at: ' + result.imagePath);
            
            if (result.imagePath) {
                document.getElementById('captured-image').src = 'file://' + result.imagePath;
            }
        } else {
            alert('No number detected');
        }
    },
    function(error) {
        alert('Error: ' + error);
    },
    {
        title: 'Scan Water Meter',
        autoCloseOnResult: true
    }
);
```

### `WaterMeter.checkPermission(successCallback, errorCallback)`

Check if camera permission is granted.

**Parameters:**

- `successCallback` (Function) - Returns `{granted: boolean}`
- `errorCallback` (Function) - Called on error

**Example:**

```javascript
WaterMeter.checkPermission(
    function(result) {
        console.log('Permission granted:', result.granted);
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

### `WaterMeter.requestPermission(successCallback, errorCallback)`

Request camera permission from user.

**Parameters:**

- `successCallback` (Function) - Returns `{granted: boolean}`
- `errorCallback` (Function) - Called if permission denied

**Example:**

```javascript
WaterMeter.requestPermission(
    function(result) {
        if (result.granted) {
            console.log('Permission granted!');
        } else {
            alert('Permission denied');
        }
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

## ⚙️ Configuration Options

### Scanner UI Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | "Quét số đồng hồ" | Title displayed on scanner screen |
| `showCloseButton` | boolean | true | Show X button to close scanner |
| `autoCloseOnResult` | boolean | true | Auto close camera after successful scan |

### Camera Features

The scanner includes built-in camera controls:

- **Flash Toggle**: Tap flash icon to turn on/off flashlight
- **Zoom**: Use +/- buttons to zoom in/out (1.0x - 4.0x)
- **Auto Focus**: Tap on preview to focus on specific area
- **AI Detection**: Real-time meter detection with confidence overlay
- **Auto Capture**: Automatically captures when confidence > 90%

### Detection Parameters

These are configured in the native SDK (not exposed to JS):

- Minimum confidence threshold: 0.5 (50%)
- Auto-close confidence: 0.9 (90%)
- Detection timeout: No timeout (scans until result or user closes)
- Supported formats: 5-8 digit water meter numbers

## 🔧 Troubleshooting

### Plugin Not Found

**Error:** `Cannot read property 'scan' of undefined`

**Solution:**
1. Verify plugin is installed:
   ```bash
   cordova plugin list
   ```
2. Should see: `cordova-plugin-water-meter 1.0.0 "Water Meter Scanner Plugin"`
3. Make sure `cordova.js` is loaded before calling plugin:
   ```html
   <script src="cordova.js"></script>
   <script>
       document.addEventListener('deviceready', function() {
           // Now safe to use WaterMeter
           WaterMeter.scan(onSuccess, onError);
       });
   </script>
   ```

### AAR File Not Found

**Error:** `Could not find water_meter_sdk.aar`

**Solution:**
1. Verify AAR exists at: `cordova-plugin-water-meter/libs/water_meter_sdk.aar`
2. Remove and re-add plugin:
   ```bash
   cordova plugin remove cordova-plugin-water-meter
   cordova plugin add /path/to/cordova-plugin-water-meter
   ```
3. The Gradle task will auto-copy AAR to `app/libs/` during build

### Camera Permission Denied

**Error:** `Camera permission denied`

**Solution:**
1. Check `AndroidManifest.xml` has permission:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   ```
2. Request permission before scanning:
   ```javascript
   WaterMeter.requestPermission(
       function(result) {
           if (result.granted) {
               WaterMeter.scan(onSuccess, onError);
           }
       },
       onError
   );
   ```

### Build Failures

**Error:** `Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'`

**Solution:**

1. Check `config.xml` has correct Android platform version:
   ```xml
   <engine name="android" spec="^9.0.0" />
   ```

2. Clean and rebuild:

   ```bash
   cordova clean android
   rm -rf platforms/android
   cordova platform add android@9.0.0
   cordova build android
   ```

### Scanner Not Detecting Numbers

**Issue:** Camera opens but doesn't detect meter numbers

**Solution:**
1. Ensure good lighting conditions
2. Hold camera steady over meter display
3. Position meter numbers in the green detection box
4. Wait for confidence indicator to reach > 50%
5. Flash can help in low light - tap flash icon

### Old Plugin Code Running

**Issue:** Code changes not reflected in app

**Solution:**
1. Force plugin refresh:
   ```bash
   cordova plugin remove cordova-plugin-water-meter
   cordova plugin add /path/to/cordova-plugin-water-meter
   cordova clean android
   cordova build android
   ```

2. Uninstall app from device before reinstalling

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

## 👥 Credits

**EOV Solutions**

- **SDK**: AI-based water meter recognition
- **Plugin**: Cordova integration wrapper
- **Contact**: [Your contact information]

## 🆘 Support

For issues, questions, or contributions:

1. Check [Troubleshooting](#-troubleshooting) section
2. Review [API Reference](#-api-reference)
3. Contact development team

---

**Made by EOV Solutions**
- **Cordova Android**: >= 9.0.0
- **Android**: >= 6.0 (API 23)
- **Permissions**: CAMERA

## 📂 Plugin Structure

```
cordova-plugin-water-meter/
├── plugin.xml                 # Plugin configuration
├── package.json              # NPM package metadata
├── www/
│   └── WaterMeter.js         # JavaScript interface
├── src/
│   └── android/
│       ├── WaterMeterPlugin.java   # Java bridge code
│       └── build.gradle            # Android dependencies
├── libs/
│   └── water_meter_sdk.aar   # SDK AAR file (you need to copy this)
└── README.md                 # This file
```

## 🐛 Troubleshooting

### SDK AAR not found

**Error:** `Could not find water_meter_sdk.aar`

**Solution:** Copy the SDK AAR file to `libs/` folder:

```bash
cp /path/to/app-release.aar cordova-plugin-water-meter/libs/water_meter_sdk.aar
```

### Camera permission denied

**Error:** Permission not granted

**Solution:** Use `requestPermission()` before scanning:

```javascript
WaterMeter.requestPermission(function(result) {
    if (result.granted) {
        WaterMeter.scan(onSuccess, onError);
    }
}, onError);
```

### Plugin not found

**Error:** `WaterMeter is not defined`

**Solution:** Make sure `deviceready` event fired:

```javascript
document.addEventListener('deviceready', function() {
    // Now you can use WaterMeter
}, false);
```

### Build fails

**Error:** Build errors in Android

**Solution:**
1. Check `config.xml` has correct Android platform version
2. Clean and rebuild:
```bash
cordova clean android
cordova build android
```

## 📝 License

MIT License - see LICENSE file

## 👥 Author

**EOV Solutions**

## 🔗 Links

- [GitHub Repository](https://github.com/EOV-Solutions/cordova-plugin-water-meter)
- [Issues](https://github.com/EOV-Solutions/cordova-plugin-water-meter/issues)

## 📮 Support

For support, please open an issue on GitHub or contact EOV Solutions.

---

Made with ❤️ by EOV Solutions
