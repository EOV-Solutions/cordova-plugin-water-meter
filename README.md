# 📱 Plugin Cordova Quét Số Đồng Hồ Nước

> Plugin quét số đồng hồ nước sử dụng AI cho ứng dụng Cordova/PhoneGap.

[![Nền tảng](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)](https://cordova.apache.org/)
[![Android](https://img.shields.io/badge/Android-%3E%3D6.0-brightgreen.svg)](https://www.android.com/)
[![iOS](https://img.shields.io/badge/iOS-%3E%3D12.0-blue.svg)](https://www.apple.com/ios/)
[![Cordova](https://img.shields.io/badge/cordova-%3E%3D9.0.0-blue.svg)](https://cordova.apache.org/)
[![Giấy phép](https://img.shields.io/badge/license-EOV-orange.svg)](LICENSE)

## ✨ Tính năng

- 📷 Xem trước camera thời gian thực với lớp phủ AI
- 🤖 Nhận diện số đồng hồ bằng AI
- 🎯 Tự động phát hiện với ngưỡng độ tin cậy
- ⚡ Tự động chụp khi căn chỉnh đúng
- 🔦 Hỗ trợ đèn flash
- 🔍 Điều khiển zoom
- 📐 Phát hiện OBB (hình chữ nhật bao quanh)
- 🔒 Quản lý quyền camera
- 📱 Hỗ trợ đa nền tảng:
  - **Android 6.0+** (API 23+)
  - **iOS 12.0+**
- 🎨 Giao diện tùy chỉnh
- 💾 Lưu ảnh và trả về đường dẫn
- 🖼️ Hỗ trợ Base64 để hiển thị ảnh trong WebView

## 🛠️ Yêu cầu

### Android
- Cordova >= 9.0.0
- cordova-android >= 9.0.0
- Android SDK API Level >= 23 (Android 6.0)
- Quyền camera

### iOS
- Cordova >= 9.0.0
- cordova-ios >= 6.0.0
- iOS 12.0 trở lên
- Quyền camera trong Info.plist

## 🚀 Cài đặt

### Cài đặt Plugin

#### Cách 1: Đường dẫn cục bộ (khuyến nghị cho phát triển)

```bash
cd YourCordovaApp
cordova plugin add /duong/dan/den/cordova-plugin-water-meter
```

#### Cách 2: Git Repository

```bash
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

### Kiểm tra cài đặt

```bash
cordova plugin list
# Phải thấy: cordova-plugin-water-meter 1.2.0 "Water Meter Scanner"
```

### Cấu hình quyền Camera (iOS)

Plugin tự động thêm quyền camera vào `Info.plist`, nhưng bạn có thể tùy chỉnh mô tả:

```xml
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần quyền truy cập camera để quét số đồng hồ nước</string>
```

### Xây dựng & chạy

**Android:**
```bash
cordova prepare android
cordova build android
cordova run android
```

**iOS:**
```bash
cordova prepare ios
cordova build ios
cordova run ios --device
```

## 💻 Sử dụng

### ⚠️ Khởi tạo License (Bắt buộc)

**QUAN TRỌNG**: Bạn phải khởi tạo license trước khi sử dụng các tính năng quét. SDK sẽ không hoạt động nếu license chưa được kích hoạt.

```javascript
document.addEventListener('deviceready', function() {
    // Khởi tạo license khi app start
    WaterMeter.initializeLicense(
        'YOUR_LICENSE_KEY',  // License key từ backend
        function(result) {
            console.log('✓ License initialized:', result);
            // result = {
            //   valid: true,
            //   status: 1,       // 1 = valid (see status codes below)
            //   message: "License is valid"
            // }
            
            // Bây giờ có thể sử dụng scan
            startScanning();
        },
        function(error) {
            console.error('✗ License error:', error);
            // Xử lý lỗi license
            alert('Không thể kích hoạt license: ' + error);
        }
    );
}, false);

// HOẶC với metadata, device user và mã tổ chức (để theo dõi trên admin)
// Lưu ý: metadataInfo, deviceUser và maToChuc là optional, có thể truyền 1 trong số đó, tất cả, hoặc không truyền
WaterMeter.initializeLicense(
    {
        licenseKey: 'YOUR_LICENSE_KEY',
        metadataInfo: { location: 'Store A', customerId: '12345' }, // Optional
        deviceUser: 'nhanvien@congty.com', // Optional
        maToChuc: 'MA_TO_CHUC_123' // Optional - Mã tổ chức
    },
    function(result) { console.log('Success:', result); },
    function(error) { console.error('Error:', error); }
);

// Hoặc chỉ setup mã tổ chức:
/*
WaterMeter.initializeLicense(
    {
        licenseKey: 'YOUR_LICENSE_KEY',
        maToChuc: 'MA_TO_CHUC_123'
    },
    success, error
);
*/

// Hoặc chỉ setup device user:
/*
WaterMeter.initializeLicense(
    {
        licenseKey: 'YOUR_LICENSE_KEY',
        deviceUser: 'nhanvien@congty.com'
    },
    success, error
);
*/

// Hoặc chỉ setup metadata:
/*
WaterMeter.initializeLicense(
    {
        licenseKey: 'YOUR_LICENSE_KEY',
        metadataInfo: { location: 'Store A' }
    },
    success, error
);
*/

// Kiểm tra license có hợp lệ không
function checkLicense() {
    WaterMeter.isLicenseValid(
        function(result) {
            console.log('License valid:', result.valid);
            console.log('License status:', result.status);
            console.log('License message:', result.message);
            // Status codes:
            // 0 = not initialized
            // 1 = valid
            // 2 = expired
            // 3 = grace period
            // 4 = invalid
            // 5 = blocked
            // 6 = quota exceeded
        },
        function(error) {
            console.error('Error:', error);
        }
    );
}
```

### Ví dụ cơ bản

```javascript
// Đợi device ready
document.addEventListener('deviceready', function() {
    WaterMeter.scan(
        function(result) {
            // Thành công
            console.log('✓ Số:', result.text);
            console.log('Độ tin cậy:', (result.confidence * 100).toFixed(1) + '%');
            
            // Hiển thị kết quả
            document.getElementById('meter-value').innerText = result.text;
            document.getElementById('confidence').innerText = (result.confidence * 100).toFixed(1) + '%';
            
            // Hiển thị ảnh đã lưu
            if (result.imagePath) {
                console.log('Ảnh đã lưu tại:', result.imagePath);
                // Android: dùng file://
                document.getElementById('captured-image').src = 'file://' + result.imagePath;
            }
            
            // iOS: dùng base64 cho WKWebView
            if (result.imageBase64) {
                document.getElementById('captured-image').src = result.imageBase64;
            }
        },
        function(error) {
            // Lỗi hoặc hủy
            console.error('Lỗi quét:', error);
            alert('Đã hủy: ' + error);
        }
    );
}, false);
```

### Ví dụ nâng cao với tuỳ chọn

```javascript
WaterMeter.scan(
    function(result) {
        console.log('Thành công:', result);
        // result = {
        //   text: "00012345",           // Số đồng hồ
        //   confidence: 0.95,           // Độ tin cậy 0.0-1.0
        //   success: true,              // true nếu có số
        //   imagePath: "/path/to/image.jpg",  // Đường dẫn ảnh
        //   imageBase64: "data:image/jpeg;base64,..." // Base64 (iOS)
        //   formattedReading: "0.0012345",  // Số đã format (iOS)
        //   isReliable: true                 // Độ tin cậy cao (iOS)
        // }
    },
    function(error) {
        console.error('Lỗi:', error);
    },
    {
        title: 'Quét số đồng hồ nước',  // Tiêu đề màn hình quét
        showCloseButton: true,          // Hiện nút đóng (X)
        autoCloseOnResult: true,        // Tự động đóng khi quét thành công
        imageMaxWidth: 1920,            // Resize ảnh về max width (giữ tỷ lệ)
        imageMaxHeight: 1080            // Resize ảnh về max height (giữ tỷ lệ)
    }
);
```

### Tích hợp hoàn chỉnh

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quét Số Đồng Hồ Nước</title>
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
            margin: 10px 5px;
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
    <h1>📱 Quét Số Đồng Hồ Nước</h1>
    
    <button onclick="startScan()">Quét</button>
    <button onclick="checkPermission()">Kiểm tra quyền</button>
    <button onclick="openSettings()">Cài đặt</button>
    
    <div id="result-container" class="result-box" style="display:none;">
        <h2>Kết quả:</h2>
        <p>Số: <strong id="meter-value">-</strong></p>
        <p>Độ tin cậy: <strong id="confidence">-</strong></p>
        <p>Đường dẫn: <span id="image-path" style="font-size:12px;">-</span></p>
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
                    // Hiển thị kết quả
                    document.getElementById('meter-value').innerText = result.text;
                    document.getElementById('confidence').innerText = (result.confidence * 100).toFixed(1) + '%';
                    
                    // Hiển thị ảnh
                    var img = document.getElementById('captured-image');
                    if (result.imageBase64) {
                        // iOS: dùng base64
                        img.src = result.imageBase64;
                        img.style.display = 'block';
                    } else if (result.imagePath) {
                        // Android: dùng file://
                        img.src = 'file://' + result.imagePath;
                        img.style.display = 'block';
                        document.getElementById('image-path').innerText = result.imagePath;
                    }
                    
                    document.getElementById('result-container').style.display = 'block';
                },
                function(error) {
                    alert('Lỗi: ' + error);
                },
                {
                    title: 'Quét số đồng hồ nước',
                    showCloseButton: true,
                    imageMaxWidth: 1920,
                    imageMaxHeight: 1080
                }
            );
        }
        
        function checkPermission() {
            WaterMeter.checkPermission(
                function(result) {
                    alert('Quyền camera: ' + (result.granted ? 'Đã cấp ✓' : 'Chưa cấp ✗'));
                },
                function(error) {
                    alert('Lỗi: ' + error);
                }
            );
        }
        
        function openSettings() {
            WaterMeter.openSettings(
                function(result) {
                    console.log('Settings opened:', result);
                },
                function(error) {
                    alert('Lỗi: ' + error);
                }
            );
        }
    </script>
</body>
</html>
```

## 📖 API

### `WaterMeter.initializeLicense(options, successCallback, errorCallback)`

**⚠️ BẮT BUỘC** - Khởi tạo SDK với license key. Phải gọi trước khi sử dụng các tính năng khác.

**Tham số:**
- `options` (string hoặc object) - Có thể truyền:
  - **String**: License key trực tiếp
  - **Object**: Cấu hình chi tiết
    - `options.licenseKey` (string, bắt buộc) - License key từ backend
    - `options.metadataInfo` (object, tùy chọn) - Metadata gửi lên server để admin theo dõi
    - `options.deviceUser` (string, tùy chọn) - Email/ID người dùng thiết bị
    - `options.maToChuc` (string, tùy chọn) - Mã tổ chức của thiết bị
- `successCallback(result)` - Được gọi khi kích hoạt thành công
  - `result.valid` (boolean) - License có hợp lệ không
  - `result.status` (number) - Mã trạng thái license (xem bảng Status Codes bên dưới)
  - `result.message` (string) - Thông báo chi tiết
- `errorCallback(error)` - Được gọi khi có lỗi

```javascript
// Cách 1: Chỉ với license key
WaterMeter.initializeLicense(
    'YOUR_LICENSE_KEY',
    function(result) {
        console.log('License activated:', result.valid);
    },
    function(error) {
        console.error('License error:', error);
    }
);

// Cách 2: Với metadata, device user và mã tổ chức
WaterMeter.initializeLicense(
    {
        licenseKey: 'YOUR_LICENSE_KEY',
        metadataInfo: { 
            location: 'Chi nhánh Quận 1', 
            customerId: '12345',
            department: 'Phòng Thu Ngân'
        },
        deviceUser: 'nhanvien@congty.com',
        maToChuc: 'MA_TO_CHUC_123'
    },
    function(result) {
        console.log('License activated:', result.valid);
    },
    function(error) {
        console.error('License error:', error);
    }
);
```

---

### `WaterMeter.isLicenseValid(successCallback, errorCallback)`

Kiểm tra license hiện tại có hợp lệ không.

**Kết quả:**
```javascript
{
    valid: true,           // License có hợp lệ
    status: 1,             // Mã trạng thái (xem bảng Status Codes)
    message: "License is valid"  // Thông báo chi tiết
}
```

**Status Codes:**
| Mã | Hằng số | Ý nghĩa |
|----|---------|--------|
| 0 | NOT_INITIALIZED | SDK chưa khởi tạo |
| 1 | VALID | License hợp lệ |
| 2 | EXPIRED | License đã hết hạn |
| 3 | GRACE_PERIOD | License trong thời gian gia hạn |
| 4 | INVALID | License key không hợp lệ |
| 5 | BLOCKED | License bị khóa |
| 6 | QUOTA_EXCEEDED | Đã vượt quota, cần sync |

```javascript
WaterMeter.isLicenseValid(
    function(result) {
        if (result.valid) {
            console.log('License is active');
        } else {
            console.log('License status:', result.status);
        }
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

---

### `WaterMeter.scan(successCallback, errorCallback, options)`

Mở camera để quét số đồng hồ nước.

**Tham số:**
- `successCallback(result)` - Được gọi khi quét thành công
- `errorCallback(error)` - Được gọi khi lỗi hoặc hủy
- `options` (tuỳ chọn):
  - `imageMaxWidth` (number) - Chiều rộng tối đa ảnh lưu (px)
  - `imageMaxHeight` (number) - Chiều cao tối đa ảnh lưu (px)

**Kết quả thành công:**

```javascript
{
    text: "00123",                              // Số đồng hồ (rỗng nếu thất bại)
    confidence: 0.95,                           // Độ tin cậy 0.0-1.0
    success: true,                              // true nếu có số
    imagePath: "/path/to/image.jpg",            // Đường dẫn ảnh đã chụp
    imageBase64: "data:image/jpeg;base64,...",  // Base64 cho WebView (cả Android và iOS)
}
```

---

### `WaterMeter.recognizeBase64(successCallback, errorCallback, base64Image)` *(iOS only)*

Nhận diện số đồng hồ từ ảnh base64.

```javascript
WaterMeter.recognizeBase64(
    function(result) {
        console.log('Kết quả:', result.text);
    },
    function(error) {
        console.error('Lỗi:', error);
    },
    'data:image/jpeg;base64,' + imageData
);
```

---

### `WaterMeter.recognizeFile(successCallback, errorCallback, filePath)` *(iOS only)*

Nhận diện số đồng hồ từ file ảnh.

```javascript
WaterMeter.recognizeFile(
    function(result) {
        console.log('Kết quả:', result.text);
    },
    function(error) {
        console.error('Lỗi:', error);
    },
    '/path/to/image.jpg'
);
```

---

### `WaterMeter.checkPermission(successCallback, errorCallback)`

Kiểm tra quyền camera.

- `successCallback(result)` - `{granted: boolean, status: string}`
  - status values (iOS): "granted", "denied", "restricted", "prompt"
- `errorCallback(error)`

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

---

### `WaterMeter.requestPermission(successCallback, errorCallback)`

Yêu cầu quyền camera.

```javascript
WaterMeter.requestPermission(
    function(result) {
        if (result.granted) {
            console.log('Permission granted!');
            WaterMeter.scan(onSuccess, onError);
        } else {
            alert('Permission denied');
        }
    },
    function(error) {
        console.error('Error:', error);
    }
);
```

---

### `WaterMeter.isInitialized(successCallback, errorCallback)` *(iOS only)*

Kiểm tra SDK đã khởi tạo chưa.

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

## ⚙️ Tuỳ chọn cấu hình

| Tuỳ chọn | Kiểu | Mặc định | Mô tả |
|----------|------|----------|-------|
| `imageMaxWidth` | number | 0 (ảnh gốc) | Chiều rộng tối đa ảnh (px) |
| `imageMaxHeight` | number | 0 (ảnh gốc) | Chiều cao tối đa ảnh (px) |

**Lưu ý:** Resize ảnh giữ tỷ lệ. Nếu chỉ định cả width và height, ảnh sẽ fit trong bounds.

## 📱 Đặc điểm theo nền tảng

### Tính năng chung (Android & iOS)

- 🔑 Khởi tạo và quản lý license (`initializeLicense`, `isLicenseValid`)
- 📷 Quét số đồng hồ nước (`scan`)
- 🔒 Quản lý quyền camera (`checkPermission`, `requestPermission`)
- 💾 Lưu ảnh và trả về đường dẫn (`imagePath`)
- 🖼️ Trả về ảnh base64 (`imageBase64`) cho WebView

## 🔧 Khắc phục sự cố

### Không tìm thấy plugin

```bash
# Kiểm tra plugin đã cài:
cordova plugin list
# Phải thấy: cordova-plugin-water-meter 1.2.0 "Water Meter Scanner"

# Đảm bảo đã load cordova.js và đợi deviceready
```

### Android: Không tìm thấy AAR

```bash
# Đảm bảo tệp AAR ở:
ls cordova-plugin-water-meter/libs/water_meter_sdk.aar

# Xoá và cài lại plugin:
cordova plugin remove cordova-plugin-water-meter
cordova plugin add /duong/dan/den/cordova-plugin-water-meter
```

### Android: Lỗi cannot find symbol CameraScanActivity

```bash
# Reinstall plugin hoàn toàn:
cordova plugin rm cordova-plugin-water-meter
cordova platform rm android
cordova platform add android
cordova plugin add /path/to/cordova-plugin-water-meter
cordova build android
```

### iOS: Framework Not Found

```bash
# Clean và rebuild:
cordova clean ios
rm -rf platforms/ios
cordova platform add ios
cordova build ios
```

### iOS: Ảnh không hiển thị trong WebView

```javascript
// ✗ Không dùng file:// URLs trong WKWebView
// img.src = 'file://' + result.imagePath;

// ✓ Dùng base64 data URL
if (result.imageBase64) {
    img.src = result.imageBase64;
}
```

### Quyền camera bị từ chối

**Android:**
```xml
<!-- Kiểm tra AndroidManifest.xml có: -->
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS:**
```xml
<!-- Kiểm tra Info.plist có: -->
<key>NSCameraUsageDescription</key>
<string>Mô tả lý do cần camera</string>
```

### Lỗi build

**Android:**
```bash
cordova clean android
rm -rf platforms/android
cordova platform add android@9.0.0
cordova build android
```

**iOS:**
```bash
cordova clean ios
rm -rf platforms/ios
cordova platform add ios
cordova build ios
```

### Code plugin cũ vẫn chạy

```bash
# Xoá và cài lại plugin, clean và build lại
cordova plugin remove cordova-plugin-water-meter
cordova plugin add /duong/dan/den/cordova-plugin-water-meter
cordova clean
cordova build

# Gỡ cài đặt app khỏi thiết bị trước khi cài lại
```

## 📝 Lịch sử thay đổi

### Phiên bản 1.2.0

- **Hỗ trợ iOS** - Tích hợp đầy đủ cho iOS 12.0+
- **WaterMeterSDK.framework** - Pre-built framework cho iOS
- **Base64 image** - Trả về ảnh base64 cho iOS WebView
- **Nhận diện từ ảnh** - API `recognizeBase64` và `recognizeFile` (iOS)
- **Màn hình cài đặt** - API `openSettings` (iOS)
- **Thông tin SDK** - API `getVersion` và `isInitialized` (iOS)

### Phiên bản 1.0.0

- Nhận diện số đồng hồ thời gian thực bằng AI
- Điều khiển flash và zoom
- Tự động chụp khi độ tin cậy > 90%
- Hiển thị độ tin cậy
- Quản lý quyền camera
- UI tuỳ chỉnh
- Tự động copy AAR khi build
- Hỗ trợ Android 6.0+
- Lưu ảnh và trả về đường dẫn

## 📄 Giấy phép

[License](./LICENSE)

## 👥 Tác giả

EOV Solutions

---

*Làm bởi EOV Solutions*