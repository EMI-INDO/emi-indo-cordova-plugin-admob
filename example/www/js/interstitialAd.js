


let isInterstitialLoad = false;

function loadInterstitial() {

    if (typeof cordova !== 'undefined') {

        cordova.plugins.emiAdmobPlugin.loadInterstitialAd({ adUnitId: Interstitial_ID, autoShow: false });

    }
}

function showInterstitial() {

    if (typeof cordova !== 'undefined') {
        
        if (isInterstitialLoad) {
            cordova.plugins.emiAdmobPlugin.showInterstitialAd();
        }
    }

}

/*

on.interstitial.loaded
on.interstitial.failed.load
on.interstitial.click
on.interstitial.dismissed
on.interstitial.failed.show
on.interstitial.impression
on.interstitial.show

// New event plugin v1.5.5 or higher

on.interstitial.revenue
on.interstitialAd.responseInfo

*/


// EVENT For example

document.addEventListener('on.interstitial.loaded', () => {
    isInterstitialLoad = true;
    console.log("on interstitial Ad loaded");
    
    window.log.value += ("\n on interstitial Ad loaded");
});


// all events that contain the keyword dismissed there is a block to load the ad after it is closed by the user.
document.addEventListener('on.interstitial.dismissed', () => {
    isInterstitialLoad = false;
    console.log("on interstitial Ad dismissed");
    console.log("you can load ads automatically after the ads are closed by users");
    
    loadInterstitial();
    
    window.log.value += ("\n you can load ads automatically after the ads are closed by users");

});


document.addEventListener('on.interstitial.failed.load', (error) => {
    isInterstitialLoad = false;
    console.log("on.interstitial.failed.load" + JSON.stringify(error));

    /*
    error.code
    error.message
    error.domain
    error.responseInfoId
    error.responseInfoExtras
    error.responseInfoAdapter
    error.responseInfoMediationAdapterClassName
    error.responseInfoAdapterResponses
*/
    
    window.log.value += ("\n on.interstitial.failed.load" + JSON.stringify(error));
});


document.addEventListener('on.interstitial.failed.show', (error) => {
    isInterstitialLoad = false;
    console.log("on.interstitial.failed.show" + JSON.stringify(error));
    
    window.log.value += ("\n on.interstitial.failed.show" + JSON.stringify(error));
});


/*
// DEBUG
// isResponseInfo: true, // debug Default false
document.addEventListener('on.interstitialAd.responseInfo', (data) => {

    console.log("on.interstitialAd.responseInfo" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.interstitialAd.responseInfo" + JSON.stringify(data));
});

*/







/*
https://support.google.com/admob/answer/11322405

Turn on the setting for impression-level ad revenue in your AdMob account:
Sign in to your AdMob account at https://apps.admob.com.
Click Settings in the sidebar.
Click the Account tab.
In the Account controls section, click the Impression-level ad revenue toggle to turn on this setting.
*/

document.addEventListener('on.interstitial.revenue', (data) => {

    console.log(data.value)
    console.log(data.currencyCode)
    console.log(data.precision)
    console.log(data.adUnitId)

   // console.log("on.interstitial.revenue" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.interstitial.revenue" + JSON.stringify(data));
});



