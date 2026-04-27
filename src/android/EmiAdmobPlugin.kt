// src/android/EmiAdmobPlugin.kt
package emi.indo.cordova.plugin.admob

import android.annotation.SuppressLint
import android.app.Activity
import android.content.SharedPreferences
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.webkit.WebView
import androidx.preference.PreferenceManager
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import com.google.android.gms.ads.admanager.AdManagerAdRequest
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.CordovaWebView
import org.json.JSONArray
import org.json.JSONObject
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean

class EmiAdmobPlugin : CordovaPlugin(), EmiAdPluginProtocol {

    // --- PROTOCOL IMPLEMENTATION ---
    override val pluginActivity: Activity
        get() = cordova.activity

    override val pluginWebView: CordovaWebView
        get() = webView

    override val isResponseInfoEnabled: Boolean
        get() = isResponseInfo

    override fun getGlobalAdRequest(extras: android.os.Bundle?): AdRequest {
        return buildAdRequest(extras)
    }

    override fun fireEvent(eventName: String, data: String?) {
        pluginActivity.runOnUiThread {
            val js = if (data != null) {
                "javascript:cordova.fireDocumentEvent('$eventName', $data);"
            } else {
                "javascript:cordova.fireDocumentEvent('$eventName');"
            }
            pluginWebView.loadUrl(js)
        }
    }
    // -------------------------------

    // --- MANAGERS ---
    private lateinit var bannerManager: EmiBannerManager
    private lateinit var appOpenManager: EmiAppOpenManager
    private lateinit var interstitialManager: EmiInterstitialManager
    private lateinit var rewardedManager: EmiRewardedManager
    private lateinit var rewardedInterstitialManager: EmiRewardedInterstitialManager

    // --- GLOBALS & TARGETING ---
    private var PUBLIC_CALLBACKS: CallbackContext? = null
    private var mPreferences: SharedPreferences? = null
    private var consentInformation: ConsentInformation? = null

    private var isResponseInfo: Boolean = false
    private var isOrientation: Int = 1

    // State Trackers for AdMob Initialization
    private val isMobileAdsInitializeCalled = AtomicBoolean(false)
    private var isAdMobInitialized = false

    // Queue for Global Settings
    private var queuedAppMuted: Boolean? = null
    private var queuedAppVolume: Float? = null
    private var queuedPubIdEnabled: Boolean? = null

    private var setDebugGeography: Boolean = false
    private var isCustomConsentManager = false

    // Targeting Variables
    private var isUsingAdManagerRequest = false
    private var customTargetingEnabled = false
    private var customTargetingList: MutableList<String>? = null
    private var categoryExclusionsEnabled = false
    private var cExclusionsValue: String = ""
    private var ppIdEnabled = false
    private var ppIdVl: String = ""
    private var ppsEnabled = false
    private var ppsVl: String = ""
    private var ppsArrayList: MutableList<Int>? = null
    private var contentURLEnabled = false
    private var cURLVl: String = ""
    private var brandSafetyEnabled = false
    private var brandSafetyUrls: MutableList<String>? = null
    private var isEnabledKeyword = false
    private var setKeyword: String = ""

    private var isSetTagForChildDirectedTreatment = RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED
    private var isSetTagForUnderAgeOfConsent = RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED
    private var isSetMaxAdContentRating = ""

    override fun pluginInitialize() {
        super.pluginInitialize()

        val context = pluginActivity.applicationContext
        mPreferences = PreferenceManager.getDefaultSharedPreferences(context)

        applyAdMobAPI35WorkaroundIfNeeded(pluginActivity.application)

        bannerManager = EmiBannerManager(this)
        appOpenManager = EmiAppOpenManager(this)
        interstitialManager = EmiInterstitialManager(this)
        rewardedManager = EmiRewardedManager(this)
        rewardedInterstitialManager = EmiRewardedInterstitialManager(this)
    }

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        PUBLIC_CALLBACKS = callbackContext

        when (action) {
            "initialize" -> handleInitialize(args, callbackContext)
            "targeting" -> handleTargeting(args, callbackContext)
            "targetingAdRequest" -> handleTargetingAdRequest(args, callbackContext)
            "setPersonalizationState" -> handleSetPersonalizationState(args, callbackContext)
            "setPPS" -> handleSetPPS(args, callbackContext)
            "globalSettings" -> handleGlobalSettings(args, callbackContext)
            "metaData" -> handleMetaData(args, callbackContext)

            "showPrivacyOptionsForm" -> handleShowPrivacyOptionsForm(callbackContext)
            "consentReset" -> handleConsentReset(callbackContext)
            "getIabTfc" -> handleGetIabTfc(callbackContext)
            "getPersonalizationState" -> handleGetPersonalizationState(callbackContext) // --- NEW FEATURE ---

            "registerWebView" -> registerWebView(callbackContext)
            "loadUrl" -> loadUrl(args, callbackContext)

            "loadBannerAd", "loadBannerCapacitor" -> bannerManager.loadBannerAd(args, callbackContext)
            "showBannerAd" -> bannerManager.showBannerAd(callbackContext)
            "hideBannerAd" -> bannerManager.hideBannerAd(callbackContext)
            "removeBannerAd" -> bannerManager.removeBannerAd(callbackContext)
            "styleBannerAd" -> bannerManager.styleBannerAd(args, callbackContext)

            "loadAppOpenAd" -> appOpenManager.loadAppOpenAd(args, callbackContext)
            "showAppOpenAd" -> appOpenManager.showAppOpenAd(callbackContext)

            "loadInterstitialAd" -> interstitialManager.loadInterstitialAd(args, callbackContext)
            "showInterstitialAd" -> interstitialManager.showInterstitialAd(callbackContext)

            "loadRewardedAd" -> rewardedManager.loadRewardedAd(args, callbackContext)
            "showRewardedAd" -> rewardedManager.showRewardedAd(callbackContext)

            "loadRewardedInterstitialAd" -> rewardedInterstitialManager.loadRewardedInterstitialAd(args, callbackContext)
            "showRewardedInterstitialAd" -> rewardedInterstitialManager.showRewardedInterstitialAd(callbackContext)

            else -> return false
        }
        return true
    }

    // =========================================================================
    // ROUTER HANDLERS
    // =========================================================================

    private fun handleInitialize(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        pluginActivity.runOnUiThread {
            isUsingAdManagerRequest = options.optBoolean("isUsingAdManagerRequest")
            isResponseInfo = options.optBoolean("isResponseInfo")
            setDebugGeography = options.optBoolean("isConsentDebug")

            if (isCustomConsentManager) {
                fireEvent("on.custom.consent.manager.used", null)
                initializeMobileAdsSdk()
                callbackContext.success()
                return@runOnUiThread
            }

            val paramsBuilder = ConsentRequestParameters.Builder()
            if (setDebugGeography) {
                deviceId?.let {
                    val debugSettings = ConsentDebugSettings.Builder(pluginActivity)
                        .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
                        .addTestDeviceHashedId(it).build()
                    paramsBuilder.setConsentDebugSettings(debugSettings)
                }
            } else {
                val isUnderAge = (isSetTagForUnderAgeOfConsent == RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE)
                paramsBuilder.setTagForUnderAgeOfConsent(isUnderAge)
            }

            consentInformation = UserMessagingPlatform.getConsentInformation(pluginActivity)
            consentInformation?.requestConsentInfoUpdate(pluginActivity, paramsBuilder.build(), {
                fireEvent("on.consent.info.update", null)
                when (consentInformation?.consentStatus) {
                    ConsentInformation.ConsentStatus.NOT_REQUIRED -> fireEvent("on.consent.status.not_required", null)
                    ConsentInformation.ConsentStatus.OBTAINED -> fireEvent("on.consent.status.obtained", null)
                    ConsentInformation.ConsentStatus.REQUIRED -> {
                        fireEvent("on.consent.status.required", null)
                        handleConsentForm()
                    }
                    ConsentInformation.ConsentStatus.UNKNOWN -> fireEvent("on.consent.status.unknown", null)
                    else -> {}
                }
            }, { formError ->
                if (consentInformation?.canRequestAds() == true) {
                    initializeMobileAdsSdk()
                }
                fireEvent("on.consent.info.update.failed", "{\"message\":\"${formError.message}\"}")
            })

            if (consentInformation?.canRequestAds() == true) {
                initializeMobileAdsSdk()
            }
            callbackContext.success()
        }
    }

    private fun handleMetaData(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        isCustomConsentManager = options.optBoolean("useCustomConsentManager")
        isEnabledKeyword = options.optBoolean("isEnabledKeyword")
        setKeyword = options.optString("setKeyword")
        callbackContext.success()
    }

    private fun handleTargeting(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return

        if (options.has("childDirectedTreatment")) {
            isSetTagForChildDirectedTreatment = if (options.optBoolean("childDirectedTreatment")) {
                RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE
            } else {
                RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_FALSE
            }
        } else {
            isSetTagForChildDirectedTreatment = RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED
        }

        if (options.has("underAgeOfConsent")) {
            isSetTagForUnderAgeOfConsent = if (options.optBoolean("underAgeOfConsent")) {
                RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE
            } else {
                RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_FALSE
            }
        } else {
            isSetTagForUnderAgeOfConsent = RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED
        }

        isSetMaxAdContentRating = options.optString("contentRating", "")

        val requestConfiguration = MobileAds.getRequestConfiguration().toBuilder()
        requestConfiguration.setTagForChildDirectedTreatment(isSetTagForChildDirectedTreatment)
        requestConfiguration.setTagForUnderAgeOfConsent(isSetTagForUnderAgeOfConsent)

        when (isSetMaxAdContentRating.uppercase(Locale.getDefault())) {
            "T" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_T)
            "PG" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_PG)
            "MA" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_MA)
            "G" -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_G)
            else -> requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_UNSPECIFIED)
        }

        MobileAds.setRequestConfiguration(requestConfiguration.build())
        callbackContext.success()
    }

    private fun handleTargetingAdRequest(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        try {
            customTargetingEnabled = options.optBoolean("customTargetingEnabled")
            categoryExclusionsEnabled = options.optBoolean("categoryExclusionsEnabled")
            ppIdEnabled = options.optBoolean("ppIdEnabled")
            contentURLEnabled = options.optBoolean("contentURLEnabled")
            brandSafetyEnabled = options.optBoolean("brandSafetyEnabled")

            val customTargeting = options.optJSONArray("customTargetingValue")
            cExclusionsValue = options.optString("categoryExclusionsValue")
            ppIdVl = options.optString("ppIdValue")
            cURLVl = options.optString("contentURLValue")
            val brandSafetyArr = options.optJSONArray("brandSafetyArr")

            customTargetingList = ArrayList()
            if (customTargeting != null) {
                for (i in 0 until customTargeting.length()) {
                    (customTargetingList as ArrayList<String>).add(customTargeting.getString(i))
                }
            }

            brandSafetyUrls = ArrayList()
            if (brandSafetyArr != null) {
                for (i in 0 until brandSafetyArr.length()) {
                    (brandSafetyUrls as ArrayList<String>).add(brandSafetyArr.getString(i))
                }
            }
            callbackContext.success()
        } catch (e: Exception) {
            callbackContext.error(e.message)
        }
    }

    private fun handleSetPersonalizationState(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        val setPPT = options.optString("setPersonalizationState")
        val state = when (setPPT) {
            "disabled" -> RequestConfiguration.PublisherPrivacyPersonalizationState.DISABLED
            "enabled" -> RequestConfiguration.PublisherPrivacyPersonalizationState.ENABLED
            else -> RequestConfiguration.PublisherPrivacyPersonalizationState.DEFAULT
        }
        val requestConfiguration = MobileAds.getRequestConfiguration().toBuilder()
            .setPublisherPrivacyPersonalizationState(state).build()
        MobileAds.setRequestConfiguration(requestConfiguration)
        callbackContext.success()
    }

    private fun handleSetPPS(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        ppsEnabled = options.optBoolean("ppsEnabled")
        ppsVl = options.optString("iabContent")
        val ppsArrValue = options.optJSONArray("ppsArrValue")

        ppsArrayList = ArrayList()
        if (ppsArrValue != null) {
            for (i in 0 until ppsArrValue.length()) {
                (ppsArrayList as ArrayList<Int>).add(ppsArrValue.getInt(i))
            }
        }
        callbackContext.success()
    }

    private fun handleGlobalSettings(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        queuedAppMuted = options.optBoolean("setAppMuted")
        queuedAppVolume = options.optInt("setAppVolume").toFloat()
        queuedPubIdEnabled = options.optBoolean("pubIdEnabled")

        pluginActivity.runOnUiThread {
            if (isAdMobInitialized) {
                applyQueuedGlobalSettings()
            }
            callbackContext.success()
        }
    }

    private fun applyQueuedGlobalSettings() {
        try {
            queuedAppMuted?.let { MobileAds.setAppMuted(it) }
            queuedAppVolume?.let { MobileAds.setAppVolume(it) }
            queuedPubIdEnabled?.let { MobileAds.putPublisherFirstPartyIdEnabled(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Error applying queued global settings: ${e.message}")
        }
    }

    // =========================================================================
    // CORE ADMOB & UMP INITIALIZATION
    // =========================================================================

    @SuppressLint("DefaultLocale")
    private fun initializeMobileAdsSdk() {
        if (isMobileAdsInitializeCalled.getAndSet(true)) return

        CoroutineScope(Dispatchers.IO).launch {
            try {
                MobileAds.initialize(pluginActivity) { initializationStatus ->

                    isAdMobInitialized = true
                    pluginActivity.runOnUiThread {
                        applyQueuedGlobalSettings()
                    }

                    val adapterInfo = StringBuilder()
                    for ((adapterClass, status) in initializationStatus.adapterStatusMap) {
                        adapterInfo.append(String.format("Adapter name: %s, Description: %s, Latency: %d\n", adapterClass, status.description, status.latency))
                    }

                    val gdprApplies = mPreferences?.getInt("IABTCF_gdprApplies", -1)
                    val purposeConsents = mPreferences?.getString("IABTCF_PurposeConsents", "")
                    val vendorConsents = mPreferences?.getString("IABTCF_VendorConsents", "")
                    val consentTCString = mPreferences?.getString("IABTCF_TCString", "")
                    val additionalConsent = mPreferences?.getString("IABTCF_AddtlConsent", "")

                    val sdkVersion = MobileAds.getVersion().toString()
                    val consentStatus = consentInformation?.consentStatus.toString()

                    val result = JSONObject().apply {
                        put("version", sdkVersion)
                        put("adapters", adapterInfo.toString())
                        put("consentStatus", consentStatus)
                        put("gdprApplies", if (gdprApplies == -1) JSONObject.NULL else gdprApplies)
                        put("purposeConsents", purposeConsents)
                        put("vendorConsents", vendorConsents)
                        put("consentTCString", consentTCString)
                        put("additionalConsent", additionalConsent)
                    }

                    fireEvent("on.sdkInitialization", result.toString())

                    // Trigger Personalization State automatically upon successful initialization
                    evaluateAndSendPersonalizationState()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error initializing MobileAds: ${e.message}")
            }
        }
    }

    private fun handleConsentForm() {
        if (consentInformation?.isConsentFormAvailable == true) {
            UserMessagingPlatform.loadConsentForm(pluginActivity, { consentForm ->
                consentForm.show(pluginActivity) { formError ->
                    if (formError != null) {
                        fireEvent("on.consent.failed.show", "{\"message\":\"${formError.message}\"}")
                    }
                    // Evaluate state again after form closes
                    evaluateAndSendPersonalizationState()
                }
            }, { formError ->
                fireEvent("on.consent.failed.load.from", "{\"message\":\"${formError.message}\"}")
            })
        }
    }

    private fun handleShowPrivacyOptionsForm(callbackContext: CallbackContext) {
        pluginActivity.runOnUiThread {
            if (consentInformation?.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED) {
                UserMessagingPlatform.showPrivacyOptionsForm(pluginActivity) { formError ->
                    if (formError != null) {
                        fireEvent("on.consent.failed.show.options", "{\"message\":\"${formError.message}\"}")
                    }
                    evaluateAndSendPersonalizationState()
                }
            }
            callbackContext.success()
        }
    }

    private fun handleConsentReset(callbackContext: CallbackContext) {
        pluginActivity.runOnUiThread {
            consentInformation?.reset()
            callbackContext.success()
        }
    }

    private fun handleGetIabTfc(callbackContext: CallbackContext) {
        pluginActivity.runOnUiThread {
            val gdprApplies = mPreferences?.getInt("IABTCF_gdprApplies", -1)
            val purposeConsents = mPreferences?.getString("IABTCF_PurposeConsents", "")
            val vendorConsents = mPreferences?.getString("IABTCF_VendorConsents", "")
            val consentString = mPreferences?.getString("IABTCF_TCString", "")

            val result = JSONObject().apply {
                put("IABTCF_gdprApplies", if (gdprApplies == -1) JSONObject.NULL else gdprApplies)
                put("IABTCF_PurposeConsents", purposeConsents)
                put("IABTCF_VendorConsents", vendorConsents)
                put("IABTCF_TCString", consentString)
            }

            callbackContext.success(result)
            fireEvent("on.getIabTfc", null)
        }
    }

    // --- NEW FEATURE: ANALYZE AND SEND PERSONALIZATION STATE ---
    private fun handleGetPersonalizationState(callbackContext: CallbackContext) {
        pluginActivity.runOnUiThread {
            val result = evaluateAndSendPersonalizationState()
            callbackContext.success(result)
        }
    }

    private fun evaluateAndSendPersonalizationState(): JSONObject {
        val gdprApplies = mPreferences?.getInt("IABTCF_gdprApplies", -1) ?: -1
        val purposeConsents = mPreferences?.getString("IABTCF_PurposeConsents", "") ?: ""

        var adState = "UNKNOWN"

        if (gdprApplies == 0 || gdprApplies == -1) {
            // Jika pengguna berada di luar wilayah GDPR atau belum ditentukan, biasanya diizinkan Personalized
            adState = "PERSONALIZED"
        } else if (gdprApplies == 1) {
            // Evaluasi String IAB TCF (Zero-indexed: Purpose 1 = index 0, Purpose 3 = index 2, Purpose 4 = index 3)
            if (purposeConsents.isNotEmpty()) {
                val purpose1 = purposeConsents.getOrNull(0) == '1' // Izin menyimpan cookie/info di perangkat
                val purpose3 = purposeConsents.getOrNull(2) == '1' // Izin membuat profil iklan personal
                val purpose4 = purposeConsents.getOrNull(3) == '1' // Izin memilih iklan personal

                adState = if (purpose1 && purpose3 && purpose4) {
                    "PERSONALIZED"
                } else if (purpose1) {
                    "NON_PERSONALIZED"
                } else {
                    "LIMITED_OR_NO_ADS" // Jika tidak ada izin Purpose 1, AdMob menolak tayang iklan
                }
            } else {
                adState = "UNKNOWN"
            }
        }

        val result = JSONObject().apply {
            put("personalizationState", adState)
            put("purposeConsents", purposeConsents)
            put("gdprApplies", if (gdprApplies == -1) JSONObject.NULL else gdprApplies)
        }

        fireEvent("on.personalization.state", result.toString())
        return result
    }

    // =========================================================================
    // BUILD AD REQUEST GLOBAL
    // =========================================================================
    private fun buildAdRequest(extras: android.os.Bundle? = null): AdRequest {
        val bundleExtra = Bundle()

        if (extras != null) {
            bundleExtra.putAll(extras)
        }

        if (isUsingAdManagerRequest) {
            val builder = AdManagerAdRequest.Builder()
            if (customTargetingEnabled && !customTargetingList.isNullOrEmpty()) builder.addCustomTargeting("age", customTargetingList!!)
            if (categoryExclusionsEnabled && cExclusionsValue.isNotEmpty()) builder.addCategoryExclusion(cExclusionsValue)
            if (ppIdEnabled && ppIdVl.isNotEmpty()) builder.setPublisherProvidedId(ppIdVl)
            if (contentURLEnabled && cURLVl.isNotEmpty()) builder.setPublisherProvidedId(cURLVl)
            if (brandSafetyEnabled && !brandSafetyUrls.isNullOrEmpty()) builder.setNeighboringContentUrls(brandSafetyUrls!!)
            if (isEnabledKeyword) setKeyword.split(",").forEach { builder.addKeyword(it.trim()) }

            if (ppsEnabled) {
                when (ppsVl) {
                    "IAB_AUDIENCE_1_1" -> bundleExtra.putIntegerArrayList("IAB_AUDIENCE_1_1", ppsArrayList as java.util.ArrayList<Int>?)
                    "IAB_CONTENT_2_2" -> bundleExtra.putIntegerArrayList("IAB_CONTENT_2_2", ppsArrayList as java.util.ArrayList<Int>?)
                }
            }

            builder.addNetworkExtrasBundle(AdMobAdapter::class.java, bundleExtra)
            return builder.build()
        } else {
            val builder = AdRequest.Builder()
            if (isEnabledKeyword) setKeyword.split(",").forEach { builder.addKeyword(it.trim()) }
            builder.addNetworkExtrasBundle(AdMobAdapter::class.java, bundleExtra)
            return builder.build()
        }
    }

    // =========================================================================
    // UTILS & LIFECYCLE
    // =========================================================================

    private fun registerWebView(callbackContext: CallbackContext) {
        pluginActivity.runOnUiThread {
            val web = pluginWebView.view
            if (web is WebView) {
                MobileAds.registerWebView(web)
                callbackContext.success("WebView registered successfully")
            } else {
                callbackContext.error("View is not a WebView.")
            }
        }
    }

    private fun loadUrl(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        val url = options.optString("url")
        pluginActivity.runOnUiThread {
            val web = pluginWebView.view
            if (web is WebView) {
                web.loadUrl(url)
                callbackContext.success("URL loaded successfully: $url")
            } else {
                callbackContext.error("WebView is not available.")
            }
        }
    }

    private val deviceId: String?
        @SuppressLint("HardwareIds")
        get() {
            return try {
                val messageDigest = MessageDigest.getInstance("SHA-256")
                val androidId = Settings.Secure.getString(pluginActivity.contentResolver, "android_id")
                messageDigest.update(androidId.toByteArray())
                messageDigest.digest().joinToString("") { "%02x".format(it) }.uppercase(Locale.getDefault())
            } catch (e: NoSuchAlgorithmException) {
                null
            }
        }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        val orientation = newConfig.orientation
        if (orientation != isOrientation) {
            fireEvent("on.screen.rotated", null)
            isOrientation = orientation
            when (orientation) {
                Configuration.ORIENTATION_PORTRAIT -> fireEvent("on.orientation.portrait", null)
                Configuration.ORIENTATION_LANDSCAPE -> fireEvent("on.orientation.landscape", null)
                Configuration.ORIENTATION_UNDEFINED -> fireEvent("on.orientation.undefined", null)
                else -> fireEvent("on.orientation.square", null)
            }
        }
    }

    private fun applyAdMobAPI35WorkaroundIfNeeded(application: android.app.Application) {
        if (Build.VERSION.SDK_INT < 35) return
        application.registerActivityLifecycleCallbacks(object : android.app.Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
            override fun onActivityStarted(activity: Activity) { applyAPI35WorkaroundToActivity(activity) }
            override fun onActivityResumed(activity: Activity) { applyAPI35WorkaroundToActivity(activity) }
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {}
        })
    }

    private fun applyAPI35WorkaroundToActivity(activity: Activity) {
        if (activity.javaClass.name != "com.google.android.gms.ads.AdActivity") return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity.window.insetsController?.let {
                it.hide(WindowInsets.Type.systemBars())
                it.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        }
    }

    companion object {
        private const val TAG = "EmiAdmobPlugin"
    }
}