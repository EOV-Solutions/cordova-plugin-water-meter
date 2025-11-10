# 📱 Plugin Cordova Quét Số Đồng Hồ Nước

> Plugin quét số đồng hồ nước sử dụng AI cho ứng dụng Cordova/PhoneGap.

[![Nền tảng](https://img.shields.io/badge/platform-Android-green.svg)](https://www.android.com/)
[![Cordova](https://img.shields.io/badge/cordova-%3E%3D9.0.0-blue.svg)](https://cordova.apache.org/)
[![Giấy phép](https://img.shields.io/badge/license-EOV-orange.svg)](LICENSE)

## ✨ Tính năng

- 📷 Xem trước camera thời gian thực với lớp phủ AI
- 🤖 Nhận diện số đồng hồ bằng AI
- 🎯 Tự động phát hiện với ngưỡng độ tin cậy
- ⚡ Tự động chụp khi căn chỉnh đúng
- 🔦 Điều khiển đèn flash
- 🔍 Điều khiển zoom
- 📐 Phát hiện OBB (hình chữ nhật bao quanh)
- 🔒 Quản lý quyền camera
- 📱 Hỗ trợ Android 6.0+ (API 23+)
- 🎨 Giao diện tùy chỉnh

## 🛠️ Yêu cầu

- Cordova >= 9.0.0
- cordova-android >= 9.0.0
- Android SDK API Level >= 23 (Android 6.0)
- Quyền camera

## 🚀 Cài đặt

### Điều kiện tiên quyết

Đảm bảo tệp AAR SDK ở `libs/water_meter_sdk.aar`:

```bash
# Tệp AAR phải nằm tại:
# cordova-plugin-water-meter/libs/water_meter_sdk.aar
```

### Cài đặt Plugin

#### Cách 1: Đường dẫn cục bộ

```bash
cd YourCordovaApp
cordova plugin add /duong/dan/den/cordova-plugin-water-meter
```

#### Cách 2: Git Repository

```bash
cordova plugin add https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

#### Cách 3: Git riêng

```bash
cordova plugin add git+https://github.com/EOV-Solutions/cordova-plugin-water-meter.git
```

### Kiểm tra cài đặt

```bash
cordova plugin list
# Phải thấy: cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"
```

### Xây dựng & chạy

```bash
cordova prepare
cordova build android
cordova run android
```

## 💻 Sử dụng

### Ví dụ cơ bản

```javascript
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
            document.getElementById('captured-image').src = 'file://' + result.imagePath;
        }
    },
    function(error) {
        // Lỗi hoặc hủy
        console.error('Lỗi quét:', error);
        alert('Đã hủy: ' + error);
    }
);
```

### Ví dụ nâng cao với tuỳ chọn

```javascript
WaterMeter.scan(
    function(result) {
        console.log('Thành công:', result);
    },
    function(error) {
        console.error('Lỗi:', error);
    },
    {
        title: 'Quét số đồng hồ nước', // Tiêu đề màn hình quét
        showCloseButton: true,     // Hiện nút đóng (X)
        autoCloseOnResult: true   // Tự động đóng khi quét thành công
    }
);
```

### Tích hợp hoàn chỉnh

```html
<!DOCTYPE html>
<html>
<head>
    <title>Quét Số Đồng Hồ Nước</title>
    <script src="cordova.js"></script>
    <style>
        #captured-image { max-width: 100%; height: auto; margin-top: 10px; }
    </style>
</head>
<body>
    <h1>Quét Số Đồng Hồ Nước</h1>
    <button onclick="startScan()">Quét</button>
    <div id="result-container" style="display:none;">
        <h2>Kết quả:</h2>
        <p>Số: <strong id="meter-value">-</strong></p>
        <p>Độ tin cậy: <strong id="confidence">-</strong></p>
        <p>Đường dẫn: <span id="image-path">-</span></p>
        <img id="captured-image" style="display:none;" />
    </div>
    <script>
        function startScan() {
            WaterMeter.scan(
                function(result) {
                    // Hiển thị kết quả
                    document.getElementById('meter-value').innerText = result.text;
                    document.getElementById('confidence').innerText = (result.confidence * 100).toFixed(1) + '%';
                    
                    // Hiển thị ảnh đã lưu
                    if (result.imagePath) {
                        document.getElementById('image-path').innerText = result.imagePath;
                        var img = document.getElementById('captured-image');
                        img.src = 'file://' + result.imagePath;
                        img.style.display = 'block';
                    }
                    
                    document.getElementById('result-container').style.display = 'block';
                },
                function(error) {
                    alert('Lỗi: ' + error);
                },
                {
                    title: 'Quét số đồng hồ nước',
                    showCloseButton: true,
                    autoCloseOnResult: true
                }
            );
        }
    </script>
</body>
</html>
```

## 📖 API

### `WaterMeter.scan(successCallback, errorCallback, options)`

Mở camera để quét số đồng hồ nước.

- `successCallback(result)` - Được gọi khi quét thành công
    - `result`: `{text: string, confidence: number, success: boolean}`
- `errorCallback(error)` - Được gọi khi lỗi hoặc hủy
- `options` (tuỳ chọn)
    - `title` (string) - Tiêu đề màn hình quét
    - `showCloseButton` (boolean) - Hiện nút đóng (X)
    - `autoCloseOnResult` (boolean) - Tự động đóng khi quét thành công

**Kết quả thành công:**

```javascript
{
    text: "00123",        // Số đồng hồ (rỗng nếu thất bại)
    confidence: 1.0,      // Độ tin cậy 0.0-1.0
    success: true,        // true nếu có số
    imagePath: "/path/to/image.jpg"  // Đường dẫn ảnh đã chụp (nếu có)
}
```

**Ví dụ:**

```javascript
WaterMeter.scan(
    function(result) {
        if (result.success) {
            alert('Meter number: ' + result.text);
            console.log('Image saved at: ' + result.imagePath);
            
            // Hiển thị ảnh đã lưu
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

**Ví dụ:**

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

Kiểm tra quyền camera.

- `successCallback(result)` - `{granted: boolean}`
- `errorCallback(error)`

**Ví dụ:**

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

Yêu cầu quyền camera.

- `successCallback(result)` - `{granted: boolean}`
- `errorCallback(error)`

**Ví dụ:**

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

## ⚙️ Tuỳ chọn cấu hình

| Tuỳ chọn | Kiểu | Mặc định | Mô tả |
|----------|------|----------|-------|
| `title` | string | "Quét số đồng hồ" | Tiêu đề màn hình quét |
| `showCloseButton` | boolean | true | Hiện nút đóng |
| `autoCloseOnResult` | boolean | true | Tự động đóng khi quét thành công |

## 🔧 Khắc phục sự cố

### Không tìm thấy plugin

- Kiểm tra plugin đã cài:
  ```bash
  cordova plugin list
  ```
- Đảm bảo có: `cordova-plugin-water-meter 1.0.0 "Water Meter Scanner"`
- Đảm bảo đã load `cordova.js` trước khi gọi plugin

### Không tìm thấy AAR

- Đảm bảo tệp AAR ở: `cordova-plugin-water-meter/libs/water_meter_sdk.aar`
- Xoá và cài lại plugin:
  ```bash
  cordova plugin remove cordova-plugin-water-meter
  cordova plugin add /duong/dan/den/cordova-plugin-water-meter
  ```

### Quyền camera bị từ chối

- Kiểm tra AndroidManifest.xml có:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  ```
- Yêu cầu quyền trước khi quét:
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

### Lỗi build

- Kiểm tra `config.xml` có:
  ```xml
  <engine name="android" spec="^9.0.0" />
  ```
- Clean và build lại:
  ```bash
  cordova clean android
  rm -rf platforms/android
  cordova platform add android@9.0.0
  cordova build android
  ```

### Code plugin cũ vẫn chạy

- Xoá và cài lại plugin, clean và build lại
  ```bash
  cordova plugin remove cordova-plugin-water-meter
  cordova plugin add /duong/dan/den/cordova-plugin-water-meter
  cordova clean android
  cordova build android
  ```
- Gỡ cài đặt app khỏi thiết bị trước khi cài lại

### Lỗi: cannot find symbol CameraScanActivity

**Nguyên nhân:** AAR không được thêm vào dependencies hoặc chưa được copy.

**Giải pháp:**

1. Kiểm tra AAR tồn tại:
   ```bash
   ls platforms/android/app/libs/water_meter_sdk.aar
   ls plugins/cordova-plugin-water-meter/libs/water_meter_sdk.aar
   ```

2. Reinstall plugin hoàn toàn:
   ```bash
   cordova plugin rm cordova-plugin-water-meter
   cordova platform rm android
   cordova platform add android
   cordova plugin add /path/to/cordova-plugin-water-meter
   ```

3. Build lại:
   ```bash
   cd platforms/android
   ./gradlew clean assembleDebug
   ```

4. Nếu vẫn lỗi, kiểm tra `platforms/android/app/build.gradle`:
   ```gradle
   dependencies {
       implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
       // ... other deps
   }
   ```

### Lỗi: Manifest merger failed (FileProvider conflict)

**Nguyên nhân:** Conflict giữa FileProvider của Cordova và SDK.

**Giải pháp:** Thêm `tools:replace` vào AndroidManifest.xml:

1. Mở `platforms/android/app/src/main/AndroidManifest.xml`
2. Thêm namespace tools:
   ```xml
   <manifest xmlns:tools="http://schemas.android.com/tools" ...>
   ```
3. Thêm tools:replace vào provider:
   ```xml
   <provider android:authorities="${applicationId}.cdv.core.file.provider"
             tools:replace="android:authorities">
       <meta-data android:name="android.support.FILE_PROVIDER_PATHS"
                  tools:replace="android:resource" />
   </provider>
   ```

### Lỗi: Gradle version mismatch

**Giải pháp 1:** Thêm vào `config.xml`:
```xml
<platform name="android">
    <preference name="GradleVersion" value="8.9" />
</platform>
```

**Giải pháp 2:** Update gradle wrapper:
```bash
# Edit platforms/android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
```

### Lỗi: Java version mismatch

**Yêu cầu:** Java 17

**Giải pháp:**
```bash
# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Verify
java -version  # Should show version 17

# Build
cordova build android
```

## 📚 Tài liệu bổ sung

- [PLUGIN_INTEGRATION_GUIDE.md](./PLUGIN_INTEGRATION_GUIDE.md) - Hướng dẫn chi tiết tích hợp plugin
- [API_DOCUMENTATION.md](../Water_SDK/API_DOCUMENTATION.md) - API documentation của SDK
- [CHANGELOG.md](./CHANGELOG.md) - Lịch sử thay đổi chi tiết

## 📝 Lịch sử thay đổi

### Phiên bản 1.0.0

- Nhận diện số đồng hồ thời gian thực bằng AI
- Sửa lỗi flash khi zoom
- Điều khiển zoom (1.0x - 4.0x)
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