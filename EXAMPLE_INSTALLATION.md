# Cordova Plugin Water Meter - Installation Example

## Quick Test Installation

To test this plugin in a Cordova app:

```bash
# Create a new Cordova app (if you don't have one)
cordova create TestWaterMeter com.example.watermeter "Water Meter Test"
cd TestWaterMeter

# Add Android platform
cordova platform add android

# Add the plugin (local path)
cordova plugin add /mnt/data2tb/code/water_meter/app/SDK/cordova-plugin-water-meter

# Replace www/index.html with the example below
# Replace www/js/index.js with the example below

# Build and run
cordova build android
cordova run android
```

## Example index.html

Replace `www/index.html` with:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Water Meter Scanner</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2196F3;
            text-align: center;
            margin-bottom: 30px;
        }
        .btn {
            width: 100%;
            background: #2196F3;
            color: white;
            border: none;
            padding: 15px;
            font-size: 18px;
            border-radius: 5px;
            cursor: pointer;
            margin-bottom: 10px;
        }
        .btn:active { background: #0b7dda; }
        .result {
            margin-top: 20px;
            padding: 20px;
            background: #e8f5e9;
            border-radius: 5px;
            display: none;
        }
        .result.show { display: block; }
        .result h2 {
            color: #4CAF50;
            margin-bottom: 10px;
            text-align: center;
        }
        .result .number {
            font-size: 32px;
            font-weight: bold;
            color: #333;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 Quét Đồng Hồ Nước</h1>
        <button class="btn" id="btnScan">📷 Mở Camera Quét</button>
        <div class="result" id="result">
            <h2>✅ Kết quả:</h2>
            <div class="number" id="number">-</div>
        </div>
    </div>
    
    <script src="cordova.js"></script>
    <script src="js/index.js"></script>
</body>
</html>
```

## Example index.js

Replace `www/js/index.js` with:

```javascript
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    console.log('Device ready!');
    document.getElementById('btnScan').addEventListener('click', startScan);
}

function startScan() {
    // Check permission first
    WaterMeter.checkPermission(
        function(result) {
            if (result.granted) {
                openScanner();
            } else {
                WaterMeter.requestPermission(
                    function(permResult) {
                        if (permResult.granted) {
                            openScanner();
                        } else {
                            alert('Camera permission required');
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
            console.log('Scan result:', result);
            
            if (result.success && result.text) {
                // Show result
                document.getElementById('number').innerText = result.text;
                document.getElementById('result').classList.add('show');
                
                // Auto hide after 5 seconds
                setTimeout(function() {
                    document.getElementById('result').classList.remove('show');
                }, 5000);
            } else {
                alert('No meter number detected');
            }
        },
        function(error) {
            if (error !== 'User cancelled') {
                alert('Scan error: ' + error);
            }
        },
        {
            title: 'Quét số đồng hồ nước',
            showCloseButton: true,
            autoCloseOnResult: true
        }
    );
}
```

## Verify Installation

After adding the plugin, verify it's installed:

```bash
cordova plugin list
```

You should see:
```
cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"
```

## Build and Test

```bash
# Build for Android
cordova build android

# Run on connected device
cordova run android

# Or install APK manually
adb install -r platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

## Troubleshooting

### Plugin not found
```bash
# Remove and re-add plugin
cordova plugin remove cordova-plugin-water-meter
cordova plugin add /mnt/data2tb/code/water_meter/app/SDK/cordova-plugin-water-meter
```

### Build errors
```bash
# Clean and rebuild
cordova clean android
cordova build android
```

### WaterMeter is undefined
Make sure you call it after `deviceready` event:
```javascript
document.addEventListener('deviceready', function() {
    // Now WaterMeter is available
}, false);
```
