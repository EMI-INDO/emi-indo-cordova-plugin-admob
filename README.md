# emi-indo-cordova-plugin-admob
 Cordova Plugin Admob Android

### Mobile Ads SDK (Android: 21.5.0)


> __Warning__
> - ## This plugin is still BETA (in progress).

  > __Note__
> - ## It's Not a fork, it's purely rewritten, clean of 3rd party code.

 > __Note__
> - ### No Ad-Sharing
> - ### No Remote Control
> - ### I guarantee 100% revenue for you.
> - [Code source:](https://github.com/googleads/googleads-mobile-android-examples) - Admob:




https://user-images.githubusercontent.com/78555833/228323239-e9e18e74-b814-4ca8-ab86-b2e28437e61c.mp4




 ## Features

- Banner Ads
- Interstitial Ads
- Rewarded Ads
- Rewarded interstitial Ads

 ## Coming soon
- App Open Ads
- User Consent
- Mediation ( In the process )


## Installation

```sh
cordova plugin add emi-indo-cordova-plugin-admob --variable APP_ID_ANDROID=ca-app-pub-3940256099942544~3347511713
```
### Or
```sh
cordova plugin add https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob --variable APP_ID_ANDROID=ca-app-pub-3940256099942544~3347511713
```
## Remove
```sh
cordova plugin rm emi-indo-cordova-plugin-admob
```

## 💰Sponsor this project
  [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/emiindo)  

## deviceready

[Example ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/index.html) - index.html:

```sh
// Before loading ads, have your app initialize the Google Mobile Ads SDK by calling
// This needs to be done only once, ideally at app launch.

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

/// setting banner size:           BANNER | LARGE_BANNER | MEDIUM_RECTANGLE | FULL_BANNER | LEADERBOARD | default: "BANNER" | (Smart Banners = DEPRECATED)
var size = "LARGE_BANNER"
/// setting banner position:       top-right | top-center | left | center | right | bottom-center | bottom-right |  default: "bottom-left" 
var position = "bottom-center"


// Load a Show cordova.plugins.emiAdmobPlugin.showBannerAd(AdUnitId.bannerAdUnitId, size, position);
// remove cordova.plugins.emiAdmobPlugin.removeBannerAd();

```

 [Banner ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-banner-ads-) - callback:


## Interstitial ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadInterstitialAd(AdUnitId.InterstitialAdAdUnitId);

// Show  cordova.plugins.emiAdmobPlugin.showInterstitialAd();

```
 [Interstitial ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-interstitial-ads-) - callback:



## Rewarded ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadRewardedAd(AdUnitId.RewardedAdAdUnitId);

// Show cordova.plugins.emiAdmobPlugin.showRewardedAd();

```

[Rewarded ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-rewarded-ads-) - callback:


## Rewarded interstitial ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadRewardedInterstitialAd(AdUnitId.RewardedInterstitialAdUnitId);

// Show cordova.plugins.emiAdmobPlugin.showRewardedInterstitialAd();

```

[Rewarded interstitial ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-rewarded-ads-) - callback:






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


# Admob Mediation
<img src="https://user-images.githubusercontent.com/78555833/229587307-91a7e380-aa2d-4140-a62d-fa8e6a8dd153.png" width="500">

## Meta Audience Network

[Integrate Meta Audience Network with bidding :](https://developers.google.com/admob/android/mediation/meta)
- (Adapter default: 6.13.7.0)
### Installation
```sh
emi-indo-cordova-plugin-mediation-meta
```

- ================================


## Unity Ads
[Integrate Unity Ads with Mediation :](https://developers.google.com/admob/android/mediation/unity)
- (Adapter default: 4.6.1.0)
### Installation
```sh
emi-indo-cordova-plugin-mediation-unity
```

- ================================


## AppLovin Ads
[Integrate AppLovin with Mediation :](https://developers.google.com/admob/android/mediation/applovin)
- (Adapter default: 11.8.2.0)
### Installation
```sh
emi-indo-cordova-plugin-mediation-applovin
```



## Variables name or preference name
> __Warning__
> This is so that if I don't have time to update the Mediation Adapter version later, you can do it yourself as below. 

- Cordova CLI Update Adapter version with Variables
```sh
cordova plugin add emi-indo-cordova-plugin-mediation-meta --variable META_ADAPTER_VERSION="xxxxx"
```
- Update Adapter version with config.xml
```sh
<preference name="META_ADAPTER_VERSION" value="xxxxx" />
```

### Variables Name

- --variable META_ADAPTER_VERSION="xxxxx"
- --variable UNITY_ADAPTER_VERSION="xxxxx"
- --variable APPLOVIN_ADAPTER_VERSION="xxxxx"

### preference name

- META_ADAPTER_VERSION
- UNITY_ADAPTER_VERSION
- APPLOVIN_ADAPTER_VERSION





### Platform Support
- Android


## 💰Sponsor this project
  [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/emiindo)   
  

 ## Earn more money, with other ad networks.
  - ### emi-indo-cordova-plugin-fan
  
  [Facebook Audience Network:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-fan) - Ads:
  
   - ### emi-indo-cordova-plugin-unityads
  
  [Cordova Plugin Unity:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-unityads) - Ads:
                             
