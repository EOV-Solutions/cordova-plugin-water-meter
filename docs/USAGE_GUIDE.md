# Water Meter Scanner - Cordova Plugin

> Plugin quét số đồng hồ nước sử dụng AI cho ứng dụng Cordova/PhoneGap

![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)
![Android](https://img.shields.io/badge/Android-%3E%3D6.0-brightgreen.svg)
![iOS](https://img.shields.io/badge/iOS-%3E%3D12.0-blue.svg)
![Cordova](https://img.shields.io/badge/cordova-%3E%3D9.0.0-blue.svg)

---

## Mục lục

1. [Giới thiệu](#giới-thiệu)
2. [Tính năng](#tính-năng)
3. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
4. [Cài đặt](#cài-đặt)
5. [Bắt đầu nhanh](#bắt-đầu-nhanh)
6. [API Reference](#api-reference)
7. [Ví dụ code](#ví-dụ-code)
8. [Khắc phục sự cố](#khắc-phục-sự-cố)

---

## Giới thiệu

**Water Meter Scanner** là plugin Cordova giúp quét và nhận diện số đồng hồ nước tự động bằng công nghệ AI. Plugin hỗ trợ cả Android và iOS, cung cấp giao diện camera trực quan với khả năng tự động phát hiện và chụp ảnh khi căn chỉnh đúng.

---

## Tính năng

| Tính năng | Mô tả |
|-----------|-------|
| Camera Preview | Xem trước camera thời gian thực với lớp phủ AI |
| AI Recognition | Nhận diện số đồng hồ tự động bằng AI |
| Auto Detection | Tự động phát hiện với ngưỡng độ tin cậy |
| Auto Capture | Tự động chụp khi căn chỉnh đúng |
| Flash Control | Điều khiển đèn flash |
| Zoom Control | Điều khiển zoom |
| License System | Hệ thống quản lý license |
| Image Export | Lưu ảnh và trả về Base64 |

---

## Yêu cầu hệ thống

### Android
- Cordova >= 9.0.0
- cordova-android >= 9.0.0  
- Android SDK API Level >= 23 (Android 6.0)

### iOS
- Cordova >= 9.0.0
- cordova-ios >= 6.0.0
- iOS 12.0+

---

## Cài đặt

### 1. Thêm plugin vào project

```bash
# Từ đường dẫn local
cordova plugin add /path/to/cordova-plugin-water-meter

# Hoặc từ Git
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

### 2. Kiểm tra cài đặt

```bash
cordova plugin list
# Output: cordova-plugin-water-meter 1.2.0 "Water Meter Scanner"
```

### 3. Build & Run

**Android:**
```bash
cordova build android
cordova run android
```

**iOS:**
```bash
cordova build ios
cordova run ios --device
```

---

## Bắt đầu nhanh

### Bước 1: Khởi tạo License (Bắt buộc)

```javascript
document.addEventListener('deviceready', function() {
    WaterMeter.initializeLicense(
        'YOUR_LICENSE_KEY',
        function(result) {
            console.log('License activated:', result.valid);
            // Bây giờ có thể sử dụng scan
        },
        function(error) {
            console.error('License error:', error);
        }
    );
}, false);
```

### Bước 2: Quét số đồng hồ

```javascript
WaterMeter.scan(
    function(result) {
        console.log('Số đồng hồ:', result.text);
        console.log('Độ tin cậy:', (result.confidence * 100) + '%');
        
        // Hiển thị ảnh
        if (result.imageBase64) {
            document.getElementById('image').src = result.imageBase64;
        }
    },
    function(error) {
        console.error('Lỗi:', error);
    },
    {
        imageMaxWidth: 1920,
        imageMaxHeight: 1080
    }
);
```

---

## API Reference

### License Management

#### `initializeLicense(licenseKey, success, error)`

Khởi tạo SDK với license key. **Bắt buộc gọi trước khi sử dụng các tính năng khác.**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| licenseKey | string | License key từ backend |
| success | function | Callback khi thành công |
| error | function | Callback khi lỗi |

**Kết quả success:**
```javascript
{
    valid: true,           // License hợp lệ
    status: 1,             // 0=unknown, 1=active, 2=expired, 3=blocked
    message: "Activated"   // Thông báo
}
```

---

#### `isLicenseValid(success, error)`

Kiểm tra license hiện tại có hợp lệ không.

**Kết quả:**
```javascript
{
    valid: true,
    status: 1
}
```

---

### Scanning

#### `scan(success, error, options)`

Mở camera để quét số đồng hồ nước.

**Options:**

| Tuỳ chọn | Kiểu | Mặc định | Mô tả |
|----------|------|----------|-------|
| imageMaxWidth | number | - | Chiều rộng tối đa ảnh (px) |
| imageMaxHeight | number | - | Chiều cao tối đa ảnh (px) |

**Kết quả success:**
```javascript
{
    text: "00123456",                        // Số đồng hồ
    confidence: 0.95,                        // Độ tin cậy 0.0-1.0
    success: true,                           // true nếu có số
    imagePath: "/path/to/image.jpg",         // Đường dẫn ảnh
    imageBase64: "data:image/jpeg;base64,..." // Base64 cho WebView
}
```

---

#### `recognizeBase64(base64Image, success, error)`

Nhận diện số từ ảnh Base64.

```javascript
WaterMeter.recognizeBase64(
    'data:image/jpeg;base64,...',
    function(result) { console.log(result.text); },
    function(error) { console.error(error); }
);
```

---

#### `recognizeFile(filePath, success, error)`

Nhận diện số từ file ảnh.

```javascript
WaterMeter.recognizeFile(
    '/path/to/image.jpg',
    function(result) { console.log(result.text); },
    function(error) { console.error(error); }
);
```

---

### Permission Management

#### `checkPermission(success, error)`

Kiểm tra quyền camera.

```javascript
WaterMeter.checkPermission(
    function(result) {
        console.log('Granted:', result.granted);
        // result.status: "granted", "denied", "restricted", "prompt"
    },
    function(error) { console.error(error); }
);
```

---

#### `requestPermission(success, error)`

Yêu cầu quyền camera.

```javascript
WaterMeter.requestPermission(
    function(result) {
        if (result.granted) {
            // Có thể quét
        }
    },
    function(error) { console.error(error); }
);
```

---

### Utility

#### `getVersion(success, error)`

Lấy phiên bản SDK.

#### `isInitialized(success, error)`

Kiểm tra SDK đã khởi tạo chưa.

#### `openSettings(success, error)`

Mở màn hình cài đặt SDK.

#### `reset(success, error)`

Reset SDK (giải phóng tài nguyên).

---

## Ví dụ code

### Tích hợp hoàn chỉnh

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Water Meter Scanner</title>
    <script src="cordova.js"></script>
    <style>
        body { font-family: system-ui; padding: 20px; }
        button { 
            background: #007AFF; color: white; 
            border: none; padding: 12px 24px; 
            border-radius: 8px; margin: 5px;
        }
        .result { background: #f5f5f5; padding: 15px; border-radius: 8px; margin-top: 20px; }
        img { max-width: 100%; border-radius: 8px; margin-top: 10px; }
    </style>
</head>
<body>
    <h1>📱 Water Meter Scanner</h1>
    
    <button onclick="startScan()">Quét</button>
    <button onclick="checkLicense()">Kiểm tra License</button>
    
    <div class="result" id="result" style="display:none;">
        <h3>Kết quả</h3>
        <p>Số: <strong id="value">-</strong></p>
        <p>Độ tin cậy: <strong id="confidence">-</strong></p>
        <img id="image" style="display:none;" />
    </div>

    <script>
        var licenseInitialized = false;
        
        document.addEventListener('deviceready', function() {
            // Khởi tạo license
            WaterMeter.initializeLicense(
                'YOUR_LICENSE_KEY',
                function(result) {
                    console.log('License OK:', result);
                    licenseInitialized = true;
                },
                function(error) {
                    alert('License error: ' + error);
                }
            );
        }, false);
        
        function startScan() {
            if (!licenseInitialized) {
                alert('Đang khởi tạo license...');
                return;
            }
            
            WaterMeter.scan(
                function(result) {
                    document.getElementById('value').innerText = result.text;
                    document.getElementById('confidence').innerText = 
                        (result.confidence * 100).toFixed(1) + '%';
                    
                    if (result.imageBase64) {
                        var img = document.getElementById('image');
                        img.src = result.imageBase64;
                        img.style.display = 'block';
                    }
                    
                    document.getElementById('result').style.display = 'block';
                },
                function(error) {
                    if (error !== 'User cancelled') {
                        alert('Lỗi: ' + error);
                    }
                },
                { imageMaxWidth: 1920, imageMaxHeight: 1080 }
            );
        }
        
        function checkLicense() {
            WaterMeter.isLicenseValid(
                function(result) {
                    alert('License valid: ' + result.valid + '\nStatus: ' + result.status);
                },
                function(error) {
                    alert('Error: ' + error);
                }
            );
        }
    </script>
</body>
</html>
```

---

## Khắc phục sự cố

### Plugin không tìm thấy

```bash
# Kiểm tra plugin
cordova plugin list

# Cài lại
cordova plugin rm cordova-plugin-water-meter
cordova plugin add /path/to/plugin
```

### Android: Lỗi build

```bash
cordova clean android
rm -rf platforms/android
cordova platform add android
cordova build android
```

### iOS: Ảnh không hiển thị

```javascript
// Sử dụng base64 thay vì file://
if (result.imageBase64) {
    img.src = result.imageBase64;
}
```

### Quyền camera bị từ chối

**Android:** Kiểm tra `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS:** Kiểm tra `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần camera để quét số đồng hồ</string>
```

---

## Liên hệ

**EOV Solutions**

---

*© 2026 EOV Solutions. All rights reserved.*
