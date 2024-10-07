
var exec = require('cordova/exec');

exports.initialize = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'initialize', [options]);
};
exports.loadAppOpenAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadAppOpenAd', [options]);
};
exports.showAppOpenAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showAppOpenAd', []);
};
exports.styleBannerAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'styleBannerAd', [options]); // v1.4.9
};
exports.loadBannerAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadBannerAd', [options]);
};
exports.showBannerAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showBannerAd', []);
};
exports.hideBannerAd = function (success, error) {
        exec(success, error, 'emiAdmobPlugin', 'hideBannerAd', []);
};
exports.removeBannerAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'removeBannerAd', [arg0]);
};
exports.loadInterstitialAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadInterstitialAd', [options]);
};
exports.showInterstitialAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showInterstitialAd', []);
};
exports.loadRewardedAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedAd', [options]);
};
exports.showRewardedAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedAd', []);
};
exports.loadRewardedInterstitialAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedInterstitialAd', [options]);
};
exports.showRewardedInterstitialAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedInterstitialAd', []);
};
exports.requestIDFA = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'requestIDFA', []);
};
exports.getConsentRequest = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'getConsentRequest', []);
};
exports.consentReset = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'consentReset', []);
};
exports.targeting = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'targeting', [options]);
};
exports.getIabTfc = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'getIabTfc', []);
};
exports.showPrivacyOptionsForm = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showPrivacyOptionsForm', []);
};
exports.globalSettings = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'globalSettings', [options]);
};


// v1.4.9
// only isUsingAdManagerRequest: true
// AdManagerAdRequest.Builder
exports.targetingAdRequest = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'targetingAdRequest', [options]);
};
exports.setPersonalizationState = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'setPersonalizationState', [options]);
};
exports.setPPS = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'setPPS', [options]);
};




