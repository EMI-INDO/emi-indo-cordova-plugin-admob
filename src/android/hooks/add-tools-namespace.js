// avoid duplicate conflicts with other plugins if any, xmlns:tools="http://schemas.android.com/tools
const fs = require('fs');
const path = require('path');

module.exports = function(context) {
    const projectRoot = context.opts.projectRoot;
    const platformRoot = path.join(projectRoot, 'platforms/android');
    
    patchAndroidManifest(platformRoot, projectRoot);
};

function patchAndroidManifest(platformRoot, projectRoot) {
    const manifestPath = path.join(platformRoot, 'app/src/main/AndroidManifest.xml');
    const configPath = path.join(projectRoot, 'config.xml');

    if (!fs.existsSync(manifestPath)) {
        return;
    }

    let manifest = fs.readFileSync(manifestPath, 'utf8');
    let hasChanges = false;

    // 1. Check and inject xmlns:tools
    if (!manifest.includes('xmlns:tools="http://schemas.android.com/tools"')) {
        manifest = manifest.replace('<manifest', '<manifest xmlns:tools="http://schemas.android.com/tools"');
        hasChanges = true;
    }

    // 2. Strict validation for ADD_AD_ID
    if (fs.existsSync(configPath)) {
        const configContent = fs.readFileSync(configPath, 'utf8');
        const requiresAdId = configContent.includes('<variable name="ADD_AD_ID" value="true"');
        
        if (requiresAdId) {
           // console.log('EMI-INDO-ADMOB: Variable ADD_AD_ID=true detected. Injecting AD_ID permission.');
            const adIdPermission = '<uses-permission android:name="com.google.android.gms.permission.AD_ID" />';
            
            if (!manifest.includes(adIdPermission)) {
                manifest = manifest.replace('</manifest>', `    ${adIdPermission}\n</manifest>`);
                hasChanges = true;
            }
        } else {
          //  console.log('EMI-INDO-ADMOB: Variable ADD_AD_ID is false or missing. Skipping AD_ID injection.');
        }
    }
    if (hasChanges) {
        fs.writeFileSync(manifestPath, manifest, 'utf8');
    }
}