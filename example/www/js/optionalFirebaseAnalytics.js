
// NOTE
// This is not a dependency, it's a separate plugin but highly recommended.
// https://github.com/EMI-INDO/emi-indo-cordova-plugin-fanalytics

// Just one example, for example Interstitial ads, the others just adjust it

// https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/www/js/interstitialAd.js

let isInterstitialLoadAd = false;

function loadInterstitialAd() {

    if (typeof cordova !== 'undefined') {

        cordova.plugins.emiAdmobPlugin.loadInterstitialAd({ adUnitId: Interstitial_ID, autoShow: false });

    }
}



function showInterstitialAd() {

    if (typeof cordova !== 'undefined') {
        
        if (isInterstitialLoadAd) {
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




let interstitialErrMsg = "";

const adEventData = {
// NOTE:   no spaces, underline is recommended _ 
on_interstitial_loaded: "on_interstitial_loaded",
on_interstitial_failed_load: interstitialErrMsg,
on_interstitial_click: "on_interstitial_click",
on_interstitial_dismissed: "on_interstitial_dismissed",
on_interstitial_failed_show: "on_interstitial_failed_show",
on_interstitial_impression: "on_interstitial_impression",
on_interstitial_show: "on_interstitial_show",
on_interstitial_revenue: "on_interstitial_revenue"

}


// EVENT For example

document.addEventListener('on.interstitial.loaded', () => {
    isInterstitialLoadAd = true;
    console.log("on interstitial Ad loaded");

    if (typeof cordova !== 'undefined') {

        cordova.plugins.EmiFirebaseAnalyticsPlugin.logEvent({ name: "interstitial_Ad", params: adEventData.on_interstitial_loaded });

    }
  
});


// all events that contain the keyword dismissed there is a block to load the ad after it is closed by the user.
document.addEventListener('on.interstitial.dismissed', () => {
    isInterstitialLoadAd = false;
    console.log("on interstitial Ad dismissed");
    console.log("you can load ads automatically after the ads are closed by users");
    
    loadInterstitialAd();
    
    if (typeof cordova !== 'undefined') {

        cordova.plugins.EmiFirebaseAnalyticsPlugin.logEvent({ name: "interstitial_Ad", params: adEventData.on_interstitial_dismissed });

    }

});


document.addEventListener('on.interstitial.failed.load', (error) => {
    isInterstitialLoadAd = false;
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

    interstitialErrMsg = error.message;
    
if (typeof cordova !== 'undefined') {

    cordova.plugins.EmiFirebaseAnalyticsPlugin.logEvent({ name: "interstitial_Ad", params: adEventData.on_interstitial_failed_load });

}


});


document.addEventListener('on.interstitial.failed.show', (error) => {
    isInterstitialLoadAd = false;
    console.log("on.interstitial.failed.show" + JSON.stringify(error));
    
   
    if (typeof cordova !== 'undefined') {

        cordova.plugins.EmiFirebaseAnalyticsPlugin.logEvent({ name: "interstitial_Ad", params: adEventData.on_interstitial_failed_show });
    
    }


});





/*
https://support.google.com/admob/answer/11322405

Turn on the setting for impression-level ad revenue in your AdMob account:
Sign in to your AdMob account at https://apps.admob.com.
Click Settings in the sidebar.
Click the Account tab.
In the Account controls section, click the Impression-level ad revenue toggle to turn on this setting.
*/

document.addEventListener('on.interstitial.revenue', (data) => {

    let adRevenuePaid = { 
        value: data.value,
        currencyCode: data.currencyCode,
        precision: data.precision,
        adUnitId: data.adUnitId
    }

    if (typeof cordova !== 'undefined') {
  
        cordova.plugins.EmiFirebaseAnalyticsPlugin.setAdMobRevenuePaid({ data: adRevenuePaid });

        cordova.plugins.EmiFirebaseAnalyticsPlugin.logEvent({ name: "interstitial_Ad", params: adEventData.on_interstitial_revenue });
  
    }

});