# Hướng dẫn tích hợp Cordova Plugin - Tiếng Việt

## 📋 Chuẩn bị

### 1. Copy file SDK AAR

Đầu tiên, copy file AAR SDK vào thư mục plugin:

```bash
cp /mnt/data2tb/code/water_meter/app/SDK/Water_SDK/app/build/outputs/aar/app-release.aar \
   /mnt/data2tb/code/water_meter/app/SDK/cordova-plugin-water-meter/libs/water_meter_sdk.aar
```

### 2. Cài đặt plugin vào Cordova app

```bash
# Di chuyển đến thư mục Cordova app của bạn
cd /path/to/your/cordova-app

# Thêm plugin
cordova plugin add /mnt/data2tb/code/water_meter/app/SDK/cordova-plugin-water-meter

# Build app
cordova build android
```

## 🚀 Sử dụng trong Cordova App

### Ví dụ đơn giản nhất

```javascript
// Đợi deviceready event
document.addEventListener('deviceready', function() {
    
    // Khi user click button quét
    document.getElementById('btnScan').addEventListener('click', function() {
        
        // Mở camera quét đồng hồ
        WaterMeter.scan(
            function(result) {
                // ✅ Thành công
                if (result.success) {
                    alert('Số đồng hồ: ' + result.text);
                } else {
                    alert('Không nhận dạng được');
                }
            },
            function(error) {
                // ❌ Lỗi hoặc user hủy
                alert('Lỗi: ' + error);
            }
        );
    });
});
```

### Ví dụ có xử lý permission

```javascript
document.addEventListener('deviceready', function() {
    
    document.getElementById('btnScan').addEventListener('click', function() {
        
        // 1. Kiểm tra permission trước
        WaterMeter.checkPermission(
            function(result) {
                if (result.granted) {
                    // Đã có permission - mở ngay
                    moCamera();
                } else {
                    // Chưa có - xin permission
                    WaterMeter.requestPermission(
                        function(permResult) {
                            if (permResult.granted) {
                                moCamera();
                            } else {
                                alert('Cần cấp quyền camera để quét');
                            }
                        },
                        function(error) {
                            alert('Lỗi xin permission: ' + error);
                        }
                    );
                }
            },
            function(error) {
                console.error('Lỗi kiểm tra permission:', error);
            }
        );
    });
});

function moCamera() {
    WaterMeter.scan(
        function(result) {
            if (result.success) {
                console.log('Kết quả:', result.text);
                console.log('Độ tin cậy:', result.confidence);
                
                // Hiển thị kết quả
                document.getElementById('ketQua').innerText = result.text;
                
                // Lưu vào database hoặc gửi lên server
                luuKetQua(result.text);
            } else {
                alert('Không quét được, thử lại nhé');
            }
        },
        function(error) {
            if (error !== 'User cancelled') {
                alert('Lỗi: ' + error);
            }
        },
        {
            title: 'Quét số đồng hồ nước',
            showCloseButton: true,
            autoCloseOnResult: true
        }
    );
}

function luuKetQua(soDongHo) {
    // TODO: Lưu vào localStorage hoặc gửi lên server
    console.log('Đã quét:', soDongHo);
}
```

## 📱 HTML Example

```html
<!DOCTYPE html>
<html>
<head>
    <title>Quét Đồng Hồ Nước</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
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
        .btn-scan {
            width: 100%;
            background: #2196F3;
            color: white;
            border: none;
            padding: 15px;
            font-size: 18px;
            border-radius: 5px;
            cursor: pointer;
            margin-bottom: 20px;
        }
        .btn-scan:active {
            background: #0b7dda;
        }
        .result {
            text-align: center;
            padding: 20px;
            background: #e8f5e9;
            border-radius: 5px;
            display: none;
        }
        .result.show {
            display: block;
        }
        .result h2 {
            color: #4CAF50;
            margin-bottom: 10px;
        }
        .result .number {
            font-size: 32px;
            font-weight: bold;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 Quét Đồng Hồ Nước</h1>
        
        <button class="btn-scan" id="btnScan">
            📷 Mở Camera Quét
        </button>
        
        <div class="result" id="result">
            <h2>✅ Kết quả quét:</h2>
            <div class="number" id="number">-</div>
        </div>
    </div>
    
    <script src="cordova.js"></script>
    <script src="js/app.js"></script>
</body>
</html>
```

## 💻 JavaScript Full Example (app.js)

```javascript
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    console.log('App đã sẵn sàng!');
    
    // Gắn sự kiện click cho button
    document.getElementById('btnScan').addEventListener('click', batDauQuet);
}

function batDauQuet() {
    console.log('Bắt đầu quét...');
    
    // Kiểm tra permission
    WaterMeter.checkPermission(
        function(result) {
            if (result.granted) {
                // Đã có quyền - mở camera
                moCamera();
            } else {
                // Chưa có quyền - xin quyền
                xinQuyenCamera();
            }
        },
        function(error) {
            console.error('Lỗi kiểm tra quyền:', error);
            alert('Không thể kiểm tra quyền camera');
        }
    );
}

function xinQuyenCamera() {
    WaterMeter.requestPermission(
        function(result) {
            if (result.granted) {
                console.log('Đã cấp quyền camera');
                moCamera();
            } else {
                alert('Bạn cần cấp quyền camera để quét đồng hồ');
            }
        },
        function(error) {
            console.error('Lỗi xin quyền:', error);
            alert('Không thể xin quyền camera: ' + error);
        }
    );
}

function moCamera() {
    console.log('Mở camera...');
    
    WaterMeter.scan(
        function(result) {
            console.log('Kết quả quét:', result);
            xuLyKetQua(result);
        },
        function(error) {
            console.error('Lỗi quét:', error);
            
            if (error === 'User cancelled') {
                console.log('User đã hủy quét');
            } else {
                alert('Lỗi khi quét: ' + error);
            }
        },
        {
            title: 'Quét số đồng hồ nước',
            showCloseButton: true,
            autoCloseOnResult: true
        }
    );
}

function xuLyKetQua(result) {
    if (result.success && result.text) {
        // Quét thành công
        console.log('Số đồng hồ:', result.text);
        console.log('Độ tin cậy:', result.confidence);
        
        // Hiển thị kết quả
        hienThiKetQua(result.text);
        
        // Lưu kết quả
        luuKetQua(result.text);
        
    } else {
        // Không quét được
        alert('Không nhận dạng được số đồng hồ.\nVui lòng thử lại với ảnh rõ hơn.');
    }
}

function hienThiKetQua(soDongHo) {
    // Hiển thị kết quả trên màn hình
    document.getElementById('number').innerText = soDongHo;
    document.getElementById('result').classList.add('show');
    
    // Tự động ẩn sau 5 giây
    setTimeout(function() {
        document.getElementById('result').classList.remove('show');
    }, 5000);
}

function luuKetQua(soDongHo) {
    // Lưu vào localStorage
    var cacKetQua = JSON.parse(localStorage.getItem('ketQuaQuet') || '[]');
    
    cacKetQua.push({
        soDongHo: soDongHo,
        thoiGian: new Date().toISOString(),
        ngay: new Date().toLocaleDateString('vi-VN')
    });
    
    localStorage.setItem('ketQuaQuet', JSON.stringify(cacKetQua));
    
    console.log('Đã lưu kết quả:', soDongHo);
    
    // TODO: Gửi lên server nếu cần
    // guiLenServer(soDongHo);
}

function guiLenServer(soDongHo) {
    // TODO: Gửi kết quả lên server
    fetch('https://your-api.com/meter-reading', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            meterNumber: soDongHo,
            timestamp: new Date().toISOString()
        })
    })
    .then(response => response.json())
    .then(data => {
        console.log('Đã gửi lên server:', data);
    })
    .catch(error => {
        console.error('Lỗi gửi server:', error);
    });
}
```

## 🔧 Config.xml

Đảm bảo `config.xml` có đúng cấu hình:

```xml
<?xml version='1.0' encoding='utf-8'?>
<widget id="com.example.watermeter" version="1.0.0">
    <name>Water Meter Scanner</name>
    <description>App quét đồng hồ nước</description>
    
    <platform name="android">
        <preference name="android-minSdkVersion" value="23" />
        <preference name="android-targetSdkVersion" value="29" />
    </platform>
    
    <!-- Plugin sẽ tự động thêm -->
</widget>
```

## ✅ Checklist

- [ ] Copy file `app-release.aar` vào `libs/water_meter_sdk.aar`
- [ ] Cài plugin: `cordova plugin add /path/to/plugin`
- [ ] Kiểm tra `config.xml` có đúng minSdkVersion (23+)
- [ ] Thêm button quét vào HTML
- [ ] Xử lý `deviceready` event
- [ ] Gọi `WaterMeter.scan()` khi user click
- [ ] Xử lý kết quả trong success callback
- [ ] Test trên thiết bị thật

## 🎉 Hoàn tất!

Giờ app Cordova của bạn đã có thể quét đồng hồ nước rồi! 🚀

```javascript
// Cực kỳ đơn giản:
WaterMeter.scan(
    function(result) { alert('Kết quả: ' + result.text); },
    function(error) { alert('Lỗi: ' + error); }
);
```
