var exec = require('cordova/exec');
exports.initialize = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'initialize', []);
};
exports.getIabTfc = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'getIabTfc', []);
};
exports.showPrivacyOptionsForm = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showPrivacyOptionsForm', []);
};
exports.loadAppOpenAd = function (arg0, arg1, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadAppOpenAd', arg0, arg1);
};
exports.showAppOpenAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showAppOpenAd', []);
};
exports.loadBannerAd = function (arg0, arg1, arg2, arg3, arg4, arg5, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadBannerAd', arg0, arg1, arg2, arg3, arg4, arg5);
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
exports.loadInterstitialAd = function (arg0, arg1, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadInterstitialAd', arg0, arg1);
};
exports.showInterstitialAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showInterstitialAd', []);
};
exports.loadRewardedAd = function (arg0, arg1, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedAd', arg0, arg1);
};
exports.showRewardedAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedAd', []);
};
exports.loadRewardedInterstitialAd = function (arg0, arg1, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedInterstitialAd', arg0, arg1);
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
exports.targeting = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'targeting', arg0, arg1, arg2);
};
exports.globalSettings = function (arg0, arg1, arg2, arg3, arg4, arg5, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'globalSettings', arg0, arg1, arg2, arg3, arg4, arg5);
};