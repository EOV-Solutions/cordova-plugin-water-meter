# 📱 Cordova Plugin Water Meter Scanner

Cordova plugin for scanning water meter numbers using AI-powered OCR with camera preview.

## ✨ Features

- 📷 **Real-time camera preview** with AI detection
- 🤖 **AI-powered OCR** for accurate water meter reading
- ⚡ **Auto-return results** - automatically closes after successful scan
- 🎯 **Easy integration** - simple JavaScript API
- 🔒 **Permission handling** - built-in camera permission management
- 📱 **Android support** - Android 6.0+ (API 23+)

## 🚀 Installation

### From local path (development)

```bash
cordova plugin add /path/to/cordova-plugin-water-meter
```

### From git repository

```bash
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

### From npm (when published)

```bash
cordova plugin add cordova-plugin-water-meter
```

## 📦 Setup

### 1. Copy SDK AAR file

Copy the Water Meter SDK AAR file to the plugin:

```bash
cp /path/to/app-release.aar cordova-plugin-water-meter/libs/water_meter_sdk.aar
```

### 2. Add plugin to your Cordova project

```bash
cd YourCordovaApp
cordova plugin add cordova-plugin-water-meter
```

### 3. Build your app

```bash
cordova build android
```

## 💻 Usage

### Basic Usage

```javascript
// Open camera scanner
WaterMeter.scan(
    function(result) {
        // Success callback
        if (result.success) {
            console.log('Scanned number: ' + result.text);
            console.log('Confidence: ' + (result.confidence * 100) + '%');
            
            // Display result
            document.getElementById('result').innerText = result.text;
        } else {
            alert('No meter number detected. Please try again.');
        }
    },
    function(error) {
        // Error callback
        console.error('Scan failed: ' + error);
        alert('Scan cancelled or failed: ' + error);
    }
);
```

### With Options

```javascript
WaterMeter.scan(
    function(result) {
        console.log('Result:', result);
    },
    function(error) {
        console.error('Error:', error);
    },
    {
        title: 'Quét số đồng hồ nước',           // Custom title
        showCloseButton: true,                   // Show close (X) button
        autoCloseOnResult: true                  // Auto close after scan
    }
);
```

### Permission Handling

```javascript
// Check if camera permission is granted
WaterMeter.checkPermission(
    function(result) {
        if (result.granted) {
            console.log('Camera permission granted');
            // Open scanner
            WaterMeter.scan(onSuccess, onError);
        } else {
            console.log('Camera permission not granted');
            // Request permission
            WaterMeter.requestPermission(
                function(result) {
                    if (result.granted) {
                        WaterMeter.scan(onSuccess, onError);
                    } else {
                        alert('Camera permission is required');
                    }
                },
                function(error) {
                    console.error('Permission error:', error);
                }
            );
        }
    },
    function(error) {
        console.error('Check permission error:', error);
    }
);
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
    success: true         // true if text is not empty
}
```

**Example:**

```javascript
WaterMeter.scan(
    function(result) {
        if (result.success) {
            alert('Meter number: ' + result.text);
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

## 📱 Complete Example

### HTML

```html
<!DOCTYPE html>
<html>
<head>
    <title>Water Meter Scanner</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            text-align: center;
        }
        #result {
            font-size: 24px;
            font-weight: bold;
            color: #4CAF50;
            margin: 20px 0;
        }
        button {
            background: #2196F3;
            color: white;
            border: none;
            padding: 15px 30px;
            font-size: 18px;
            border-radius: 5px;
            cursor: pointer;
        }
        button:active {
            background: #0b7dda;
        }
    </style>
</head>
<body>
    <h1>Water Meter Scanner</h1>
    <button id="scanBtn">📷 Scan Meter</button>
    <div id="result"></div>
    
    <script src="cordova.js"></script>
    <script src="js/index.js"></script>
</body>
</html>
```

### JavaScript (index.js)

```javascript
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    console.log('Device ready');
    
    document.getElementById('scanBtn').addEventListener('click', function() {
        scanWaterMeter();
    });
}

function scanWaterMeter() {
    // Check permission first
    WaterMeter.checkPermission(
        function(result) {
            if (result.granted) {
                // Permission granted - open scanner
                openScanner();
            } else {
                // Request permission
                WaterMeter.requestPermission(
                    function(permResult) {
                        if (permResult.granted) {
                            openScanner();
                        } else {
                            alert('Camera permission is required to scan');
                        }
                    },
                    function(error) {
                        alert('Permission error: ' + error);
                    }
                );
            }
        },
        function(error) {
            console.error('Check permission error:', error);
        }
    );
}

function openScanner() {
    WaterMeter.scan(
        function(result) {
            // Success
            console.log('Scan result:', result);
            
            if (result.success && result.text) {
                // Show result
                document.getElementById('result').innerHTML = 
                    '✅ Meter Number: ' + result.text + 
                    '<br>Confidence: ' + Math.round(result.confidence * 100) + '%';
                
                // Save to database or send to server
                saveMeterReading(result.text);
            } else {
                // No detection
                document.getElementById('result').innerHTML = 
                    '❌ No meter number detected';
            }
        },
        function(error) {
            // Error or cancelled
            console.error('Scan error:', error);
            if (error !== 'User cancelled') {
                alert('Scan failed: ' + error);
            }
        },
        {
            title: 'Quét số đồng hồ nước',
            showCloseButton: true,
            autoCloseOnResult: true
        }
    );
}

function saveMeterReading(meterNumber) {
    // TODO: Save to local storage or send to server
    console.log('Saving meter reading:', meterNumber);
    
    // Example: Save to localStorage
    var readings = JSON.parse(localStorage.getItem('readings') || '[]');
    readings.push({
        number: meterNumber,
        timestamp: new Date().toISOString()
    });
    localStorage.setItem('readings', JSON.stringify(readings));
}
```

## 🔧 Requirements

- **Cordova**: >= 9.0.0
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
