// ccordova.plugins.emiAdmobPlugin.styleBannerAd({isOverlapping: true, overlappingHeight: 0, padding: 0, margins: 0 });  // ( only android)
//cordova.plugins.emiAdmobPlugin.loadBannerAd({config});
//cordova.plugins.emiAdmobPlugin.showBannerAd(); // default
//cordova.plugins.emiAdmobPlugin.hideBannerAd(); // default
//cordova.plugins.emiAdmobPlugin.removeBannerAd(); // default



function loadBanner() {

    if (typeof cordova !== 'undefined') {

        // IOS Still under development
        if (isPlatformIOS){
            // If there is a problem isOverlapping: false
            cordova.plugins.emiAdmobPlugin.styleBannerAd({
                isOverlapping: true, // default false IOS | Android
                paddingWebView: 1.0 // Only IOS
            });
            
        } else {

         // Android

         cordova.plugins.emiAdmobPlugin.styleBannerAd({
            isOverlapping: true, // default false IOS | Android
            isStatusBarShow: true, // default true Only Android
            overlappingHeight: 0, // default 0 (Automatic) Only Android
            padding: 0, // default 0 Only Android
            margins: 0 // default 0 (Automatic) Only Android
        });


        }

        
        
    

        cordova.plugins.emiAdmobPlugin.loadBannerAd({
            adUnitId: Banner_ID, //Banner_ID,
            position: "bottom-center", // "Recommended: bottom-center"
            size: "banner", // autoResize: true (only responsive_adaptive)
            collapsible: "bottom", // position: top | bottom (disable, empty string)
            autoResize: true, // default false
            autoShow: true, // default false

        });
    }

}



function showBanner() {

    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.showBannerAd();
    }

}

function hideBanner() {

    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.hideBannerAd();
    }

}


function removeBanner() {

    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.removeBannerAd();
    }

}


/* ///////<<<<  bannerAd position  >>>>>>\\\\\\\

(ANDROID)

top-right
top-center
left
center
right
bottom-center
bottom-right

(IOS)

bottom-center
top-center

*/

/* ///////<<<<  bannerAd size  >>>>>>\\\\\\\

(ANDROID)

responsive_adaptive
anchored_adaptive
full_width_adaptive
in_line_adaptive
banner
large_banner
medium_rectangle
full_banner
leaderboard
fluid

(IOS)

responsive_adaptive
in_line_adaptive
banner
large_banner
full_banner
leaderboard



*/




/* ///////<<<<  bannerAd event  >>>>>>\\\\\\\

on.banner.load
on.banner.failed.load
on.banner.click
on.banner.close
on.banner.impression
on.banner.open

on.banner.revenue
on.banner.remove
on.banner.hide

 // New event plugin v1.5.5 or higher

 on.is.collapsible
 on.bannerAd.responseInfo

 */




// EVENT For example


// (Optional)
// This is only triggered when cordova.plugins.emiAdmobPlugin.styleBannerAd
document.addEventListener('on.style.banner.ad', (data) => {
    console.log("on.style.banner.ad: " + JSON.stringify(data));
/*
    const navBarHeight = data.navBarHeight;
    const screenHeight = data.screenHeight;
    const usableHeight = data.usableHeight;
    const isOverlapping = data.isOverlapping;
    const overlappingHeight = data.overlappingHeight;
    const paddingInPx = data.paddingInPx;
    const marginsInPx = data.marginsInPx;
*/

   // You can load banner ads here, or manipulate variables, even rearrange cordova.plugins.emiAdmobPlugin.styleBannerAd to your liking.


});





document.addEventListener('on.banner.load', (arg) => {
    let bannerAdHeight=arg.height;
    console.log("on banner load", bannerAdHeight);
});


document.addEventListener('on.is.collapsible', function (event) {
    // bannerConfig collapsible: "bottom", // position: top | bottom (disable, empty string)
    console.log("Collapsible Status: " + event.collapsible);


});

document.addEventListener('on.banner.failed.load', (error) => {
    console.log("on.banner.failed.load" + JSON.stringify(error));

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

});



/*
// DEBUG
// isResponseInfo: true, // debug Default false
document.addEventListener('on.bannerAd.responseInfo', (data) => {
    console.log("on.bannerAd.responseInfo" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.bannerAd.responseInfo" + JSON.stringify(data));
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

document.addEventListener('on.banner.revenue', (data) => {
    
    console.log(data.value)
    console.log(data.currencyCode)
    console.log(data.precision)
    console.log(data.adUnitId)
    
    //console.log("on.banner.revenue" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.banner.revenue" + JSON.stringify(data));
});