var exec = require('cordova/exec');


exports.adsinitialize = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'adsinitialize', [arg0]);
};

exports.loadInterstitialAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadInterstitialAd', [arg0]);
};

exports.showInterstitialAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showInterstitialAd', [arg0]);
};

exports.loadRewardedAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedAd', [arg0]);
};

exports.showRewardedAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showRewardedAd', [arg0]);
};

exports.loadRewardedInterstitialAd = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadRewardedInterstitialAd', [arg0]);
};

exports.showBanner = function (arg0, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showBanner', [arg0]);
};