// avoid duplicate conflicts with other plugins if any, xmlns:tools="http://schemas.android.com/tools
const fs = require('fs');
const path = require('path');

module.exports = function(context) {
    const projectRoot = context.opts.projectRoot;
    const platformRoot = path.join(projectRoot, 'platforms/android');
    
    // Pass projectRoot as an additional argument to access config.xml
    patchAndroidManifest(platformRoot, projectRoot);
};

function patchAndroidManifest(platformRoot, projectRoot) {
    const manifestPath = path.join(platformRoot, 'app/src/main/AndroidManifest.xml');
    const configPath = path.join(projectRoot, 'config.xml');

    if (fs.existsSync(manifestPath)) {
        let manifest = fs.readFileSync(manifestPath, 'utf8');
        let hasChanges = false;

        // 1. Existing logic: Check if xmlns:tools exists
        if (!manifest.includes('xmlns:tools="http://schemas.android.com/tools"')) {
            // Add the tools namespace to the <manifest> tag.
            manifest = manifest.replace('<manifest', '<manifest xmlns:tools="http://schemas.android.com/tools"');
            hasChanges = true;
            // console.log('   └─ [Manifest] Added xmlns:tools to AndroidManifest.xml');
        } else {
            // console.log('   └─ [Manifest] xmlns:tools already exists, skipping...');
        }

        if (fs.existsSync(configPath)) {
            const configContent = fs.readFileSync(configPath, 'utf8');
            const variableRegex = /<variable\s+name="ADD_AD_ID"\s+value="([^"]+)"\s*\/?>/i;
            const match = configContent.match(variableRegex);

            let addAdIdValue = "false";
            if (match && match[1]) {
                addAdIdValue = match[1].toLowerCase();
            }

            // If variable is explicitly set to "true"
            if (addAdIdValue === "true") {
                const adIdPermission = '<uses-permission android:name="com.google.android.gms.permission.AD_ID" />';
                
                // Prevent duplicate injection
                if (!manifest.includes(adIdPermission)) {
                    // Inject the permission before the closing </manifest> tag
                    manifest = manifest.replace('</manifest>', `    ${adIdPermission}\n</manifest>`);
                    hasChanges = true;
                }
            }
        }
        if (hasChanges) {
            fs.writeFileSync(manifestPath, manifest, 'utf8');
        }
    }
}