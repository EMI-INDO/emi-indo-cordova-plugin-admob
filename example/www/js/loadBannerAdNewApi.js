

/*

Do not use 
cordova.plugins.emiAdmobPlugin.loadBannerAd 
and 
cordova.plugins.emiAdmobPlugin.styleBannerAd

Everything is in hand automatically, including whether it is currently in full-screen mode or not.

*/

// Android only BETA
function loadBannerNewApi() {

    if (typeof cordova !== 'undefined') {

        cordova.plugins.emiAdmobPlugin.loadBannerAdNewApi({
            adUnitId: Banner_ID, //Banner_ID,
            position: "bottom-center", // "Recommended: bottom-center"
            size: "banner", // autoResize: true (only responsive_adaptive)large_banner
            collapsible: "", // position: top | bottom (disable, empty string)
            autoShow: true, // default false
            overlapping: false // default false
        });

    }


}