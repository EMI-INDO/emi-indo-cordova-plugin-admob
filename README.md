# emi-indo-cordova-plugin-admob
 Cordova Plugin Admob Android and IOS

### Mobile Ads SDK (Android: 22.1.0) [Release Notes:](https://developers.google.com/admob/android/rel-notes)

### Mobile Ads SDK (IOS: 10.3.0) [Release Notes:](https://developers.google.com/admob/ios/rel-notes)

###  [Documentation for IOS](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/discussions/3)

-


  > __Note__
> - ## It's Not a fork, it's purely rewritten, clean of 3rd party code.

 > __Note__
> - ### No Ad-Sharing
> - ### No Remote Control
> - ### I guarantee 100% revenue for you.
> - [Code source:](https://github.com/googleads/googleads-mobile-android-examples) - Admob:


## 💰Sponsor this project
  [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/emiindo)  
  
##  [Check all release notes:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/)


## Features

- SDK initialize
- targeting
- globalSettings
- App Open Ads
- Banner Ads
- Interstitial Ads
- Rewarded Ads
- Rewarded interstitial Ads
- [Consent](https://github.com/EMI-INDO/emi-indo-cordova-plugin-consent)
- Mediation

 ## Coming soon
- App Open Ads ( Finished )
- User Consent ( Finished ) [emi-indo-cordova-plugin-consent](https://github.com/EMI-INDO/emi-indo-cordova-plugin-consent)
- Mediation ( Finished )


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

## upgrade Mobile Ads SDK
[Release Notes Mobile Ads SDK:](https://developers.google.com/admob/android/rel-notes)
```sh
cordova plugin add emi-indo-cordova-plugin-admob --variable APP_ID_ANDROID=ca-app-pub-3940256099942544~3347511713 --variable PLAY_SERVICES_VERSION="xxxx" 
```

## Response Info
- Here is a sample output returned by responseInfo = true showing the debugging data returned for a loaded ad:

```sh
{
  "Response ID": "COOllLGxlPoCFdAx4Aod-Q4A0g",
  "Mediation Adapter Class Name": "com.google.ads.mediation.admob.AdMobAdapter",
  "Adapter Responses": [
    {
      "Adapter": "com.google.ads.mediation.admob.AdMobAdapter",
      "Latency": 328,
      "Ad Source Name": "Reservation campaign",
      "Ad Source ID": "7068401028668408324",
      "Ad Source Instance Name": "[DO NOT EDIT] Publisher Test Interstitial",
      "Ad Source Instance ID": "4665218928925097",
      "Credentials": {},
      "Ad Error": "null"
    }
  ],
  "Loaded Adapter Response": {
    "Adapter": "com.google.ads.mediation.admob.AdMobAdapter",
    "Latency": 328,
    "Ad Source Name": "Reservation campaign",
    "Ad Source ID": "7068401028668408324",
    "Ad Source Instance Name": "[DO NOT EDIT] Publisher Test Interstitial",
    "Ad Source Instance ID": "4665218928925097",
    "Credentials": {},
    "Ad Error": "null"
  },
  "Response Extras": {
    "mediation_group_name": "Campaign"
  }
}


Bundle[{max_ad_content_rating=G, 
npa=1, 
is_designed_for_families=0, 
under_age_of_consent=0] 


```


### As suggested by Google, when the SDK initializes this plugin automatically takes the Global Settings and Targeting values.

### Global Settings
```sh
// Instruction: https://developers.google.com/admob/android/global-settings

cordova.plugins.emiAdmobPlugin.globalSettings(

    setAppMuted = true, // Type Boolean default: true
    setAppVolume = 1.0, // Type float
    enableSameAppKey = false, // Type Boolean default: false
      
      // Optional
    (info) => { alert(info) },
    (error) => { alert(error)

    });
 ```   
  
  ### Targeting
  
   > __Note__
> - ## You can see the value when the ad is loaded, set responseInfo = true
   
   ```sh
// Instruction: https://developers.google.com/admob/android/targeting
// Overview: https://developers.google.com/android/reference/com/google/android/gms/ads/RequestConfiguration

 cordova.plugins.emiAdmobPlugin.targeting(
    TagForChildDirectedTreatment = 0, // value: 0 | -1 | 1
    TagForUnderAgeOfConsent = 0, // // value: 0 | -1 | 1
    MaxAdContentRating = "G", // value: G | MA | PG | T | ""

   // Optional
   (info) => { alert(info) },
   (error) => { alert(error)

    });
    
    
// (TagForChildDirectedTreatment)
// Type number:
// value: 0 | -1 | 1
// (value description)
// 0 = FALSE
// 1 = TRUE
// -1 = UNSPECIFIED
// (if else/undefined = false/0)

///////////////////////////////

// (TagForUnderAgeOfConsent)
// Type number:
// value: 0 | -1 | 1
// (value description)
// 0 = FALSE
// 1 = TRUE
// -1 = UNSPECIFIED
// (if else/undefined = false/0)

//////////////////////////////

// (MaxAdContentRating)
// Type String:
// value: G | MA | PG | T | ""
// (value description)
// https://developers.google.com/admob/unity/reference/class/google-mobile-ads/api/max-ad-content-rating
// (if else/undefined/"" = NULL)
    
    
 ```  
   
   

## deviceready

[Example ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/index.html) - index.html:


```sh

// Before loading ads, have your app initialize the Google Mobile Ads SDK by calling
// This needs to be done only once, ideally at app launch.

cordova.plugins.emiAdmobPlugin.initialize(
// Optional
(info) => { alert(info) },
 (error) => { alert(error)

 });
 
 
 //(Auto Loaded during SDK initialize and ad loaded)
 
 cordova.plugins.emiAdmobPlugin.targeting(
    TagForChildDirectedTreatment = 0, // value: 0 | -1 | 1
    TagForUnderAgeOfConsent = 0, // // value: 0 | -1 | 1
    MaxAdContentRating = "G", // value: G | MA | PG | T | ""

    // Optional
    (info) => { console.log(info)},
    (error) => { alert(error)

    });
    
    
    cordova.plugins.emiAdmobPlugin.globalSettings(

    setAppMuted = true, // Type Boolean default: true
    setAppVolume = 1.0, // Type float
    enableSameAppKey = false, // Type Boolean default: false

    // Optional
     (info) => { console.log(info) },
     (error) => { alert(error)

    });

document.addEventListener('on.SdkInitializationComplete', () => {

alert("on Sdk Initialization Complete");

});


```


## App Open Ads

> __Note__
### Variable name and index (final) cannot be changed.
- AdUnitId | index 0
- npa | index 1
- responseInfo | index 2

```sh
// load App Open Ad

let loadAppOpenAd = () => {
    cordova.plugins.emiAdmobPlugin.loadAppOpenAd(
    AdUnitId = "ca-app-pub-3940256099942544/3419835294",
    npa = "1", // String | 0 | 1
    responseInfo = true, // boolean
    // Optional
    (info) => { alert(info) },
    (error) => { alert(error)

    });
}

// call loadAppOpenAd();

// Show App Open Ad

let showAppOpenAd = () => {
    cordova.plugins.emiAdmobPlugin.showAppOpenAd();
}

// call showAppOpenAd();

```


## Banner Ads

> __Note__
### Variable name and index (final) cannot be changed.
- AdUnitId | index 0
- npa | index 1
- position | index 2
- size | index 3
- adaptiveWidth | index 4



```sh
/// setting banner size: 
/*          
BANNER
FLUID 
LARGE_BANNER
MEDIUM_RECTANGLE
FULL_BANNER
LEADERBOARD
(Smart Banners = DEPRECATED)
Inline_adaptive
Anchored_adaptive
default: Anchored_FULL_WIDTH

adaptiveWidth = 320 // number (only adaptive banner)

*/
/// setting banner position:  
/*     
top-right
top-center
left
center
right
bottom-center
bottom-right
default: "bottom-left"
*/


//  Banner Adaptive

let showBannerAdaptive = () => {
    cordova.plugins.emiAdmobPlugin.showBannerAd(
    AdUnitId = "ca-app-pub-3940256099942544/6300978111",
    npa = "1", // String | 0 | 1
    position = "bottom-center",
    size = "Anchored_FULL_WIDTH", // | Inline_adaptive | Anchored_adaptive
    adaptiveWidth = 320,
    responseInfo = true, // boolean (debugging)
    
    // Optional
    (info) => { alert(info) },
    (error) => { alert(error)

    });
}

// call showBannerAdaptive();

//  not Adaptive banner

let showBannerNotAdaptive = () => {
    cordova.plugins.emiAdmobPlugin.showBannerAd(
    AdUnitId = "ca-app-pub-3940256099942544/6300978111",
    npa = "1", // String | 0 | 1
    position = "bottom-center",
    size = "FLUID",
    responseInfo = true, // boolean (debugging)
    
    // Optional
    (info) => { alert(info) },
    (error) => { alert(error)

    });
}

// call showBannerNotAdaptive();

// Remove Banner

let removeBannerAd = () => {
    cordova.plugins.emiAdmobPlugin.removeBannerAd();
}

// call removeBannerAd();

```
 [Banner ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-banner-ads-) - callback:


## Interstitial Ads

> __Note__
### Variable name and index (final) cannot be changed.
- AdUnitId | index 0
- npa | index 1
- responseInfo | index 2

```sh
// Load Interstitial Ad

let loadInterstitialAd = () => {
    cordova.plugins.emiAdmobPlugin.loadInterstitialAd(
    AdUnitId = "ca-app-pub-3940256099942544/1033173712",
    npa = "1", // String | 0 | 1
    responseInfo = true, // boolean (debugging)
    
    // Optional
    (info) => { alert(info) }, 
    (error) => { alert(error)
    
    });
}

// call loadInterstitialAd();

// Show Interstitial Ad

let showInterstitialAd = () => {
    cordova.plugins.emiAdmobPlugin.showInterstitialAd();
}

// call showInterstitialAd();

```

 [Interstitial ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-interstitial-ads-) - callback:



## Rewarded Ads

> __Note__
### Variable name and index (final) cannot be changed.
- AdUnitId | index 0
- npa | index 1
- responseInfo | index 2

```sh

// Load Rewarded Ad

let loadRewardedAd = () => {
    cordova.plugins.emiAdmobPlugin.loadRewardedAd(
    AdUnitId = "ca-app-pub-3940256099942544/5224354917",
    npa = "1", // String | 0 | 1
    responseInfo = true, // boolean (debugging)
    // Optional
    (info) => { alert(info) },
    (error) => { alert(error)

    });
}

// call loadRewardedAd();

// Show Rewarded Ad

let showRewardedAd = () => {
    cordova.plugins.emiAdmobPlugin.showRewardedAd();
}

// call showRewardedAd();


```

[Rewarded ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-rewarded-ads-) - callback:


## Rewarded interstitial Ads

> __Note__
### Variable name and index (final) cannot be changed.
- AdUnitId | index 0
- npa | index 1
- responseInfo | index 2

```sh

// load Rewarded Interstitial Ad

let loadRewardedInterstitialAd = () => {
    cordova.plugins.emiAdmobPlugin.loadRewardedInterstitialAd(
    AdUnitId = "ca-app-pub-3940256099942544/5354046379",
    npa = "1", // String | 0 | 1
    responseInfo = true, // boolean (debugging)
    // Optional
    (info) => { alert(info) },
    (error) => { alert(error)

    });
}

// call loadRewardedInterstitialAd();

// Show Rewarded Interstitial Ad

const showRewardedInterstitialAd = () => {
    cordova.plugins.emiAdmobPlugin.showRewardedInterstitialAd();
}

// cal showRewardedInterstitialAd();


```

[Rewarded interstitial ads event](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob#-rewarded-ads-) - callback:



# Event | callback:
### event code

```sh
document.addEventListener('on.bannerAdLoaded', () => {

alert("on.banner Ad Loaded");

});

```

> __Note__
### (final) cannot be changed.

## ( SDK )
- on.SdkInitializationComplete


## ( App Open Ads )

### Event Load

- on.open.loaded
- on.open.failed.loaded

### Event Show

- on.open.dismissed
- on.open.failed.show
- on.open.show


## ( Banner Ads )

### position

- top-right
- top-center
- left
- center
- right
- bottom-center
- bottom-right



### size

- Anchored_adaptive
- Inline_adaptive
- BANNER
- FLUID
- LARGE_BANNER
- MEDIUM_RECTANGLE
- FULL_BANNER
- LEADERBOARD
- adaptiveWidth = number 
- Smart Banners = DEPRECATED
- default: Anchored_FULL_WIDTH




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
- on.rewarded.rewarded



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
- on.rewardedInterstitial.rewarded





# Admob Mediation
<img src="https://user-images.githubusercontent.com/78555833/229587307-91a7e380-aa2d-4140-a62d-fa8e6a8dd153.png" width="500">


## get Mediation Adapter Name

responseInfo = true // (debugging)

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

- ================================


## AdColony Ads
[Integrate AdColony with Mediation :](https://developers.google.com/admob/android/mediation/adcolony)
- (Adapter default: 4.8.0.1)
### Installation
```sh
cordova plugin add emi-indo-cordova-plugin-mediation-adcolony
```

- ================================


## Chartboost Ads
[Integrate Chartboost with Mediation :](https://developers.google.com/admob/android/mediation/chartboost)
- (Adapter default: 9.2.1.0)
### Installation
```sh
cordova plugin add emi-indo-cordova-plugin-mediation-chartboost
```

- ================================


## ironSource Ads
[Integrate ironSource with Mediation :](https://developers.google.com/admob/android/mediation/ironsource)
- (Adapter default: 7.2.7.0)
### Installation
```sh
cordova plugin add emi-indo-cordova-plugin-mediation-ironsource
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
- --variable ADCOLONY_ADAPTER_VERSION="xxxxx"
- --variable CHARTBOOST_ADAPTER_VERSION="xxxxx"
- --variable IRONSOURCE_ADAPTER_VERSION="xxxxx"

### preference name

- META_ADAPTER_VERSION
- UNITY_ADAPTER_VERSION
- APPLOVIN_ADAPTER_VERSION
- ADCOLONY_ADAPTER_VERSION
- CHARTBOOST_ADAPTER_VERSION
- IRONSOURCE_ADAPTER_VERSION

- ================================


emi-indo-cordova-plugin-admob@0.0.5

  
> - ##  Note Release
- [emi-indo-cordova-plugin-admob@0.0.4](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/tag/%400.0.4) 
 
- [emi-indo-cordova-plugin-admob@0.0.5](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/tag/v0.0.5) 
 
 <img src="https://user-images.githubusercontent.com/78555833/231241800-8834ca2a-fa95-4cc2-91ca-1478c6b3c1ef.jpg" width="250">

- [emi-indo-cordova-plugin-admob@0.0.6](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/tag/v0.0.6) 


### Platform Support
- Android
- IOS


## 💰Sponsor this project
  [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/emiindo)   
  

 ## Earn more money, with other ad networks.
  - ### emi-indo-cordova-plugin-fan
  
  [Facebook Audience Network:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-fan) - Ads:
  
   - ### emi-indo-cordova-plugin-unityads
  
  [Cordova Plugin Unity:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-unityads) - Ads:
  
  ## New Open AI
 
 - ### emi-indo-cordova-plugin-open-ai
  
  [Cordova Plugin Open Ai:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-open-ai) - Open AI:
  
  
   ## New Firebase Analytics
 
 - ### emi-indo-cordova-plugin-fanalytics
  
  [Cordova Plugin Firebase Analytics:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-fanalytics) - Firebase Analytics:
                             
