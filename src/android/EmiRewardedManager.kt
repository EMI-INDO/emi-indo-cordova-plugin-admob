package emi.indo.cordova.plugin.admob

import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdValue
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.OnPaidEventListener
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import org.apache.cordova.CallbackContext
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class EmiRewardedManager(private val plugin: EmiAdPluginProtocol) {

    private var rewardedAd: RewardedAd? = null
    private var rewardedAutoShow: Boolean = false
    private var isAdSkip: Int = 0 

    private var isLoading: Boolean = false
    private var lastLoadTime: Long = 0
    private var minLoadInterval: Long = 5000 
    private var lastAdUnitId: String = ""

    fun loadRewardedAd(args: JSONArray, callbackContext: CallbackContext) {
        if (isLoading) {
            return
        }

        val options = args.optJSONObject(0) ?: return
        val adUnitId = options.optString("adUnitId", "")
        rewardedAutoShow = options.optBoolean("autoShow", false)

        val loadIntervalSec = options.optDouble("loadInterval", 5.0)
        minLoadInterval = (loadIntervalSec * 1000).toLong()

        val now = System.currentTimeMillis()

        if (adUnitId == lastAdUnitId && rewardedAd != null) {
            if (rewardedAutoShow) {
                showRewardedAd(null)
            } else {
                plugin.fireEvent("on.rewarded.loaded", null)
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
        rewardedAd = null
        isAdSkip = 0

        plugin.pluginActivity.runOnUiThread {
            RewardedAd.load(
                plugin.pluginActivity,
                adUnitId,
                plugin.getGlobalAdRequest(),
                object : RewardedAdLoadCallback() {

                    override fun onAdLoaded(ad: RewardedAd) {
                        isLoading = false
                        rewardedAd = ad
                        isAdSkip = 0

                        if (rewardedAutoShow) {
                            showInternal()
                        }

                        plugin.fireEvent("on.rewarded.loaded", null)
                        setupAdCallbacks()
                    }

                    override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                        isLoading = false
                        rewardedAd = null

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
                        plugin.fireEvent("on.rewarded.failed.load", errorData.toString())
                    }
                }
            )
        }
        callbackContext.success()
    }

    fun showRewardedAd(callbackContext: CallbackContext?) {
        plugin.pluginActivity.runOnUiThread {
            if (rewardedAd != null) {
                showInternal()
                callbackContext?.success()
            } else {
                callbackContext?.error("The rewarded ad wasn't ready yet")
            }
        }
    }

    private fun showInternal() {
        plugin.pluginActivity.let { activity ->
            isAdSkip = 1 
            rewardedAd?.show(activity) { rewardItem ->
                isAdSkip = 2 
                val result = JSONObject()
                try {
                    result.put("rewardType", rewardItem.type)
                    result.put("rewardAmount", rewardItem.amount)
                    plugin.fireEvent("on.reward.userEarnedReward", result.toString())
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun setupAdCallbacks() {
        rewardedAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdClicked() {
                plugin.fireEvent("on.rewarded.click", null)
            }

            override fun onAdDismissedFullScreenContent() {
                if (isAdSkip != 2) {
                    plugin.fireEvent("on.rewarded.ad.skip", null)
                } else {
                    plugin.fireEvent("on.rewarded.dismissed", null)
                }

                rewardedAd = null
                lastAdUnitId = "" 
                plugin.pluginWebView.view.requestFocus()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                rewardedAd = null
                val errorData = JSONObject().apply {
                    put("code", adError.code)
                    put("message", adError.message)
                    put("domain", adError.domain)
                    put("cause", adError.cause?.toString() ?: "null")
                }
                plugin.fireEvent("on.rewarded.failed.show", errorData.toString())
            }

            override fun onAdImpression() {
                plugin.fireEvent("on.rewarded.impression", null)
            }

            override fun onAdShowedFullScreenContent() {
                isAdSkip = 1
                plugin.fireEvent("on.rewarded.show", null)
            }
        }

        rewardedAd?.onPaidEventListener = OnPaidEventListener { adValue: AdValue ->
            val result = JSONObject()
            try {
                result.put("value", if (adValue.valueMicros > 0) adValue.valueMicros else 0L)
                result.put("currencyCode", adValue.currencyCode.ifBlank { "UNKNOWN" })
                result.put("precision", if (adValue.precisionType >= 0) adValue.precisionType else AdValue.PrecisionType.UNKNOWN)
                result.put("adUnitId", rewardedAd?.adUnitId ?: "null")
                plugin.fireEvent("on.rewarded.revenue", result.toString())
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }

        if (plugin.isResponseInfoEnabled) {
            val responseInfo = rewardedAd?.responseInfo
            if (responseInfo != null) {
                val result = JSONObject()
                try {
                    result.put("getResponseId", responseInfo.responseId)
                    result.put("getAdapterResponses", responseInfo.adapterResponses.toString())
                    result.put("getResponseExtras", responseInfo.responseExtras?.toString())
                    result.put("getMediationAdapterClassName", responseInfo.mediationAdapterClassName)
                    plugin.fireEvent("on.rewardedAd.responseInfo", result.toString())
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }
        }
    }
}
