const fs = require('fs');
const path = require('path');

module.exports = function(context) {
    const platformRoot = path.join(context.opts.projectRoot, 'platforms/android');

    // 1. (Manifest Namespace)
    patchAndroidManifest(platformRoot);

    // 2. Force Kotlin 2.1.0 build.gradle
    patchRootBuildGradle(platformRoot);
    
    console.log('✅ [EMI-AdMob] Pre-Build Hooks Configuration Complete!');
};

function patchAndroidManifest(platformRoot) {
    const manifestPath = path.join(platformRoot, 'app/src/main/AndroidManifest.xml');

    if (fs.existsSync(manifestPath)) {
        let manifest = fs.readFileSync(manifestPath, 'utf8');

        // Check if xmlns:tools exists
        if (!manifest.includes('xmlns:tools="http://schemas.android.com/tools"')) {
            // Add the tools namespace to the <manifest> tag.
            manifest = manifest.replace('<manifest', '<manifest xmlns:tools="http://schemas.android.com/tools"');
            fs.writeFileSync(manifestPath, manifest, 'utf8');
            console.log('   └─ [Manifest] Added xmlns:tools to AndroidManifest.xml');
        } else {
            // console.log('   └─ [Manifest] xmlns:tools already exists, skipping...');
        }
    }
}

function patchRootBuildGradle(platformRoot) {
    const buildGradlePath = path.join(platformRoot, 'build.gradle');

    if (fs.existsSync(buildGradlePath)) {
        let buildGradle = fs.readFileSync(buildGradlePath, 'utf8');

        const kotlinPattern = /classpath\s+["']org\.jetbrains\.kotlin:kotlin-gradle-plugin:.*?["']/g;
        
        const newKotlinLine = 'classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0"';

        if (buildGradle.match(kotlinPattern)) {
            if (!buildGradle.includes(newKotlinLine)) {
                buildGradle = buildGradle.replace(kotlinPattern, newKotlinLine);
                fs.writeFileSync(buildGradlePath, buildGradle, 'utf8');
                console.log('   └─ [Build.gradle] FORCED Kotlin Gradle Plugin to 2.1.0');
            } else {
                // console.log('   └─ [Build.gradle] Kotlin version is already set to 2.1.0');
            }
        }
    }
}