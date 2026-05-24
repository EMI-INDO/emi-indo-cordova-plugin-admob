// App.jsx

import logo from "./logo.svg";
import styles from "./App.module.css";
import { createSignal, onMount, onCleanup } from "solid-js";

function App() {
  const [status, setStatus] = createSignal("Waiting for Device Ready...");
  const [logs, setLogs] = createSignal([]);

  // Banner Configuration Signals
  const [bannerPos, setBannerPos] = createSignal("bottom-center");
  const [isCollapsible, setIsCollapsible] = createSignal(false);
  const [isOverlapping, setIsOverlapping] = createSignal(false);

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
    // targeting Method optional (If needed, add it directly during initialize)
    AdMob.targeting({
        childDirectedTreatment: null, // true|false default: null (Enable COPPA true)
        underAgeOfConsent: null, // true || false default: null  (Enable teen privacy/TFUA true)
        contentRating: "", // value: G | MA | PG | T | default: ""
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

        // Targeting can be combined here. 
        // childDirectedTreatment: null, // true|false default: null (Enable COPPA true)
        // underAgeOfConsent: null, // true || false default: null (Enable teen privacy/TFUA true)
        // contentRating: "", // value: G | MA | PG | T | default: ""
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
    document.addEventListener('on.sdkInitialization',  (data) => {
        addLog(`On Sdk Initialization version: ${data.version}`);
        addLog(`On Consent Status: ${data.consentStatus}`);
        console.log("on personalization state: " + JSON.stringify(data));
    });

    document.addEventListener('on.personalization.state', (data) => 
        console.log("on personalization state: " + JSON.stringify(data))
    );

    document.addEventListener("on.banner.load", (data) =>
      addLog(`Banner Loaded height : ${data.height}`),
    );
    document.addEventListener("on.banner.failed.show", (e) =>
      addLog("Banner Fail: " + e.message),
    );

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

    /* New large banner size adaptive: (Android | IOS)

    large_anchored_adaptive
    large_portrait_anchored_adaptive
    large_landscape_anchored_adaptive
    current_orientation_inline_adaptive

    */

  // 1. BANNER (Dynamic Configuration)
  const showBanner = () => {
    window.cordova.plugins.emiAdmobPlugin.loadBannerAd({
        adUnitId: 'ca-app-pub-3940256099942544/9214589741', 
        position: bannerPos(), // Get value from signal
        size: "banner", // adaptive | banner | large_banner | full_banner | leaderboard | default: adaptive
        collapsible: isCollapsible(), // Get boolean value from signal
        autoShow: true, 
        isOverlapping: isOverlapping(), // Get boolean value from signal
    });
    addLog(`Requesting Banner (Pos: ${bannerPos()}, Col: ${isCollapsible()}, Over: ${isOverlapping()})`);
  };

  const removeBanner = () => {
    window.cordova.plugins.emiAdmobPlugin.removeBannerAd();
    addLog("Banner removed");
  };

  // 2. INTERSTITIAL
  const loadInterstitial = () => {
    window.cordova.plugins.emiAdmobPlugin.loadInterstitialAd({ 
        adUnitId: "ca-app-pub-3940256099942544/1033173712", 
        autoShow: false,
    });
    addLog("Loading Interstitial...");
  };
  const showInterstitial = () => window.cordova.plugins.emiAdmobPlugin.showInterstitialAd();

  // 3. REWARDED
  const loadRewarded = () => {
    window.cordova.plugins.emiAdmobPlugin.loadRewardedAd({ 
        adUnitId: "ca-app-pub-3940256099942544/5224354917", 
        autoShow: false,
    });
    addLog("Loading Rewarded...");
  };
  const showRewarded = () => window.cordova.plugins.emiAdmobPlugin.showRewardedAd();

  // 4. APP OPEN
  const loadAppOpen = () => {
    window.cordova.plugins.emiAdmobPlugin.loadAppOpenAd({ 
        adUnitId: "ca-app-pub-3940256099942544/9257395921", 
        autoShow: false,
    });
    addLog("Loading App Open...");
  };
  const showAppOpen = () => window.cordova.plugins.emiAdmobPlugin.showAppOpenAd();

  return (
    <div
      style={{
        display: "flex",
        "flex-direction": "column",
        height: "100vh", // Force exactly 100vh to prevent full page scroll
        overflow: "hidden", // Lock body scroll
        "background-color": "#282c34",
        color: "white",
      }}
    >
      {/* CONTENT AREA */}
      <div style={{ flex: 1, padding: "15px", "text-align": "center", display: "flex", "flex-direction": "column", "min-height": 0 }}>
        
        {/* Header Section */}
        <div>
            <img
            src={logo}
            class={styles.logo}
            alt="logo"
            style={{ height: "60px" }}
            />
            <p style={{ "font-weight": "bold", color: "#4caf50", margin: "10px 0", "font-size": "14px" }}>{status()}</p>
        </div>

        {/* Scrollable Container for Controls */}
        <div style={{ flex: 1, overflowY: "auto", padding: "5px", border: "1px solid #444", "border-radius": "8px", "background-color": "#222" }}>
            
            {/* CONTROLS */}
            <div style={{ display: "flex", "flex-direction": "column", gap: "15px", "margin-top": "10px" }}>
            
            {/* Banner Section */}
            <div style={adGroupStyle}>
                <div style={groupTitleStyle}>Banner Ads</div>
                
                {/* Configuration Row */}
                <div style={configRowStyle}>
                    <div style={selectContainerStyle}>
                        <label>Pos:</label>
                        <select style={selectStyle} value={bannerPos()} onInput={(e) => setBannerPos(e.target.value)}>
                            <option value="bottom-center">bottom</option>
                            <option value="top-center">top</option>
                        </select>
                    </div>
                    <div style={selectContainerStyle}>
                        <label>Col:</label>
                        <select style={selectStyle} value={isCollapsible().toString()} onInput={(e) => setIsCollapsible(e.target.value === "true")}>
                            <option value="false">false</option>
                            <option value="true">true</option>
                        </select>
                    </div>
                    <div style={selectContainerStyle}>
                        <label>Over:</label>
                        <select style={selectStyle} value={isOverlapping().toString()} onInput={(e) => setIsOverlapping(e.target.value === "true")}>
                            <option value="false">false</option>
                            <option value="true">true</option>
                        </select>
                    </div>
                </div>

                <div style={btnGroupStyle}>
                    <button onClick={showBanner}>Load & Show</button>
                    <button onClick={removeBanner} style={{ background: "#d32f2f" }}>Remove</button>
                </div>
            </div>

            {/* Interstitial Section */}
            <div style={adGroupStyle}>
                <div style={groupTitleStyle}>Interstitial Ads</div>
                <div style={btnGroupStyle}>
                    <button onClick={loadInterstitial}>Load</button>
                    <button onClick={showInterstitial} style={{ background: "#ff9800" }}>Show</button>
                </div>
            </div>

            {/* Rewarded Section */}
            <div style={adGroupStyle}>
                <div style={groupTitleStyle}>Rewarded Ads</div>
                <div style={btnGroupStyle}>
                    <button onClick={loadRewarded}>Load</button>
                    <button onClick={showRewarded} style={{ background: "#ff9800" }}>Show</button>
                </div>
            </div>

            {/* App Open Section */}
            <div style={adGroupStyle}>
                <div style={groupTitleStyle}>App Open Ads</div>
                <div style={btnGroupStyle}>
                    <button onClick={loadAppOpen}>Load</button>
                    <button onClick={showAppOpen} style={{ background: "#ff9800" }}>Show</button>
                </div>
            </div>

            </div>
        </div>

        {/* LOG PANEL (Fixed at bottom of content area) */}
        <div
          style={{
            background: "#1e1e1e",
            color: "#0f0",
            padding: "10px",
            height: "100px",
            "overflow-y": "auto",
            "text-align": "left",
            "font-family": "monospace",
            "font-size": "10px",
            margin: "15px 0 5px 0",
            border: "1px solid #555",
            "border-radius": "5px",
            "flex-shrink": 0
          }}
        >
          {logs().map((log) => (
            <div>{log}</div>
          ))}
        </div>

      </div>

      {/* FOOTER INDICATOR */}
      <div
        style={{
          padding: "10px",
          "background-color": "#ffeb3b",
          color: "#000",
          "text-align": "center",
          "font-weight": "bold",
          "border-top": "4px solid #f44336",
          "font-size": "12px",
        }}
      >
        ⬇️ BOTTOM OF WEBVIEW ⬇️ <br />
        <span style={{ "font-size": "9px" }}>
          If banner is working correctly, this bar should sit ABOVE the ad.
        </span>
      </div>
    </div>
  );
}

// Styling Objects
const adGroupStyle = {
  "border-bottom": "1px solid #444",
  "padding-bottom": "10px",
  "margin-bottom": "5px"
};

const groupTitleStyle = {
  "font-size": "12px",
  color: "#aaa",
  "text-transform": "uppercase",
  "margin-bottom": "8px",
  "text-align": "left",
  "padding-left": "5px"
};

const configRowStyle = {
  display: "flex",
  "justify-content": "center",
  gap: "10px",
  "margin-bottom": "10px",
  "background-color": "#333",
  padding: "8px",
  "border-radius": "4px"
};

const selectContainerStyle = {
  display: "flex",
  "align-items": "center",
  gap: "4px",
  "font-size": "11px"
};

const selectStyle = {
  color: "black",
  "font-size": "11px",
  padding: "2px",
  "border-radius": "3px"
};

const btnGroupStyle = {
  display: "grid",
  "grid-template-columns": "1fr 1fr",
  gap: "8px",
  padding: "0 5px"
};

export default App;