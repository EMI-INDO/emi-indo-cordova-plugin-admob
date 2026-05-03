const fs = require('fs');
const path = require('path');
const plist = require('plist');

const configPath = path.join(process.cwd(), 'capacitor.config.json');
const androidPlatformPath = path.join(process.cwd(), 'android');
const iosPlatformPath = path.join(process.cwd(), 'ios');
const pluginPath = path.join(process.cwd(), 'node_modules', 'emi-indo-cordova-plugin-admob', 'plugin.xml');
const infoPlistPath = path.join(process.cwd(), 'ios', 'App', 'App', 'Info.plist');

function fileExists(filePath) {
  return fs.existsSync(filePath);
}

function getAdMobConfig() {
  if (!fileExists(configPath)) {
    throw new Error('capacitor.config.json not found. Ensure this is a Capacitor project.');
  }

  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const admobConfig = config.plugins?.AdMob;

  if (!admobConfig || !admobConfig.APP_ID_ANDROID || !admobConfig.APP_ID_IOS) {
    throw new Error('AdMob configuration is missing in capacitor.config.json. Ensure APP_ID_ANDROID and APP_ID_IOS are defined.');
  }

  return {
    APP_ID_ANDROID: admobConfig.APP_ID_ANDROID,
    APP_ID_IOS: admobConfig.APP_ID_IOS,
    USE_LITE_ADS: admobConfig.USE_LITE_ADS === "lite",
  };
}

function updatePluginXml(admobConfig) {
  if (!fileExists(pluginPath)) {
    console.error('plugin.xml not found. Ensure the plugin is installed.');
    return;
  }

  let pluginContent = fs.readFileSync(pluginPath, 'utf8');

  pluginContent = pluginContent
    .replace(/<preference name="APP_ID_ANDROID" default=".*?" \/>/, `<preference name="APP_ID_ANDROID" default="${admobConfig.APP_ID_ANDROID}" />`)
    .replace(/<preference name="APP_ID_IOS" default=".*?" \/>/, `<preference name="APP_ID_IOS" default="${admobConfig.APP_ID_IOS}" />`);

  if (admobConfig.USE_LITE_ADS) {
    pluginContent = pluginContent.replace(
      /<framework src="com.google.android.gms:play-services-ads:.*?" \/>/,
      `<framework src="com.google.android.gms:play-services-ads-lite:$PLAY_SERVICES_VERSION" />`
    );
  } else {
    pluginContent = pluginContent.replace(
      /<framework src="com.google.android.gms:play-services-ads-lite:.*?" \/>/,
      `<framework src="com.google.android.gms:play-services-ads:$PLAY_SERVICES_VERSION" />`
    );
  }

  fs.writeFileSync(pluginPath, pluginContent, 'utf8');
  console.log('AdMob IDs and framework dependency successfully updated in plugin.xml');
}

// Fixed Capacitor's forgotten XML namespace
function fixAndroidManifestNamespaces() {
  const manifestPaths = [
    path.join(process.cwd(), 'android', 'capacitor-cordova-android-plugins', 'src', 'main', 'AndroidManifest.xml'),
    path.join(process.cwd(), 'android', 'app', 'src', 'main', 'AndroidManifest.xml')
  ];

  manifestPaths.forEach(manifestPath => {
    if (fileExists(manifestPath)) {
      let xmlContent = fs.readFileSync(manifestPath, 'utf8');
      let needsWrite = false;

      if (xmlContent.includes('tools:') && !xmlContent.includes('xmlns:tools')) {
        xmlContent = xmlContent.replace('<manifest', '<manifest xmlns:tools="http://schemas.android.com/tools"');
        needsWrite = true;
      }
      
      if (xmlContent.includes('app:') && !xmlContent.includes('xmlns:app')) {
        xmlContent = xmlContent.replace('<manifest', '<manifest xmlns:app="http://schemas.android.com/apk/res-auto"');
        needsWrite = true;
      }

      if (needsWrite) {
        fs.writeFileSync(manifestPath, xmlContent, 'utf8');
        //console.log(`Auto-healed XML namespaces in ${path.basename(manifestPath)}`);
      }
    }
  });
}

function updateInfoPlist(admobConfig) {
  if (!fileExists(infoPlistPath)) {
    console.error('Info.plist not found. Ensure you have built the iOS project.');
    return;
  }

  const plistContent = fs.readFileSync(infoPlistPath, 'utf8');
  const plistData = plist.parse(plistContent);

  plistData.GADApplicationIdentifier = admobConfig.APP_ID_IOS;
  plistData.NSUserTrackingUsageDescription = 'This identifier will be used to deliver personalized ads to you.';
  plistData.GADDelayAppMeasurementInit = true;

  // https://developers.google.com/admob/ios/quick-start
  plistData.SKAdNetworkItems = [
    { SKAdNetworkIdentifier: 'cstr6suwn9.skadnetwork' },
    { SKAdNetworkIdentifier: '4fzdc2evr5.skadnetwork' },
    { SKAdNetworkIdentifier: '2fnua5tdw4.skadnetwork' },
    { SKAdNetworkIdentifier: 'ydx93a7ass.skadnetwork' },
    { SKAdNetworkIdentifier: 'p78axxw29g.skadnetwork' },
    { SKAdNetworkIdentifier: 'v72qych5uu.skadnetwork' },
    { SKAdNetworkIdentifier: 'ludvb6z3bs.skadnetwork' },
    { SKAdNetworkIdentifier: 'cp8zw746q7.skadnetwork' },
    { SKAdNetworkIdentifier: '3sh42y64q3.skadnetwork' },
    { SKAdNetworkIdentifier: 'c6k4g5qg8m.skadnetwork' },
    { SKAdNetworkIdentifier: 's39g8k73mm.skadnetwork' },
    { SKAdNetworkIdentifier: 'wg4vff78zm.skadnetwork' },
    { SKAdNetworkIdentifier: '3qy4746246.skadnetwork' },
    { SKAdNetworkIdentifier: 'f38h382jlk.skadnetwork' },
    { SKAdNetworkIdentifier: 'hs6bdukanm.skadnetwork' },
    { SKAdNetworkIdentifier: 'mlmmfzh3r3.skadnetwork' },
    { SKAdNetworkIdentifier: 'v4nxqhlyqp.skadnetwork' },
    { SKAdNetworkIdentifier: 'wzmmz9fp6w.skadnetwork' },
    { SKAdNetworkIdentifier: 'su67r6k2v3.skadnetwork' },
    { SKAdNetworkIdentifier: 'yclnxrl5pm.skadnetwork' },
    { SKAdNetworkIdentifier: 't38b2kh725.skadnetwork' },
    { SKAdNetworkIdentifier: '7ug5zh24hu.skadnetwork' },
    { SKAdNetworkIdentifier: 'gta9lk7p23.skadnetwork' },
    { SKAdNetworkIdentifier: 'vutu7akeur.skadnetwork' },
    { SKAdNetworkIdentifier: 'y5ghdn5j9k.skadnetwork' },
    { SKAdNetworkIdentifier: 'v9wttpbfk9.skadnetwork' },
    { SKAdNetworkIdentifier: 'n38lu8286q.skadnetwork' },
    { SKAdNetworkIdentifier: '47vhws6wlr.skadnetwork' },
    { SKAdNetworkIdentifier: 'kbd757ywx3.skadnetwork' },
    { SKAdNetworkIdentifier: '9t245vhmpl.skadnetwork' },
    { SKAdNetworkIdentifier: 'a2p9lx4jpn.skadnetwork' },
    { SKAdNetworkIdentifier: '22mmun2rn5.skadnetwork' },
    { SKAdNetworkIdentifier: '44jx6755aq.skadnetwork' },
    { SKAdNetworkIdentifier: 'k674qkevps.skadnetwork' },
    { SKAdNetworkIdentifier: '4468km3ulz.skadnetwork' },
    { SKAdNetworkIdentifier: '2u9pt9hc89.skadnetwork' },
    { SKAdNetworkIdentifier: '8s468mfl3y.skadnetwork' },
    { SKAdNetworkIdentifier: 'klf5c3l5u5.skadnetwork' },
    { SKAdNetworkIdentifier: 'ppxm28t8ap.skadnetwork' },
    { SKAdNetworkIdentifier: 'kbmxgpxpgc.skadnetwork' },
    { SKAdNetworkIdentifier: 'uw77j35x4d.skadnetwork' },
    { SKAdNetworkIdentifier: '578prtvx9j.skadnetwork' },
    { SKAdNetworkIdentifier: '4dzt52r2t5.skadnetwork' },
    { SKAdNetworkIdentifier: 'tl55sbb4fm.skadnetwork' },
    { SKAdNetworkIdentifier: 'c3frkrj4fj.skadnetwork' },
    { SKAdNetworkIdentifier: 'e5fvkxwrpn.skadnetwork' },
    { SKAdNetworkIdentifier: '8c4e2ghe7u.skadnetwork' },
    { SKAdNetworkIdentifier: '3rd42ekr43.skadnetwork' },
    { SKAdNetworkIdentifier: '97r2b46745.skadnetwork' },
    { SKAdNetworkIdentifier: '3qcr597p9d.skadnetwork' }
  ];

  const updatedPlistContent = plist.build(plistData);
  fs.writeFileSync(infoPlistPath, updatedPlistContent, 'utf8');
  console.log('AdMob IDs and additional configurations successfully updated in Info.plist');
}

try {
  if (!fileExists(configPath)) {
    throw new Error('capacitor.config.json not found. Skipping setup.');
  }

  if (!fileExists(androidPlatformPath) && !fileExists(iosPlatformPath)) {
    throw new Error('Neither Android nor iOS platforms are found. Ensure platforms are added to your Capacitor project.');
  }

  const admobConfig = getAdMobConfig();

  if (fileExists(androidPlatformPath)) {
    updatePluginXml(admobConfig);
    fixAndroidManifestNamespaces();
  }

  if (fileExists(iosPlatformPath)) {
    updateInfoPlist(admobConfig);
  }
} catch (error) {
  console.error(error.message);
}


  
  