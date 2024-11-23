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

  fs.writeFileSync(pluginPath, pluginContent, 'utf8');
  console.log('AdMob IDs successfully updated in plugin.xml');
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
    { SKAdNetworkIdentifier: 'cstr6suwn9.skadnetwork' }, // Google
    { SKAdNetworkIdentifier: '4fzdc2evr5.skadnetwork' }, // Aarki
    { SKAdNetworkIdentifier: '2fnua5tdw4.skadnetwork' }, // Adform
    { SKAdNetworkIdentifier: 'ydx93a7ass.skadnetwork' }, // Adikteev
    { SKAdNetworkIdentifier: 'p78axxw29g.skadnetwork' }, // Amazon
    { SKAdNetworkIdentifier: 'v72qych5uu.skadnetwork' }, // Appier
    { SKAdNetworkIdentifier: 'ludvb6z3bs.skadnetwork' }, // Applovin
    { SKAdNetworkIdentifier: 'cp8zw746q7.skadnetwork' }, // Arpeely
    { SKAdNetworkIdentifier: '3sh42y64q3.skadnetwork' }, // Basis
    { SKAdNetworkIdentifier: 'c6k4g5qg8m.skadnetwork' }, // Beeswax.io
    { SKAdNetworkIdentifier: 's39g8k73mm.skadnetwork' }, // Bidease
    { SKAdNetworkIdentifier: '3qy4746246.skadnetwork' }, // Bigabid
    { SKAdNetworkIdentifier: 'hs6bdukanm.skadnetwork' }, // Criteo
    { SKAdNetworkIdentifier: 'mlmmfzh3r3.skadnetwork' }, // Digital Turbine DSP
    { SKAdNetworkIdentifier: 'v4nxqhlyqp.skadnetwork' }, // i-mobile
    { SKAdNetworkIdentifier: 'wzmmz9fp6w.skadnetwork' }, // InMobi
    { SKAdNetworkIdentifier: 'su67r6k2v3.skadnetwork' }, // ironSource Ads
    { SKAdNetworkIdentifier: 'yclnxrl5pm.skadnetwork' }, // Jampp
    { SKAdNetworkIdentifier: '7ug5zh24hu.skadnetwork' }, // Liftoff
    { SKAdNetworkIdentifier: 'gta9lk7p23.skadnetwork' }, // Liftoff Monetize
    { SKAdNetworkIdentifier: 'vutu7akeur.skadnetwork' }, // LINE
    { SKAdNetworkIdentifier: 'y5ghdn5j9k.skadnetwork' }, // Mediaforce
    { SKAdNetworkIdentifier: 'v9wttpbfk9.skadnetwork' }, // Meta (1 of 2)
    { SKAdNetworkIdentifier: 'n38lu8286q.skadnetwork' }, // Meta (2 of 2)
    { SKAdNetworkIdentifier: '47vhws6wlr.skadnetwork' }, // MicroAd
    { SKAdNetworkIdentifier: 'kbd757ywx3.skadnetwork' }, // Mintegral / Mobvista
    { SKAdNetworkIdentifier: '9t245vhmpl.skadnetwork' }, // Moloco
    { SKAdNetworkIdentifier: 'a2p9lx4jpn.skadnetwork' }, // Opera
    { SKAdNetworkIdentifier: '22mmun2rn5.skadnetwork' }, // Pangle
    { SKAdNetworkIdentifier: '4468km3ulz.skadnetwork' }, // Realtime Technologies GmbH
    { SKAdNetworkIdentifier: '2u9pt9hc89.skadnetwork' }, // Remerge
    { SKAdNetworkIdentifier: '8s468mfl3y.skadnetwork' }, // RTB House
    { SKAdNetworkIdentifier: 'ppxm28t8ap.skadnetwork' }, // Smadex
    { SKAdNetworkIdentifier: 'uw77j35x4d.skadnetwork' }, // The Trade Desk
    { SKAdNetworkIdentifier: 'pwa73g5rt2.skadnetwork' }, // Tremor
    { SKAdNetworkIdentifier: '578prtvx9j.skadnetwork' }, // Unicorn
    { SKAdNetworkIdentifier: '4dzt52r2t5.skadnetwork' }, // Unity Ads
    { SKAdNetworkIdentifier: 'tl55sbb4fm.skadnetwork' }, // Verve
    { SKAdNetworkIdentifier: 'e5fvkxwrpn.skadnetwork' }, // Yahoo!
    { SKAdNetworkIdentifier: '8c4e2ghe7u.skadnetwork' }, // Yahoo! Japan Ads
    { SKAdNetworkIdentifier: '3rd42ekr43.skadnetwork' }, // YouAppi
    { SKAdNetworkIdentifier: '3qcr597p9d.skadnetwork' }, // Zucks
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
  }


  if (fileExists(iosPlatformPath)) {
    updateInfoPlist(admobConfig);
  }
} catch (error) {
  console.error(error.message);
}
