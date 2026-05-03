import logo from "./logo.svg";
import styles from "./App.module.css";
import { createSignal, onMount, onCleanup } from "solid-js";

function App() {
  const [status, setStatus] = createSignal("Waiting for Device Ready...");
  const [logs, setLogs] = createSignal([]);

  const addLog = (msg) => {
    console.log(msg);
    setLogs((prev) =>
      [`[${new Date().toLocaleTimeString()}] ${msg}`, ...prev].slice(0, 50),
    );
  };

  onMount(() => {
    document.addEventListener("deviceready", onDeviceReady, false);
  });

  onCleanup(() => {
    document.removeEventListener("deviceready", onDeviceReady);
  });

  // For complete example API check out: https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/blob/main/example-cordova/www/js
  const onDeviceReady = () => {
    setStatus("Device Ready. Checking Plugin...");
    const AdMob = window.cordova.plugins.emiAdmobPlugin;

    if (!AdMob) {
      setStatus("ERROR: AdMob Plugin not found!");
      return;
    }

    setupEventListeners();

    // https://developers.google.com/admob/android/targeting
    AdMob.targeting({
        childDirectedTreatment: null, // true|false default: null
        underAgeOfConsent: null, // true || false default: null
        contentRating: "", // value: G | MA | PG | T | default ""
    }, () => {
        addLog("Requesting Targeting...");
        addLog("initSdk...");
        initSdk(AdMob);
      },
      (err) => {
        addLog("Targeting Error: " + JSON.stringify(err));
        initSdk(AdMob);
      },
    );
  };

    

  const initSdk = (AdMob) => {
    setStatus("Initializing SDK...");
    AdMob.initialize({
        isUsingAdManagerRequest: false, // true = AdManager | false = AdMob (Default false)
        isResponseInfo: false, // debug true | Production false
        isConsentDebug: true, // debug true | Production false // Requesting Consent...
    },() => {
        setStatus("SDK Ready! Select an ad format.");
        addLog(">>> Mobile Ads SDK Initialized <<<");
      },
      (err) => {
        setStatus("SDK Init Failed!");
        addLog("Init Error: " + err);
      },
    );
  };

  const setupEventListeners = () => {



    // SDK EVENT Initialization
    // Optional
    document.addEventListener('on.sdkInitialization',  (data) =>
        // JSON.stringify(data)
        addLog(`On Sdk Initialization version: ${data.version}`), // SDK version
        addLog(`On Consent Status: ${data.consentStatus}`), // UMP
        console.log("on personalization state: " + JSON.stringify(data))
    );


    // Optional
    document.addEventListener('on.personalization.state', (data) => 
        console.log("on personalization state: " + JSON.stringify(data)),
        /*
        if (data.personalizationState === "PERSONALIZED"){
            console.log("PERSONALIZED")
         } else if (data.personalizationState === "NON_PERSONALIZED"){
            console.log("NON_PERSONALIZED")
         } if (data.personalizationState === "LIMITED_OR_NO_ADS"){
           console.log("LIMITED_OR_NO_ADS")
        } else {
          console.log("UNKNOWN")
        }
        */
    );


    // Banner specific events
    document.addEventListener("on.banner.load", (data) =>
      addLog(`Banner Loaded height : ${data.height}`),
    );
    document.addEventListener("on.banner.failed.show", (e) =>
      addLog("Banner Fail: " + e.message),
    );

    // Other events
    document.addEventListener("on.interstitial.loaded", () =>
      addLog("Interstitial: LOADED"),
    );
    document.addEventListener("on.interstitial.dismissed", () =>
      addLog("Interstitial: DISMISSED"),
    );
    document.addEventListener("on.rewarded.loaded", () =>
      addLog("Rewarded: LOADED"),
    );
    document.addEventListener("on.reward.userEarnedReward", (e) =>
      addLog(`REWARD: Earned ${e.amount} ${e.currency}`),
    );
    document.addEventListener("on.rewarded.dismissed", () =>
      addLog("Rewarded: DISMISSED"),
    );
    document.addEventListener("on.appOpenAd.loaded", () =>
      addLog("App Open: LOADED"),
    );
    document.addEventListener("on.appOpenAd.dismissed", () =>
      addLog("App Open: DISMISSED"),
    );
  };

  // ================= AD CONTROLS =================

  // 1. BANNER (PUSH CONTENT MODE)
  const showBanner = () => {
    window.cordova.plugins.emiAdmobPlugin.loadBannerAd({
            adUnitId: 'ca-app-pub-3940256099942544/9214589741', 
            position: "bottom-center", //  bottom-center | top-center
            size: "banner", // adaptive | banner | large_banner | full_banner | leaderboard
            collapsible: false, // default false
            autoShow: true, // default false
            isOverlapping: false, // The height of the body is reduced by the height of the banner.
            isCapacitor: true, // only for capacitors: if isOverlapping: false
        //  padding: 10 // Optional: only isOverlapping: false, Extra 20px distance between WebView and Banner
        //  loadInterval: 5 // Opsional: Anti-Flicker/Spam, Default interval 5 seconds, disable 0
        });
    addLog("Requesting Banner (Push Mode)...");
  };

  const showBannerCollapsible = () => {
    window.cordova.plugins.emiAdmobPlugin.loadBannerAd({
            adUnitId: 'ca-app-pub-3940256099942544/9214589741', 
            position: "bottom-center", //  bottom-center | top-center
            size: "banner", // adaptive | banner | large_banner | full_banner | leaderboard
            collapsible: true, // default false
            autoShow: true, // default false
            isOverlapping: false, // The height of the body is reduced by the height of the banner.
            isCapacitor: true, // only for capacitors: if isOverlapping: false
        //  padding: 10 // Optional: only isOverlapping: false, Extra 20px distance between WebView and Banner
        //  loadInterval: 5 // Opsional: Anti-Flicker/Spam, Default interval 5 seconds, disable 0
        });
    addLog("Requesting collapsible Banner (Push Mode)...");
  };

  const removeBanner = () => {
    window.cordova.plugins.emiAdmobPlugin.removeBannerAd();
    addLog("Banner removed");
  };

  // ... (Other functions remain the same: showInterstitial, showRewarded, etc.)
  const loadInterstitial = () => {
    window.cordova.plugins.emiAdmobPlugin.loadInterstitialAd({ 
            adUnitId: "ca-app-pub-3940256099942544/1033173712", 
            autoShow: false,
         // loadInterval: 5 // Opsional: Anti Spam, Default interval 5 seconds, disable 0 
        });
    addLog("Loading Interstitial...");
  };
  const showInterstitial = () => window.cordova.plugins.emiAdmobPlugin.showInterstitialAd();


  const loadRewarded = () => {
    window.cordova.plugins.emiAdmobPlugin.loadRewardedAd({ 
            adUnitId: "ca-app-pub-3940256099942544/5224354917", 
            autoShow: false,
         // loadInterval: 5 // Opsional: Anti Spam, Default interval 5 seconds, disable 0 
        });
    addLog("Loading Rewarded...");
  };
  const showRewarded = () => window.cordova.plugins.emiAdmobPlugin.showRewardedAd();


  const loadAppOpen = () => {
    window.cordova.plugins.emiAdmobPlugin.loadAppOpenAd({ 
            adUnitId: "ca-app-pub-3940256099942544/9257395921", 
            autoShow: false,
         // loadInterval: 5 // Opsional: Anti Spam, Default interval 5 seconds, disable 0
        });;
    addLog("Loading App Open...");
  };


  const showAppOpen = () => window.cordova.plugins.emiAdmobPlugin.showAppOpenAd();


  return (
    // Main container uses Flexbox to push footer to bottom
    <div
      style={{
        display: "flex",
        "flex-direction": "column",
        "min-height": "100vh", // Force full height
        "background-color": "#282c34",
        color: "white",
      }}
    >
      {/* CONTENT AREA (Grows to fill space) */}
      <div style={{ flex: 1, padding: "20px", "text-align": "center" }}>
        <img
          src={logo}
          class={styles.logo}
          alt="logo"
          style={{ height: "80px" }}
        />
        <p style={{ "font-weight": "bold", color: "#4caf50" }}>{status()}</p>

        {/* LOG PANEL */}
        <div
          style={{
            background: "#1e1e1e",
            color: "#0f0",
            padding: "10px",
            height: "150px",
            overflow: "scroll",
            "text-align": "left",
            "font-family": "monospace",
            "font-size": "11px",
            margin: "10px auto",
            border: "1px solid #555",
            "border-radius": "5px",
          }}
        >
          {logs().map((log) => (
            <div>{log}</div>
          ))}
        </div>

        {/* CONTROLS */}
        <div
          style={{
            display: "flex",
            "flex-direction": "column",
            gap: "10px",
            "margin-top": "20px",
          }}
        >
          <div style={btnGroupStyle}>
            <span style={labelStyle}>Banner:</span>
            <button onClick={showBanner}>Show (Push)</button>
            <button onClick={removeBanner} style={{ background: "#d32f2f" }}>
              Remove
            </button>
            <button onClick={showBannerCollapsible}>Show Collapsible (Push)</button>
          </div>

          <div style={btnGroupStyle}>
            <span style={labelStyle}>Interstitial:</span>
            <button onClick={loadInterstitial}>Load</button>
            <button
              onClick={showInterstitial}
              style={{ background: "#ff9800" }}
            >
              Show
            </button>
          </div>

          <div style={btnGroupStyle}>
            <span style={labelStyle}>Rewarded:</span>
            <button onClick={loadRewarded}>Load</button>
            <button onClick={showRewarded} style={{ background: "#ff9800" }}>
              Show
            </button>
          </div>

          <div style={btnGroupStyle}>
            <span style={labelStyle}>App Open:</span>
            <button onClick={loadAppOpen}>Load</button>
            <button onClick={showAppOpen} style={{ background: "#ff9800" }}>
              Show
            </button>
          </div>

        </div>
      </div>

      {/* FOOTER INDICATOR */}
      {/* This element is key. If banner pushes content, this will move UP. */}
      <div
        style={{
          padding: "15px",
          "background-color": "#ffeb3b",
          color: "#000",
          "text-align": "center",
          "font-weight": "bold",
          "border-top": "4px solid #f44336",
        }}
      >
        ⬇️ BOTTOM OF WEBVIEW ⬇️ <br />
        <span style={{ "font-size": "10px" }}>
          If banner is working correctly, this bar should sit ABOVE the ad.
        </span>
      </div>
    </div>
  );
}

// Styling
const btnGroupStyle = {
  display: "grid",
  "grid-template-columns": "80px 1fr 1fr",
  gap: "5px",
  "align-items": "center",
};

const labelStyle = {
  "font-size": "12px",
  "text-align": "right",
  "margin-right": "5px",
};

export default App;
