# emi-indo-cordova-plugin-admob

[![NPM version](https://img.shields.io/npm/v/emi-indo-cordova-plugin-admob.svg)](https://www.npmjs.com/package/emi-indo-cordova-plugin-admob)
[![Downloads](https://img.shields.io/npm/dm/emi-indo-cordova-plugin-admob.svg)](https://www.npmjs.com/package/emi-indo-cordova-plugin-admob)
[![License](https://img.shields.io/npm/l/emi-indo-cordova-plugin-admob.svg)](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/LICENSE)


> [!TIP]
> **🚀 Cloud Build Ready:** > Tired of local environment errors? This plugin is fully tested and 100% compatible with **[SwapLab Public Build](https://public.swaplab.net/)**. 
>
> Build your Android/iOS apps instantly in the cloud without setting up Android Studio or Xcode. Supports **Cordova, Framework7, and Capacitor** stacks.


**Cordova/Quasar/Capacitor Plugin for AdMob (Android & iOS)**

This plugin supports the latest Mobile Ads SDK, User Messaging Platform (UMP), CMP, and various ad formats including Collapsible Banners.

> [!NOTE]
> **Revenue Policy:**
> * **No Ad-Sharing:** This plugin is purely rewritten and clean of 3rd party revenue-sharing code.
> * **100% Revenue:** All ad revenue goes directly to you.
> * **No Remote Control:** You have full control over your implementation.


### 🎉 New Milestone 2026
We are starting the year strong! **Version 2.5.9-beta.1** is now available with significant improvements.
👉 [**Check out the Release Notes (v2.5.9-beta.1)**](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/tag/2.5.9-beta.1)

---

## 🚀 Features & Methods

* **Core:** `initialize`, `targeting`, `globalSettings`
* **Privacy & Consent:**
    * AppTrackingTransparency (ATT)
    * CMP SDK (IAB TCF v2.2)
    * UMP SDK
    * CustomConsentManager
* **Ad Formats:**
    * App Open Ads
    * Banner Ads (including Collapsible & Adaptive)
    * Interstitial Ads
    * Rewarded Ads
    * Rewarded Interstitial Ads
* **Revenue & Advanced:**
    * AdSense Support
    * Mediation (Meta, Unity, AppLovin, etc.)
    * Impression-level ad revenue
    * Targeting Request (`targetingAdRequest`, `setPersonalizationState`, `setPPS`)

---

## 📢 Version 2.0.8+ Highlights

* **Android Migration:** Mobile Ads SDK updated from v23 to **v24**.
* **iOS Migration:** Mobile Ads SDK updated from v11 to **v12**.
* **Cordova:** Migrated from Android 13.0.0 to **14.0.1**.
* **Announcement:** [Cordova Android 14.0.0](https://cordova.apache.org/announcements/2025/03/26/cordova-android-14.0.0.html)
* **Release Notes:** [Check all release notes here](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/releases/)
* **Examples:** [Full Source Code Examples](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/tree/main/example/www/js)

### 📦 Current SDK Versions (Maintained & Up-to-Date)

This plugin is regularly updated to support the latest standards.

| Component | Platform | Version | Release Notes |
| :--- | :--- | :--- | :--- |
| **Mobile Ads SDK** | Android | **24.9.0** | [View Notes](https://developers.google.com/admob/android/rel-notes) |
| **UMP SDK** | Android | **4.0.0** | [View Notes](https://developers.google.com/admob/android/privacy/release-notes) |
| **Mobile Ads SDK** | iOS | **12.14.0** | [View Notes](https://developers.google.com/admob/ios/rel-notes) |
| **UMP SDK** | iOS | **3.2.0** | [View Notes](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/privacy/download) |

### Recommended `config.xml` Setup

```xml
<preference name="fullscreen" value="false" /> <preference name="android-minSdkVersion" value="23" />
<preference name="android-targetSdkVersion" value="36" />
```

---

## 📱 Supported Frameworks

This plugin works seamlessly with the following frameworks:

* **Quasar Framework:** [Implementation Discussion](https://github.com/quasarframework/quasar/discussions/17706)
* **Capacitor:** [Implementation Discussion](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/discussions/29)
* **jQuery Mobile:** [Official Site](https://jquerymobile.com/)

---

## 🛠 Installation

### 1. Install Plugin

**Android Only:**
```bash
cordova plugin add emi-indo-cordova-plugin-admob --save --variable APP_ID_ANDROID=ca-app-pub-xxx~xxx
```

**iOS Only:**
```bash
cordova plugin add emi-indo-cordova-plugin-admob --save --variable APP_ID_IOS=ca-app-pub-xxx~xxx
```

**Both Platforms (Recommended):**
```bash
cordova plugin add emi-indo-cordova-plugin-admob --save --variable APP_ID_ANDROID=ca-app-pub-xxx~xxx --variable APP_ID_IOS=ca-app-pub-xxx~xxx
```

**Remove Plugin:**
```bash
cordova plugin rm emi-indo-cordova-plugin-admob
```

### 2. Important Steps for iOS
> [!WARNING]
> To prevent Xcode warnings or errors:
> 1.  After adding the platform/plugin, go to your project root and run: `cordova prepare`
> 2.  Navigate to the iOS folder: `cd platforms/ios`
> 3.  Run Pod install: `pod install --repo-update`

---

## 📸 Screenshots & Demos

**Video Demos:**
* [Banner Top-Center](https://www.youtube.com/watch?v=uQrC0k3-VU8)
* [Banner Bottom-Center](https://www.youtube.com/watch?v=qqxxa2gi7OU)

### Banner Ad: No Overlapping
*The body height is reduced by the height of the banner. Auto-detects full-screen mode.*

<table>
  <tr>
    <td align="left"><strong>Banner Ad</strong></td>
    <td align="center"><strong>Collapsible (Non Full-Screen)</strong></td>
    <td align="center"><strong>Collapsible (Closed)</strong></td>
    <td align="center"><strong>Collapsible (Full-Screen)</strong></td>
    <td align="center"><strong>Collapsible (Closed FS)</strong></td>
  </tr>
  <tr>
    <td></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/53b832d2-8d15-4450-919b-9833569d0ffb" alt="Banner Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/80ebf83f-b8fd-4a4c-8121-e2088005399d" alt="Banner Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/13c3333f-b612-426e-8c3a-1e31695dc548" alt="Banner Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/f4583d93-5764-4d24-a11c-ffdf623cb50a" alt="Banner Ad" /></td>
  </tr>
</table>

### Banner Ad: Overlapping
*The banner overlaps on top of the body. Auto-detects full-screen mode.*

<table>
  <tr>
    <td align="left"><strong>Banner Ad</strong></td>
    <td align="center"><strong>Collapsible (Full-Screen)</strong></td>
    <td align="center"><strong>Collapsible (Closed FS)</strong></td>
    <td align="center"><strong>Collapsible (Non Full-Screen)</strong></td>
    <td align="center"><strong>Collapsible (Closed)</strong></td>
  </tr>
  <tr>
    <td></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/14646090-bbc8-4c31-812b-f945faaadd06" alt="Banner Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/c78e7879-cab6-4963-ad72-4a68316d7181" alt="Banner Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/840ce3ef-60bb-4f74-9705-61d511d964f0" alt="Banner Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/9342fb3b-bb38-4681-a794-44e25d6b9bd8" alt="Banner Ad" /></td>
  </tr>
</table>

### Other Formats

<table>
  <tr>
    <td align="center"><strong>App Open Ad</strong></td>
    <td align="center"><strong>Interstitial Ad</strong></td>
    <td align="center"><strong>Rewarded Ad</strong></td>
    <td align="center"><strong>AdSense</strong></td>
  </tr>
  <tr>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/fc641c56-5219-4f02-8122-6a42a51f0853" alt="App Open Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/7a5c68f2-18f9-4e23-9464-4a4c307f06ae" alt="Interstitial Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/2d87f85e-5fb7-4bf4-8b86-c2411c35fdcf" alt="Rewarded Ad" /></td>
    <td align="center"><img width="180" src="https://github.com/user-attachments/assets/14b289c4-74f7-45a7-9a8a-52df8859afec" alt="AdSense" /></td>
  </tr>
</table>

---

## 📖 API & Usage Guide

### 1. Initialization (Required)
You must initialize the plugin before using any ads.

```javascript
document.addEventListener("deviceready", function(){

    // 1. Initialize
    cordova.plugins.emiAdmobPlugin.initialize({
        isUsingAdManagerRequest: true, // true = AdManager | false = AdMob (Default true)
        isResponseInfo: true,          // Default false (Debug true)
        isConsentDebug: true,          // Default false (Debug true)
    });

    // 2. Listen for SDK Ready
    document.addEventListener('on.sdkInitialization', (data) => {
        // Data available: version, adapters, consentStatus, gdprApplies, etc.
        console.log("On Sdk Initialization version: " + data.version);
        console.log("On Consent Status: " + data.consentStatus);
    });

}, false);
```

**Privacy & Consent (UMP/CMP/ATT):**
```javascript
// Show Privacy Options Form
cordova.plugins.emiAdmobPlugin.showPrivacyOptionsForm();

// Reset Consent (For testing)
cordova.plugins.emiAdmobPlugin.consentReset();

// iOS: Request App Tracking Transparency (ATT)
cordova.plugins.emiAdmobPlugin.requestIDFA();

// CMP SDK 2.2 (Get Data)
cordova.plugins.emiAdmobPlugin.getIabTfc((IABTFC) => { 
    console.log(JSON.stringify(IABTFC)); 
});
```
<details>
<summary>View Consent Events</summary>

```javascript
document.addEventListener('on.get.consent.status', () => {
   console.log("on get consent status");
});

document.addEventListener('on.TCString.expired', () => {
   console.log("on TCString expires 360 days");
   cordova.plugins.emiAdmobPlugin.consentReset();
});
```
</details>


### 2. Banner Ads

```javascript
const bannerConfig = {
   adUnitId: "ca-app-pub-xxx/xxx", 
   position: "bottom-center",       // top-center, bottom-center, etc.
   size: "responsive_adaptive",     // responsive_adaptive, anchored_adaptive, banner, medium_rectangle...
   collapsible: "bottom",           // 'top' | 'bottom' | '' (disable)
   autoShow: true,                  // Show immediately
   isOverlapping: false
}

// Load
cordova.plugins.emiAdmobPlugin.loadBannerAd(bannerConfig);

// Other Methods
cordova.plugins.emiAdmobPlugin.showBannerAd();
cordova.plugins.emiAdmobPlugin.hideBannerAd();
cordova.plugins.emiAdmobPlugin.removeBannerAd();

// Styling (Android Only)
cordova.plugins.emiAdmobPlugin.styleBannerAd({ padding: 50, margins: 50 });
```

<details>
<summary>Banner Events</summary>

```javascript
on.banner.load
on.banner.failed.load
on.banner.click
on.banner.close
on.banner.impression
on.banner.open
on.banner.revenue
on.banner.remove
on.banner.hide
on.is.collapsible
on.bannerAd.responseInfo

// Example:
document.addEventListener('on.is.collapsible', function(event) {
    console.log("Collapsible Status: " + event.collapsible);
});
```
</details>


### 3. Interstitial Ads

```javascript
// Load
cordova.plugins.emiAdmobPlugin.loadInterstitialAd({ 
    adUnitId: "ca-app-pub-xxx/xxx", 
    autoShow: true 
});

// Show manually (if autoShow is false)
cordova.plugins.emiAdmobPlugin.showInterstitialAd();
```

<details>
<summary>Interstitial Events</summary>

```javascript
on.interstitial.loaded
on.interstitial.failed.load
on.interstitial.click
on.interstitial.dismissed
on.interstitial.failed.show
on.interstitial.impression
on.interstitial.show
on.interstitial.revenue
on.interstitialAd.responseInfo

// Reload after dismiss:
document.addEventListener('on.interstitial.dismissed', () => {
   console.log("Ad dismissed. Reloading...");
   // loadInterstitialAd(...);
});
```
</details>


### 4. Rewarded Ads

```javascript
// Load
cordova.plugins.emiAdmobPlugin.loadRewardedAd({ 
    adUnitId: "ca-app-pub-xxx/xxx", 
    autoShow: true 
});

// Show
cordova.plugins.emiAdmobPlugin.showRewardedAd();
```

<details>
<summary>Rewarded Events</summary>

```javascript
on.rewarded.loaded
on.rewarded.failed.load
on.rewarded.click
on.rewarded.dismissed
on.rewarded.failed.show
on.rewarded.impression
on.rewarded.show
on.reward.userEarnedReward
on.rewarded.revenue
on.rewarded.ad.skip
on.rewardedAd.responseInfo
```
</details>


### 5. Rewarded Interstitial Ads

```javascript
// Load
cordova.plugins.emiAdmobPlugin.loadRewardedInterstitialAd({ 
    adUnitId: "ca-app-pub-xxx/xxx", 
    autoShow: true 
});
```
*Supports similar events to Rewarded Ads (replace `rewarded` with `rewardedInt`).*


### 6. App Open Ads

```javascript
cordova.plugins.emiAdmobPlugin.loadAppOpenAd({ 
    adUnitId: "ca-app-pub-xxx/xxx", 
    autoShow: true 
});
```


### 7. Advanced Configuration (Android Only)

**Targeting & PPS:**
```javascript
// 1. Targeting Request
const configAdRequest = {
    customTargetingEnabled: false,
    categoryExclusionsEnabled: false,
    ppIdEnabled: false,
    contentURLEnabled: false,
    brandSafetyEnabled: false,
    customTargetingValue: ["24", "25"], 
    categoryExclusionsValue: "automobile",
    ppIdValue: "AB123456789",
    contentURLValue: "[https://www.example.com](https://www.example.com)"
}
cordova.plugins.emiAdmobPlugin.targetingAdRequest(configAdRequest);

// 2. Personalization State
cordova.plugins.emiAdmobPlugin.setPersonalizationState({
    setPersonalizationState: "disabled" // "disabled" | "enabled"
});

// 3. PPS
cordova.plugins.emiAdmobPlugin.setPPS({
    ppsEnabled: true,
    iabContent: "IAB_AUDIENCE_1_1", 
    ppsArrValue: [6,284]
});
```

### 8. Advanced Configuration (iOS Only)

**Force Privacy Form Display:**
Useful if `TCString` is null due to ATT status.
```javascript
document.addEventListener('on.sdkInitialization', (data) => {
    let userGdpr = data.gdprApplies;
    let userTCString = data.consentTCString;

    if (userGdpr === 1 && userTCString === null){
        cordova.plugins.emiAdmobPlugin.forceDisplayPrivacyForm();
    }
});
```

---

## 🤝 Mediation Support

<details>
<summary>Click to view Mediation Adapters & Installation</summary>

### 1. Meta Audience Network
* Default Adapter: 6.13.7.0
```bash
cordova plugin add emi-indo-cordova-plugin-mediation-meta
```

### 2. Unity Ads
* Default Adapter: 4.6.1.0
```bash
cordova plugin add emi-indo-cordova-plugin-mediation-unity
```

### 3. AppLovin
* Default Adapter: 11.8.2.0
```bash
cordova plugin add emi-indo-cordova-plugin-mediation-applovin
```

### 4. AdColony
* Default Adapter: 4.8.0.1
```bash
cordova plugin add emi-indo-cordova-plugin-mediation-adcolony
```

### 5. Chartboost
* Default Adapter: 9.2.1.0
```bash
cordova plugin add emi-indo-cordova-plugin-mediation-chartboost
```

### 6. ironSource
* Default Adapter: 7.2.7.0
```bash
cordova plugin add emi-indo-cordova-plugin-mediation-ironsource
```

### Locking Adapter Versions
To ensure stability, you can lock specific adapter versions using variables:

**CLI Example:**
```bash
cordova plugin add emi-indo-cordova-plugin-mediation-meta --save --variable META_ADAPTER_VERSION="xxxxx" --variable IOS_META_ADAPTER_VERSION="xxxxx"
```

**Config.xml Example:**
```xml
<preference name="META_ADAPTER_VERSION" value="xxxxx" />
<preference name="IOS_META_ADAPTER_VERSION" value="xxxxx" />
```

**Available Variables:**
* `META_ADAPTER_VERSION` / `IOS_META_ADAPTER_VERSION`
* `UNITY_ADAPTER_VERSION` / `IOS_UNITY_ADAPTER_VERSION`
* `APPLOVIN_ADAPTER_VERSION` / `IOS_APPLOVIN_ADAPTER_VERSION`
* `ADCOLONY_ADAPTER_VERSION` / `IOS_ADCOLONY_ADAPTER_VERSION`
* `CHARTBOOST_ADAPTER_VERSION` / `IOS_CHARTBOOST_ADAPTER_VERSION`
* `IRONSOURCE_ADAPTER_VERSION` / `IOS_IRONSOURCE_ADAPTER_VERSION`

</details>

---

## 📅 Older Versions / History

<details>
<summary>Click to view details for older plugin versions</summary>

### Minimum Engines
* cordova-android version = 12.0.0
* cordova-ios version = 7.0.0

### iOS Notes
* **iOS 18 Support:** [Discussion #42](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/discussions/42)
* **Mobile Ads SDK iOS 11.12.0:** Requires cocoapods 1.16.2+
* **Xcode:** Minimum 15.3+
* **macOS:** Minimum 14.4+
* **Swift:** 5.10+

### Video Tests (Old Versions)
* [Collapsible Banner Test](https://youtu.be/uUivVBC0cqs)
* [UMP/CMP Android Test](https://youtu.be/lELJRKDrkNk)
* [UMP/CMP iOS Test](https://youtu.be/d2dSn4LBvro)
* [Ad Type Test iOS](https://youtu.be/YYMJuf7gIsg)
* [AutoResize Test iOS](https://youtu.be/sLXHKdU6DAg)

</details>

---

## ❤️ Sponsor & Support

To maintain this plugin for the long run and ensure regular updates, please consider supporting the project.



### Other Plugins by EMI-INDO
* [Facebook Audience Network](https://github.com/EMI-INDO/emi-indo-cordova-plugin-fan)
* [Unity Ads](https://github.com/EMI-INDO/emi-indo-cordova-plugin-unityads)
* [Open AI](https://github.com/EMI-INDO/emi-indo-cordova-plugin-open-ai)
* [Firebase Analytics](https://github.com/EMI-INDO/emi-indo-cordova-plugin-fanalytics)