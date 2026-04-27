package emi.indo.cordova.plugin.admob

import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdValue
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.OnPaidEventListener
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAdLoadCallback
import org.apache.cordova.CallbackContext
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class EmiRewardedInterstitialManager(private val plugin: EmiAdPluginProtocol) {

    private var rewardedInterstitialAd: RewardedInterstitialAd? = null
    private var rIntAutoShow: Boolean = false
    private var isAdSkip: Int = 0 

    private var isLoading: Boolean = false
    private var lastLoadTime: Long = 0
    private var minLoadInterval: Long = 5000 
    private var lastAdUnitId: String = ""

    fun loadRewardedInterstitialAd(args: JSONArray, callbackContext: CallbackContext) {
        if (isLoading) {
            return
        }

        val options = args.optJSONObject(0) ?: return
        val adUnitId = options.optString("adUnitId", "")
        rIntAutoShow = options.optBoolean("autoShow", false)

        val loadIntervalSec = options.optDouble("loadInterval", 5.0)
        minLoadInterval = (loadIntervalSec * 1000).toLong()

        val now = System.currentTimeMillis()

        if (adUnitId == lastAdUnitId && rewardedInterstitialAd != null) {
            if (rIntAutoShow) {
                showRewardedInterstitialAd(null)
            } else {
                plugin.fireEvent("on.rewardedInt.loaded", null)
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
        rewardedInterstitialAd = null
        isAdSkip = 0

        plugin.pluginActivity.runOnUiThread {
            RewardedInterstitialAd.load(
                plugin.pluginActivity,
                adUnitId,
                plugin.getGlobalAdRequest(),
                object : RewardedInterstitialAdLoadCallback() {

                    override fun onAdLoaded(ad: RewardedInterstitialAd) {
                        isLoading = false
                        rewardedInterstitialAd = ad
                        isAdSkip = 0

                        if (rIntAutoShow) {
                            showInternal()
                        }

                        plugin.fireEvent("on.rewardedInt.loaded", null)
                        setupAdCallbacks()
                    }

                    override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                        isLoading = false
                        rewardedInterstitialAd = null

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
                        plugin.fireEvent("on.rewardedInt.failed.load", errorData.toString())
                    }
                }
            )
        }
        callbackContext.success()
    }

    fun showRewardedInterstitialAd(callbackContext: CallbackContext?) {
        plugin.pluginActivity.runOnUiThread {
            if (rewardedInterstitialAd != null) {
                showInternal()
                callbackContext?.success()
            } else {
                callbackContext?.error("The rewarded interstitial ad wasn't ready yet")
            }
        }
    }

    private fun showInternal() {
        plugin.pluginActivity.let { activity ->
            isAdSkip = 1 
            rewardedInterstitialAd?.show(activity) { rewardItem ->
                isAdSkip = 2 
                val result = JSONObject()
                try {
                    result.put("rewardType", rewardItem.type)
                    result.put("rewardAmount", rewardItem.amount)
                    plugin.fireEvent("on.rewardedInt.userEarnedReward", result.toString())
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun setupAdCallbacks() {
        rewardedInterstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdClicked() {
                plugin.fireEvent("on.rewardedInt.click", null)
            }

            override fun onAdDismissedFullScreenContent() {
                if (isAdSkip != 2) {
                    plugin.fireEvent("on.rewardedInt.ad.skip", null)
                } else {
                    plugin.fireEvent("on.rewardedInt.dismissed", null)
                }

                rewardedInterstitialAd = null
                lastAdUnitId = "" 
                plugin.pluginWebView.view.requestFocus()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                rewardedInterstitialAd = null
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                plugin.fireEvent("on.rewardedInt.failed.show", errorData.toString())
            }

            override fun onAdImpression() {
                plugin.fireEvent("on.rewardedInt.impression", null)
            }

            override fun onAdShowedFullScreenContent() {
                isAdSkip = 1
                plugin.fireEvent("on.rewardedInt.showed", null)
            }
        }

        rewardedInterstitialAd?.onPaidEventListener = OnPaidEventListener { adValue: AdValue ->
            val result = JSONObject()
            try {
                result.put("value", if (adValue.valueMicros > 0) adValue.valueMicros else 0L)
                result.put("currencyCode", adValue.currencyCode.ifBlank { "UNKNOWN" })
                result.put("precision", if (adValue.precisionType >= 0) adValue.precisionType else AdValue.PrecisionType.UNKNOWN)
                result.put("adUnitId", rewardedInterstitialAd?.adUnitId ?: "null")
                plugin.fireEvent("on.rewardedInt.revenue", result.toString())
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }

        if (plugin.isResponseInfoEnabled) {
            val responseInfo = rewardedInterstitialAd?.responseInfo
            if (responseInfo != null) {
                val result = JSONObject()
                try {
                    result.put("getResponseId", responseInfo.responseId)
                    result.put("getAdapterResponses", responseInfo.adapterResponses.toString())
                    result.put("getResponseExtras", responseInfo.responseExtras?.toString())
                    result.put("getMediationAdapterClassName", responseInfo.mediationAdapterClassName)
                    plugin.fireEvent("on.rewardedIntAd.responseInfo", result.toString())
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }
        }
    }
}
