# emi-indo-cordova-plugin-admob
 Cordova Plugin Admob Android

### Mobile Ads SDK (Android: 22.0.0)
[Release Notes:](https://developers.google.com/admob/android/rel-notes)

> __Warning__
> Updating the Mobile Ads SDK version may cause some code to malfunction, as the latest version usually deprecates some older code, [scrrenshot](https://drive.google.com/file/d/1UKaEjdmGRXgdZ2DKfOne8BSq13IUY14_/view) Current plugin code SDK 22.0.0

> __Warning__
> If the cordova admob plugin using Mobile Ads SDK code version 20.6.0 is upgraded to Mobile Ads SDK version 22.0.0, some of the old plugin code will not work.


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

## Upgrade Mobile Ads SDK
[Release Notes Mobile Ads SDK:](https://developers.google.com/admob/android/rel-notes)
```sh
cordova plugin add https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob --variable APP_ID_ANDROID=ca-app-pub-3940256099942544~3347511713 --variable PLAY_SERVICES_VERSION="xxxx" 
```



## 💰Sponsor this project
  [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/emiindo)  

## deviceready

[Example ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/index.html) - index.html:




```sh

/*
( set banner size: )

Anchored_adaptive
Inline_adaptive
BANNER
LARGE_BANNER
MEDIUM_RECTANGLE
FULL_BANNER
LEADERBOARD
Smart Banners = DEPRECATED
default: Anchored_adaptive


( set banner position )

top-right
top-center
left
center
right
bottom-center
bottom-right

adaptiveWidth = 320 // default: 320
*/


var bannerAdUnitId = "ca-app-pub-3940256099942544/6300978111"
var interstitialAdAdUnitId = "ca-app-pub-3940256099942544/1033173712"
var rewardedInterstitialAdUnitId = "ca-app-pub-3940256099942544/5354046379"
var rewardedAdAdUnitId = "ca-app-pub-3940256099942544/5224354917"

var size = "Anchored_adaptive"     
var position = "bottom-center"
var adaptiveWidth = 320


// Before loading ads, have your app initialize the Google Mobile Ads SDK by calling
// This needs to be done only once, ideally at app launch.

cordova.plugins.emiAdmobPlugin.initialize();

document.addEventListener('on.SdkInitializationComplete', () => {

alert("on Sdk Initialization Complete");

});


```

## Banner Ads
```sh
// Load a Show BANNER   cordova.plugins.emiAdmobPlugin.showBannerAd(bannerAdUnitId, size, position);
// Load a Show BANNER adaptive   cordova.plugins.emiAdmobPlugin.showBannerAd(bannerAdUnitId, size, position, adaptiveWidth);
// remove cordova.plugins.emiAdmobPlugin.removeBannerAd();
```
 [Banner ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-banner-ads-) - callback:


## Interstitial ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadInterstitialAd(interstitialAdAdUnitId);

// Show  cordova.plugins.emiAdmobPlugin.showInterstitialAd();
```

 [Interstitial ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-interstitial-ads-) - callback:



## Rewarded ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadRewardedAd(rewardedAdAdUnitId);

// Show cordova.plugins.emiAdmobPlugin.showRewardedAd();

```

[Rewarded ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-rewarded-ads-) - callback:


## Rewarded interstitial ads

```sh

// Load cordova.plugins.emiAdmobPlugin.loadRewardedInterstitialAd(rewardedInterstitialAdUnitId);

// Show cordova.plugins.emiAdmobPlugin.showRewardedInterstitialAd();

```

[Rewarded interstitial ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-rewarded-ads-) - callback:


## handle success or error

[Example code ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/getMediationAdapterName.html)
```sh

cordova.plugins.emiAdmobPlugin.loadRewardedAd(rewardedAdAdUnitId, success, error);

```


# Event | callback:
### event code

```sh
document.addEventListener('on.bannerAdLoaded', () => {

alert("on.banner Ad Loaded");

});

```

## ( SDK )
- on.SdkInitializationComplete


## ( Banner Ads )

### size
- Anchored_adaptive
- Inline_adaptive
- BANNER
- LARGE_BANNER
- MEDIUM_RECTANGLE
- FULL_BANNER
- LEADERBOARD
- Smart Banners = DEPRECATED
- default: Anchored_adaptive


### position

- top-right
- top-center
- left
- center
- right
- bottom-center
- bottom-right
- adaptiveWidth = number 
> default: 320


### Event Load a Show

- on.bannerAdClicked
- on.bannerAdClosed
- on.bannerAdFailedToLoad
- on.bannerAdImpression
- on.bannerAdLoaded
- on.bannerAdOpened




## ( Interstitial Ads )

### Event Load

- on.InterstitialAdLoaded
- on.InterstitialAdFailedToLoad

### Event Show

- on.InterstitialAdClicked
- on.InterstitialAdDismissedFullScreenContent
- on.InterstitialAdFailedToShowFullScreenContent
- on.InterstitialAdImpression
- on.InterstitialAdShowedFullScreenContent




## ( Rewarded Ads )

### Event Load

- on.RewardedAdFailedToLoad
- on.RewardedAdLoaded


### Event Show

- on.rewardedAdClicked
- on.rewardedAdDismissedFullScreenContent
- on.rewardedAdFailedToShowFullScreenContent
- on.rewardedAdImpression
- on.rewardedAdShowedFullScreenContent



## ( Rewarded interstitial Ads )

### Event Load

- on.RewardedInterstitialAdLoaded
- on.RewardedInterstitialAdFailedToLoad


### Event Show

- on.rewardedInterstitialAdClicked
- on.rewardedInterstitialAdDismissedFullScreenContent
- on.rewardedInterstitialAdFailedToShowFullScreenContent
- on.rewardedInterstitialAdImpression
- on.rewardedInterstitialAdShowedFullScreenContent


# Admob Mediation
<img src="https://user-images.githubusercontent.com/78555833/229587307-91a7e380-aa2d-4140-a62d-fa8e6a8dd153.png" width="500">


## get Mediation Adapter Name

[Example code ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/getMediationAdapterName.html) - get Mediation Adapter Name:

<img src="https://user-images.githubusercontent.com/78555833/230655800-0dbc3f12-72fb-4cf3-b4e6-801704fade28.png" width="250">



## Meta Audience Network

[Integrate Meta Audience Network with bidding :](https://developers.google.com/admob/android/mediation/meta)
- (Adapter default: 6.13.7.0)
### Installation
```sh
cordova plugin add emi-indo-cordova-plugin-mediation-meta
```

- ================================


## Unity Ads
[Integrate Unity Ads with Mediation :](https://developers.google.com/admob/android/mediation/unity)
- (Adapter default: 4.6.1.0)
### Installation
```sh
cordova plugin add emi-indo-cordova-plugin-mediation-unity
```

- ================================


## AppLovin Ads
[Integrate AppLovin with Mediation :](https://developers.google.com/admob/android/mediation/applovin)
- (Adapter default: 11.8.2.0)
### Installation
```sh
cordova plugin add emi-indo-cordova-plugin-mediation-applovin
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



- ================================




  
> - ##  Note Release
 [emi-indo-cordova-plugin-admob@0.0.4](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/tag/%400.0.4) 



### Platform Support
- Android


## 💰Sponsor this project
  [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/emiindo)   
  

 ## Earn more money, with other ad networks.
  - ### emi-indo-cordova-plugin-fan
  
  [Facebook Audience Network:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-fan) - Ads:
  
   - ### emi-indo-cordova-plugin-unityads
  
  [Cordova Plugin Unity:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-unityads) - Ads:
                             
