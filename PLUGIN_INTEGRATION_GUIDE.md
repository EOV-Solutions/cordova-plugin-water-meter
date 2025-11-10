# Plugin Integration Guide (Hướng dẫn tích hợp Plugin)

## For App Developers (Cho nhà phát triển ứng dụng)

### Installation (Cài đặt)

```bash
# Install from npm (when published)
cordova plugin add cordova-plugin-water-meter

# Or install from local folder
cordova plugin add path/to/cordova-plugin-water-meter

# Or install from GitHub
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

### Basic Usage (Sử dụng cơ bản)

```javascript
// Scan water meter
WaterMeter.scan({
    title: "Scan Water Meter",
    showCloseButton: true,
    autoCloseOnResult: false
}, function(result) {
    console.log("Reading: " + result.text);
    console.log("Confidence: " + result.confidence);
    console.log("Image saved at: " + result.imagePath);
    
    // Display image
    if (result.imagePath) {
        document.getElementById('photo').src = 'file://' + result.imagePath;
    }
}, function(error) {
    console.error("Scan failed: " + error);
});
```

### Build Requirements (Yêu cầu build)

#### Android

**Minimum versions:**
- `cordova-android` >= 14.0.0
- Android SDK API 23+ (Android 6.0+)
- Gradle 8.9+
- Java 17

**Automatic configuration:**
The plugin automatically:
- Copies `water_meter_sdk.aar` to `platforms/android/app/libs/`
- Adds AAR as dependency in build.gradle
- Configures camera permissions

**If you encounter build errors:**

1. **"cannot find symbol CameraScanActivity"**
   - Make sure plugin is properly installed: `cordova plugin ls`
   - Rebuild platform: `cordova platform rm android && cordova platform add android`
   - Check if AAR exists: `ls platforms/android/app/libs/water_meter_sdk.aar`

2. **"Manifest merger failed" (FileProvider conflict)**
   - Edit `platforms/android/app/src/main/AndroidManifest.xml`
   - Add `xmlns:tools="http://schemas.android.com/tools"` to `<manifest>` tag
   - Add `tools:replace="android:authorities"` to `<provider>` tag:
   ```xml
   <manifest xmlns:tools="http://schemas.android.com/tools" ...>
       ...
       <provider android:authorities="${applicationId}.cdv.core.file.provider" 
                 tools:replace="android:authorities">
           <meta-data android:name="android.support.FILE_PROVIDER_PATHS" 
                      tools:replace="android:resource" />
       </provider>
   </manifest>
   ```

3. **Gradle version mismatch**
   - Check `config.xml`: add `<preference name="GradleVersion" value="8.9" />`
   - Or update wrapper: edit `platforms/android/gradle/wrapper/gradle-wrapper.properties`
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
   ```

4. **Java version error**
   - Set JAVA_HOME before building:
   ```bash
   export JAVA_HOME=/path/to/jdk-17
   export PATH=$JAVA_HOME/bin:$PATH
   cordova build android
   ```

### Build Script Example (Ví dụ script build)

Create `build_app.sh`:

```bash
#!/bin/bash
set -e

# Set Java 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "Building Android app..."
cd platforms/android
./gradlew clean assembleDebug

echo "✓ APK: app/build/outputs/apk/debug/app-debug.apk"
```

---

## For Plugin Developers (Cho nhà phát triển plugin)

### Project Structure

```
cordova-plugin-water-meter/
├── plugin.xml                      # Plugin configuration
├── package.json                    # NPM metadata
├── www/
│   └── WaterMeter.js              # JavaScript API
├── src/
│   └── android/
│       ├── WaterMeterPlugin.java  # Cordova bridge
│       └── build.gradle           # Android dependencies
└── libs/
    └── water_meter_sdk.aar        # Native SDK (27MB)
```

### How Plugin Installation Works

When `cordova plugin add` is executed:

1. **Files copied:**
   - `plugin.xml` → `plugins/cordova-plugin-water-meter/`
   - `libs/water_meter_sdk.aar` → `plugins/cordova-plugin-water-meter/libs/`
   - `src/android/*` → Platform-specific locations

2. **Gradle configuration:**
   - `src/android/build.gradle` is applied as `gradleReference`
   - Task `copyAarToAppLibs` runs before `preBuild`
   - AAR copied: `plugins/.../libs/*.aar` → `platforms/android/app/libs/`

3. **Dependencies added:**
   ```gradle
   dependencies {
       implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
       implementation 'androidx.appcompat:appcompat:1.3.1'
       // ... other deps
   }
   ```

### Building SDK AAR

See `Water_SDK/README.md` for SDK build instructions.

Quick build:
```bash
cd Water_SDK
./build_sdk.sh
# AAR output: build_output/water_meter_sdk_release_latest.aar
```

Copy to plugin:
```bash
cp Water_SDK/build_output/water_meter_sdk_release_latest.aar \
   cordova-plugin-water-meter/libs/water_meter_sdk.aar
```

### Testing Plugin Locally

```bash
# Build SDK first
cd Water_SDK && ./build_sdk.sh

# Copy AAR to plugin
cp build_output/water_meter_sdk_release_latest.aar \
   ../cordova-plugin-water-meter/libs/water_meter_sdk.aar

# Install plugin in test app
cd ../cordova_water_meter_app
cordova plugin rm cordova-plugin-water-meter
cordova plugin add ../cordova-plugin-water-meter

# Build app
./build_app.sh
```

### Publishing to NPM

```bash
cd cordova-plugin-water-meter

# Update version in package.json and plugin.xml
npm version patch  # or minor/major

# Test installation
npm pack
cordova plugin add cordova-plugin-water-meter-1.0.1.tgz

# Publish (requires npm account)
npm publish
```

### Troubleshooting Plugin Development

**Problem: AAR not found during build**
- Check: `platforms/android/app/libs/water_meter_sdk.aar` exists?
- Solution: Ensure `copyAarToAppLibs` task runs before `preBuild`

**Problem: Classes not found (CameraScanActivity)**
- Check: Is AAR added to dependencies?
- Solution: Add `implementation fileTree(dir: 'libs', include: '*.aar')` in build.gradle

**Problem: Plugin changes not applied**
- Solution: Reinstall plugin completely:
  ```bash
  cordova plugin rm cordova-plugin-water-meter
  cordova platform rm android
  cordova platform add android
  cordova plugin add ../cordova-plugin-water-meter
  ```

### Architecture Notes

**Why separate AAR from plugin code?**
- SDK (27MB) is pre-built native library with PaddleOCR models
- Plugin is just a thin Java wrapper for Cordova
- Separation allows SDK updates without plugin changes

**Why use fileTree instead of direct AAR reference?**
- Cordova doesn't support `<lib-file>` for AAR files
- Gradle `fileTree` works with both JAR and AAR
- Allows multiple AARs in libs folder

---

## Common Issues & Solutions

### "Plugin not found" in JavaScript
```javascript
// Wrong:
cordova.plugins.WaterMeter.scan(...)

// Correct:
WaterMeter.scan(...)
```

### Images not displaying
```javascript
// Add CSP to index.html:
<meta http-equiv="Content-Security-Policy" 
      content="img-src 'self' data: content: file: https:;">

// Load image:
img.src = 'file://' + result.imagePath;
```

### Permission denied
```xml
<!-- Already added by plugin, but check AndroidManifest.xml: -->
<uses-permission android:name="android.permission.CAMERA" />
```

### Slow first scan
- First scan loads PaddleOCR models (~2-3s)
- Subsequent scans are fast (<500ms)
- Keep camera open for multiple scans

---

## Support

- GitHub Issues: https://github.com/EOV-Solutions/cordova-plugin-water-meter/issues
- Documentation: See README.md and API_DOCUMENTATION.md
- Email: support@eov-solutions.com

## License

Commercial License - EOV Solutions © 2024
See LICENSE file for details.
