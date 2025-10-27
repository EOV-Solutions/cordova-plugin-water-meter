# 🚀 Quick Start - 3 bước để sử dụng plugin

## Bước 1️⃣: Cài đặt plugin

```bash
cd YourCordovaApp
cordova plugin add /mnt/data2tb/code/water_meter/app/SDK/cordova-plugin-water-meter
```

## Bước 2️⃣: Viết code (3 dòng!)

```javascript
document.addEventListener('deviceready', function() {
    WaterMeter.scan(
        function(result) { alert('Số: ' + result.text); },
        function(error) { alert('Lỗi: ' + error); }
    );
});
```

## Bước 3️⃣: Build & Run

```bash
cordova build android
cordova run android
```

**XONG!** 🎉

---

## 🧪 Hoặc test ngay với script tự động:

```bash
cd /mnt/data2tb/code/water_meter/app/SDK/cordova-plugin-water-meter
./create-test-app.sh
```

Script sẽ tự động:
- ✅ Tạo Cordova app mới
- ✅ Add Android platform
- ✅ Cài plugin
- ✅ Tạo UI đẹp sẵn
- ✅ Build app
- ✅ Sẵn sàng test!

---

## 📚 Đọc thêm:

- **README.md** - Full documentation (English)
- **HUONG_DAN_TICH_HOP.md** - Hướng dẫn chi tiết (Tiếng Việt)
- **PLUGIN_SUMMARY.md** - Tổng quan plugin
- **EXAMPLE_INSTALLATION.md** - Ví dụ cài đặt

---

## 💡 API đơn giản:

```javascript
// 1. Quét đồng hồ
WaterMeter.scan(successCallback, errorCallback, options);

// 2. Kiểm tra permission
WaterMeter.checkPermission(successCallback, errorCallback);

// 3. Xin permission
WaterMeter.requestPermission(successCallback, errorCallback);
```

**Chỉ vậy thôi!** Không cần config gì thêm! 🚀
