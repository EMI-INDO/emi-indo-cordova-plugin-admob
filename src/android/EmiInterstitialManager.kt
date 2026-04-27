package emi.indo.cordova.plugin.admob

import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdValue
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.OnPaidEventListener
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import org.apache.cordova.CallbackContext
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class EmiInterstitialManager(private val plugin: EmiAdPluginProtocol) {

    private var mInterstitialAd: InterstitialAd? = null
    private var intAutoShow: Boolean = false

    private var isLoading: Boolean = false
    private var lastLoadTime: Long = 0
    private var minLoadInterval: Long = 5000 
    private var lastAdUnitId: String = ""

    fun loadInterstitialAd(args: JSONArray, callbackContext: CallbackContext) {
        if (isLoading) {
            return
        }

        val options = args.optJSONObject(0) ?: return
        val adUnitId = options.optString("adUnitId", "")
        intAutoShow = options.optBoolean("autoShow", false)

        val loadIntervalSec = options.optDouble("loadInterval", 5.0)
        minLoadInterval = (loadIntervalSec * 1000).toLong()

        val now = System.currentTimeMillis()

        if (adUnitId == lastAdUnitId && mInterstitialAd != null) {
            if (intAutoShow) {
                showInterstitialAd(null)
            } else {
                plugin.fireEvent("on.interstitial.loaded", null)
                callbackContext.success()
            }
            return
        }

        if (now - lastLoadTime < minLoadInterval) {
            return
        }

        isLoading = true
        lastLoadTime = now
        lastAdUnitId = adUnitId
        mInterstitialAd = null

        plugin.pluginActivity.runOnUiThread {
            InterstitialAd.load(
                plugin.pluginActivity,
                adUnitId,
                plugin.getGlobalAdRequest(),
                object : InterstitialAdLoadCallback() {

                    override fun onAdLoaded(interstitialAd: InterstitialAd) {
                        isLoading = false
                        mInterstitialAd = interstitialAd

                        if (intAutoShow) {
                            showInternal()
                        }

                        plugin.fireEvent("on.interstitial.loaded", null)
                        setupAdCallbacks()
                    }

                    override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                        isLoading = false
                        mInterstitialAd = null

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
                        plugin.fireEvent("on.interstitial.failed.load", errorData.toString())
                    }
                }
            )
        }
        callbackContext.success()
    }

    fun showInterstitialAd(callbackContext: CallbackContext?) {
        plugin.pluginActivity.runOnUiThread {
            if (mInterstitialAd != null) {
                showInternal()
                callbackContext?.success()
            } else {
                callbackContext?.error("The Interstitial ad wasn't ready yet")
            }
        }
    }

    private fun showInternal() {
        mInterstitialAd?.show(plugin.pluginActivity)
    }

    private fun setupAdCallbacks() {
        mInterstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdClicked() {
                plugin.fireEvent("on.interstitial.click", null)
            }

            override fun onAdDismissedFullScreenContent() {
                mInterstitialAd = null
                lastAdUnitId = "" 
                plugin.fireEvent("on.interstitial.dismissed", null)
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                mInterstitialAd = null
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                plugin.fireEvent("on.interstitial.failed.show", errorData.toString())
            }

            override fun onAdImpression() {
                plugin.fireEvent("on.interstitial.impression", null)
            }

            override fun onAdShowedFullScreenContent() {
                plugin.fireEvent("on.interstitial.show", null)
                plugin.fireEvent("onPresentAd", null) 
            }
        }

        mInterstitialAd?.onPaidEventListener = OnPaidEventListener { adValue: AdValue ->
            val result = JSONObject()
            try {
                result.put("value", if (adValue.valueMicros > 0) adValue.valueMicros else 0L)
                result.put("currencyCode", adValue.currencyCode.ifBlank { "UNKNOWN" })
                result.put("precision", if (adValue.precisionType >= 0) adValue.precisionType else AdValue.PrecisionType.UNKNOWN)
                result.put("adUnitId", mInterstitialAd?.adUnitId ?: "null")
                plugin.fireEvent("on.interstitial.revenue", result.toString())
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }

        if (plugin.isResponseInfoEnabled) {
            val responseInfo = mInterstitialAd?.responseInfo
            if (responseInfo != null) {
                val result = JSONObject()
                try {
                    result.put("getResponseId", responseInfo.responseId)
                    result.put("getAdapterResponses", responseInfo.adapterResponses.toString())
                    result.put("getResponseExtras", responseInfo.responseExtras?.toString())
                    result.put("getMediationAdapterClassName", responseInfo.mediationAdapterClassName)
                    plugin.fireEvent("on.interstitialAd.responseInfo", result.toString())
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }
        }
    }
}
