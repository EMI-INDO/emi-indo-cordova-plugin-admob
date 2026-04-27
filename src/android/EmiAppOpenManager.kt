// src/android/EmiAppOpenManager.kt
package emi.indo.cordova.plugin.admob

import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdValue
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.OnPaidEventListener
import com.google.android.gms.ads.appopen.AppOpenAd
import org.apache.cordova.CallbackContext
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class EmiAppOpenManager(private val plugin: EmiAdPluginProtocol) {

    private var appOpenAd: AppOpenAd? = null
    private var appOpenAutoShow: Boolean = false

    // Security & Throttle Guards (Anti-Flicker)
    private var isLoading: Boolean = false
    private var lastLoadTime: Long = 0
    private var minLoadInterval: Long = 5000 // Default 5 detik (dalam milidetik)
    private var lastAdUnitId: String = ""

    fun loadAppOpenAd(args: JSONArray, callbackContext: CallbackContext) {
        // 1. Pengaman Anti-Double Request
        if (isLoading) {
            return
        }

        val options = args.optJSONObject(0) ?: return
        val adUnitId = options.optString("adUnitId", "")
        appOpenAutoShow = options.optBoolean("autoShow", false)

        // 2. Baca interval kustom dari pengguna
        val loadIntervalSec = options.optDouble("loadInterval", 5.0)
        minLoadInterval = (loadIntervalSec * 1000).toLong()

        val now = System.currentTimeMillis()

        // 3. Pengaman Same Ad Unit
        if (adUnitId == lastAdUnitId && appOpenAd != null) {
            if (appOpenAutoShow) {
                showAppOpenAd(null)
            } else {
                plugin.fireEvent("on.appOpenAd.loaded", null)
                callbackContext.success()
            }
            return
        }

        // 4. Pengaman Throttle
        if (now - lastLoadTime < minLoadInterval) {
            return
        }

        // Kunci status loading
        isLoading = true
        lastLoadTime = now
        lastAdUnitId = adUnitId
        appOpenAd = null

        plugin.pluginActivity.runOnUiThread {
            AppOpenAd.load(
                plugin.pluginActivity,
                adUnitId,
                plugin.getGlobalAdRequest(),
                object : AppOpenAd.AppOpenAdLoadCallback() {

                    override fun onAdLoaded(ad: AppOpenAd) {
                        isLoading = false
                        appOpenAd = ad

                        if (appOpenAutoShow) {
                            showInternal()
                        }

                        plugin.fireEvent("on.appOpenAd.loaded", null)
                        setupAdCallbacks()
                    }

                    override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                        isLoading = false
                        appOpenAd = null

                        val errorData = JSONObject().apply {
                            put("code", loadAdError.code)
                            put("message", loadAdError.message)
                            put("domain", loadAdError.domain)
                            put("cause", loadAdError.cause?.toString() ?: "null")

                            loadAdError.responseInfo?.let { info ->
                                put("responseInfoId", info.responseId)
                                put("responseInfoExtras", info.responseExtras?.toString())
                                put("responseInfoAdapter", info.loadedAdapterResponseInfo?.toString())
                                put("responseInfoMediationAdapterClassName", info.mediationAdapterClassName)
                                put("responseInfoAdapterResponses", info.adapterResponses.toString())
                            }
                        }
                        plugin.fireEvent("on.appOpenAd.failed.loaded", errorData.toString())
                    }
                }
            )
        }
        callbackContext.success()
    }

    fun showAppOpenAd(callbackContext: CallbackContext?) {
        plugin.pluginActivity.runOnUiThread {
            if (appOpenAd != null) {
                showInternal()
                callbackContext?.success()
            } else {
                callbackContext?.error("The App Open ad wasn't ready yet")
            }
        }
    }

    private fun showInternal() {
        appOpenAd?.show(plugin.pluginActivity)
    }

    private fun setupAdCallbacks() {
        appOpenAd?.fullScreenContentCallback = object : FullScreenContentCallback() {

            override fun onAdDismissedFullScreenContent() {
                plugin.fireEvent("on.appOpenAd.dismissed", null)
                appOpenAd = null
                lastAdUnitId = "" // Bersihkan cache agar siap di-load lagi

                // Kembalikan fokus ke WebView Cordova
                plugin.pluginWebView.view.requestFocus()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                appOpenAd = null
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                plugin.fireEvent("on.appOpenAd.failed.show", errorData.toString())
            }

            override fun onAdShowedFullScreenContent() {
                plugin.fireEvent("on.appOpenAd.show", null)
            }
        }

        appOpenAd?.onPaidEventListener = OnPaidEventListener { adValue: AdValue ->
            val result = JSONObject()
            try {
                result.put("value", if (adValue.valueMicros > 0) adValue.valueMicros else 0L)
                result.put("currencyCode", adValue.currencyCode.ifBlank { "UNKNOWN" })
                result.put("precision", if (adValue.precisionType >= 0) adValue.precisionType else AdValue.PrecisionType.UNKNOWN)
                result.put("adUnitId", appOpenAd?.adUnitId ?: "null")
                plugin.fireEvent("on.appOpenAd.revenue", result.toString())
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }

        if (plugin.isResponseInfoEnabled) {
            val responseInfo = appOpenAd?.responseInfo
            if (responseInfo != null) {
                val result = JSONObject()
                try {
                    result.put("getResponseId", responseInfo.responseId)
                    result.put("getAdapterResponses", responseInfo.adapterResponses.toString())
                    result.put("getResponseExtras", responseInfo.responseExtras?.toString())
                    result.put("getMediationAdapterClassName", responseInfo.mediationAdapterClassName)
                    plugin.fireEvent("on.appOpenAd.responseInfo", result.toString())
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }
        }
    }
}