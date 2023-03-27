# emi-indo-cordova-plugin-admob
 Cordova Plugin Admob Android

### Mobile Ads SDK (Android: 21.5.0)

 ## Features

- Banner ads
- Interstitial ads
- Rewarded ads
- Rewarded interstitial ads
- App Open Ads (Coming soon)




## Installation

```sh
emi-indo-cordova-plugin-admob --variable APP_ID_ANDROID=ca-app-pub-3940256099942544~3347511713
```


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

/// setting banner size:           BANNER | LARGE_BANNER | MEDIUM_RECTANGLE | FULL_BANNER | LEADERBOARD | default: "" = BANNER
var size = "LARGE_BANNER"
/// setting banner position:       top-right | top-center | left | center | right | bottom-center | bottom-right |  default: "" = bottom-left
var position = "bottom-center"


// Load a Show cordova.plugins.emiAdmobPlugin.showBannerAd(AdUnitId.bannerAdUnitId, size, position);
// remove cordova.plugins.emiAdmobPlugin.removeBannerAd();

```

 [Banner ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/edit/main/README.md#banner-ad) - callback:


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

## Rewarded interstitial ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadRewardedInterstitialAd(AdUnitId.RewardedInterstitialAdUnitId);

// Show cordova.plugins.emiAdmobPlugin.showRewardedInterstitialAd();

```








# Event | callback:
### event code

```sh
document.addEventListener('onAdLoaded.bannerAd', () => {

alert("on Ad Loaded banner");

});

```

## ( Banner ads )

### Event Show a load

- onAdClicked.bannerAd
- onAdClosed.bannerAd
- onAdFailedToLoad.bannerAd
- onAdImpression.bannerAd
- onAdLoaded.bannerAd
- onAdOpened.bannerAd




## ( Interstitial ads )

### Event Load

- onAdLoaded.InterstitialAd
- onAdFailedToLoad.InterstitialAd

### Event Show

- onAdClicked.InterstitialAd
- onAdDismissedFullScreenContent.InterstitialAd
- onAdFailedToShowFullScreenContent.InterstitialAd
- onAdImpression.InterstitialAd
- onAdShowedFullScreenContent.InterstitialAd




## ( Rewarded ads )

### Event Load

- onAdFailedToLoad.RewardedAd
- onAdLoaded.RewardedAd


### Event Show

- onAdClicked.rewardedAd
- onAdDismissedFullScreenContent.rewardedAd
- onAdFailedToShowFullScreenContent.rewardedAd
- onAdImpression.rewardedAd
- onAdShowedFullScreenContent.rewardedAd



## ( Rewarded interstitial ads )

### Event Load

- onAdLoaded.RewardedInterstitial
- onAdFailedToLoad.RewardedInterstitial


### Event Show

- onAdClicked.rewardedInterstitialAd
- onAdDismissedFullScreenContent.rewardedInterstitialAd
- onAdFailedToShowFullScreenContent.rewardedInterstitialAd
- onAdImpression.rewardedInterstitialAd
- onAdShowedFullScreenContent.rewardedInterstitialAd


                    
                             
