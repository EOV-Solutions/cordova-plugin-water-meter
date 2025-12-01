/**
 * iOS Build Settings Hook
 * Sets required build settings for WaterMeterSDK
 */

module.exports = function(context) {
    const fs = require('fs');
    const path = require('path');
    
    // Try to require xcode module the modern way
    let xcode;
    try {
        xcode = require('xcode');
    } catch (e) {
        // Fallback to old method
        try {
            xcode = context.requireCordovaModule('xcode');
        } catch (e2) {
            console.log('⚠️ Could not load xcode module, skipping build settings hook');
            return;
        }
    }
    
    const platforms = context.opts.platforms || [];
    
    if (!platforms.includes('ios')) {
        return;
    }
    
    const projectRoot = context.opts.projectRoot;
    const platformPath = path.join(projectRoot, 'platforms', 'ios');
    
    // Check if platform exists
    if (!fs.existsSync(platformPath)) {
        console.log('iOS platform not found, skipping');
        return;
    }
    
    // Find xcodeproj
    const files = fs.readdirSync(platformPath);
    const xcodeproj = files.find(f => f.endsWith('.xcodeproj'));
    
    if (!xcodeproj) {
        console.log('No Xcode project found');
        return;
    }
    
    const pbxprojPath = path.join(platformPath, xcodeproj, 'project.pbxproj');
    
    if (!fs.existsSync(pbxprojPath)) {
        console.log('project.pbxproj not found');
        return;
    }
    
    const project = xcode.project(pbxprojPath);
    
    try {
        project.parseSync();
    } catch (e) {
        console.log('Failed to parse Xcode project:', e.message);
        return;
    }
    
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
    const configs = project.pbxXCBuildConfigurationSection();
    for (const configName of Object.keys(configs)) {
        const config = configs[configName];
        if (config && config.buildSettings) {
            Object.assign(config.buildSettings, buildSettings);
        }
    }
    
    fs.writeFileSync(pbxprojPath, project.writeSync());
    
    console.log('✅ iOS build settings configured for WaterMeterSDK');
};
