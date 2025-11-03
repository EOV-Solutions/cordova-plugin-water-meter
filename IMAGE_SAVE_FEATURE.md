# Tính năng mới: Lưu ảnh và trả về đường dẫn

## 📋 Tổng quan

SDK Water Meter hiện đã hỗ trợ tự động lưu ảnh đã chụp và trả về đường dẫn ảnh cùng với kết quả OCR.

## ✨ Tính năng

### 1. Tự động lưu ảnh
- Ảnh được lưu tự động khi quét thành công
- Không cần quyền WRITE_EXTERNAL_STORAGE (sử dụng app-scoped storage)
- Định dạng: JPEG với chất lượng 90%
- Tên file: `[timestamp].jpg` (ví dụ: `1730626822456.jpg`)

### 2. Đường dẫn ảnh trong kết quả
```javascript
{
    text: "00123",                              // Số đồng hồ
    confidence: 0.95,                           // Độ tin cậy
    success: true,                              // Thành công
    imagePath: "/storage/.../1730626822456.jpg"  // 🆕 Đường dẫn ảnh
}
```

### 3. Vị trí lưu ảnh
```
/storage/emulated/0/Android/data/[package-name]/files/Pictures/WaterMeter/
```

Ví dụ:
```
/storage/emulated/0/Android/data/com.example.app/files/Pictures/WaterMeter/1730626822456.jpg
```

## 🔧 Các thay đổi kỹ thuật

### CameraScanActivity.java
- ✅ Thêm constant `EXTRA_RESULT_IMAGE_PATH`
- ✅ Thêm method `saveImageToFile(Bitmap)` để lưu ảnh
- ✅ Cập nhật `returnResult()` để nhận image path
- ✅ Lưu ảnh trước khi trả kết quả về

### WaterMeterPlugin.java
- ✅ Nhận `imagePath` từ Activity result
- ✅ Thêm `imagePath` vào JSON result
- ✅ Forward đường dẫn về JavaScript callback

### README.md
- ✅ Cập nhật API documentation
- ✅ Thêm ví dụ hiển thị ảnh
- ✅ Cập nhật result object structure

## 📝 Ví dụ sử dụng

### Hiển thị ảnh đã chụp
```javascript
WaterMeter.scan(
    function(result) {
        if (result.success) {
            console.log('Số đồng hồ:', result.text);
            console.log('Độ tin cậy:', result.confidence);
            console.log('Ảnh lưu tại:', result.imagePath);
            
            // Hiển thị ảnh
            if (result.imagePath) {
                var img = document.getElementById('captured-image');
                img.src = 'file://' + result.imagePath;
                img.style.display = 'block';
            }
        }
    },
    function(error) {
        console.error('Lỗi:', error);
    }
);
```

### Upload ảnh lên server
```javascript
WaterMeter.scan(
    function(result) {
        if (result.success && result.imagePath) {
            // Đọc file và upload
            window.resolveLocalFileSystemURL(
                result.imagePath,
                function(fileEntry) {
                    fileEntry.file(function(file) {
                        var reader = new FileReader();
                        reader.onloadend = function() {
                            // Upload base64 hoặc blob lên server
                            uploadToServer(result.text, this.result);
                        };
                        reader.readAsDataURL(file);
                    });
                }
            );
        }
    },
    onError
);
```

### Lưu vào SQLite database
```javascript
WaterMeter.scan(
    function(result) {
        if (result.success) {
            // Lưu vào database
            db.transaction(function(tx) {
                tx.executeSql(
                    'INSERT INTO readings (meter_number, confidence, image_path, created_at) VALUES (?, ?, ?, ?)',
                    [result.text, result.confidence, result.imagePath, new Date().toISOString()]
                );
            });
        }
    },
    onError
);
```

## 🧪 Testing

### Test lưu ảnh
1. Chụp ảnh đồng hồ nước
2. Kiểm tra result.imagePath có giá trị
3. Kiểm tra file tồn tại tại đường dẫn
4. Xác nhận ảnh hiển thị đúng

### Test đường dẫn
```javascript
if (result.imagePath) {
    // Kiểm tra file tồn tại
    window.resolveLocalFileSystemURL(
        result.imagePath,
        function(fileEntry) {
            console.log('✓ File exists:', fileEntry.name);
            fileEntry.file(function(file) {
                console.log('✓ File size:', file.size, 'bytes');
            });
        },
        function(error) {
            console.error('✗ File not found:', error);
        }
    );
}
```

## 📊 Version

- **Version trước**: 1.0.0 - Không lưu ảnh
- **Version mới**: 1.1.0 - Có lưu ảnh + trả về đường dẫn

## 📝 Tên file

Tên file sử dụng timestamp (milliseconds từ epoch) giống như logic trong app gốc:
- Format: `[timestamp].jpg`
- Ví dụ: `1730626822456.jpg`
- Lợi ích: 
  - Unique (không trùng lặp)
  - Sortable (sắp xếp theo thời gian)
  - Compatible với logic hiện có

## 🔄 Migration

Nếu bạn đang sử dụng version 1.0.0:

### Không cần thay đổi code
Code cũ vẫn hoạt động bình thường:
```javascript
WaterMeter.scan(
    function(result) {
        console.log(result.text); // Vẫn work
        // result.imagePath sẽ có thêm (optional)
    },
    onError
);
```

### Sử dụng tính năng mới (optional)
```javascript
WaterMeter.scan(
    function(result) {
        console.log(result.text);
        
        // 🆕 Sử dụng ảnh nếu cần
        if (result.imagePath) {
            displayImage(result.imagePath);
        }
    },
    onError
);
```

## ❓ FAQ

**Q: Ảnh lưu ở đâu?**
A: Ảnh lưu trong thư mục private của app: `Android/data/[package]/files/Pictures/WaterMeter/`

**Q: Có cần quyền WRITE_EXTERNAL_STORAGE không?**
A: Không cần. Sử dụng `getExternalFilesDir()` - app-scoped storage.

**Q: Ảnh có bị xoá khi gỡ app không?**
A: Có. Ảnh trong app-scoped storage sẽ bị xoá khi uninstall app.

**Q: Có thể lưu vào thư mục khác không?**
A: Hiện tại chỉ lưu vào thư mục mặc định. Có thể custom trong native code nếu cần.

**Q: Định dạng ảnh là gì?**
A: JPEG với compression quality 90%.

**Q: Kích thước ảnh bao nhiêu?**
A: Tuỳ độ phân giải camera, thường ~200KB-500KB mỗi ảnh.

## 📞 Liên hệ

- **Email**: contact@eovsolutions.com
- **GitHub**: https://github.com/EOV-Solutions/cordova-plugin-water-meter

---

*Cập nhật: 03/11/2025*
