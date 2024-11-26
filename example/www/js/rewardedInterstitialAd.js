

let isRewardedIntLoad = false;

function loadRewardedInt() {

    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.loadRewardedInterstitialAd({ adUnitId: Rewarded_Interstitial_ID, autoShow: false });
    }

}

function showRewardedInt() {

    if (typeof cordova !== 'undefined') {
        if (isRewardedIntLoad) {
            cordova.plugins.emiAdmobPlugin.showRewardedInterstitialAd();
        }
    }

}


/*
on.rewardedInt.loaded
on.rewardedInt.failed.load
on.rewardedInt.click
on.rewardedInt.dismissed
on.rewardedInt.failed.show
on.rewardedInt.impression
on.rewardedInt.showed
on.rewardedInt.userEarnedReward
 // new
on.rewardedInt.revenue
on.rewardedInt.ad.skip
on.rewardedIntAd.responseInfo

*/



document.addEventListener('on.rewardedInt.loaded', () => {
    isRewardedIntLoad = true;
    console.log("on.rewardedInt.loaded");
    window.log.value += ("\n on.rewardedInt.loaded");
});


document.addEventListener('on.rewardedInt.failed.load', (error) => {
    isRewardedIntLoad = false;
    console.log("on.rewardedInt.failed.load" + JSON.stringify(error));

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

    window.log.value += ("\n on.rewardedInt.failed.load" + JSON.stringify(error));
});


document.addEventListener('on.rewardedInt.failed.show', (error) => {
    isRewardedIntLoad = false;
    console.log("on.rewardedInt.failed.show" + JSON.stringify(error));

    window.log.value += ("\n on.rewardedInt.failed.show" + JSON.stringify(error));
});


document.addEventListener('on.rewardedInt.userEarnedReward', (rewarded) => {
    // Give gifts to users here
    isRewardedIntLoad = false;
    console.log("Give gifts to users here" + JSON.stringify(rewarded));
    // const rewardAmount = rewarded.amount;
    // const rewardType = rewarded.currency;
    window.log.value += ("\n Give gifts to users here" + JSON.stringify(rewarded));
});


// all events that contain the keyword dismissed there is a block to load the ad after it is closed by the user.
document.addEventListener('on.rewardedInt.dismissed', () => {
    isRewardedIntLoad = false;
    console.log("on.rewardedInt.dismissed");
    console.log("you can load ads automatically after the ads are closed by users");
    loadRewardedInt();

    window.log.value += ("\n you can load ads automatically after the ads are closed by users");

});





/*
// DEBUG
// isResponseInfo: true, // debug Default false
document.addEventListener('on.rewardedIntAd.responseInfo', (data) => {

    console.log("on.rewardedIntAd.responseInfo" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.rewardedIntAd.responseInfo" + JSON.stringify(data));
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

document.addEventListener('on.rewardedInt.revenue', (data) => {

    console.log(data.value)
    console.log(data.currencyCode)
    console.log(data.precision)
    console.log(data.adUnitId)

   // console.log("on.rewardedInt.revenue" + JSON.stringify(data));
    if (window.log) window.log.value += ("\n on.rewardedInt.revenue" + JSON.stringify(data));
});