#!/bin/bash

# Script để tạo Cordova app test plugin Water Meter
# Chạy script này để tạo app demo và test plugin

set -e  # Exit on error

echo "🚀 Tạo Cordova app để test Water Meter Plugin..."
echo ""

# Kiểm tra cordova đã cài chưa
if ! command -v cordova &> /dev/null; then
    echo "❌ Cordova chưa được cài đặt!"
    echo "   Cài đặt Cordova: npm install -g cordova"
    exit 1
fi

# Tạo thư mục test app
TEST_APP_DIR="TestWaterMeterApp"

if [ -d "$TEST_APP_DIR" ]; then
    echo "⚠️  Thư mục $TEST_APP_DIR đã tồn tại"
    read -p "   Xóa và tạo lại? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TEST_APP_DIR"
    else
        echo "❌ Hủy bỏ"
        exit 1
    fi
fi

# 1. Tạo Cordova app
echo "📱 Tạo Cordova app..."
cordova create "$TEST_APP_DIR" com.eov.watermeter.test "Water Meter Test"
cd "$TEST_APP_DIR"

# 2. Add Android platform
echo "📦 Thêm Android platform..."
cordova platform add android

# 3. Add plugin
echo "🔌 Thêm Water Meter plugin..."
PLUGIN_PATH="$(dirname "$(pwd)")/cordova-plugin-water-meter"
cordova plugin add "$PLUGIN_PATH"

# 4. Tạo index.html
echo "📝 Tạo index.html..."
cat > www/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Water Meter Scanner Test</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 500px;
            margin: 50px auto;
            background: white;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        h1 {
            color: #667eea;
            text-align: center;
            margin-bottom: 10px;
            font-size: 28px;
        }
        .subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        .btn {
            width: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 18px;
            font-size: 18px;
            border-radius: 10px;
            cursor: pointer;
            margin-bottom: 15px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            transition: transform 0.2s, box-shadow 0.2s;
            font-weight: 600;
        }
        .btn:active {
            transform: scale(0.98);
            box-shadow: 0 2px 10px rgba(102, 126, 234, 0.4);
        }
        .btn.secondary {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            box-shadow: 0 4px 15px rgba(245, 87, 108, 0.4);
        }
        .result {
            margin-top: 20px;
            padding: 25px;
            background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
            border-radius: 15px;
            display: none;
            animation: slideIn 0.3s ease-out;
        }
        .result.show { display: block; }
        .result h2 {
            color: #667eea;
            margin-bottom: 15px;
            text-align: center;
            font-size: 20px;
        }
        .result .number {
            font-size: 42px;
            font-weight: bold;
            color: #333;
            text-align: center;
            letter-spacing: 4px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .result .confidence {
            text-align: center;
            color: #666;
            margin-top: 10px;
            font-size: 14px;
        }
        .status {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 14px;
            display: none;
        }
        .status.show { display: block; }
        .status.info {
            background: #e3f2fd;
            color: #1976d2;
        }
        .status.success {
            background: #e8f5e9;
            color: #388e3c;
        }
        .status.error {
            background: #ffebee;
            color: #c62828;
        }
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 Water Meter Scanner</h1>
        <div class="subtitle">AI-Powered OCR Test App</div>
        
        <div class="status" id="status"></div>
        
        <button class="btn" id="btnScan">
            📷 Quét Đồng Hồ Nước
        </button>
        
        <button class="btn secondary" id="btnCheckPerm">
            🔒 Kiểm tra Permission
        </button>
        
        <div class="result" id="result">
            <h2>✅ Kết quả quét:</h2>
            <div class="number" id="number">-</div>
            <div class="confidence" id="confidence">-</div>
        </div>
    </div>
    
    <script src="cordova.js"></script>
    <script src="js/index.js"></script>
</body>
</html>
EOF

# 5. Tạo index.js
echo "💻 Tạo index.js..."
cat > www/js/index.js << 'EOF'
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    console.log('✅ Device ready!');
    showStatus('✅ App ready! Click button to scan', 'success');
    
    document.getElementById('btnScan').addEventListener('click', startScan);
    document.getElementById('btnCheckPerm').addEventListener('click', checkPermission);
}

function showStatus(message, type) {
    const status = document.getElementById('status');
    status.className = 'status show ' + type;
    status.innerText = message;
    
    if (type === 'success' || type === 'error') {
        setTimeout(() => {
            status.classList.remove('show');
        }, 3000);
    }
}

function checkPermission() {
    showStatus('🔍 Checking permission...', 'info');
    
    WaterMeter.checkPermission(
        function(result) {
            if (result.granted) {
                showStatus('✅ Camera permission granted!', 'success');
            } else {
                showStatus('❌ Camera permission NOT granted', 'error');
            }
        },
        function(error) {
            showStatus('❌ Error: ' + error, 'error');
        }
    );
}

function startScan() {
    showStatus('📷 Opening camera...', 'info');
    
    // Hide previous result
    document.getElementById('result').classList.remove('show');
    
    // Check permission first
    WaterMeter.checkPermission(
        function(result) {
            if (result.granted) {
                openScanner();
            } else {
                // Request permission
                showStatus('🔐 Requesting permission...', 'info');
                
                WaterMeter.requestPermission(
                    function(permResult) {
                        if (permResult.granted) {
                            openScanner();
                        } else {
                            showStatus('❌ Camera permission denied', 'error');
                            alert('Camera permission is required to scan water meter');
                        }
                    },
                    function(error) {
                        showStatus('❌ Permission error: ' + error, 'error');
                    }
                );
            }
        },
        function(error) {
            showStatus('❌ Error checking permission', 'error');
            console.error('Check permission error:', error);
        }
    );
}

function openScanner() {
    console.log('📷 Opening scanner...');
    
    WaterMeter.scan(
        function(result) {
            console.log('✅ Scan result:', result);
            handleScanResult(result);
        },
        function(error) {
            console.error('❌ Scan error:', error);
            
            if (error === 'User cancelled') {
                showStatus('ℹ️ Scan cancelled', 'info');
            } else {
                showStatus('❌ Scan error: ' + error, 'error');
                alert('Scan failed: ' + error);
            }
        },
        {
            title: 'Quét số đồng hồ nước',
            showCloseButton: true,
            autoCloseOnResult: true
        }
    );
}

function handleScanResult(result) {
    if (result.success && result.text) {
        // Success - show result
        showStatus('✅ Scan successful!', 'success');
        
        document.getElementById('number').innerText = result.text;
        document.getElementById('confidence').innerText = 
            'Confidence: ' + Math.round(result.confidence * 100) + '%';
        document.getElementById('result').classList.add('show');
        
        // Save to localStorage
        saveReading(result.text);
        
        // Vibrate
        if (navigator.vibrate) {
            navigator.vibrate([200, 100, 200]);
        }
        
    } else {
        // No detection
        showStatus('❌ No meter number detected', 'error');
        alert('No meter number detected.\nPlease try again with better lighting.');
    }
}

function saveReading(meterNumber) {
    try {
        const readings = JSON.parse(localStorage.getItem('readings') || '[]');
        readings.push({
            number: meterNumber,
            timestamp: new Date().toISOString(),
            date: new Date().toLocaleString('vi-VN')
        });
        localStorage.setItem('readings', JSON.stringify(readings));
        console.log('💾 Saved reading:', meterNumber);
    } catch (error) {
        console.error('Error saving reading:', error);
    }
}
EOF

# 6. Build
echo "🔨 Building app..."
cordova build android

echo ""
echo "✅ HOÀN TẤT!"
echo ""
echo "📂 App đã được tạo tại: $TEST_APP_DIR"
echo ""
echo "📱 Để chạy app:"
echo "   cd $TEST_APP_DIR"
echo "   cordova run android"
echo ""
echo "   (Hoặc cài APK thủ công từ platforms/android/app/build/outputs/apk/debug/)"
echo ""
echo "🎉 Happy testing!"
