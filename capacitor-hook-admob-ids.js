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

  const updatedPlistContent = plist.build(plistData);
  fs.writeFileSync(infoPlistPath, updatedPlistContent, 'utf8');
  console.log('AdMob IDs successfully updated in Info.plist');
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
