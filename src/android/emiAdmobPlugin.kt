package emi.indo.cordova.plugin.admob
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.Point
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.DisplayMetrics
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.WindowManager
import android.webkit.WebView
import android.widget.FrameLayout
import androidx.preference.PreferenceManager
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdValue
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.OnPaidEventListener
import com.google.android.gms.ads.RequestConfiguration
import com.google.android.gms.ads.RequestConfiguration.PublisherPrivacyPersonalizationState
import com.google.android.gms.ads.admanager.AdManagerAdRequest
import com.google.android.gms.ads.appopen.AppOpenAd
import com.google.android.gms.ads.appopen.AppOpenAd.AppOpenAdLoadCallback
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardItem
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAdLoadCallback
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentForm
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.FormError
import com.google.android.ump.UserMessagingPlatform
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.CordovaWebView
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean


/**
 * Created by EMI INDO So on Apr 2, 2023
 */
class emiAdmobPlugin : CordovaPlugin() {
    private var PUBLIC_CALLBACKS: CallbackContext? = null

    private var rewardedAd: RewardedAd? = null
    private var rewardedInterstitialAd: RewardedInterstitialAd? = null
    private var cWebView: CordovaWebView? = null
    private var isAppOpenAdShow = false
    private var isInterstitialLoad = false
    private var isRewardedInterstitialLoad = false
    private var isRewardedLoad = false
    private var isBannerPause = 0
    private var isPosition: String? = null
    private var isSize: String? = null

    private var paddingInPx = 0
    private var marginsInPx = 0
    var isResponseInfo: Boolean = false
    private var isAdSkip = 0
    private var isSetTagForChildDirectedTreatment: Boolean = false
    private var isSetTagForUnderAgeOfConsent: Boolean = false
    private var isSetMaxAdContentRating: String = "G"
    private var bannerAdUnitId: String? = null

    private var consentInformation: ConsentInformation? = null

    private var isOverlapping: Boolean = false
    private var overlappingHeight: Int = 0
    private var isStatusBarShow: Boolean = true

    var adType = ""

    var isBannerLoad: Boolean = false
    var isBannerShow: Boolean = false

    var isBannerShows: Boolean = true
    private var bannerAutoShow = false
    // private var isAutoResize: Boolean = false


    var appOpenAutoShow: Boolean = false
    var intAutoShow: Boolean = false
    var rewardedAutoShow: Boolean = false
    var rIntAutoShow: Boolean = false
    var lock: Boolean = true
    private var setDebugGeography: Boolean = false

    private var mInterstitialAd: InterstitialAd? = null
    private var appOpenAd: AppOpenAd? = null
    private var isOrientation: Int = 1

    private var mPreferences: SharedPreferences? = null
    var mBundleExtra: Bundle? = null
    private var collapsiblePos: String? = ""

    // only isUsingAdManagerRequest = true
    private var customTargetingEnabled: Boolean = false
    private var customTargetingList: MutableList<String>? = null
    private var categoryExclusionsEnabled: Boolean = false
    private var cExclusionsValue: String = ""
    private var ppIdEnabled: Boolean = false
    private var ppIdVl: String = ""
    private var ppsEnabled: Boolean = false
    private var ppsVl: String = ""
    private var ppsArrayList: MutableList<Int>? = null
    private var contentURLEnabled: Boolean = false
    private var cURLVl: String = ""
    private var brandSafetyEnabled: Boolean = false
    private var brandSafetyUrls: MutableList<String>? = null

    private var bannerViewLayout: FrameLayout? = null
    private var bannerView: AdView? = null
    private var bannerViewHeight: Int = 0

    private val isMobileAdsInitializeCalled = AtomicBoolean(false)

    private var isUsingAdManagerRequest = false

    private var isCustomConsentManager = false
    private var isEnabledKeyword: Boolean = false
    private var setKeyword: String = ""

    private var mActivity: Activity? = null
    private var mContext: Context? = null

    private var isFullScreen: Boolean = false
    private var bannerOverlapping: Boolean = false

    private var loadBannerCapacitor: Boolean = false
    private var loadBannerCordova: Boolean = false

    override fun pluginInitialize() {
        super.pluginInitialize()

        cWebView = webView
        mActivity = cordova.activity

        if (mActivity != null) {
            mContext = mActivity?.applicationContext
            mPreferences = mContext?.let { PreferenceManager.getDefaultSharedPreferences(it) }
        } else {
            Log.e("PluginCordova", "Activity is null during initialization")
        }
    }


    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        val orientation = newConfig.orientation
        if (orientation != isOrientation) {
            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.screen.rotated');")
            isOrientation = orientation
            when (orientation) {
                Configuration.ORIENTATION_PORTRAIT -> {
                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.orientation.portrait');")
                }
                Configuration.ORIENTATION_LANDSCAPE -> {
                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.orientation.landscape');")
                }
                Configuration.ORIENTATION_UNDEFINED -> {
                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.orientation.undefined');")
                }
                else -> {
                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.orientation.square');")
                }
            }

        }
    }



    @Throws(JSONException::class)
    override fun execute(
        action: String,
        args: JSONArray,
        callbackContext: CallbackContext
    ): Boolean {
        PUBLIC_CALLBACKS = callbackContext

        if (action == "initialize") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    val setAdRequest = options.optBoolean("isUsingAdManagerRequest")
                    val responseInfo = options.optBoolean("isResponseInfo")
                    val setDebugGeography = options.optBoolean("isConsentDebug")
                    setUsingAdManagerRequest(setAdRequest)
                    this.isResponseInfo = responseInfo
                    this.setDebugGeography = setDebugGeography

                    // If the user uses a custom CMP
                    if (this.isCustomConsentManager) {
                        cWebView!!.loadUrl("javascript:cordova.fireDocumentEvent('on.custom.consent.manager.used');")
                        initializeMobileAdsSdk()
                        return@runOnUiThread
                    }

                    val params: ConsentRequestParameters
                    if (this.setDebugGeography) {
                        val debugSettings = mActivity?.let {
                            deviceId?.let { it1 ->
                                ConsentDebugSettings.Builder(it)
                                    .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
                                    .addTestDeviceHashedId(it1).build()
                            }
                        }
                        params = ConsentRequestParameters.Builder()
                            .setConsentDebugSettings(debugSettings).build()
                    } else {
                        params = ConsentRequestParameters.Builder()
                            .setTagForUnderAgeOfConsent(this.isSetTagForUnderAgeOfConsent).build()
                    }

                    consentInformation =
                        mContext?.let { UserMessagingPlatform.getConsentInformation(it) }
                    mActivity?.let {
                        consentInformation?.requestConsentInfoUpdate(
                            it,
                            params,
                            {
                                cWebView!!.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.info.update');")
                                when (consentInformation?.getConsentStatus()) {
                                    ConsentInformation.ConsentStatus.NOT_REQUIRED -> cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.not_required');")

                                    ConsentInformation.ConsentStatus.OBTAINED -> cWebView?.loadUrl( "javascript:cordova.fireDocumentEvent('on.consent.status.obtained');")

                                    ConsentInformation.ConsentStatus.REQUIRED -> { handleConsentForm()
                                        cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.required');")
                                    }

                                    ConsentInformation.ConsentStatus.UNKNOWN -> cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.unknown');")
                                }
                            },
                            { formError: FormError ->
                                if (consentInformation!!.canRequestAds()) {
                                    initializeMobileAdsSdk()
                                }
                                cWebView!!.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.info.update.failed', { message: '" + formError.message + "' });")
                            })
                    }
                    if (consentInformation?.canRequestAds()!!) {
                        initializeMobileAdsSdk()
                    }
                }
            }
            return true

        } else if (action == "targeting") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity!!.runOnUiThread {
                    try {
                        val childDirectedTreatment = options.optBoolean("childDirectedTreatment")
                        val underAgeOfConsent = options.optBoolean("underAgeOfConsent")
                        val contentRating = options.optString("contentRating")
                        this.isSetTagForChildDirectedTreatment = childDirectedTreatment
                        this.isSetTagForUnderAgeOfConsent = underAgeOfConsent
                        this.isSetMaxAdContentRating = contentRating
                        targeting(childDirectedTreatment, underAgeOfConsent, contentRating)
                        callbackContext.success();
                    } catch (e: Exception) {
                        callbackContext.error("targeting Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "targetingAdRequest") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity!!.runOnUiThread {
                    val customTargetingEnabled = options.optBoolean("customTargetingEnabled")
                    val categoryExclusionsEnabled = options.optBoolean("categoryExclusionsEnabled")
                    val ppIdEnabled = options.optBoolean("ppIdEnabled")
                    val contentURLEnabled = options.optBoolean("contentURLEnabled")
                    val brandSafetyEnabled = options.optBoolean("brandSafetyEnabled")

                    val customTargeting = options.optJSONArray("customTargetingValue")
                    val categoryExclusions = options.optString("categoryExclusionsValue")
                    val ppId = options.optString("ppIdValue")
                    val ctURL = options.optString("contentURLValue")
                    val brandSafetyArr = options.optJSONArray("brandSafetyArr")
                    try {
                        this.customTargetingEnabled = customTargetingEnabled
                        this.categoryExclusionsEnabled = categoryExclusionsEnabled
                        this.ppIdEnabled = ppIdEnabled
                        this.contentURLEnabled = contentURLEnabled
                        this.brandSafetyEnabled = brandSafetyEnabled
                        this.cExclusionsValue = categoryExclusions
                        this.ppIdVl = ppId
                        this.cURLVl = ctURL
                        targetingAdRequest( customTargeting, categoryExclusions, ppId, ctURL, brandSafetyArr)
                        callbackContext.success()
                    } catch (e: Exception) {
                        callbackContext.error("targetingAdRequest Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "setPersonalizationState") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity!!.runOnUiThread {
                    val setPPT = options.optString("setPersonalizationState")
                    try {
                        setPersonalizationState(setPPT)
                        callbackContext.success()
                    } catch (e: Exception) {
                        callbackContext.error("setPersonalizationState Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "setPPS") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity!!.runOnUiThread {
                    val ppsEnabled = options.optBoolean("ppsEnabled")
                    val iabContent = options.optString("iabContent")
                    val ppsArrValue = options.optJSONArray("ppsArrValue")
                    try {
                        this.ppsEnabled = ppsEnabled
                        this.ppsVl = iabContent
                        setPublisherProvidedSignals(ppsArrValue)
                        callbackContext.success()
                    } catch (e: Exception) {
                        callbackContext.error("setPPS Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "globalSettings") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity!!.runOnUiThread {
                    val setAppMuted = options.optBoolean("setAppMuted")
                    val setAppVolume = options.optInt("setAppVolume").toFloat()
                    val pubIdEnabled = options.optBoolean("pubIdEnabled")
                    try {
                        globalSettings(setAppMuted, setAppVolume, pubIdEnabled)
                    } catch (e: Exception) {
                        callbackContext.error("globalSettings Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "loadAppOpenAd") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    val adUnitId = options.optString("adUnitId")
                    val autoShow = options.optBoolean("autoShow")
                    try {
                        this.appOpenAutoShow = autoShow
                        AppOpenAd.load(
                            mActivity!!, adUnitId, buildAdRequest(),
                            object : AppOpenAdLoadCallback() {
                                @SuppressLint("DefaultLocale")
                                override fun onAdLoaded(ad: AppOpenAd) {
                                    appOpenAd = ad
                                    isAppOpenAdShow = true

                                    if (appOpenAutoShow) {
                                        openAutoShow()
                                    }

                                    cWebView?.loadUrl(
                                        "javascript:cordova.fireDocumentEvent('on.appOpenAd.loaded');"
                                    )

                                    appOpenAdLoadCallback()

                                    appOpenAd?.onPaidEventListener =
                                        OnPaidEventListener { adValue: AdValue ->
                                            val valueMicros = adValue.valueMicros.takeIf { it > 0 } ?: 0L
                                            val currencyCode = adValue.currencyCode.ifBlank { "UNKNOWN" }
                                            val precision = adValue.precisionType.takeIf { it >= 0 } ?: AdValue.PrecisionType.UNKNOWN
                                            val appOpenAdAdUnitId = appOpenAd?.adUnitId ?: "null"

                                            val result = JSONObject()
                                            try {
                                                result.put("micros", valueMicros)
                                                result.put("currency", currencyCode)
                                                result.put("precision", precision)
                                                result.put("adUnitId", appOpenAdAdUnitId)

                                                cWebView!!.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.revenue', ${result})")

                                            } catch (e: JSONException) {
                                                callbackContext.error("loadAppOpenAd Error: " + e.message)
                                            }
                                        }


                                    if (isResponseInfo) {
                                        val result = JSONObject()
                                        val responseInfo = appOpenAd?.responseInfo
                                        try {
                                            result.put("getResponseId", responseInfo?.responseId.toString())
                                            result.put("getAdapterResponses", responseInfo?.adapterResponses.toString())
                                            result.put("getResponseExtras", responseInfo?.responseExtras.toString())
                                            result.put("getMediationAdapterClassName", responseInfo?.mediationAdapterClassName.toString())
                                            result.put("getBundleExtra", mBundleExtra.toString())
                                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.responseInfo', ${result})")
                                        } catch (e: JSONException) {
                                            callbackContext.error("loadAppOpenAd Error: " + e.message)
                                        }


                                    }


                                }

                                private fun openAutoShow() {
                                    try {
                                        if (mActivity != null && isAppOpenAdShow && appOpenAd != null) {
                                            mActivity?.runOnUiThread {
                                                appOpenAd?.show(
                                                    mActivity!!
                                                ) ?: callbackContext.error("Failed to show App Open Ad")
                                            }
                                        }
                                    } catch (e: Exception) {
                                        PUBLIC_CALLBACKS?.error("loadAppOpenAd Error: " + e.message)
                                    }
                                }

                                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                                    isAppOpenAdShow = false
                                    val errorData = JSONObject().apply {
                                        put("code", loadAdError.code)
                                        put("message", loadAdError.message)
                                        put("domain", loadAdError.domain)
                                        put("cause", loadAdError.cause?.toString() ?: "null")

                                        val responseId = loadAdError.responseInfo?.responseId.toString()
                                        val responseExtras = loadAdError.responseInfo?.responseExtras.toString()
                                        val loadedAdapterResponseInfo = loadAdError.responseInfo?.loadedAdapterResponseInfo.toString()
                                        val mediationAdapterClassName = loadAdError.responseInfo?.mediationAdapterClassName.toString()
                                        val adapterResponses = loadAdError.responseInfo?.adapterResponses.toString()

                                        put("responseInfoId", responseId)
                                        put("responseInfoExtras", responseExtras)
                                        put("responseInfoAdapter", loadedAdapterResponseInfo)
                                        put("responseInfoMediationAdapterClassName", mediationAdapterClassName)
                                        put("responseInfoAdapterResponses", adapterResponses)
                                    }
                                    cWebView?.loadUrl(
                                        "javascript:cordova.fireDocumentEvent('on.appOpenAd.failed.loaded', ${errorData});"
                                    )
                                }

                            })
                    } catch (e: Exception) {
                        callbackContext.error("loadAppOpenAd Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "showAppOpenAd") {

            try {
                if (mActivity != null && isAppOpenAdShow && appOpenAd != null) {
                    mActivity?.runOnUiThread { appOpenAd?.show(mActivity!!) ?: callbackContext.error("Failed to show App Open Ad") }
                    appOpenAdLoadCallback()
                } else {
                    callbackContext.error("The App Open Ad wasn't ready yet")
                }
            } catch (e: Exception) {
                PUBLIC_CALLBACKS?.error("showAppOpenAd Error: " + e.message)
            }

            return true
        } else if (action == "loadInterstitialAd") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    val adUnitId = options.optString("adUnitId")
                    val autoShow = options.optBoolean("autoShow")
                    try {
                        this.intAutoShow = autoShow
                        InterstitialAd.load(
                            mActivity!!, adUnitId, buildAdRequest(),
                            object : InterstitialAdLoadCallback() {
                                override fun onAdLoaded(interstitialAd: InterstitialAd) {
                                    isInterstitialLoad = true
                                    mInterstitialAd = interstitialAd

                                    if (intAutoShow) {
                                        isIntAutoShow
                                    }

                                    cWebView?.loadUrl(
                                        "javascript:cordova.fireDocumentEvent('on.interstitial.loaded');"
                                    )

                                    interstitialAdLoadCallback()

                                    if (isResponseInfo) {
                                        val result = JSONObject()
                                        val responseInfo = mInterstitialAd?.responseInfo
                                        try {
                                            result.put("getResponseId", responseInfo?.responseId)
                                            result.put("getAdapterResponses", responseInfo?.adapterResponses)
                                            result.put("getResponseExtras", responseInfo?.responseExtras)
                                            result.put("getMediationAdapterClassName", responseInfo?.mediationAdapterClassName)
                                            result.put("getBundleExtra", mBundleExtra.toString())
                                            cWebView!!.loadUrl( "javascript:cordova.fireDocumentEvent('on.interstitialAd.responseInfo', ${result});")

                                        } catch (e: JSONException) {
                                            callbackContext.error("loadInterstitialAd Error: " + e.message)
                                        }
                                    }
                                    mInterstitialAd?.onPaidEventListener =
                                        OnPaidEventListener { adValue: AdValue ->
                                            val valueMicros = adValue.valueMicros.takeIf { it > 0 } ?: 0L
                                            val currencyCode = adValue.currencyCode.ifBlank { "UNKNOWN" }
                                            val precision = adValue.precisionType.takeIf { it >= 0 } ?: AdValue.PrecisionType.UNKNOWN
                                            val interstitialAdUnitId = mInterstitialAd?.adUnitId ?: "null"
                                            val result = JSONObject()
                                            try {
                                                result.put("micros", valueMicros)
                                                result.put("currency", currencyCode)
                                                result.put("precision", precision)
                                                result.put("adUnitId", interstitialAdUnitId)
                                                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.revenue', ${result});")

                                            } catch (e: JSONException) {
                                                callbackContext.error("loadInterstitialAd Error: " + e.message)
                                            }

                                        }
                                }

                                private val isIntAutoShow: Unit
                                    get() {
                                        if (mActivity != null && isInterstitialLoad && mInterstitialAd != null) {
                                            mActivity?.runOnUiThread {
                                                mInterstitialAd?.show(
                                                    mActivity!!
                                                ) ?: callbackContext.error("Failed to show Interstitial Ad")
                                            }
                                        }
                                    }

                                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                                    mInterstitialAd = null
                                    isInterstitialLoad = false

                                    val errorData = JSONObject().apply {
                                        put("code", loadAdError.code)
                                        put("message", loadAdError.message)
                                        put("domain", loadAdError.domain)
                                        put("cause", loadAdError.cause?.toString() ?: "null")

                                        val responseId = loadAdError.responseInfo?.responseId.toString()
                                        val responseExtras = loadAdError.responseInfo?.responseExtras.toString()
                                        val loadedAdapterResponseInfo = loadAdError.responseInfo?.loadedAdapterResponseInfo.toString()
                                        val mediationAdapterClassName = loadAdError.responseInfo?.mediationAdapterClassName.toString()
                                        val adapterResponses = loadAdError.responseInfo?.adapterResponses.toString()

                                        put("responseInfoId", responseId)
                                        put("responseInfoExtras", responseExtras)
                                        put("responseInfoAdapter", loadedAdapterResponseInfo)
                                        put("responseInfoMediationAdapterClassName", mediationAdapterClassName)
                                        put("responseInfoAdapterResponses", adapterResponses)
                                    }

                                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.failed.load', ${errorData});")

                                }
                            })
                    } catch (e: Exception) {
                        callbackContext.error("loadInterstitialAd Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "showInterstitialAd") {

            if (mActivity != null && isInterstitialLoad && mInterstitialAd != null) {
                mActivity?.runOnUiThread { mInterstitialAd?.show(mActivity!!)  ?: callbackContext.error("Failed to show Interstitial Ad") }
                interstitialAdLoadCallback()
            } else {
                callbackContext.error("The Interstitial ad wasn't ready yet")
            }
            return true
        } else if (action == "loadRewardedAd") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    val adUnitId = options.optString("adUnitId")
                    val autoShow = options.optBoolean("autoShow")
                    try {
                        this.rewardedAutoShow = autoShow
                        RewardedAd.load(
                            mActivity!!, adUnitId, buildAdRequest(),
                            object : RewardedAdLoadCallback() {
                                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                                    rewardedAd = null
                                    isRewardedLoad = false

                                    val errorData = JSONObject().apply {
                                        put("code", loadAdError.code)
                                        put("message", loadAdError.message)
                                        put("domain", loadAdError.domain)
                                        put("cause", loadAdError.cause?.toString() ?: "null")


                                        val responseId = loadAdError.responseInfo?.responseId.toString()
                                        val responseExtras = loadAdError.responseInfo?.responseExtras.toString()
                                        val loadedAdapterResponseInfo = loadAdError.responseInfo?.loadedAdapterResponseInfo.toString()
                                        val mediationAdapterClassName = loadAdError.responseInfo?.mediationAdapterClassName.toString()
                                        val adapterResponses = loadAdError.responseInfo?.adapterResponses.toString()

                                        put("responseInfoId", responseId)
                                        put("responseInfoExtras", responseExtras)
                                        put("responseInfoAdapter", loadedAdapterResponseInfo)
                                        put("responseInfoMediationAdapterClassName", mediationAdapterClassName)
                                        put("responseInfoAdapterResponses", adapterResponses)

                                    }

                                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.failed.load', ${errorData});")

                                }

                                override fun onAdLoaded(ad: RewardedAd) {
                                    rewardedAd = ad
                                    isRewardedLoad = true
                                    isAdSkip = 0
                                    if (rewardedAutoShow) {
                                        isRewardedAutoShow
                                    }


                                    rewardedAdLoadCallback()

                                    cWebView?.loadUrl( "javascript:cordova.fireDocumentEvent('on.rewarded.loaded');")

                                    rewardedAd?.onPaidEventListener =
                                        OnPaidEventListener { adValue: AdValue ->
                                            val valueMicros = adValue.valueMicros.takeIf { it > 0 } ?: 0L
                                            val currencyCode = adValue.currencyCode.ifBlank { "UNKNOWN" }
                                            val precision = adValue.precisionType.takeIf { it >= 0 } ?: AdValue.PrecisionType.UNKNOWN
                                            val rewardedAdAdUnitId = rewardedAd?.adUnitId ?: "null"
                                            val result = JSONObject()
                                            try {
                                                result.put("micros", valueMicros)
                                                result.put("currency", currencyCode)
                                                result.put("precision", precision)
                                                result.put("adUnitId", rewardedAdAdUnitId)
                                                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.revenue', ${result});")
                                            } catch (e: JSONException) {
                                                callbackContext.error("loadRewardedAd Error: " + e.message)
                                            }

                                        }



                                    if (isResponseInfo) {
                                        val result = JSONObject()
                                        val responseInfo = rewardedAd?.responseInfo
                                        try {
                                            result.put("getResponseId", responseInfo?.responseId)
                                            result.put("getAdapterResponses", responseInfo?.adapterResponses)
                                            result.put("getResponseExtras", responseInfo?.responseExtras)
                                            result.put("getMediationAdapterClassName", responseInfo?.mediationAdapterClassName)
                                            result.put("getBundleExtra", mBundleExtra.toString())
                                            cWebView!!.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedAd.responseInfo', ${result})")
                                        } catch (e: JSONException) {
                                            callbackContext.error("loadRewardedAd Error: " + e.message)
                                        }
                                    }


                                }

                                private val isRewardedAutoShow: Unit
                                    get() {
                                        if (mActivity != null) {
                                            mActivity?.runOnUiThread {
                                                if (isRewardedLoad && rewardedAd != null) {
                                                    isAdSkip = 1
                                                    rewardedAd?.show(mActivity!!) { rewardItem: RewardItem ->
                                                        isAdSkip = 2
                                                        val rewardAmount = rewardItem.amount
                                                        val rewardType = rewardItem.type
                                                        val result = JSONObject()
                                                        try {
                                                            result.put("rewardType", rewardType)
                                                            result.put("rewardAmount", rewardAmount)
                                                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.reward.userEarnedReward', ${result});")
                                                        } catch (e: JSONException) {
                                                            callbackContext.error("loadRewardedAd Error: " + e.message)
                                                        }

                                                    }
                                                }
                                            }
                                        }
                                    }
                            })
                    } catch (e: Exception) {
                        callbackContext.error("loadRewardedAd Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "showRewardedAd") {
            if (mActivity != null && isRewardedLoad && rewardedAd != null) {
                mActivity?.runOnUiThread {
                    isAdSkip = 1
                    rewardedAd?.show(mActivity!!) { rewardItem: RewardItem ->
                        isAdSkip = 2
                        val rewardAmount = rewardItem.amount
                        val rewardType = rewardItem.type
                        val result = JSONObject()
                        try {
                            result.put("rewardType", rewardType)
                            result.put("rewardAmount", rewardAmount)
                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.reward.userEarnedReward', ${result});")
                        } catch (e: JSONException) {
                            callbackContext.error("showRewardedAd Error: " + e.message)
                        }

                    }
                    rewardedAdLoadCallback()

                }

            } else {
                callbackContext.error("The rewarded ad wasn't ready yet")
            }
            return true

        } else if (action == "loadRewardedInterstitialAd") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    val adUnitId = options.optString("adUnitId")
                    val autoShow = options.optBoolean("autoShow")
                    try {
                        this.rIntAutoShow = autoShow
                        RewardedInterstitialAd.load(
                            mActivity!!, adUnitId, buildAdRequest(),
                            object : RewardedInterstitialAdLoadCallback() {
                                override fun onAdLoaded(ad: RewardedInterstitialAd) {
                                    rewardedInterstitialAd = ad
                                    isRewardedInterstitialLoad = true
                                    isAdSkip = 0

                                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.loaded');")

                                    if (rIntAutoShow) {
                                        isRIntAutoShow
                                    }

                                    rewardedInterstitialAdLoadCallback()

                                    rewardedInterstitialAd?.onPaidEventListener =
                                        OnPaidEventListener { adValue: AdValue ->
                                            val valueMicros = adValue.valueMicros.takeIf { it > 0 } ?: 0L
                                            val currencyCode = adValue.currencyCode.ifBlank { "UNKNOWN" }
                                            val precision = adValue.precisionType.takeIf { it >= 0 } ?: AdValue.PrecisionType.UNKNOWN
                                            val rewardedIntAdUnitId = rewardedInterstitialAd?.adUnitId ?: "null"
                                            val result = JSONObject()
                                            try {
                                                result.put("micros", valueMicros)
                                                result.put("currency", currencyCode)
                                                result.put("precision", precision)
                                                result.put("adUnitId", rewardedIntAdUnitId)
                                                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.revenue', ${result});")
                                            } catch (e: JSONException) {
                                                callbackContext.error("loadRewardedInterstitialAd Error: " + e.message)
                                            }

                                        }


                                    if (isResponseInfo) {
                                        val result = JSONObject()
                                        val responseInfo = rewardedInterstitialAd?.responseInfo
                                        try {
                                            result.put("getResponseId", responseInfo?.responseId)
                                            result.put("getAdapterResponses", responseInfo?.adapterResponses)
                                            result.put("getResponseExtras", responseInfo?.responseExtras)
                                            result.put("getMediationAdapterClassName", responseInfo?.mediationAdapterClassName)
                                            result.put("getBundleExtra", mBundleExtra.toString())
                                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedIntAd.responseInfo', ${result});")
                                        } catch (e: JSONException) {
                                            callbackContext.error("loadRewardedInterstitialAd Error: " + e.message)
                                        }
                                    }


                                }


                                private val isRIntAutoShow: Unit
                                    get() {
                                        if (mActivity !== null) {
                                            mActivity?.runOnUiThread {
                                                if (isRewardedInterstitialLoad && rewardedInterstitialAd != null) {
                                                    isAdSkip = 1
                                                    rewardedInterstitialAd?.show(mActivity!!) { rewardItem: RewardItem ->
                                                        isAdSkip = 2
                                                        val rewardAmount = rewardItem.amount
                                                        val rewardType = rewardItem.type
                                                        val result = JSONObject()
                                                        try {
                                                            result.put("rewardType", rewardType)
                                                            result.put("rewardAmount", rewardAmount)
                                                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.userEarnedReward', ${result});")
                                                        } catch (e: JSONException) {
                                                            callbackContext.error("loadRewardedInterstitialAd Error: " + e.message)
                                                        }

                                                    }
                                                }
                                            }
                                        }
                                    }

                                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                                    rewardedInterstitialAd = null
                                    isRewardedInterstitialLoad = false
                                    val errorData = JSONObject().apply {
                                        put("code", loadAdError.code)
                                        put("message", loadAdError.message)
                                        put("domain", loadAdError.domain)
                                        put("cause", loadAdError.cause?.toString() ?: "null")

                                        val responseId = loadAdError.responseInfo?.responseId.toString()
                                        val responseExtras = loadAdError.responseInfo?.responseExtras.toString()
                                        val loadedAdapterResponseInfo = loadAdError.responseInfo?.loadedAdapterResponseInfo.toString()
                                        val mediationAdapterClassName = loadAdError.responseInfo?.mediationAdapterClassName.toString()
                                        val adapterResponses = loadAdError.responseInfo?.adapterResponses.toString()

                                        put("responseInfoId", responseId)
                                        put("responseInfoExtras", responseExtras)
                                        put("responseInfoAdapter", loadedAdapterResponseInfo)
                                        put("responseInfoMediationAdapterClassName", mediationAdapterClassName)
                                        put("responseInfoAdapterResponses", adapterResponses)
                                    }
                                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.failed.load', ${errorData});")

                                }
                            })
                    } catch (e: Exception) {
                        callbackContext.error("loadRewardedInterstitialAd Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "showRewardedInterstitialAd") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    if (isRewardedInterstitialLoad && rewardedInterstitialAd != null) {
                        isAdSkip = 1
                        rewardedInterstitialAd?.show(mActivity!!) { rewardItem: RewardItem ->
                            isAdSkip = 2
                            val rewardAmount = rewardItem.amount
                            val rewardType = rewardItem.type
                            val result = JSONObject()
                            try {
                                result.put("rewardType", rewardType)
                                result.put("rewardAmount", rewardAmount)
                                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.userEarnedReward', ${result});")
                            } catch (e: JSONException) {
                                callbackContext.error("loadRewardedInterstitialAd Error: " + e.message)
                            }

                        }
                        rewardedInterstitialAdLoadCallback()
                    } else {
                        callbackContext.error("The rewarded ad wasn't ready yet")
                    }
                }
            }
            return true

        } else if (action == "showPrivacyOptionsForm") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    try {
                        val params: ConsentRequestParameters
                        if (this.setDebugGeography) {
                            val debugSettings = deviceId?.let {
                                mActivity?.let { it1 ->
                                    ConsentDebugSettings.Builder(it1)
                                        .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
                                        .addTestDeviceHashedId(it).build()
                                }
                            }
                            params = ConsentRequestParameters.Builder()
                                .setConsentDebugSettings(debugSettings).build()
                        } else {
                            params = ConsentRequestParameters.Builder()
                                .setTagForUnderAgeOfConsent(this.isSetTagForUnderAgeOfConsent)
                                .build()
                        }
                        consentInformation = mContext?.let {
                            UserMessagingPlatform.getConsentInformation(
                                it
                            )
                        }
                        mActivity?.let {
                            consentInformation?.requestConsentInfoUpdate(
                                it,
                                params,
                                {
                                    mActivity?.let { it1 ->
                                        UserMessagingPlatform.loadAndShowConsentFormIfRequired(
                                            it1
                                        ) { loadAndShowError: FormError? ->
                                            if (loadAndShowError != null) {
                                                mActivity?.runOnUiThread {
                                                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.show', { message: '" + loadAndShowError.message + "' });")
                                                }
                                            }
                                            if (isPrivacyOptionsRequired == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED) {
                                                mActivity?.let { it2 ->
                                                    UserMessagingPlatform.showPrivacyOptionsForm(
                                                        it2
                                                    ) { formError: FormError? ->
                                                        if (formError != null) {
                                                            mActivity?.runOnUiThread {
                                                                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.show.options', { message: '" + formError.message + "' });")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                },
                                { requestConsentError: FormError ->
                                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.info.update.failed', { message: '" + requestConsentError.message + "' });")
                                })
                        }
                    } catch (e: Exception) {
                        callbackContext.error("showPrivacyOptionsForm Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "consentReset") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    try {
                        consentInformation?.reset()
                    } catch (e: Exception) {
                        callbackContext.error("consentReset Error: " + e.message)
                    }
                }
            }
            return true
        } else if (action == "getIabTfc") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    val gdprApplies = mPreferences?.getInt("IABTCF_gdprApplies", 0)
                    val purposeConsents = mPreferences?.getString("IABTCF_PurposeConsents", "")
                    val vendorConsents = mPreferences?.getString("IABTCF_VendorConsents", "")
                    val consentString = mPreferences?.getString("IABTCF_TCString", "")
                    val userInfoJson = JSONObject()
                    try {
                        userInfoJson.put("IABTCF_gdprApplies", gdprApplies)
                        userInfoJson.put("IABTCF_PurposeConsents", purposeConsents)
                        userInfoJson.put("IABTCF_VendorConsents", vendorConsents)
                        userInfoJson.put("IABTCF_TCString", consentString)
                        val editor = mPreferences!!.edit()
                        editor.putString("IABTCF_TCString", consentString)
                        editor.putLong(LAST_ACCESS_SUFFIX, System.currentTimeMillis())
                        editor.apply()
                        getString(consentString.toString())
                        callbackContext.success(userInfoJson)
                        cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.getIabTfc');")
                    } catch (e: Exception) {
                        callbackContext.error("getIabTfc Error: " + e.message)
                        cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.getIabTfc.error');")
                    }
                }
            }
            return true

        } else if (action == "loadBannerCordova") {
            if (mActivity != null) {
                val options = args.getJSONObject(0)
                mActivity?.runOnUiThread {
                    val adUnitId = options.optString("adUnitId")
                    val position = options.optString("position")
                    val collapsible = options.optString("collapsible")
                    val size = options.optString("size")
                    val autoShow = options.optBoolean("autoShow")
                    this.bannerAdUnitId = adUnitId
                    this.isPosition = position
                    this.isSize = size
                    this.bannerAutoShow = autoShow
                    this.collapsiblePos = collapsible
                    this.loadBannerCordova = true

                    try {
                        loadBannerAd(adUnitId, position, size)
                    } catch (e: Exception) {
                        callbackContext.error("loadBannerAd Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "loadBannerCapacitor") {
            if (mActivity != null) {
                val options = args.getJSONObject(0)
                mActivity?.runOnUiThread {
                    val adUnitId = options.optString("adUnitId")
                    val position = options.optString("position")
                    val collapsible = options.optString("collapsible")
                    val size = options.optString("size")
                    val autoShow = options.optBoolean("autoShow")
                    this.bannerAdUnitId = adUnitId
                    this.isPosition = position
                    this.isSize = size
                    this.bannerAutoShow = autoShow
                    this.collapsiblePos = collapsible
                    this.loadBannerCapacitor = true

                    try {
                        loadBannerAd(adUnitId, position, size)
                    } catch (e: Exception) {
                        callbackContext.error("loadBannerAd Error: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "showBannerAd") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    if (isBannerPause == 0) {
                        isShowBannerAds
                    } else if (isBannerPause == 1) {
                        try {
                            bannerView?.visibility = View.VISIBLE
                            bannerView?.resume()

                            if (loadBannerCordova) {
                                if (isPosition == "top-center") {
                                    setBannerAdTopCordova()
                                } else {
                                    setBannerAdBottomCordova()
                                }
                            } else if (loadBannerCapacitor) {
                                if (isPosition == "top-center") {
                                    setBannerAdTopCapacitor()
                                } else {
                                    setBannerAdBottomCapacitor()
                                }
                            }

                            bannerViewLayout?.requestFocus()

                        } catch (e: Exception) {
                            callbackContext.error("showBannerAd Error: " + e.message)
                        }
                    }
                }
            }
            return true

        } else if (action == "styleBannerAd") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {

                val screenHeight: Int
                val usableHeight: Int

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    val windowMetrics = cordova.activity.windowManager.currentWindowMetrics
                    val insets = windowMetrics.windowInsets.getInsetsIgnoringVisibility(WindowInsets.Type.navigationBars())
                    screenHeight = windowMetrics.bounds.height()
                    usableHeight = screenHeight - insets.bottom
                } else {
                    @Suppress("DEPRECATION")
                    val display = cordova.activity.windowManager.defaultDisplay
                    val size = Point()
                    val realSize = Point()
                    @Suppress("DEPRECATION")
                    display.getSize(size)
                    @Suppress("DEPRECATION")
                    display.getRealSize(realSize)

                    usableHeight = size.y
                    screenHeight = realSize.y
                }

                val navBarHeight = maxOf(0, screenHeight - usableHeight)

                val isOverlapping = options.optBoolean("isOverlapping", false)
                val setStatusBarShow = options.optBoolean("isStatusBarShow", true)
                val overlappingHeight = options.optInt("overlappingHeight", navBarHeight)
                val paddingPx = options.optInt("padding", 0)
                val marginsPx = options.optInt("margins", navBarHeight)

                this.isOverlapping = isOverlapping
                this.isStatusBarShow = setStatusBarShow
                this.overlappingHeight = if (overlappingHeight > 0) overlappingHeight else navBarHeight
                this.paddingInPx = paddingPx
                this.marginsInPx = if (marginsPx > 0) marginsPx else navBarHeight

                cordova.getThreadPool().execute {

                    try {

                        val eventData = """
                    {
                        "navBarHeight": "$navBarHeight",
                        "screenHeight": "$screenHeight",
                        "usableHeight": "$usableHeight",
                        "isOverlapping": $isOverlapping,
                        "overlappingHeight": "$overlappingHeight",
                        "paddingInPx": "$paddingPx",
                        "marginsInPx": "$marginsInPx"
                    }
                """.trimIndent()

                        mActivity?.runOnUiThread { cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.style.banner.ad', $eventData)") }
                    } catch (e: Exception) {
                        callbackContext.error("Error in styleBannerAd: ${e.message}")
                    }

                }
            }
            return true

        } else if (action == "metaData") {
            val options = args.getJSONObject(0)
            val useCustomConsentManager = options.optBoolean("useCustomConsentManager")
            val useCustomKeyword = options.optBoolean("isEnabledKeyword")
            val keywordValue = options.optString("setKeyword")
            if (mActivity != null) {
                this.isCustomConsentManager = useCustomConsentManager
                this.isEnabledKeyword = useCustomKeyword
                this.setKeyword = keywordValue
            }
            return true
        } else if (action == "hideBannerAd") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    if (isBannerShow) {
                        try {
                            bannerView?.visibility = View.GONE
                            bannerView?.pause()
                            isBannerLoad = false
                            isBannerPause = 1
                            bannerOverlappingToZero()
                        } catch (e: Exception) {
                            callbackContext.error("hideBannerAd Error: " + e.message)
                        }
                    }
                }
            }
            return true

        } else if (action == "removeBannerAd") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    try {
                        if (bannerViewLayout != null && bannerView != null) {
                            bannerOverlappingToZero()
                            bannerViewLayout?.removeView(bannerView)
                            bannerView?.destroy()
                            bannerView = null
                            bannerViewLayout = null
                            isBannerLoad = false
                            isBannerShow = false
                            isBannerPause = 2
                            lock = true
                        }
                    } catch (e: Exception) {
                        PUBLIC_CALLBACKS?.error("Error removing banner: " + e.message)
                    }
                }
            }
            return true

        } else if (action == "registerWebView") {
            if (mActivity != null) {
                mActivity?.runOnUiThread {
                    try {
                        registerWebView(callbackContext)
                    } catch (e: Exception) {
                        PUBLIC_CALLBACKS?.error("Error register WebView: " + e.message)
                    }
                }
            }
            return true
        } else if (action == "loadUrl") {
            val options = args.getJSONObject(0)
            if (mActivity != null) {
                val url = options.optString("url")
                mActivity?.runOnUiThread {
                    try {
                        loadUrl(url, callbackContext)
                    } catch (e: Exception) {
                        PUBLIC_CALLBACKS?.error("Error load Url: " + e.message)
                    }
                }

            }
            return true
        }
        return false
    }


    private fun registerWebView(callbackContext: CallbackContext) {
        try {
            val webView = cWebView?.view
            if (webView is WebView) {
                MobileAds.registerWebView(webView)
                callbackContext.success("WebView registered successfully")
            } else {
                callbackContext.error("View is not a WebView.")
            }
        } catch (e: Exception) {
            callbackContext.error("Error registering WebView: ${e.message}")
        }

    }


    private fun loadUrl(url: String, callbackContext: CallbackContext) {
        try {
            val webView = cWebView?.view

            if (webView is WebView) {
                webView.loadUrl(url)
                callbackContext.success("URL loaded successfully: $url")
            } else {
                callbackContext.error("WebView is not available.")
            }

        } catch (e: Exception) {
            callbackContext.error("Error loading URL: ${e.message}")
        }
    }



    private fun loadBannerAd(adUnitId: String, position: String, size: String) {
        adType = size
        try {
            if (bannerViewLayout == null) {
                bannerViewLayout = FrameLayout(mActivity!!)
                val params = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
                val decorView = mActivity?.window?.decorView as ViewGroup
                decorView.addView(bannerViewLayout, params)
                bannerView = AdView(mActivity!!)
                setBannerPosition(position)
                setBannerSize(size)
                bannerView?.adUnitId = adUnitId
                bannerView?.adListener = bannerAdListener
                bannerView?.loadAd(buildAdRequest())
            } else {
                PUBLIC_CALLBACKS?.error("Banner view layout already exists.")
            }
        } catch (e: Exception) {
            PUBLIC_CALLBACKS?.error("Error showing banner: " + e.message)
        }
    }




    @SuppressLint("RtlHardcoded")
    private fun setBannerPosition(position: String?) {
        val bannerParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        )

        when (position) {
            "top-right" -> {
                bannerParams.gravity = Gravity.TOP or Gravity.RIGHT
                bannerParams.setMargins(0, marginsInPx, marginsInPx, 0)
                bannerViewLayout!!.setPadding(0, paddingInPx, paddingInPx, 0)
            }

            "top-center" -> {
                bannerParams.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                bannerParams.setMargins(0, marginsInPx, 0, 0)
                bannerViewLayout!!.setPadding(0, paddingInPx, 0, 0)

            }

            "left" -> {
                bannerParams.gravity = Gravity.LEFT or Gravity.CENTER_VERTICAL
                bannerParams.setMargins(marginsInPx, 0, 0, 0)
                bannerViewLayout!!.setPadding(paddingInPx, 0, 0, 0)
            }

            "center" -> {
                bannerParams.gravity = Gravity.CENTER
            }

            "right" -> {
                bannerParams.gravity = Gravity.RIGHT or Gravity.CENTER_VERTICAL
                bannerParams.setMargins(0, 0, marginsInPx, 0)
                bannerViewLayout!!.setPadding(0, 0, paddingInPx, 0)
            }

            "bottom-center" -> {
                bannerParams.gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                bannerParams.setMargins(0, 0, 0, marginsInPx)
                bannerViewLayout!!.setPadding(0, 0, 0, paddingInPx)
            }

            "bottom-right" -> {
                bannerParams.gravity = Gravity.BOTTOM or Gravity.RIGHT
                bannerParams.setMargins(0, 0, marginsInPx, marginsInPx)
                bannerViewLayout!!.setPadding(0, 0, paddingInPx, paddingInPx)
            }

            else -> {
                bannerParams.gravity = Gravity.CENTER_HORIZONTAL or Gravity.BOTTOM
                bannerParams.setMargins(marginsInPx, 0, 0, marginsInPx)
                bannerViewLayout!!.setPadding(paddingInPx, 0, 0, paddingInPx)
            }
        }

        bannerViewLayout?.layoutParams = bannerParams
    }


    private fun isBannerAutoShow() {
        try {
            if (mActivity != null && bannerView != null && bannerViewLayout != null) {
                if (lock) {
                    bannerViewLayout?.addView(bannerView)
                    bannerViewLayout?.bringToFront()
                    bannerViewLayout?.requestFocus();
                    lock = false
                }
                isBannerPause = 0
                isBannerLoad = true
            } else {
                val errorMessage = "Error showing banner: bannerView or bannerViewLayout is null."
                PUBLIC_CALLBACKS?.error(errorMessage)
            }
        } catch (e: Exception) {
            val errorMessage = "Error showing banner: " + e.message
            PUBLIC_CALLBACKS?.error(errorMessage)
        }
    }


    private val isShowBannerAds: Unit
        get() {
            if (mActivity != null && isBannerLoad && bannerView != null) {
                try {
                    if (lock) {
                        bannerViewLayout?.addView(bannerView)
                        bannerViewLayout?.bringToFront()
                        bannerViewLayout?.requestFocus();
                        lock = false

                    }

                    isBannerShow = true
                } catch (e: Exception) {
                    lock = true
                    PUBLIC_CALLBACKS?.error("Error isShowBannerAds: ${e.message}")
                }
            }
        }


    private val bannerAdListener: AdListener = object : AdListener() {
        override fun onAdClicked() {
            cWebView!!.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.click');")
        }

        override fun onAdClosed() {
            cWebView!!.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.close');")
        }


        override fun onAdFailedToLoad(adError: LoadAdError) {
            bannerOverlappingToZero()
            val errorData = JSONObject().apply {
                put("code", adError.code)
                put("message", adError.message)
                put("domain", adError.domain)
                put("cause", adError.cause?.toString() ?: "null")

                val responseId = adError.responseInfo?.responseId.toString()
                val responseExtras = adError.responseInfo?.responseExtras.toString()
                val loadedAdapterResponseInfo = adError.responseInfo?.loadedAdapterResponseInfo.toString()
                val mediationAdapterClassName = adError.responseInfo?.mediationAdapterClassName.toString()
                val adapterResponses = adError.responseInfo?.adapterResponses.toString()

                put("responseInfoId", responseId)
                put("responseInfoExtras", responseExtras)
                put("responseInfoAdapter", loadedAdapterResponseInfo)
                put("responseInfoMediationAdapterClassName", mediationAdapterClassName)
                put("responseInfoAdapterResponses", adapterResponses)
            }

            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.failed.load', ${errorData});")

            if (bannerViewLayout != null && bannerView != null) {
                bannerViewLayout?.removeView(bannerView)
                bannerView?.destroy()
                bannerView = null
                bannerViewLayout = null
                isBannerLoad = false
                isBannerShow = false
                isBannerPause = 2
                lock = true
            }

        }

        override fun onAdImpression() {
            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.impression');")
        }

        private fun getAdHeightInDp(adSize: AdSize, context: Context): Int {
            val heightInPixels = adSize.getHeightInPixels(context)
            val density = context.resources.displayMetrics.density
            return (heightInPixels / density).toInt()
        }


        override fun onAdLoaded() {

            isBannerLoad = true
            isBannerPause = 0

            bannerView?.post {
                val heightInPx = bannerView?.height
                bannerViewHeight = heightInPx ?: 0
            }

            if (loadBannerCordova) {
                if (isPosition == "top-center") {
                    setBannerAdTopCordova()
                } else {
                    setBannerAdBottomCordova()
                }
            } else if (loadBannerCapacitor) {
                if (isPosition == "top-center") {
                    setBannerAdTopCapacitor()
                } else {
                    setBannerAdBottomCapacitor()
                }
            }

            if (bannerAutoShow) {
                isBannerAutoShow()
            }

            val context = cordova.activity.applicationContext
            var currentAdSize = when (adType) {
                "banner" -> AdSize.BANNER
                "large_banner" -> AdSize.LARGE_BANNER
                "medium_rectangle" -> AdSize.MEDIUM_RECTANGLE
                "full_banner" -> AdSize.FULL_BANNER
                "leaderboard" -> AdSize.LEADERBOARD
                else -> adSize
            }

            val bannerHeightDp = getAdHeightInDp(currentAdSize, context)

            val bannerLoadEventData = String.format(Locale.US, "{\"height\": %d}", bannerHeightDp)


            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.load', $bannerLoadEventData);")

            val eventData = String.format(
                "{\"collapsible\": \"%s\"}",
                if (bannerView!!.isCollapsible) "collapsible" else "not collapsible"
            )

            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.is.collapsible', $eventData)")

            bannerView?.onPaidEventListener = bannerPaidAdListener

            if (isResponseInfo) {
                val result = JSONObject()
                val responseInfo = bannerView?.responseInfo
                try {
                    checkNotNull(responseInfo)
                    result.put("getResponseId", responseInfo.responseId)
                    result.put("getAdapterResponses", responseInfo.adapterResponses)
                    result.put("getResponseExtras", responseInfo.responseExtras)
                    result.put("getMediationAdapterClassName", responseInfo.mediationAdapterClassName)
                    if (mBundleExtra != null) {
                        result.put("getBundleExtra", mBundleExtra.toString())
                    } else {
                        result.put("getBundleExtra", JSONObject.NULL)
                    }
                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.bannerAd.responseInfo', ${result});")
                } catch (e: JSONException) {
                    PUBLIC_CALLBACKS?.error("Error isResponseInfo: ${e.message}")
                }
            }
        }


        override fun onAdOpened() {
            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.open');")
            isBannerShows = false
        }
    }



    private fun bannerOverlappingToZero() {
        if (bannerView != null && mActivity != null && cWebView != null) {
            mActivity?.runOnUiThread {
                try {
                    val rootView = (cWebView?.view?.parent as View)
                    rootView.post {
                        val totalHeight = rootView.height
                        val layoutParams = cWebView?.view?.layoutParams
                        layoutParams?.height = totalHeight
                        cWebView?.view?.layoutParams = layoutParams
                        cWebView?.view?.setPadding(0, 0, 0, 0)
                        (cWebView?.view?.parent as? ViewGroup)?.setPadding(0, 0, 0, 0)
                        cWebView?.view?.requestLayout()

                    }
                } catch (e: Exception) {
                    PUBLIC_CALLBACKS?.error("Error bannerOverlappingToZero: ${e.message}")
                }
            }
        }
    }



    private fun setBannerAdBottomCordova() {
        if (bannerView != null && mActivity != null && cWebView != null) {
            mActivity?.runOnUiThread {
                bannerView?.post {
                    try {
                        val screenHeightInPx = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            val windowMetrics = mActivity!!.windowManager.currentWindowMetrics
                            val insets = windowMetrics.windowInsets.getInsets(WindowInsets.Type.systemBars())
                            val height = windowMetrics.bounds.height() - insets.top - insets.bottom
                            height
                        } else {
                            val displayMetrics = DisplayMetrics()
                            @Suppress("DEPRECATION")
                            mActivity!!.windowManager.defaultDisplay.getMetrics(displayMetrics)
                            displayMetrics.heightPixels
                        }

                        val webViewHeight = screenHeightInPx - bannerViewHeight

                        if (!isFullScreen) {
                            val navBarHeight = getNavigationBarHeight(mActivity!!)
                            bannerViewLayout?.let { container ->
                                container.post {
                                    val params = container.layoutParams
                                    if (params is ViewGroup.MarginLayoutParams) {
                                        params.bottomMargin = navBarHeight
                                        container.layoutParams = params
                                        container.requestLayout()
                                    }
                                }
                            }
                        }

                        if (!isOverlapping) {
                            val layoutParams = cWebView!!.view.layoutParams
                            layoutParams.height = webViewHeight
                            cWebView!!.view.layoutParams = layoutParams
                        }

                    } catch (e: Exception) {
                        PUBLIC_CALLBACKS?.error("Error bannerOverlapping: ${e.message}")
                    }
                }
            }
        }
    }





    private fun setBannerAdTopCordova() {
        mActivity?.let { activity ->
            bannerView?.post {
                val bannerHeightPx = bannerViewHeight
                val statusBarHeight = getStatusBarHeight(activity)

                if (isPosition.equals("top-center", ignoreCase = true)) {
                    val bannerLp = bannerView?.layoutParams as? FrameLayout.LayoutParams
                    bannerLp?.let { lp ->
                        if (bannerOverlapping) {
                            if (isFullScreen) {
                                lp.topMargin = 0
                                bannerView?.layoutParams = lp
                            } else {
                                lp.topMargin = 0 // bannerHeightPx // + statusBarHeight
                                bannerView?.layoutParams = lp
                            }
                        } else {
                            if (isFullScreen) {
                                lp.topMargin = 0
                                bannerView?.layoutParams = lp
                            } else {
                                lp.topMargin = statusBarHeight
                                bannerView?.layoutParams = lp
                            }
                        }

                    }
                }

                cWebView?.let { webView ->
                    val webLp = webView.view.layoutParams as FrameLayout.LayoutParams
                    if (isPosition.equals("top-center", ignoreCase = true)) {

                        if (bannerOverlapping) {
                            if (isFullScreen) {
                                webLp.topMargin = 0 //+ statusBarHeight
                            } else {
                                webLp.topMargin = 0 //bannerHeightPx // + statusBarHeight
                            }
                        } else {
                            if (isFullScreen) {
                                webLp.topMargin = bannerHeightPx
                            } else {
                                webLp.topMargin = bannerHeightPx
                            }
                        }
                    }

                    webView.view.layoutParams = webLp
                    webView.view.requestLayout()
                }
            }}
    }










    private fun setBannerAdBottomCapacitor() {
        if (bannerView != null && mActivity != null && cWebView != null) {
            mActivity?.runOnUiThread {
                bannerView?.post {
                    try {
                        val measuredBannerHeight = if (bannerView!!.height > 0)
                            bannerView!!.height //167

                        //adSize.height
                        else
                            adSize.getHeightInPixels(mActivity!!)

                        //61

                        val screenHeightInPx = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {    //2186


                            val windowMetrics = mActivity!!.windowManager.currentWindowMetrics  //WindowMetrics:{bounds=Rect(0, 0 - 1080, 2400), windowInsets=null, density=2.75}
                            val insets = windowMetrics.windowInsets.getInsets(WindowInsets.Type.systemBars())   //Insets{left=0, top=84, right=0, bottom=130}
                            val height = windowMetrics.bounds.height() - insets.top - insets.bottom  //2186    2400 - 84 - 130
                            height
                        } else {
                            val displayMetrics = DisplayMetrics()
                            @Suppress("DEPRECATION")
                            mActivity!!.windowManager.defaultDisplay.getMetrics(displayMetrics)
                            displayMetrics.heightPixels
                        }

                        val webViewHeight = screenHeightInPx// - measuredBannerHeight //2186 - 167

                        if (!isFullScreen) {
                            var navBarHeight = 0

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                val windowMetrics = mActivity!!.windowManager.currentWindowMetrics
                                val insets = windowMetrics.windowInsets.getInsets(WindowInsets.Type.navigationBars())
                                navBarHeight = insets.bottom
                            } else {
                                val decorView = mActivity!!.window.decorView

                                val isNavBarVisible = (decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_HIDE_NAVIGATION) == 0
                                if (isNavBarVisible) {
                                    navBarHeight = getNavigationBarHeight(mActivity!!)
                                }
                            }

                            if (navBarHeight > 0) {
                                bannerViewLayout?.let { container ->
                                    container.post {
                                        val params = container.layoutParams
                                        if (params is ViewGroup.MarginLayoutParams) {
                                            params.bottomMargin = navBarHeight
                                            container.layoutParams = params
                                            container.requestLayout()
                                        }
                                    }
                                }
                            }
                        }



                        if (!isOverlapping) {
                            val layoutParams = cWebView!!.view.layoutParams

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                val windowMetrics = mActivity!!.windowManager.currentWindowMetrics
                                val insets = windowMetrics.windowInsets.getInsets(WindowInsets.Type.systemBars())
                                val usableHeight = windowMetrics.bounds.height()

                                layoutParams.height = if (isFullScreen) {
                                    // In fullscreen, do NOT subtract nav bar height
                                    usableHeight - adSize.getHeightInPixels(mActivity!!)
                                } else {
                                    usableHeight - getNavigationBarHeight(mActivity!!) - adSize.getHeightInPixels(mActivity!!)
                                }
                            } else {

                                layoutParams.height = if (isFullScreen) {
                                    webViewHeight - adSize.getHeightInPixels(mActivity!!) + getNavigationBarHeight(mActivity!!)
                                } else {
                                    webViewHeight  - adSize.getHeightInPixels(mActivity!!)  //- getNavigationBarHeight(mActivity!!)
                                }
                            }

                            cWebView!!.view.layoutParams = layoutParams
                        }

                        val bannerParams = bannerView?.layoutParams as? FrameLayout.LayoutParams
                        bannerParams?.bottomMargin = 0
                        bannerParams?.gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL     //81
                        bannerView?.layoutParams = bannerParams

                        bannerViewLayout?.setPadding(0, 0, 0, 0)


                    } catch (e: Exception) {
                        PUBLIC_CALLBACKS?.error("Error bannerOverlapping: ${e.message}")
                    }
                }
            }
        }
    }



    private fun setBannerAdTopCapacitor() {
        mActivity?.let { activity ->
            bannerView?.post {
                val bannerHeightPx = bannerViewHeight
                val statusBarHeight = getStatusBarHeight(activity)

                if (isPosition.equals("top-center", ignoreCase = true)) {
                    val bannerLp = bannerView?.layoutParams as? FrameLayout.LayoutParams
                    bannerLp?.let { lp ->
                        if (bannerOverlapping) {
                            if (isFullScreen) {
                                lp.topMargin = 0
                                bannerView?.layoutParams = lp
                            } else {
                                lp.topMargin = 0 // bannerHeightPx // + statusBarHeight
                                bannerView?.layoutParams = lp
                            }
                        } else {
                            if (isFullScreen) {
                                lp.topMargin = 0
                                bannerView?.layoutParams = lp
                            } else {
                                lp.topMargin = statusBarHeight
                                bannerView?.layoutParams = lp
                            }
                        }

                    }
                }

                cWebView?.let { webView ->
                    val webLp = webView.view.layoutParams as FrameLayout.LayoutParams
                    if (isPosition.equals("top-center", ignoreCase = true)) {

                        if (bannerOverlapping) {
                            if (isFullScreen) {
                                webLp.topMargin = 0 //+ statusBarHeight
                            } else {
                                webLp.topMargin = 0 //bannerHeightPx // + statusBarHeight
                            }
                        } else {
                            if (isFullScreen) {
                                webLp.topMargin = bannerHeightPx
                            } else {
                                webLp.topMargin = bannerHeightPx
                            }
                        }
                    }

                    webView.view.layoutParams = webLp
                    webView.view.requestLayout()
                }
            }}
    }









    private val bannerPaidAdListener = OnPaidEventListener { adValue ->
        val valueMicros = adValue.valueMicros.takeIf { it > 0 } ?: 0L
        val currencyCode = adValue.currencyCode.ifBlank { "UNKNOWN" }
        val precision = adValue.precisionType.takeIf { it >= 0 } ?: AdValue.PrecisionType.UNKNOWN
        val adUnitId = bannerView?.adUnitId ?: "null"
        val result = JSONObject()
        try {
            result.put("micros", valueMicros)
            result.put("currency", currencyCode)
            result.put("precision", precision)
            result.put("adUnitId", adUnitId)
            isBannerLoad = false
            isBannerShow = true
            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.revenue', ${result});")
        } catch (e: JSONException) {
            PUBLIC_CALLBACKS?.error("Error bannerPaidAdListener: ${e.message}")
        }
    }

    private fun setBannerSize(size: String?) {
        if (mActivity == null || bannerView == null) {
            Log.e("AdBanner", "mActivity or bannerView is null. Cannot set banner size.")
            return
        }

        when (size) {
            "responsive_adaptive" -> bannerView?.setAdSize(adSize)
            "anchored_adaptive" -> bannerView?.setAdSize(
                AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                    mActivity!!, adWidth
                )
            )
            "full_width_adaptive" -> bannerView?.setAdSize(
                AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                    mActivity!!, adWidth
                )
            )
            "in_line_adaptive" -> bannerView?.setAdSize(
                AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(
                    mActivity!!, adWidth
                )
            )
            "banner" -> bannerView?.setAdSize(AdSize.BANNER)
            "large_banner" -> bannerView?.setAdSize(AdSize.LARGE_BANNER)
            "medium_rectangle" -> bannerView?.setAdSize(AdSize.MEDIUM_RECTANGLE)
            "full_banner" -> bannerView?.setAdSize(AdSize.FULL_BANNER)
            "leaderboard" -> bannerView?.setAdSize(AdSize.LEADERBOARD)
            "fluid" -> bannerView?.setAdSize(AdSize.FLUID)
            else -> Log.e("AdBanner", "Unknown banner size: $size")
        }
    }

    private val adSize: AdSize
        get() {
            if (mActivity == null) {
                throw IllegalStateException("mActivity is null. Cannot get adSize.")
            }

            val outMetrics = DisplayMetrics()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                mActivity?.windowManager?.currentWindowMetrics?.let { windowMetrics ->
                    val insets = windowMetrics.windowInsets
                        .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
                    val bounds = windowMetrics.bounds
                    val widthPixels = bounds.width() - insets.left - insets.right
                    outMetrics.widthPixels = widthPixels
                    outMetrics.density = mActivity!!.resources.displayMetrics.density
                }
            } else {
                @Suppress("DEPRECATION")
                mActivity?.windowManager?.defaultDisplay?.getMetrics(outMetrics)
            }

            val density = outMetrics.density
            val adWidthPixels =
                if ((bannerViewLayout?.width ?: 0) > 0) bannerViewLayout!!.width else outMetrics.widthPixels
            val adWidth = (adWidthPixels / density).toInt()
            return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(mActivity!!, adWidth)
        }

    private val adWidth: Int
        get() {
            if (mActivity == null) {
                throw IllegalStateException("mActivity is null. Cannot calculate adWidth.")
            }

            val outMetrics = DisplayMetrics()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                mActivity?.windowManager?.currentWindowMetrics?.let { windowMetrics ->
                    val insets = windowMetrics.windowInsets
                        .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
                    val bounds = windowMetrics.bounds
                    val widthPixels = bounds.width() - insets.left - insets.right
                    outMetrics.widthPixels = widthPixels
                    outMetrics.density = mActivity?.resources?.displayMetrics!!.density
                }
            } else {
                @Suppress("DEPRECATION")
                mActivity?.windowManager?.defaultDisplay?.getMetrics(outMetrics)
            }

            val density = outMetrics.density
            val adWidthPixels =
                (bannerViewLayout?.width?.takeIf { it > 0 } ?: outMetrics.widthPixels).toFloat()
            return (adWidthPixels / density).toInt()
        }


    private fun handleConsentForm() {
        if(mActivity != null) {
            if (consentInformation!!.isConsentFormAvailable) {
                mContext?.let {
                    UserMessagingPlatform.loadConsentForm(it,
                        { consentForm: ConsentForm ->
                            mActivity?.let { it1 ->
                                consentForm.show(
                                    it1
                                ) { formError: FormError? ->
                                    if (formError != null) {
                                        mActivity?.runOnUiThread {
                                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.show', { message: '" + formError.message + "' });")
                                        }
                                    }
                                }
                            }
                        },
                        { formError: FormError ->
                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.load.from', { message: '" + formError.message + "' });")
                        }
                    )
                }
            }
        }
    }


    private fun setUsingAdManagerRequest(isUsingAdManagerRequest: Boolean) {
        this.isUsingAdManagerRequest = isUsingAdManagerRequest
    }


    private fun targetingAdRequest(customTargeting: JSONArray?, categoryExclusions: String, ppId: String, ctURL: String, brandSafetyArr: JSONArray?) {
        try {
            customTargetingList = ArrayList()

            if (customTargeting != null) {
                for (i in 0 until customTargeting.length()) {
                    (customTargetingList as ArrayList<String>).add(customTargeting.getString(i))
                }
            }


            brandSafetyUrls = ArrayList()
            if (brandSafetyArr != null) {
                for (i in 0 until brandSafetyArr.length()) {
                    try {
                        (brandSafetyUrls as ArrayList<String>).add(brandSafetyArr.getString(i))
                    } catch (e: JSONException) {
                        e.printStackTrace();
                    }
                }
            }

            this.cExclusionsValue = categoryExclusions
            this.ppIdVl = ppId
            this.cURLVl = ctURL
        } catch (e: JSONException) {
            e.printStackTrace();
        }
    }


    private fun setPublisherProvidedSignals(ppsArrValue: JSONArray?) {
        try {
            ppsArrayList = ArrayList()
            if (ppsArrValue != null) {
                for (i in 0 until ppsArrValue.length()) {
                    (ppsArrayList as ArrayList<Int>).add(ppsArrValue.getInt(i))
                }
            }
        } catch (e: JSONException) {
            e.printStackTrace();
        }
    }





    @SuppressLint("DefaultLocale")
    private fun initializeMobileAdsSdk() {

        isFullScreen = isFullScreenMode(mActivity!!)

        if (isMobileAdsInitializeCalled.getAndSet(true)) {
            return
        }

        if (mActivity != null && cWebView != null) {
            CoroutineScope(Dispatchers.IO).launch {
                try {
                    MobileAds.initialize(mActivity!!) { initializationStatus ->

                        val statusMap = initializationStatus.adapterStatusMap
                        val adapterInfo = StringBuilder()

                        for ((adapterClass, status) in statusMap) {
                            adapterInfo.append(
                                String.format(
                                    "Adapter name: %s, Description: %s, Latency: %d\n",
                                    adapterClass,
                                    status.description,
                                    status.latency
                                )
                            )
                        }

                        val gdprApplies = mPreferences?.getInt("IABTCF_gdprApplies", 0)
                        val purposeConsents = mPreferences?.getString("IABTCF_PurposeConsents", "")
                        val vendorConsents = mPreferences?.getString("IABTCF_VendorConsents", "")
                        val consentTCString = mPreferences?.getString("IABTCF_TCString", "")
                        val additionalConsent = mPreferences?.getString("IABTCF_AddtlConsent", "")

                        val sdkVersion = MobileAds.getVersion().toString()
                        val consentStatus = consentInformation?.consentStatus.toString()

                        val eventData = """
                    {
                        "version": "$sdkVersion",
                        "adapters": "$adapterInfo",
                        "consentStatus": "$consentStatus",
                        "gdprApplies": $gdprApplies,
                        "purposeConsents": "$purposeConsents",
                        "vendorConsents": "$vendorConsents",
                        "consentTCString": "$consentTCString",
                        "additionalConsent": "$additionalConsent"
                    }
                """.trimIndent()

                        mActivity?.runOnUiThread {
                            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.sdkInitialization', $eventData)")
                        }
                    }
                } catch (e: Exception) {
                    PUBLIC_CALLBACKS?.error("Error during MobileAds initialization: ${e.message}")
                }
            }
        }
    }




    @SuppressLint("DefaultLocale")
    private fun buildAdRequest(): AdRequest {
        if (isUsingAdManagerRequest) {
            val builder = AdManagerAdRequest.Builder()

            if (this.customTargetingEnabled) {
                if (customTargetingList!!.isEmpty()) {
                    PUBLIC_CALLBACKS?.error("List is empty")
                } else {
                    builder.addCustomTargeting("age", customTargetingList!!)
                }
            }

            if (this.categoryExclusionsEnabled) {
                if (cExclusionsValue != "") {
                    builder.addCategoryExclusion(this.cExclusionsValue)
                }
            }

            if (this.ppIdEnabled) {
                if (ppIdVl != "") {
                    builder.setPublisherProvidedId(this.ppIdVl)
                }
            }


            if (this.contentURLEnabled) {
                if (cURLVl != "") {
                    builder.setPublisherProvidedId(this.cURLVl)
                }
            }


            if (this.brandSafetyEnabled) {
                if (brandSafetyUrls!!.isEmpty()) {
                    PUBLIC_CALLBACKS?.error("List is empty")
                } else {
                    builder.setNeighboringContentUrls(brandSafetyUrls!!)
                }
            }

            if (isEnabledKeyword) {
                setKeyword.split(",").forEach { keyword ->
                    builder.addKeyword(keyword.trim())
                }
            }

            val bundleExtra = Bundle()
            // bundleExtra.putString("npa", this.Npa); DEPRECATED Beginning January 16, 2024
            if (collapsiblePos !== "") {
                bundleExtra.putString("collapsible", this.collapsiblePos)
            }
            bundleExtra.putBoolean("is_designed_for_families", this.isSetTagForChildDirectedTreatment)
            bundleExtra.putBoolean("under_age_of_consent", this.isSetTagForUnderAgeOfConsent)
            bundleExtra.putString("max_ad_content_rating", this.isSetMaxAdContentRating)
            builder.addNetworkExtrasBundle(AdMobAdapter::class.java, bundleExtra)

            if (this.ppsEnabled) {
                when (this.ppsVl) {
                    "IAB_AUDIENCE_1_1" -> bundleExtra.putIntegerArrayList(
                        "IAB_AUDIENCE_1_1",
                        ppsArrayList as ArrayList<Int>?
                    )

                    "IAB_CONTENT_2_2" -> bundleExtra.putIntegerArrayList(
                        "IAB_CONTENT_2_2",
                        ppsArrayList as ArrayList<Int>?
                    )
                }
            }
            mBundleExtra = bundleExtra

            return builder.build()
        } else {
            val builder = AdRequest.Builder()
            val bundleExtra = Bundle()
            // bundleExtra.putString("npa", this.Npa); DEPRECATED Beginning January 16, 2024
            if (collapsiblePos !== "") {
                bundleExtra.putString("collapsible", this.collapsiblePos)
            }

            if (isEnabledKeyword) {
                setKeyword.split(",").forEach { keyword ->
                    builder.addKeyword(keyword.trim())
                }
            }

            bundleExtra.putBoolean("is_designed_for_families", this.isSetTagForChildDirectedTreatment)
            bundleExtra.putBoolean("under_age_of_consent", this.isSetTagForUnderAgeOfConsent)
            bundleExtra.putString("max_ad_content_rating", this.isSetMaxAdContentRating)
            builder.addNetworkExtrasBundle(AdMobAdapter::class.java, bundleExtra)
            mBundleExtra = bundleExtra

            return builder.build()
        }
    }


    private val deviceId: String?
        get() {
            var algorithm = "SHA-256"
            try {
                val messageDigest = MessageDigest.getInstance(algorithm)
                val contentResolver = mContext!!.contentResolver
                @SuppressLint("HardwareIds") val androidId =
                    Settings.Secure.getString(contentResolver, "android_id")
                messageDigest.update(androidId.toByteArray())
                val by = messageDigest.digest()
                val sb = StringBuilder()
                for (b in by) {
                    val emi = StringBuilder(Integer.toHexString((255 and b.toInt())))
                    while (emi.length < 2) {
                        emi.insert(0, "0")
                    }
                    sb.append(emi)
                }
                return sb.toString().uppercase(Locale.getDefault())
            } catch (e: NoSuchAlgorithmException) {
                algorithm = "SHA-1"
                e.printStackTrace()
                try {
                    val messageDigest = MessageDigest.getInstance(algorithm)
                    val contentResolver = mContext!!.contentResolver
                    @SuppressLint("HardwareIds") val androidId =
                        Settings.Secure.getString(contentResolver, "android_id")
                    messageDigest.update(androidId.toByteArray())
                    val by = messageDigest.digest()
                    val sb = StringBuilder()
                    for (b in by) {
                        val emi = StringBuilder(Integer.toHexString((255 and b.toInt())))
                        while (emi.length < 2) {
                            emi.insert(0, "0")
                        }
                        sb.append(emi)
                    }
                    return sb.toString().uppercase(Locale.getDefault())
                } catch (ex: NoSuchAlgorithmException) {
                    ex.printStackTrace();
                    return null
                }
            }
        }


    private fun getString(key: String) {
        val lastAccessTime = mPreferences!!.getLong(key + LAST_ACCESS_SUFFIX, 0)
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastAccessTime > EXPIRATION_TIME) {
            removeKey(key)
            cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.TCString.expired');")
        }
        val editor = mPreferences?.edit()
        editor?.putLong(key + LAST_ACCESS_SUFFIX, currentTime)
        editor?.apply()
    }

    private fun removeKey(key: String) {
        val editor = mPreferences?.edit()
        editor?.remove(key)
        editor?.remove(key + LAST_ACCESS_SUFFIX)
        editor?.apply()
        cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.TCString.remove');")
    }






    private fun appOpenAdLoadCallback() {
        appOpenAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.dismissed');")
                val mainView: View? = view
                mainView?.requestFocus()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                appOpenAd = null
                isAppOpenAdShow = false
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.failed.show', ${errorData});")
            }

            override fun onAdShowedFullScreenContent() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.show');")
            }
        }
    }


    private fun interstitialAdLoadCallback() {
        mInterstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdClicked() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.click');")
            }

            override fun onAdDismissedFullScreenContent() {
                mInterstitialAd = null
                isInterstitialLoad = false
                val mainView: View? = view
                mainView?.requestFocus()
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.dismissed');")
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                mInterstitialAd = null
                isInterstitialLoad = false
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.failed.show', ${errorData});")
            }

            override fun onAdImpression() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.impression');")
            }

            override fun onAdShowedFullScreenContent() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.show');")
            }
        }
    }

    private fun rewardedAdLoadCallback() {
        rewardedAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdClicked() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.click');")
            }

            override fun onAdDismissedFullScreenContent() {
                if (isAdSkip != 2) {
                    rewardedAd = null
                    isRewardedLoad = false
                    val mainView: View? = view
                    mainView?.requestFocus()
                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.ad.skip');")
                }
                rewardedAd = null
                isRewardedLoad = false
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.dismissed');")
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                rewardedAd = null
                isRewardedLoad = false
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.failed.show', ${errorData});")
            }

            override fun onAdImpression() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.impression');")
            }

            override fun onAdShowedFullScreenContent() {
                isAdSkip = 1
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.show');")
            }
        }
    }

    private fun rewardedInterstitialAdLoadCallback() {
        rewardedInterstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdClicked() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.click');")
            }

            override fun onAdDismissedFullScreenContent() {
                if (isAdSkip != 2) {
                    rewardedInterstitialAd = null
                    isRewardedInterstitialLoad = false
                    cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.ad.skip');")
                }
                rewardedInterstitialAd = null
                isRewardedInterstitialLoad = false
                val mainView: View? = view
                mainView?.requestFocus()
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.dismissed');")
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                rewardedInterstitialAd = null
                isRewardedInterstitialLoad = false
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.failed.show', ${errorData});")
            }

            override fun onAdImpression() {
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.impression');")
            }

            override fun onAdShowedFullScreenContent() {
                isAdSkip = 1
                cWebView?.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.showed');")
            }
        }
    }

    private fun globalSettings(setAppMuted: Boolean, setAppVolume: Float, pubIdEnabled: Boolean) {
        MobileAds.setAppMuted(setAppMuted)
        MobileAds.setAppVolume(setAppVolume)
        MobileAds.putPublisherFirstPartyIdEnabled(pubIdEnabled)
    }

    private fun targeting(childDirectedTreatment: Boolean, underAgeOfConsent: Boolean, contentRating: String) {
        val requestConfiguration = MobileAds.getRequestConfiguration().toBuilder()
        requestConfiguration.setTagForChildDirectedTreatment(if (childDirectedTreatment) RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE else RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_FALSE)
        requestConfiguration.setTagForUnderAgeOfConsent(if (underAgeOfConsent) RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE else RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_FALSE)
        when (contentRating) {
            "T" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_T)
            "PG" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_PG)
            "MA" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_MA)
            "G" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_G)
            else -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_UNSPECIFIED)
        }
        MobileAds.setRequestConfiguration(requestConfiguration.build())
    }

    private val isPrivacyOptionsRequired: ConsentInformation.PrivacyOptionsRequirementStatus get() = consentInformation?.getPrivacyOptionsRequirementStatus() ?: ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED



    private fun setPersonalizationState(setPPT: String) {
        val state = when (setPPT) {
            "disabled" -> PublisherPrivacyPersonalizationState.DISABLED
            "enabled" -> PublisherPrivacyPersonalizationState.ENABLED
            else -> PublisherPrivacyPersonalizationState.DEFAULT
        }
        val requestConfiguration = MobileAds.getRequestConfiguration()
            .toBuilder()
            .setPublisherPrivacyPersonalizationState(state)
            .build()
        MobileAds.setRequestConfiguration(requestConfiguration)
    }



    private fun isFullScreenMode(activity: Activity): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity.window.decorView.rootWindowInsets?.isVisible(WindowInsets.Type.statusBars()) == false
        } else {
            @Suppress("DEPRECATION")
            (activity.window.attributes.flags and WindowManager.LayoutParams.FLAG_FULLSCREEN) != 0
        }
    }



    @SuppressLint("DiscouragedApi", "InternalInsetResource")
    private fun getNavigationBarHeight(context: Context): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val windowMetrics = context.getSystemService(WindowManager::class.java).currentWindowMetrics
            val insets = windowMetrics.windowInsets.getInsetsIgnoringVisibility(WindowInsets.Type.navigationBars())
            insets.bottom
        } else {
            val resources = context.resources
            val resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android")
            if (resourceId > 0) resources.getDimensionPixelSize(resourceId) else 0
        }
    }


    @SuppressLint("InternalInsetResource", "DiscouragedApi")
    private fun getStatusBarHeight(context: Context): Int {
        var result = 0

        val resourceId = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) {
            result = context.resources.getDimensionPixelSize(resourceId)
        }
        return result
    }



    private val view: View?
        get() {
            if (View::class.java.isAssignableFrom(CordovaWebView::class.java)) {
                return cWebView as View?
            }
            return mActivity?.window?.decorView?.findViewById(View.generateViewId())
        }

    override fun onPause(multitasking: Boolean) {
        if (bannerView != null) {
            bannerView?.pause()
        }

        super.onPause(multitasking)
    }

    override fun onResume(multitasking: Boolean) {
        super.onResume(multitasking)
        if (bannerView != null) {
            bannerView?.resume()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
    }

    override fun onDestroy() {
        if (bannerView != null) {
            bannerView?.destroy()
            bannerView = null
        }
        if (bannerViewLayout != null) {
            val parentView = bannerViewLayout?.parent as ViewGroup
            parentView.removeView(bannerViewLayout)
            bannerViewLayout = null
        }
        super.onDestroy()
    }


    companion object {
       // private const val TAG = "emiAdmobPlugin"

        // Consent status will automatically reset after 12 months
        // https://support.google.com/admanager/answer/9999955?hl=en
        private const val LAST_ACCESS_SUFFIX = "_last_access"
        private const val EXPIRATION_TIME = 360L * 24 * 60 * 60 * 1000
    }
}
