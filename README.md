# emi-indo-cordova-plugin-admob
 Cordova Plugin Admob Android
 ## Features

- Banner ads
- Interstitial ads
- Rewarded ads
- Rewarded interstitial ads
- App Open Ads (Coming soon)

## deviceready

```sh
cordova.plugins.emiAdmobPlugin.initialize();

document.addEventListener('onInitializationComplete', () => {

alert("on Initialization Complete");

});



```
## Banner ads

```sh
var AdUnitId = {

bannerAdUnitId: "ca-app-pub-3940256099942544/6300978111",
InterstitialAdAdUnitId: "ca-app-pub-3940256099942544/1033173712",
RewardedInterstitialAdUnitId: "ca-app-pub-3940256099942544/5354046379",
RewardedAdAdUnitId: "ca-app-pub-3940256099942544/5224354917"


}

// Load a Show cordova.plugins.emiAdmobPlugin.showBannerAd(AdUnitId.bannerAdUnitId);
// remove cordova.plugins.emiAdmobPlugin.removeBannerAd();

```
## Interstitial ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadInterstitialAd(AdUnitId.InterstitialAdAdUnitId);

// Show  cordova.plugins.emiAdmobPlugin.showInterstitialAd();

```
## Rewarded ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadRewardedAd(AdUnitId.RewardedAdAdUnitId);

// Show cordova.plugins.emiAdmobPlugin.showRewardedAd();

```
