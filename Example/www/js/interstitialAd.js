


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
 // new
 on.interstitial.revenue

*/


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
    
    window.log.value += ("\n on.interstitial.failed.load" + JSON.stringify(error));
});

document.addEventListener('on.interstitial.failed.show', (error) => {
    isInterstitialLoad = false;
    console.log("on.interstitial.failed.show" + JSON.stringify(error));
    
    window.log.value += ("\n on.interstitial.failed.show" + JSON.stringify(error));
});
