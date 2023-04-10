var exec = require('cordova/exec');

exports.initialize = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'initialize', [arg0]);
};

exports.showBannerAd = function (arg0, arg1, arg2, arg3, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showBannerAd', [arg0, arg1, arg2, arg3]);
};

exports.removeBannerAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'removeBannerAd', [arg0]);
};

exports.loadInterstitialAd = function (arg0, arg1, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadInterstitialAd', [arg0, arg1]);
};

exports.showInterstitialAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showInterstitialAd', [arg0]);
};

exports.loadRewardedAd = function (arg0, arg1, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedAd', [arg0, arg1]);
};

exports.showRewardedAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedAd', [arg0]);
};

exports.loadRewardedInterstitialAd = function (arg0, arg1, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedInterstitialAd', [arg0, arg1]);
};

exports.showRewardedInterstitialAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedInterstitialAd', [arg0]);
};