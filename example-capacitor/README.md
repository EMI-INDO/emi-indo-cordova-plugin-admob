# SolidJS + Capacitor + Mobile Ads SDK Template 🚀

This is a starter template for building high-performance hybrid apps using **SolidJS**, **Vite**, and **Capacitor**

## ☁️ Cloud Build (Quick Test)
---

> Fastest test (APK Debug): **[⚡ With github action ](https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/discussions/87)** (Optional)

---

## 📦 Prerequisites

* Node.js (v22+)
* Android Studio (for Android builds)
* Java JDK 21+

## 🛠️ Installation

1.  **Clone or Download** this repository.
2.  Install dependencies:

```bash
npm install
```

3.  Install the emi-indo-cordova-plugin-admob plugin:

```bash
npm install emi-indo-cordova-plugin-admob
```

---

## ⚙️ Configuration (Important)

To ensure the AdMob plugin works correctly with Capacitor, you need to configure the build hooks and App ID.

### 1. Update `package.json`

Add the `update-admob` and `cap-sync` scripts to your `package.json`. The **hook script** is crucial for injecting the App ID into the Android Manifest automatically.

```json
"scripts": {
  "dev": "vite",
  "build": "vite build",
  "capacitor:sync:after": "node node_modules/emi-indo-cordova-plugin-admob/capacitor-hook-admob-ids.js",
  "capacitor:update:after": "node node_modules/emi-indo-cordova-plugin-admob/capacitor-hook-admob-ids.js",
  "cap-sync": "npm run build && npx cap sync"
}
```

### 2. Update `capacitor.config.json`

Add your **App ID** and SDK versions under the `plugins` object.
*(Note: The example below uses Google's Test ID. Replace with your real ID for production).*

```json
{
  "appId": "com.example.solidtest",
  "appName": "SolidAdMob",
  "webDir": "dist",
  "plugins": {
    "AdMob": {
      "APP_ID_ANDROID": "ca-app-pub-3940256099942544~3347511713", 
      "APP_ID_IOS": "ca-app-pub-3940256099942544~1458002511",
      "USE_LITE_ADS": ""
    }
  }
}
```

---

## 📱 Android Setup & Build

Follow these steps carefully to initialize the Android platform.

### Step 1: Add Android Platform

Install the Capacitor Android core and add the platform folder:

```bash
npm install @capacitor/android@8.3.1
npx cap add android
```

### Step 2: Sync with Hook (Crucial Step)

**Do not** run `npx cap sync` manually. Instead, run the custom command we created. This ensures the hook runs and updates `AndroidManifest.xml` and `build.gradle` correctly.

```bash
npm run cap-sync
```

### Step 3: Open Android Studio

Once the sync is complete, open the project in Android Studio:

```bash
npx cap open android
```

---

## 🍏 iOS Setup & Build

Follow these steps carefully to initialize the iOS platform.

### Step 1: Add iOS Platform

Install the Capacitor iOS core and add the platform folder:

```
npm install @capacitor/ios
npx cap add ios
```

### Step 2: Sync with Hook (Crucial Step)

Just like Android, **do not** run `npx cap sync` manually. Run the custom hook command. This is extremely important because it automatically injects your App ID, the App Tracking Transparency (ATT) prompt, and over 40+ SKAdNetwork identifiers directly into your `Info.plist`.

```
npm run cap-sync
```

### Step 3: Open Xcode

Once the sync is complete, open the project in Xcode to build and test:

```
npx cap open ios
```

---

## 💡 Usage in SolidJS

See `src/App.jsx` for a complete example. Since this is a Cordova plugin, you must wait for the `deviceready` event.


## 📄 License

MIT