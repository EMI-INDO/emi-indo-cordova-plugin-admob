# emi-indo-cordova-plugin-admob
 Cordova Plugin Admob Android and IOS

### Mobile Ads SDK (Android: 22.6.0) [Release Notes:](https://developers.google.com/admob/android/rel-notes)

### Mobile Ads SDK (IOS: 10.14.0) [Release Notes:](https://developers.google.com/admob/ios/rel-notes)

## Minimum Cordova Engines
- cordova-android version = 12.0.0
- cordova-ios version = 7.0.0


## Minimum macOS | Xcode, and others
- Monterey
- Xcode 14.1 or higher
- Command Line Tools 14.1 or higher
- Target iOS 11.0 or higher
https://developers.google.com/admob/ios/quick-start




## >>>>>> Device Ready <<<<<<

- [AppTrackingTransparency (ATT) framework:](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/authorizationstatus) 
- [Consent Management Platform API:](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)

- [Example Get Consent Status:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/consent.html) index.html
- [Example requestIDFA:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/requestIDFA.html) index.html
- [Example IABTFC:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/IABTFC.html) index.html
```
// Support Platform: Android or IOS
<script>
cordova.plugins.emiAdmobPlugin.globalSettings([config_globalSettings]);
cordova.plugins.emiAdmobPlugin.targeting([config_Targeting]);
cordova.plugins.emiAdmobPlugin.initialize();

/*
cordova.plugins.emiAdmobPlugin.requestIDFA(); // UMP SDK to handle Apple's App Tracking Transparency (ATT) (Platform: IOS)
cordova.plugins.emiAdmobPlugin.getIabTfc((IABTFC) => {JSONstringify(IABTFC)}); // CMP SDK 2.2 (Platform: Both)

// UMP SDK 2.1.0
cordova.plugins.emiAdmobPlugin.getConsentRequest(); // (Platform: Both)
cordova.plugins.emiAdmobPlugin.consentReset(); // (Platform: Both)
cordova.plugins.emiAdmobPlugin.showPrivacyOptionsForm(); // (Platform: Both)
*/
</script>
```

### AppOpenAd ADS
 [FULL AppOpenAd basic:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/app_open_ads.html) index.html
//[:]() index.html
```
<script>
// Support Platform: Android | IOS
cordova.plugins.emiAdmobPlugin.loadAppOpenAd([config_AppOpenAd]);
cordova.plugins.emiAdmobPlugin.showAppOpenAd();
</script>
```


 ### BANNER ADS
 [FULL Banner basic:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/banner_ads.html) index.html
 ```
 // Support Platform: Android | IOS
 <script>
cordova.plugins.emiAdmobPlugin.loadBannerAd([bannerConfig]);
cordova.plugins.emiAdmobPlugin.showBannerAd();
cordova.plugins.emiAdmobPlugin.hideBannerAd();
cordova.plugins.emiAdmobPlugin.removeBannerAd();
</script>
```

### Interstitial ADS
[FULL Interstitial basic:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/interstitial_ads.html) index.html
```
// Support Platform: Android | IOS
<script>
cordova.plugins.emiAdmobPlugin.loadInterstitialAd([config_Interstitial]);
cordova.plugins.emiAdmobPlugin.showInterstitialAd();
</script>
```


### Rewarded Interstitial ADS
[FULL Rewarded Interstitial basic:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/rewarded_interstitial_ads.html) index.html
```
// Support Platform: Android | IOS
<script>
cordova.plugins.emiAdmobPlugin.loadRewardedInterstitialAd([config_rewardedInt]);
cordova.plugins.emiAdmobPlugin.showRewardedInterstitialAd();
</script>
```

### Rewarded ADS
[FULL Rewarded basic:](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/rewarded_ads.html) index.html
```
// Support Platform: Android | IOS
<script>
cordova.plugins.emiAdmobPlugin.loadRewardedAd([config_rewarded]);
cordova.plugins.emiAdmobPlugin.showRewardedAd();
</script>
```


## Installation

```sh
cordova plugin add emi-indo-cordova-plugin-admob  --save --variable APP_ID_ANDROID=ca-app-pub-xxx~xxx --variable APP_ID_IOS=ca-app-pub-xxx~xxx
```
### Or
```sh
cordova plugin add https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob  --save --variable APP_ID_ANDROID=ca-app-pub-xxx~xxx --variable APP_ID_IOS=ca-app-pub-xxx~xxx
```
## Remove
```sh
cordova plugin rm emi-indo-cordova-plugin-admob
```




## Import the Mobile Ads SDK
### Then from the command line run:
- cd platforms/ios
### Then from the command line run:
- pod install --repo-update










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
- [Consent](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/consent.html)
- Mediation
- impression-level-ad-revenue
- GDPR IAB TFCv2.2
- AppTrackingTransparency (ATT)
- Collapsible banner ads (BETA)

 ## Coming soon
- App Open Ads ( Finished )
- User Consent ( Finished ) 
- Mediation ( Finished )
- https://developers.google.com/admob/android/native/start
- https://developers.google.com/admob/android/impression-level-ad-revenue ( Finished ) v1.1.9
- https://developers.google.com/admob/android/ssv
- https://developers.google.com/admob/android/privacy/gdpr ( Finished ) v1.4.0 [index.html](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/consent_GDPR_IAB_TFCv2.2.html)
- https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/ ( Finished ) v1.4.0 [index.html](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/consent_GDPR_IAB_TFCv2.2.html)








  > __Note__
> 

> - # Plugin version @1.4.0

 ###  [ GDPR | IAB TFC code example: ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/consent_GDPR_IAB_TFCv2.2.html)
 - replace all AdUnitId to adUnitId
 - new banner size: FULL_WIDTH
### New only on github
   https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/tag/%401.4.0

> - # Plugin version @1.3.9

 [FULL Example ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/) - index.html:

 ###  [ App Open Ad code example: ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/app_open_ads.html)
 ###  [ Banner Ad code example: ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/banner_ads.html)
 ###  [ Interstitial Ad code example: ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/interstitial_ads.html)
 ###  [ Rewarded interstitial Ad code example: ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/rewarded_interstitial_ads.html)
 ###  [ Rewarded Ad code example: ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/rewarded_ads.html)

 ###  [ Advanced topics: ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/tree/main/example/Advanced%20topics)

# IAB Europe Transparency & Consent Framework
### Example How to read consent choices

                
               // index.html  https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example/Advanced%20topics/consent_GDPR_IAB_TFCv2.2.html
 ```sh
               // >>>>>>>>  New features (UMP) SDK v2.1.0
               // https://developers.google.com/admob/android/privacy/gdpr
                /*
                If the user chooses not to display ads, 
                you can restrict access to the app, or ban it,
                until they change their decision back, 
                Just call showPrivacyOptionsForm();
                */


             cordova.plugins.emiAdmobPlugin.getIabTfc(
                (info) => {
                    // How to read consent choices
                    console.log("IABTCF_gdprApplies: " + info.IABTCF_gdprApplies);
                    console.log("IABTCF_PurposeConsents: " + info.IABTCF_PurposeConsents);
                    console.log("IABTCF_TCString: " + info.IABTCF_TCString);

                                        // A small example
                                        var fundingChoices;
                    
                                        fundingChoices = info.IABTCF_PurposeConsents;
                                       if (fundingChoices === "1111111111"){
                                           
                                       // Enable app features.
                                        loadRewardedAd();
                                        
                                       } else if (fundingChoices === "") {
                    
                                           // disable app features.
                    
                                       } else {
                    
                                          // You have to test everything yourself.
                                          console.log(info);
                    
                                       }
                   
                },
                (error) => {
                     console.log("Error: " + error);
                    
                });

        

```


# Event | callback:
### Example event code

```sh
document.addEventListener('on.appOpenAd.loaded', () => {

alert("On App Open Ad loaded");

});

```

> __Note__
### (final) cannot be changed.

## ( SDK )
- on.sdkInitialization

## ( App Open Ads )

### Event Load

- on.appOpenAd.loaded
- on.appOpenAd.failed.loaded

### Event Show

- on.appOpenAd.dismissed
- on.appOpenAd.failed.show
- on.appOpenAd.show
 ### NEW
- on.appOpenAd.revenue


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

- ANCHORED
- IN_LINE
- FULL_WIDTH
- BANNER
- FLUID
- LARGE_BANNER
- MEDIUM_RECTANGLE
- FULL_BANNER
- LEADERBOARD
- adaptive_Width = number 
- Smart Banners = DEPRECATED


### Event Load

- on.banner.load
- on.banner.failed.load

### Event Show

- on.banner.click
- on.banner.close
- on.banner.impression
- on.banner.open
### NEW
- on.banner.revenue
- on.banner.remove
- on.banner.hide
  



## ( Interstitial Ads )

### Event Load

- on.interstitial.loaded
- on.interstitial.failed.load

### Event Show

- on.interstitial.click
- on.interstitial.dismissed
- on.interstitial.failed.show
- on.interstitial.impression
- on.interstitial.show
### NEW
- on.interstitial.revenue





## ( Rewarded Ads )

### Event Load

- on.rewarded.loaded
- on.rewarded.failed.load


### Event Show

- on.rewarded.click
- on.rewarded.dismissed
- on.rewarded.failed.show
- on.rewarded.impression
- on.rewarded.show
### NEW
- on.rewarded.revenue
- on.rewarded.ad.skip
- on.reward.userEarnedReward



## ( Rewarded interstitial Ads )

### Event Load

- on.rewardedInt.loaded
- on.rewardedInt.failed.load


### Event Show

- on.rewardedInt.click
- on.rewardedInt.dismissed
- on.rewardedInt.failed.show
- on.rewardedInt.impression
- on.rewardedInt.showed
### NEW
- on.rewardedInt.revenue
- on.rewardedInt.ad.skip
- on.rewardedInt.userEarnedReward


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
                             
