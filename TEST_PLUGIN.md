# Test Plugin in New App (Ví dụ test plugin trong app mới)

## Tạo app mới để test plugin

```bash
# 1. Create new Cordova app
cordova create TestWaterMeterApp com.example.watermeter "Water Meter Test"
cd TestWaterMeterApp

# 2. Add Android platform
cordova platform add android@14.0.0

# 3. Install plugin from local path
cordova plugin add /path/to/cordova-plugin-water-meter

# Or from git (when published)
# cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git

# 4. Configure Gradle version in config.xml
# Add this inside <platform name="android">:
# <preference name="GradleVersion" value="8.9" />

# 5. Build
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
cordova build android

# 6. Run on device
cordova run android
```

## Minimal test HTML

Replace `www/index.html` with:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="Content-Security-Policy" 
          content="default-src 'self' data: https: 'unsafe-inline' 'unsafe-eval'; 
                   img-src 'self' data: content: file: https:;">
    <title>Water Meter Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            text-align: center;
        }
        button {
            padding: 15px 30px;
            font-size: 18px;
            background: #007AFF;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            margin: 10px;
        }
        #result {
            margin-top: 20px;
            padding: 15px;
            background: #f0f0f0;
            border-radius: 8px;
        }
        #photo {
            max-width: 100%;
            margin-top: 10px;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <h1>Water Meter Scanner Test</h1>
    <button onclick="scanMeter()">📷 Scan Water Meter</button>
    <div id="result"></div>
    <img id="photo" style="display:none;">
    
    <script src="cordova.js"></script>
    <script>
        document.addEventListener('deviceready', function() {
            console.log('Device ready! WaterMeter plugin:', typeof WaterMeter);
            if (typeof WaterMeter === 'undefined') {
                document.getElementById('result').innerHTML = 
                    '<p style="color:red;">❌ Plugin not loaded!</p>';
            } else {
                document.getElementById('result').innerHTML = 
                    '<p style="color:green;">✅ Plugin ready</p>';
            }
        }, false);
        
        function scanMeter() {
            if (typeof WaterMeter === 'undefined') {
                alert('Plugin not available!');
                return;
            }
            
            WaterMeter.scan({
                title: "Scan Water Meter",
                showCloseButton: true,
                autoCloseOnResult: false
            }, 
            function(result) {
                console.log('Success:', result);
                
                var html = '<h2>✅ Scan Success!</h2>';
                html += '<p><strong>Reading:</strong> ' + result.text + '</p>';
                html += '<p><strong>Confidence:</strong> ' + 
                        (result.confidence * 100).toFixed(1) + '%</p>';
                
                if (result.imagePath) {
                    html += '<p><strong>Image:</strong> ' + result.imagePath + '</p>';
                    var photo = document.getElementById('photo');
                    photo.src = 'file://' + result.imagePath;
                    photo.style.display = 'block';
                }
                
                document.getElementById('result').innerHTML = html;
            },
            function(error) {
                console.error('Error:', error);
                document.getElementById('result').innerHTML = 
                    '<h2>❌ Scan Failed</h2><p>' + error + '</p>';
            });
        }
    </script>
</body>
</html>
```

## Expected behavior

1. **On launch:**
   - Shows "✅ Plugin ready"
   - Button "📷 Scan Water Meter" is clickable

2. **On button click:**
   - Camera opens with AI overlay
   - Real-time detection starts
   - Auto-capture when confidence > 90%
   - Returns to app with results

3. **On success:**
   - Shows reading text
   - Shows confidence percentage
   - Displays captured image

## Troubleshooting

### Plugin not loaded (undefined)

```bash
# Check plugin installation
cordova plugin ls
# Should show: cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"

# Reinstall if needed
cordova plugin rm cordova-plugin-water-meter
cordova plugin add /path/to/cordova-plugin-water-meter
```

### Build errors

```bash
# Check AAR exists
ls platforms/android/app/libs/water_meter_sdk.aar

# If missing, reinstall plugin
cordova plugin rm cordova-plugin-water-meter
cordova platform rm android
cordova platform add android
cordova plugin add /path/to/cordova-plugin-water-meter
```

### Camera permission denied

```bash
# Check AndroidManifest.xml has:
# <uses-permission android:name="android.permission.CAMERA" />

# On Android 6+, permission is requested automatically
# User must grant permission in system dialog
```

### Images not displaying

1. Check CSP allows file:// protocol:
   ```html
   <meta http-equiv="Content-Security-Policy" 
         content="img-src 'self' data: content: file: https:;">
   ```

2. Check image path format:
   ```javascript
   img.src = 'file://' + result.imagePath;  // Correct
   img.src = result.imagePath;              // Wrong (missing file://)
   ```

## Performance notes

- **First scan:** ~2-3 seconds (loading AI models)
- **Subsequent scans:** <500ms
- **Image size:** ~200-500KB (JPEG 90% quality)
- **APK size:** +27MB (includes PaddleOCR models)

## Next steps

After verifying plugin works:

1. Customize UI in your app
2. Add error handling
3. Implement scan history
4. Add image review/retake
5. Integrate with backend API
6. Test on various devices

## Support

See [PLUGIN_INTEGRATION_GUIDE.md](./PLUGIN_INTEGRATION_GUIDE.md) for detailed troubleshooting.
