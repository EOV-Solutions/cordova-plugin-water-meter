# WaterMeterSDK XCFramework

This directory should contain the built `WaterMeterSDK.xcframework` for iOS integration.

## Building the Framework

Run the build script from the iOS SDK directory:

```bash
cd /path/to/iOS-SDK-Water-Meter
./build_sdk.sh
```

Then copy the output:

```bash
cp -R build/WaterMeterSDK.xcframework /path/to/cordova-plugin-water-meter/frameworks/
```

## Contents

After building, this directory should contain:

```
frameworks/
├── WaterMeterSDK.xcframework/
│   ├── Info.plist
│   ├── ios-arm64/
│   │   └── WaterMeterSDK.framework/
│   └── ios-arm64_x86_64-simulator/
│       └── WaterMeterSDK.framework/
└── README.md
```

## Size

Expected framework size: ~50MB (includes embedded ML models and OpenCV)
