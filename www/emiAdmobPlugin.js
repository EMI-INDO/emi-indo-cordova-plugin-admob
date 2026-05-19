var exec = require('cordova/exec');

exports.initialize = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'initialize', [options]);
};
exports.getPersonalizationState = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'getPersonalizationState', []);
};
exports.registerWebView = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'registerWebView', []);
};
exports.loadUrl = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadUrl', [options]);
};
exports.loadAppOpenAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadAppOpenAd', [options]);
};
exports.showAppOpenAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showAppOpenAd', []);
};
exports.styleBannerAd = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'styleBannerAd', [options]);
};
exports.loadBannerAd = function (options, success, error) {
    if (!options) {
        options = {};
    }
    var isCapacitorEnvironment = typeof window.Capacitor !== 'undefined';
        var isCordova15Environment = false;
        if (!isCapacitorEnvironment && typeof cordova !== 'undefined' && cordova.platformVersion) {
            var majorVersion = parseInt(cordova.platformVersion.split('.')[0], 10);
            if (majorVersion >= 15) {
                isCordova15Environment = true;
            }
        }
        options = options || {};
        options.isCapacitor = isCapacitorEnvironment;
        options.isCordova15 = isCordova15Environment;

    // ==========================================
    // PARAMETER NORMALIZATION: COLLAPSIBLE (Legacy Support)
    // ==========================================
    var isCollapsible = false;
    
    if (options.collapsible !== undefined && options.collapsible !== null) {
        if (typeof options.collapsible === 'boolean') {
            isCollapsible = options.collapsible;
        } else if (typeof options.collapsible === 'string') {
            var colVal = options.collapsible.trim().toLowerCase();
            // Supports legacy documentation: "top", "bottom" or the string "true"
            if (colVal === "top" || colVal === "bottom" || colVal === "true") {
                isCollapsible = true;
            } else {
                isCollapsible = false;
            }
        }
    }
    options.collapsible = isCollapsible;

    // ==========================================
    // NORMALIZATION OF PARAMETERS: SIZE (Legacy Support)
    // ==========================================
    var rawSize = options.size ? String(options.size).trim().toUpperCase() : "ADAPTIVE";

    switch (rawSize) {
        case "BANNER":
            options.size = "banner";
            break;
        case "LARGE_BANNER":
            options.size = "large_banner";
            break;
        case "FULL_BANNER":
            options.size = "full_banner";
            break;
        case "LEADERBOARD":
            options.size = "leaderboard";
            break;
        case "MEDIUM_RECTANGLE":
            options.size = "medium_rectangle"; 
            break;
        case "FLUID":
            options.size = "fluid";
            break;
        // NEW Size
        case "LARGE_ANCHORED_ADAPTIVE":
            options.size = "large_anchored_adaptive";
            break;
        case "CURRENT_ORIENTATION_INLINE_ADAPTIVE":
            options.size = "current_orientation_inline_adaptive";
            break;
        case "LARGE_PORTRAIT_ANCHORED_ADAPTIVE":
            options.size = "large_portrait_anchored_adaptive";
            break;
        case "LARGE_LANDSCAPE_ANCHORED_ADAPTIVE":
            options.size = "large_landscape_anchored_adaptive";
            break;
        case "IN_LINE_ADAPTIVE":
            options.size = "in_line_adaptive";
            break;
        // Old size ADAPTIVE: Still working, build warning: 'static fun getCurrentOrientationAnchoredAdaptiveBannerAdSize(context: Context, width: Int): AdSize' is deprecated. Deprecated in Java
        case "ADAPTIVE":
        case "RESPONSIVE_ADAPTIVE":
        case "ANCHORED_ADAPTIVE":
        case "FULL_WIDTH_ADAPTIVE":
        case "FULL_WIDTH":
        default:
            options.size = "adaptive";
            break;
    }

    // ==========================================
    // PARAMETER NORMALIZATION: POSITION (Legacy Support)
    // ==========================================
    var rawPosition = options.position ? String(options.position).trim().toLowerCase() : "bottom-center";

    switch (rawPosition) {
        case "top":
        case "top-center":
        case "top_center":
        case "topcenter":
            options.position = "top-center";
            break;

        case "bottom":
        case "bottom-center":
        case "bottom_center":
        case "bottomcenter":
            options.position = "bottom-center";
            break;

        default:
            options.position = rawPosition.replace("_", "-");
            break;
    }

    exec(success, error, 'emiAdmobPlugin', 'loadBannerAd', [options]);
};
exports.loadBannerCapacitor = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'loadBannerCapacitor', [options]);
};
exports.showBannerAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'showBannerAd', []);
};
exports.hideBannerAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'hideBannerAd', []);
};
exports.removeBannerAd = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'removeBannerAd', []);
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
exports.forceDisplayPrivacyForm = function (success, error) {
    exec(success, error, 'emiAdmobPlugin', 'forceDisplayPrivacyForm', []); 
};
exports.metaData = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'metaData', [options]);
};
exports.targetingAdRequest = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'targetingAdRequest', [options]);
};
exports.setPersonalizationState = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'setPersonalizationState', [options]);
};
exports.setPPS = function (options, success, error) {
    exec(success, error, 'emiAdmobPlugin', 'setPPS', [options]);
};





