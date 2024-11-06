

let isRewardedLoad = false;

function loadRewarded() {

    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.loadRewardedAd({ adUnitId: Rewarded_ID, autoShow: false });
    }

}

function showRewarded() {

    if (typeof cordova !== 'undefined') {
        if (isRewardedLoad) {
            cordova.plugins.emiAdmobPlugin.showRewardedAd();
        }
    }

}

/*
on.rewarded.loaded
on.rewarded.failed.load
on.rewarded.click
on.rewarded.dismissed
on.rewarded.failed.show
on.rewarded.impression
on.rewarded.show
on.reward.userEarnedReward
 // new
on.rewarded.revenue
on.rewarded.ad.skip
*/



document.addEventListener('on.rewarded.loaded', () => {
    isRewardedLoad = true;
    console.log("on rewarded Ad loaded");
    window.log.value += ("\n on rewarded Ad loaded");
});

document.addEventListener('on.rewarded.failed.load', (error) => {
    isRewardedLoad = false;
    console.log("on.rewarded.failed.load" + JSON.stringify(error));

    window.log.value += ("\n on.rewarded.failed.load" + JSON.stringify(error));
});

document.addEventListener('on.rewarded.failed.show', (error) => {
    isRewardedLoad = false;
    console.log("on.rewarded.failed.show" + JSON.stringify(error));

    window.log.value += ("\n on.rewarded.failed.show" + JSON.stringify(error));
});

document.addEventListener('on.reward.userEarnedReward', (rewarded) => {
    // Give gifts to users here
    isRewardedLoad = false;
    console.log("Give gifts to users here" + JSON.stringify(rewarded));
    // const rewardAmount = rewarded.amount;
    // const rewardType = rewarded.currency;
    window.log.value += ("\n Give gifts to users here" + JSON.stringify(rewarded));
});

// all events that contain the keyword dismissed there is a block to load the ad after it is closed by the user.
document.addEventListener('on.rewarded.dismissed', () => {
    isRewardedLoad = false;
    console.log("on interstitial Ad dismissed");
    console.log("you can load ads automatically after the ads are closed by users");
    loadRewarded();

    window.log.value += ("\n you can load ads automatically after the ads are closed by users");

});



