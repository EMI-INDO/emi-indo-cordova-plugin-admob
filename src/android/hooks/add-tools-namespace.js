const fs = require('fs');
const path = require('path');

// To avoid this conflict with https://github.com/dpa99c/cordova-plugin-firebasex/blob/master/plugin.xml but still ensure xmlns:tools is present in AndroidManifest.xml

module.exports = function(context) {
    const platformRoot = path.join(context.opts.projectRoot, 'platforms/android');
    const manifestPath = path.join(platformRoot, 'app/src/main/AndroidManifest.xml');

    if (fs.existsSync(manifestPath)) {
        let manifest = fs.readFileSync(manifestPath, 'utf8');

        // Check if xmlns:tools exists
        if (!manifest.includes('xmlns:tools="http://schemas.android.com/tools"')) {
            // Add the tools namespace to the <manifest> tag.
            manifest = manifest.replace('<manifest', '<manifest xmlns:tools="http://schemas.android.com/tools"');
            fs.writeFileSync(manifestPath, manifest, 'utf8');
            console.log('EMI-ADMob: Added xmlns:tools to AndroidManifest.xml');
        } else {
            console.log('EMI-ADMob: xmlns:tools already exists, skipping...');
        }
    }
};