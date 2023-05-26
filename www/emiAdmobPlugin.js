var exec = require('cordova/exec');

exports.initialize = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'initialize', [arg0]);
};

exports.loadAppOpenAd = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadAppOpenAd', [arg0, arg1, arg2]);
};

exports.showAppOpenAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showAppOpenAd', [arg0]);
};

exports.showBannerAd = function (arg0, arg1, arg2, arg3, arg4, arg5, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showBannerAd', [arg0, arg1, arg2, arg3, arg4, arg5]);
};

exports.removeBannerAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'removeBannerAd', [arg0]);
};

exports.loadInterstitialAd = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadInterstitialAd', [arg0, arg1, arg2]);
};

exports.showInterstitialAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showInterstitialAd', [arg0]);
};

exports.loadRewardedAd = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedAd', [arg0, arg1, arg2]);
};

exports.showRewardedAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedAd', [arg0]);
};

exports.loadRewardedInterstitialAd = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedInterstitialAd', [arg0, arg1, arg2]);
};

exports.showRewardedInterstitialAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedInterstitialAd', [arg0]);
};

exports.getConsentRequest = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'getConsentRequest', [arg0]);
};

exports.consentReset = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'consentReset', [arg0]);
};

exports.targeting = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'targeting', [arg0, arg1, arg2]);
};

exports.globalSettings = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'globalSettings', [arg0, arg1, arg2]);
};