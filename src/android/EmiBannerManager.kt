package emi.indo.cordova.plugin.admob

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.WindowManager
import android.widget.FrameLayout
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdValue
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.OnPaidEventListener
import org.apache.cordova.CallbackContext
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.Locale

class EmiBannerManager(private val plugin: EmiAdPluginProtocol) {

    private var bannerViewLayout: FrameLayout? = null
    private var bannerView: AdView? = null

    private var isPosition: String = "bottom-center"
    private var adType: String = "BANNER"
    private var bannerViewHeight: Int = 0
    private var paddingInPx: Int = 0
    private var marginsInPx: Int = 0
    private var isCollapsible: Boolean = false

    private var isBannerLoad: Boolean = false
    private var isBannerShow: Boolean = false
    private var bannerAutoShow: Boolean = false
    private var isOverlapping: Boolean = false
    private var isFullScreen: Boolean = false
    private var lock: Boolean = true
    private var isBannerPause: Int = 2

    private var isLoading: Boolean = false
    private var lastLoadTime: Long = 0
    private var minLoadInterval: Long = 5000
    private var lastAdUnitId: String = ""

    private fun runOnUiThread(action: Runnable) {
        plugin.pluginActivity.runOnUiThread(action)
    }

    @SuppressLint("RtlHardcoded")
    private fun setBannerPosition(position: String?) {
        val bannerParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        )

        when (position) {
            "top-right" -> {
                bannerParams.gravity = Gravity.TOP or Gravity.RIGHT
                bannerParams.setMargins(0, marginsInPx, marginsInPx, 0)
            }
            "top-center" -> {
                bannerParams.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                bannerParams.setMargins(0, marginsInPx, 0, 0)
            }
            "left" -> {
                bannerParams.gravity = Gravity.LEFT or Gravity.CENTER_VERTICAL
                bannerParams.setMargins(marginsInPx, 0, 0, 0)
            }
            "center" -> {
                bannerParams.gravity = Gravity.CENTER
            }
            "right" -> {
                bannerParams.gravity = Gravity.RIGHT or Gravity.CENTER_VERTICAL
                bannerParams.setMargins(0, 0, marginsInPx, 0)
            }
            "bottom-center" -> {
                bannerParams.gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                bannerParams.setMargins(0, 0, 0, marginsInPx)
            }
            "bottom-right" -> {
                bannerParams.gravity = Gravity.BOTTOM or Gravity.RIGHT
                bannerParams.setMargins(0, 0, marginsInPx, marginsInPx)
            }
            else -> {
                bannerParams.gravity = Gravity.CENTER_HORIZONTAL or Gravity.BOTTOM
                bannerParams.setMargins(marginsInPx, 0, 0, marginsInPx)
            }
        }
        bannerViewLayout?.layoutParams = bannerParams
    }

    private fun bannerOverlappingToZero() {
        if (bannerView != null) {
            runOnUiThread {
                try {
                    val rootView = plugin.pluginWebView.view.parent as View
                    rootView.post {
                        val webLp = plugin.pluginWebView.view.layoutParams as? FrameLayout.LayoutParams
                        if (webLp != null) {
                            webLp.height = FrameLayout.LayoutParams.MATCH_PARENT
                            webLp.topMargin = 0
                            webLp.bottomMargin = 0
                            plugin.pluginWebView.view.layoutParams = webLp
                        }
                        plugin.pluginWebView.view.setPadding(0, 0, 0, 0)
                        (plugin.pluginWebView.view.parent as? ViewGroup)?.setPadding(0, 0, 0, 0)
                        plugin.pluginWebView.view.requestLayout()
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun setBannerAdTop() {
        val activity = plugin.pluginActivity
        bannerView?.post {
            val bannerHeightPx = bannerViewHeight
            val statusBarHeight = getStatusBarHeight(activity)

            if (isPosition.equals("top-center", ignoreCase = true)) {
                val bannerLp = bannerView?.layoutParams as? FrameLayout.LayoutParams
                bannerLp?.let { lp ->

                    lp.topMargin = if (isFullScreen) 0 else statusBarHeight
                    bannerView?.layoutParams = lp
                }
            }

            val webView = plugin.pluginWebView.view
            val webLp = webView.layoutParams as? FrameLayout.LayoutParams
            if (webLp != null && isPosition.equals("top-center", ignoreCase = true)) {
                if (!isOverlapping) {

                    webLp.topMargin = bannerHeightPx + paddingInPx
                    webLp.height = FrameLayout.LayoutParams.MATCH_PARENT
                } else {
                    webLp.topMargin = 0
                    webLp.height = FrameLayout.LayoutParams.MATCH_PARENT
                }
                webView.layoutParams = webLp
            }
            webView.requestLayout()
        }
    }

    private fun setBannerAdBottom() {
        if (bannerView != null) {
            runOnUiThread {
                bannerView?.post {
                    try {
                        val activity = plugin.pluginActivity

                        val screenHeightInPx = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            val windowMetrics = activity.windowManager.currentWindowMetrics
                            val insets = windowMetrics.windowInsets.getInsets(WindowInsets.Type.systemBars())
                            windowMetrics.bounds.height() - insets.top - insets.bottom
                        } else {
                            val displayMetrics = DisplayMetrics()
                            @Suppress("DEPRECATION")
                            activity.windowManager.defaultDisplay.getMetrics(displayMetrics)
                            displayMetrics.heightPixels
                        }

                        val navBarHeight = if (!isFullScreen) getNavigationBarHeight(activity) else 0
                        bannerViewLayout?.let { container ->
                            val params = container.layoutParams as? ViewGroup.MarginLayoutParams
                            if (params != null) {
                                params.bottomMargin = navBarHeight
                                container.layoutParams = params
                            }
                        }

                        val webLp = plugin.pluginWebView.view.layoutParams as? FrameLayout.LayoutParams
                        if (webLp != null) {
                            if (!isOverlapping) {
                                val webViewHeight = screenHeightInPx - bannerViewHeight - paddingInPx
                                webLp.height = webViewHeight
                                webLp.topMargin = 0
                            } else {
                                webLp.height = FrameLayout.LayoutParams.MATCH_PARENT
                                webLp.topMargin = 0
                            }
                            plugin.pluginWebView.view.layoutParams = webLp
                        }

                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        }
    }

    private fun checkAndShowBanner() {
        runOnUiThread {
            if (isBannerLoad && bannerView != null && bannerViewLayout != null) {
                try {
                    if (lock) {
                        val adParams = FrameLayout.LayoutParams(
                            FrameLayout.LayoutParams.MATCH_PARENT,
                            FrameLayout.LayoutParams.WRAP_CONTENT
                        )
                        bannerViewLayout?.addView(bannerView, adParams)
                        bannerViewLayout?.bringToFront()
                        bannerViewLayout?.requestFocus()
                        lock = false
                    }
                    isBannerShow = true
                    isBannerPause = 0
                    bannerView?.visibility = View.VISIBLE
                    bannerView?.resume()
                } catch (e: Exception) {
                    lock = true
                    e.printStackTrace()
                }
            }
        }
    }

    private fun destroyBannerInternal() {
        try {
            if (bannerViewLayout != null || bannerView != null) {
                bannerOverlappingToZero()
                bannerViewLayout?.removeView(bannerView)
                bannerView?.destroy()
                (bannerViewLayout?.parent as? ViewGroup)?.removeView(bannerViewLayout)
                bannerView = null
                bannerViewLayout = null
                isBannerLoad = false
                isBannerShow = false
                isBannerPause = 2
                lock = true
                isLoading = false
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun loadBannerAd(args: JSONArray, callbackContext: CallbackContext) {
        if (isLoading) return

        val options = args.optJSONObject(0) ?: return
        val adUnitId = options.optString("adUnitId", "")
        val position = options.optString("position", "bottom-center")
        val sizeStr = options.optString("size", "BANNER")

        isOverlapping = options.optBoolean("isOverlapping", false)
        bannerAutoShow = options.optBoolean("autoShow", false)
        isPosition = position
        adType = sizeStr
        paddingInPx = options.optInt("padding", 0)
        marginsInPx = options.optInt("margins", 0)

        isCollapsible = false
        val collapsibleObj = options.opt("collapsible")
        if (collapsibleObj is Boolean) {
            isCollapsible = collapsibleObj
        } else if (collapsibleObj is String) {
            val valStr = collapsibleObj.toString().lowercase(Locale.getDefault())
            if (valStr == "true" || valStr == "top" || valStr == "bottom") {
                isCollapsible = true
            }
        }

        val loadIntervalSec = options.optDouble("loadInterval", 5.0)
        minLoadInterval = (loadIntervalSec * 1000).toLong()
        val now = System.currentTimeMillis()

        if (adUnitId == lastAdUnitId && bannerView != null) {
            if (bannerAutoShow) checkAndShowBanner()
            callbackContext.success()
            return
        }

        if (now - lastLoadTime < minLoadInterval) return

        isLoading = true
        lastLoadTime = now
        lastAdUnitId = adUnitId
        isFullScreen = isFullScreenMode(plugin.pluginActivity)

        runOnUiThread {
            try {
                val activity = plugin.pluginActivity
                val decorView = activity.window.decorView as ViewGroup

                val ghostLayout = decorView.findViewWithTag<FrameLayout>("emi_banner_layout")
                if (ghostLayout != null) {
                    decorView.removeView(ghostLayout)
                }

                destroyBannerInternal()

                bannerViewLayout = FrameLayout(activity).apply {
                    tag = "emi_banner_layout"
                }

                val params = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
                decorView.addView(bannerViewLayout, params)

                bannerView = AdView(activity)
                setBannerPosition(isPosition)
                setBannerSize(adType)
                bannerView?.adUnitId = adUnitId
                bannerView?.adListener = bannerAdListener

                lock = true

                val bannerExtras = android.os.Bundle()
                if (isCollapsible) {
                    val anchor = if (isPosition.contains("top", ignoreCase = true)) "top" else "bottom"
                    bannerExtras.putString("collapsible", anchor)
                }

                val request = plugin.getGlobalAdRequest(if (isCollapsible) bannerExtras else null)
                bannerView?.loadAd(request)

            } catch (e: Exception) {
                isLoading = false
                plugin.fireEvent("on.banner.failed.load", "{\"message\":\"${e.message}\"}")
            }
        }
        callbackContext.success()
    }

    fun showBannerAd(callbackContext: CallbackContext?) {
        runOnUiThread {
            if (isBannerPause == 0) {
                checkAndShowBanner()
            } else if (isBannerPause == 1) {
                try {
                    bannerView?.visibility = View.VISIBLE
                    bannerView?.resume()

                    if (isPosition == "top-center") {
                        setBannerAdTop()
                    } else {
                        setBannerAdBottom()
                    }
                    bannerViewLayout?.requestFocus()
                    isBannerShow = true
                    isBannerPause = 0
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            callbackContext?.success()
        }
    }

    fun hideBannerAd(callbackContext: CallbackContext) {
        runOnUiThread {
            if (isBannerShow) {
                try {
                    bannerView?.visibility = View.GONE
                    bannerView?.pause()
                    isBannerLoad = false
                    isBannerPause = 1
                    bannerOverlappingToZero()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            plugin.fireEvent("on.banner.hide", null)
            callbackContext.success()
        }
    }

    fun removeBannerAd(callbackContext: CallbackContext) {
        runOnUiThread {
            destroyBannerInternal()
            lastAdUnitId = ""
            plugin.fireEvent("on.banner.remove", null)
            callbackContext.success()
        }
    }

    fun styleBannerAd(args: JSONArray, callbackContext: CallbackContext) {
        val options = args.optJSONObject(0) ?: return
        if (options.has("isOverlapping")) {
            isOverlapping = options.optBoolean("isOverlapping")
        }
        if (options.has("padding")) {
            paddingInPx = options.optInt("padding")
        }
        runOnUiThread {
            if (isPosition == "top-center") {
                setBannerAdTop()
            } else {
                setBannerAdBottom()
            }
            callbackContext.success()
        }
    }

    private val bannerAdListener = object : AdListener() {
        override fun onAdLoaded() {
            isLoading = false
            isBannerLoad = true
            isBannerPause = 0

            if (bannerAutoShow) {
                checkAndShowBanner()
            }

            bannerView?.post {
                bannerViewHeight = getAdHeightInPx(bannerView?.adSize)

                if (isPosition == "top-center") {
                    setBannerAdTop()
                } else {
                    setBannerAdBottom()
                }
            }

            val currentAdSize = if (isCollapsible) {
                AdSize.BANNER
            } else {
                when (adType.uppercase(Locale.getDefault())) {
                    "BANNER" -> AdSize.BANNER
                    "LARGE_BANNER" -> AdSize.LARGE_BANNER
                    "MEDIUM_RECTANGLE" -> AdSize.MEDIUM_RECTANGLE
                    "FULL_BANNER" -> AdSize.FULL_BANNER
                    "LEADERBOARD" -> AdSize.LEADERBOARD
                    "FLUID" -> AdSize.FLUID
                    "FULL_WIDTH", "FULL_WIDTH_ADAPTIVE", "ANCHORED_ADAPTIVE", "RESPONSIVE_ADAPTIVE" -> adSize
                    else -> adSize
                }
            }

            val bannerHeightDp = getAdHeightInDp(currentAdSize, plugin.pluginActivity)
            val bannerLoadEventData = String.format(Locale.US, "{\"height\": %d}", bannerHeightDp)
            plugin.fireEvent("on.banner.load", bannerLoadEventData)

            val isColStr = if (isCollapsible) "collapsible" else "not collapsible"
            plugin.fireEvent("on.is.collapsible", "{\"collapsible\": \"$isColStr\"}")

            bannerView?.onPaidEventListener = OnPaidEventListener { adValue ->
                val result = JSONObject()
                try {
                    result.put("value", if (adValue.valueMicros > 0) adValue.valueMicros else 0L)
                    result.put("currencyCode", adValue.currencyCode.ifBlank { "UNKNOWN" })
                    result.put("precision", if (adValue.precisionType >= 0) adValue.precisionType else AdValue.PrecisionType.UNKNOWN)
                    result.put("adUnitId", bannerView?.adUnitId ?: "null")
                    isBannerLoad = false
                    isBannerShow = true
                    plugin.fireEvent("on.banner.revenue", result.toString())
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }

            if (plugin.isResponseInfoEnabled) {
                bannerView?.responseInfo?.let { info ->
                    val result = JSONObject().apply {
                        put("getResponseId", info.responseId)
                        put("getAdapterResponses", info.adapterResponses.toString())
                        put("getResponseExtras", info.responseExtras.toString())
                        put("getMediationAdapterClassName", info.mediationAdapterClassName)
                    }
                    plugin.fireEvent("on.bannerAd.responseInfo", result.toString())
                }
            }
        }

        override fun onAdFailedToLoad(adError: LoadAdError) {
            isLoading = false
            if (bannerViewLayout != null && bannerView != null) {
                isBannerLoad = false
                isBannerPause = 2
                lock = true
            }

            val errorData = JSONObject().apply {
                put("code", adError.code)
                put("message", adError.message)
                put("domain", adError.domain)
                put("cause", adError.cause?.toString() ?: "null")
            }
            plugin.fireEvent("on.banner.failed.load", errorData.toString())
        }

        override fun onAdClicked() {
            plugin.fireEvent("on.banner.click", null)
        }

        override fun onAdClosed() {
            plugin.fireEvent("on.banner.close", null)
        }

        override fun onAdImpression() {
            plugin.fireEvent("on.banner.impression", null)
        }

        override fun onAdOpened() {
            plugin.fireEvent("on.banner.open", null)
            isBannerShow = false
        }
    }

    private fun setBannerSize(size: String?) {
        val activity = plugin.pluginActivity
        if (bannerView == null) return

        if (isCollapsible) {
            bannerView?.setAdSize(AdSize.BANNER)
            return
        }

        when (size?.uppercase(Locale.getDefault())) {
            "RESPONSIVE_ADAPTIVE" -> bannerView?.setAdSize(adSize)
            "ANCHORED_ADAPTIVE" -> bannerView?.setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, adWidth))
            "FULL_WIDTH_ADAPTIVE", "FULL_WIDTH" -> bannerView?.setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, adWidth))
            "IN_LINE_ADAPTIVE" -> bannerView?.setAdSize(AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(activity, adWidth))
            "BANNER" -> bannerView?.setAdSize(AdSize.BANNER)
            "LARGE_BANNER" -> bannerView?.setAdSize(AdSize.LARGE_BANNER)
            "MEDIUM_RECTANGLE" -> bannerView?.setAdSize(AdSize.MEDIUM_RECTANGLE)
            "FULL_BANNER" -> bannerView?.setAdSize(AdSize.FULL_BANNER)
            "LEADERBOARD" -> bannerView?.setAdSize(AdSize.LEADERBOARD)
            "FLUID" -> bannerView?.setAdSize(AdSize.FLUID)
            else -> bannerView?.setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, adWidth))
        }
    }

    private val adSize: AdSize
        get() {
            val activity = plugin.pluginActivity
            val outMetrics = DisplayMetrics()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                activity.windowManager?.currentWindowMetrics?.let { windowMetrics ->
                    val insets = windowMetrics.windowInsets.getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
                    val bounds = windowMetrics.bounds
                    outMetrics.widthPixels = bounds.width() - insets.left - insets.right
                    outMetrics.density = activity.resources.displayMetrics.density
                }
            } else {
                @Suppress("DEPRECATION")
                activity.windowManager?.defaultDisplay?.getMetrics(outMetrics)
            }
            val density = outMetrics.density
            val adWidthPixels = if ((bannerViewLayout?.width ?: 0) > 0) bannerViewLayout!!.width else outMetrics.widthPixels
            val adWidthInt = (adWidthPixels / density).toInt()
            return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, adWidthInt)
        }

    private val adWidth: Int
        get() {
            val activity = plugin.pluginActivity
            val outMetrics = DisplayMetrics()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                activity.windowManager?.currentWindowMetrics?.let { windowMetrics ->
                    val insets = windowMetrics.windowInsets.getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
                    val bounds = windowMetrics.bounds
                    outMetrics.widthPixels = bounds.width() - insets.left - insets.right
                    outMetrics.density = activity.resources.displayMetrics.density
                }
            } else {
                @Suppress("DEPRECATION")
                activity.windowManager?.defaultDisplay?.getMetrics(outMetrics)
            }
            val density = outMetrics.density
            val adWidthPixels = (bannerViewLayout?.width?.takeIf { it > 0 } ?: outMetrics.widthPixels).toFloat()
            return (adWidthPixels / density).toInt()
        }

    private fun getAdHeightInPx(adSize: AdSize?): Int {
        if (adSize == null) return 0
        return adSize.getHeightInPixels(plugin.pluginActivity)
    }

    private fun getAdHeightInDp(adSize: AdSize, context: Context): Int {
        val heightInPixels = adSize.getHeightInPixels(context)
        val density = context.resources.displayMetrics.density
        return (heightInPixels / density).toInt()
    }

    private fun isFullScreenMode(activity: android.app.Activity): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity.window.decorView.rootWindowInsets?.isVisible(WindowInsets.Type.statusBars()) == false
        } else {
            @Suppress("DEPRECATION")
            (activity.window.attributes.flags and WindowManager.LayoutParams.FLAG_FULLSCREEN) != 0
        }
    }

    @SuppressLint("InternalInsetResource", "DiscouragedApi")
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
        val resourceId = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (resourceId > 0) context.resources.getDimensionPixelSize(resourceId) else 0
    }
}
