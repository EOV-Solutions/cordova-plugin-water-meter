/**
 * iOS Build Settings Hook
 * Sets required build settings for WaterMeterSDK
 */

module.exports = function(context) {
    const fs = require('fs');
    const path = require('path');
    
    const xcode = context.requireCordovaModule('xcode');
    const platforms = context.opts.platforms;
    
    if (!platforms.includes('ios')) {
        return;
    }
    
    const projectRoot = context.opts.projectRoot;
    const platformPath = path.join(projectRoot, 'platforms', 'ios');
    
    // Find xcodeproj
    const files = fs.readdirSync(platformPath);
    const xcodeproj = files.find(f => f.endsWith('.xcodeproj'));
    
    if (!xcodeproj) {
        console.log('No Xcode project found');
        return;
    }
    
    const pbxprojPath = path.join(platformPath, xcodeproj, 'project.pbxproj');
    const project = xcode.project(pbxprojPath);
    
    project.parseSync();
    
    // Build settings for C++17 and ARM NEON
    const buildSettings = {
        'CLANG_CXX_LANGUAGE_STANDARD': 'c++17',
        'CLANG_CXX_LIBRARY': 'libc++',
        'GCC_PREPROCESSOR_DEFINITIONS': '$(inherited) ARM_NEON=1',
        'ENABLE_BITCODE': 'NO',
        'IPHONEOS_DEPLOYMENT_TARGET': '13.0',
        'SWIFT_VERSION': '5.0',
        'OTHER_LDFLAGS': '$(inherited) -ObjC',
    };
    
    // Apply to all build configurations
    for (const configName of Object.keys(project.pbxXCBuildConfigurationSection())) {
        const config = project.pbxXCBuildConfigurationSection()[configName];
        if (config && config.buildSettings) {
            Object.assign(config.buildSettings, buildSettings);
        }
    }
    
    fs.writeFileSync(pbxprojPath, project.writeSync());
    
    console.log('✅ iOS build settings configured for WaterMeterSDK');
};
