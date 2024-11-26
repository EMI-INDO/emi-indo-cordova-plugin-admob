

/*

Best practices
App open ads help you monetize your app's loading screen, when the app first launches and during app switches, 
but it's important to keep best practices in mind so that your users enjoy using your app. It's best to:

Show your first app open ad after your users have used your app a few times.
Show app open ads during times when your users would otherwise be waiting for your app to load.
If you have a loading screen under the app open ad, 
and your loading screen completes loading before the ad is dismissed, 
you may want to dismiss your loading screen in the on.appOpenAd.dismissed method.

*/








let isAppOpenAdLoad = false;

function loadAppOpen() {

    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.loadAppOpenAd({ adUnitId: App_Open_ID, autoShow: true });
    }

}


/*
function showAppOpen() {

    if (typeof cordova !== 'undefined') {
        if (isAppOpenAdLoad) {
            cordova.plugins.emiAdmobPlugin.showAppOpenAd();
        }
    }

}

*/


/*
on.appOpenAd.loaded
 on.appOpenAd.failed.loaded
 on.appOpenAd.dismissed
 on.appOpenAd.failed.show
 on.appOpenAd.show

 // New event plugin v1.5.5 or higher

on.appOpenAd.revenue
on.appOpenAd.responseInfo


*/


document.addEventListener('on.appOpenAd.loaded', () => {
    isAppOpenAdLoad = true;
    console.log("on.appOpenAd.loaded");
    window.log.value += ("\n on.appOpenAd.loaded");
});


document.addEventListener('on.appOpenAd.failed.loaded', (error) => {
    isAppOpenAdLoad = false;
    console.log("on.appOpenAd.failed.loaded" + JSON.stringify(error));
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
    window.log.value += ("\n on.appOpenAd.failed.loaded" + JSON.stringify(error));
});


document.addEventListener('on.appOpenAd.failed.show', (error) => {
    isAppOpenAdLoad = false;
    console.log("on.appOpenAd.failed.show" + JSON.stringify(error));

    window.log.value += ("\n on.appOpenAd.failed.show" + JSON.stringify(error));
});



// all events that contain the keyword dismissed there is a block to load the ad after it is closed by the user.
document.addEventListener('on.appOpenAd.dismissed', () => {
    // Stop loading the app, go straight to the main menu of the app.
    isAppOpenAdLoad = false;
    console.log("Stop loading the app, go straight to the main menu of the app.");
    console.log("you can load ads automatically after the ads are closed by users");
   

    window.log.value += ("\n you can load ads automatically after the ads are closed by users");

});











/*
// DEBUG
// isResponseInfo: true, // debug Default false
document.addEventListener('on.appOpenAd.responseInfo', (data) => {

    console.log("on.appOpenAd.responseInfo" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.appOpenAd.responseInfo" + JSON.stringify(data));
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

document.addEventListener('on.appOpenAd.revenue', (data) => {

    console.log(data.value)
    console.log(data.currencyCode)
    console.log(data.precision)
    console.log(data.adUnitId)

   // console.log("on.appOpenAd.revenue" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.appOpenAd.revenue" + JSON.stringify(data));
});