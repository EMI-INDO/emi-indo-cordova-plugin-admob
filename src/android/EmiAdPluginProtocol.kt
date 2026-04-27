package emi.indo.cordova.plugin.admob

import android.app.Activity
import com.google.android.gms.ads.AdRequest
import org.apache.cordova.CordovaWebView

interface EmiAdPluginProtocol {
    val pluginActivity: Activity
    val pluginWebView: CordovaWebView
    val isResponseInfoEnabled: Boolean

    fun getGlobalAdRequest(extras: android.os.Bundle? = null): AdRequest
    fun fireEvent(eventName: String, data: String?)
}
