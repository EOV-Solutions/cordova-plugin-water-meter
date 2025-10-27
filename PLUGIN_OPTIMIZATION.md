# 🚀 Plugin Optimization - Load SDK thay vì Copy

## ❌ Vấn đề hiện tại

**Plugin hiện tại:**
```xml
<lib-file src="libs/water_meter_sdk.aar" />
```

**Kết quả:**
- Mỗi app cài plugin → Copy 28MB AAR
- 10 apps = 10 x 28MB = 280MB lãng phí!
- Tốn thời gian copy mỗi lần cài plugin

---

## ✅ Giải pháp 1: Maven Local Repository (BEST)

### Bước 1: Publish SDK lên Maven Local

Tạo script `publish-to-maven-local.sh`:

```bash
#!/bin/bash

SDK_AAR="/mnt/data2tb/code/water_meter/app/SDK/Water_SDK/app/build/outputs/aar/app-release.aar"
GROUP_ID="com.eov.watermeter"
ARTIFACT_ID="water-meter-sdk"
VERSION="1.0.0"

mvn install:install-file \
  -Dfile="$SDK_AAR" \
  -DgroupId="$GROUP_ID" \
  -DartifactId="$ARTIFACT_ID" \
  -Dversion="$VERSION" \
  -Dpackaging=aar \
  -DgeneratePom=true

echo "✅ Published to Maven Local: $GROUP_ID:$ARTIFACT_ID:$VERSION"
echo "📁 Location: ~/.m2/repository/com/eov/watermeter/water-meter-sdk/$VERSION/"
```

**Chạy một lần:**
```bash
chmod +x publish-to-maven-local.sh
./publish-to-maven-local.sh
```

### Bước 2: Sửa plugin.xml

**Xóa:**
```xml
<lib-file src="libs/water_meter_sdk.aar" />
```

**Không cần copy AAR nữa!**

### Bước 3: Sửa src/android/build.gradle

```gradle
ext {
    // SDK version
    minSdkVersion = 23
    compileSdkVersion = 29
    targetSdkVersion = 29
}

repositories {
    google()
    mavenCentral()
    mavenLocal()  // ⭐ Thêm Maven Local
}

dependencies {
    // AndroidX
    implementation 'androidx.appcompat:appcompat:1.3.1'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.0'
    
    // Camera2
    implementation 'androidx.camera:camera-core:1.0.2'
    implementation 'androidx.camera:camera-camera2:1.0.2'
    implementation 'androidx.camera:camera-lifecycle:1.0.2'
    implementation 'androidx.camera:camera-view:1.0.0-alpha27'
    
    // ⭐ Water Meter SDK from Maven Local
    implementation 'com.eov.watermeter:water-meter-sdk:1.0.0'
}
```

### Kết quả:

✅ **Mọi app chỉ cần reference SDK từ Maven Local (~/.m2/repository/)**  
✅ **Không copy 28MB mỗi lần**  
✅ **Update SDK → Chỉ cần publish lại Maven Local**  
✅ **Mọi app tự động dùng version mới**  

---

## ✅ Giải pháp 2: File Path Reference (Alternative)

Nếu không muốn dùng Maven, có thể reference trực tiếp file path.

### Sửa src/android/build.gradle:

```gradle
dependencies {
    // ... other deps ...
    
    // ⭐ Reference AAR từ path cố định
    implementation files('/path/to/sdk/water_meter_sdk.aar')
    
    // Hoặc dùng biến môi trường
    def sdkPath = System.getenv('WATER_METER_SDK_PATH') ?: '/default/path/water_meter_sdk.aar'
    implementation files(sdkPath)
}
```

### Plugin.xml thêm preference:

```xml
<preference name="WATER_METER_SDK_PATH" default="/opt/water_meter_sdk/app-release.aar" />
```

### Kết quả:

✅ **SDK để ở 1 chỗ duy nhất**  
✅ **Mọi app reference đến đó**  
⚠️ **Phải đảm bảo path tồn tại trên mọi máy build**  

---

## ✅ Giải pháp 3: Private Maven Repository (Production)

Nếu team/công ty, nên dùng private Maven repository (Nexus, Artifactory, GitHub Packages).

### Publish lên GitHub Packages:

```bash
# build.gradle (SDK project)
publishing {
    publications {
        release(MavenPublication) {
            groupId = 'com.eov.watermeter'
            artifactId = 'water-meter-sdk'
            version = '1.0.0'
            
            artifact("$buildDir/outputs/aar/app-release.aar")
        }
    }
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/EOV-Solutions/water-meter-sdk")
            credentials {
                username = project.findProperty("gpr.user") ?: System.getenv("USERNAME")
                password = project.findProperty("gpr.key") ?: System.getenv("TOKEN")
            }
        }
    }
}
```

### Plugin build.gradle:

```gradle
repositories {
    maven {
        url = uri("https://maven.pkg.github.com/EOV-Solutions/water-meter-sdk")
        credentials {
            username = project.findProperty("gpr.user")
            password = project.findProperty("gpr.key")
        }
    }
}

dependencies {
    implementation 'com.eov.watermeter:water-meter-sdk:1.0.0'
}
```

### Kết quả:

✅ **Professional solution**  
✅ **Version control tốt**  
✅ **Team collaboration dễ dàng**  
✅ **CI/CD friendly**  
⚠️ **Cần setup GitHub token**  

---

## 📊 So sánh các giải pháp

| Giải pháp | Pros | Cons | Recommended |
|-----------|------|------|-------------|
| **Copy AAR** (hiện tại) | Đơn giản, không phụ thuộc | Lãng phí 28MB/app | ❌ No |
| **Maven Local** | Không copy, dễ update | Phải publish trước | ✅ YES |
| **File Path** | Không copy, simple | Path phải tồn tại | ⚠️ OK |
| **Private Maven** | Professional, CI/CD | Phải setup infra | ✅ Production |

---

## 🚀 Implementation: Maven Local (BEST CHOICE)

### Step 1: Tạo script publish SDK

```bash
#!/bin/bash
# File: /mnt/data2tb/code/water_meter/app/SDK/Water_SDK/publish-to-maven-local.sh

set -e

echo "📦 Publishing Water Meter SDK to Maven Local..."

SDK_AAR="app/build/outputs/aar/app-release.aar"
GROUP_ID="com.eov.watermeter"
ARTIFACT_ID="water-meter-sdk"
VERSION="1.0.0"

if [ ! -f "$SDK_AAR" ]; then
    echo "❌ AAR not found: $SDK_AAR"
    echo "   Please build SDK first: ./gradlew assembleRelease"
    exit 1
fi

mvn install:install-file \
  -Dfile="$SDK_AAR" \
  -DgroupId="$GROUP_ID" \
  -DartifactId="$ARTIFACT_ID" \
  -Dversion="$VERSION" \
  -Dpackaging=aar \
  -DgeneratePom=true

echo ""
echo "✅ Published successfully!"
echo "   Group ID: $GROUP_ID"
echo "   Artifact ID: $ARTIFACT_ID"
echo "   Version: $VERSION"
echo ""
echo "📁 Location: ~/.m2/repository/com/eov/watermeter/water-meter-sdk/$VERSION/"
echo ""
echo "🔧 Usage in build.gradle:"
echo "   implementation 'com.eov.watermeter:water-meter-sdk:$VERSION'"
```

### Step 2: Build & Publish SDK

```bash
cd /mnt/data2tb/code/water_meter/app/SDK/Water_SDK

# Build SDK
./gradlew assembleRelease

# Publish to Maven Local
chmod +x publish-to-maven-local.sh
./publish-to-maven-local.sh
```

### Step 3: Update plugin.xml

**Xóa dòng này:**
```xml
<!-- Copy SDK AAR to libs -->
<lib-file src="libs/water_meter_sdk.aar" />
```

**Plugin giờ nhẹ hơn 28MB!**

### Step 4: Update src/android/build.gradle

```gradle
ext {
    minSdkVersion = 23
    compileSdkVersion = 29
    targetSdkVersion = 29
}

repositories {
    google()
    mavenCentral()
    mavenLocal()  // ⭐ Key: Load from Maven Local
}

dependencies {
    // AndroidX
    implementation 'androidx.appcompat:appcompat:1.3.1'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.0'
    
    // Camera2
    implementation 'androidx.camera:camera-core:1.0.2'
    implementation 'androidx.camera:camera-camera2:1.0.2'
    implementation 'androidx.camera:camera-lifecycle:1.0.2'
    implementation 'androidx.camera:camera-view:1.0.0-alpha27'
    
    // ⭐ Water Meter SDK from Maven Local
    implementation 'com.eov.watermeter:water-meter-sdk:1.0.0'
}
```

### Step 5: Remove libs/ folder

```bash
cd /mnt/data2tb/code/water_meter/app/SDK/cordova-plugin-water-meter
rm -rf libs/
```

**Plugin size: 29MB → 1MB!** 🎉

### Step 6: Update documentation

**README.md:**
```markdown
## Installation

### Prerequisites

1. **Publish SDK to Maven Local (one-time setup):**

```bash
cd /path/to/water-meter-sdk
./publish-to-maven-local.sh
```

2. **Add plugin to your Cordova app:**

```bash
cordova plugin add cordova-plugin-water-meter
```

The plugin will automatically load SDK from Maven Local (~/.m2/repository/).
```

---

## 🎉 Benefits

### Before (Copy AAR):
- Plugin size: **29MB**
- 10 apps = 10 x 28MB = **280MB storage**
- Install time: **Slow** (copy 28MB each time)
- Update SDK: Remove plugin → Re-add plugin (slow!)

### After (Maven Local):
- Plugin size: **1MB** 💚
- 10 apps = **28MB total** (shared)
- Install time: **Fast** (no copy)
- Update SDK: Just publish new version → All apps get it!

---

## 📝 Summary

**Recommended approach:**

1. ✅ **Publish SDK to Maven Local once**
2. ✅ **Remove `<lib-file>` from plugin.xml**
3. ✅ **Add `mavenLocal()` to build.gradle**
4. ✅ **Reference SDK as dependency**

**Result:**
- 🚀 Plugin 28x smaller (29MB → 1MB)
- ⚡ Faster installation
- 🔄 Easy SDK updates
- 💚 No duplication across apps

---

**Want me to implement this now?** 🚀
