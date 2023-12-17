package emi.indo.cordova.plugin.admob;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import androidx.annotation.NonNull;
import androidx.preference.PreferenceManager;
import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdValue;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.OnPaidEventListener;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.appopen.AppOpenAd;
import com.google.android.gms.ads.initialization.AdapterStatus;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd;
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAdLoadCallback;
import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.ConsentForm;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.UserMessagingPlatform;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Map;
import java.util.Objects;
public class emiAdmobPlugin extends CordovaPlugin {
  private static final String TAG = "emiAdmobPlugin";
  private CallbackContext PUBLIC_CALLBACKS = null;
  private InterstitialAd mInterstitialAd;
  private RewardedAd rewardedAd;
  private RewardedInterstitialAd rewardedInterstitialAd;
  private CordovaWebView cWebView;
  private boolean isAppOpenAdShow = false;
  static boolean isinterstitialload = false;
  static boolean isrewardedInterstitialload = false;
  static boolean isrewardedload = false;
  int isBannerPause = 0;
  String Npa;
  String Position;
  String Size;
  int AdaptiveWidth = 320;
  Boolean ResponseInfo = false;
  int bannerAdImpression = 0;
  private int isAdSkip = 0;
  int SetTagForChildDirectedTreatment = -1;
  Boolean SetTagForUnderAgeOfConsent = false;
  String SetMaxAdContentRating = "G";
  String appOpenAdUnitId;
  String bannerAdUnitId;
  String interstitialAdUnitId;
  String rewardedInterstitialAdUnitId;
  String rewardedAdUnitId;
  boolean SetAppMuted = false;
  float SetAppVolume = 1;
  boolean EnableSameAppKey = false;
  private ConsentInformation consentInformation;
  private RelativeLayout bannerViewLayout;
  private AdView bannerView;
  private boolean isBannerLoad = false;
  private boolean isBannerShow = false;
  Boolean bannerAutoShow = false;
  Boolean appOpenAutoShow = false;
  Boolean intAutoShow = false;
  Boolean rewardedAutoShow = false;
  Boolean rIntAutoShow = false;
  String Collapsible;
  Boolean isCollapsible = false;
  Boolean lock = true;
  Boolean setDebugGeography = false;
  protected Activity mActivity;
  protected Context mContext;
  private AppOpenAd appOpenAd;
  int orientation = 0;
  private static final String LAST_ACCESS_SUFFIX = "_last_access";
  private static final long EXPIRATION_TIME = (long) 360 * 24 * 60 * 60 * 1000;
  private SharedPreferences mPreferences;
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    cWebView = webView;
    mActivity = this.cordova.getActivity();
    mContext = mActivity.getApplicationContext();
    mPreferences = PreferenceManager.getDefaultSharedPreferences(mContext);
    int orientation = mActivity.getResources().getConfiguration().orientation;
    if (orientation == Configuration.ORIENTATION_PORTRAIT) {
      this.orientation = 0;
    } else {
      this.orientation = 1;
    }
  }
  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) {
    PUBLIC_CALLBACKS = callbackContext;
    switch (action) {
    case "initialize":
      Log.d(TAG, "Google Mobile Ads SDK: " + MobileAds.getVersion());
      MobileAds.initialize(mActivity, initializationStatus -> {
        Map < String,
        AdapterStatus > statusMap = initializationStatus.getAdapterStatusMap();
        for (String adapterClass: statusMap.keySet()) {
          AdapterStatus status = statusMap.get(adapterClass);
          if (status != null) {
            Log.d(TAG, String.format("Adapter name:%s,Description:%s,Latency:%d", adapterClass, status.getDescription(), status.getLatency()));
          } else {
            callbackContext.error(MobileAds.ERROR_DOMAIN);
          }
        }
        callbackContext.success("Google Mobile Ads SDK: " + MobileAds.getVersion());cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.sdkInitialization');");
      });
      return true;
    case "targeting":
      cordova.getActivity().runOnUiThread(() -> {
        final int childDirectedTreatment = args.optInt(0);final boolean underAgeOfConsent = args.optBoolean(1);final String contentRating = args.optString(2);
        try {
          this.SetTagForChildDirectedTreatment = childDirectedTreatment;
          this.SetTagForUnderAgeOfConsent = underAgeOfConsent;
          this.SetMaxAdContentRating = contentRating;
          _Targeting();
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "globalSettings":
      cordova.getActivity().runOnUiThread(() -> {
        final boolean setAppMuted = args.optBoolean(0);final float setAppVolume = (float) args.optDouble(1);final boolean publisherFirstPartyIdEnabled = args.optBoolean(2);final String npa = args.optString(3);final boolean enableCollapsible = args.optBoolean(4);final boolean responseInfo = args.optBoolean(5);final boolean setDebugGeography = args.optBoolean(6);
        try {
          this.SetAppMuted = setAppMuted;
          this.SetAppVolume = setAppVolume;
          this.EnableSameAppKey = publisherFirstPartyIdEnabled;
          this.Npa = npa;
          this.isCollapsible = enableCollapsible;
          this.ResponseInfo = responseInfo;
          this.setDebugGeography = setDebugGeography;
          _globalSettings();
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "loadAppOpenAd":
      cordova.getActivity().runOnUiThread(() -> {
        final String adUnitId = args.optString(0);final boolean autoShow = args.optBoolean(1);
        try {
          this.appOpenAdUnitId = adUnitId;
          this.appOpenAutoShow = autoShow;
          Bundle bundleExtra = new Bundle();
          bundleExtra.putString("npa", this.Npa);
          bundleExtra.putInt("is_designed_for_families", this.SetTagForChildDirectedTreatment);
          bundleExtra.putBoolean("under_age_of_consent", this.SetTagForUnderAgeOfConsent);
          bundleExtra.putString("max_ad_content_rating", this.SetMaxAdContentRating);
          AdRequest adRequest = new AdRequest.Builder().addNetworkExtrasBundle(AdMobAdapter.class, bundleExtra).build();
          AppOpenAd.load(mActivity, this.appOpenAdUnitId, adRequest, new AppOpenAd.AppOpenAdLoadCallback() {
            @Override public void onAdLoaded(@NonNull AppOpenAd ad) {
              appOpenAd = ad;
              isAppOpenAdShow = true;
              if (appOpenAutoShow) {
                cordova.getActivity().runOnUiThread(() -> appOpenAd.show(mActivity));
                _appOpenAdLoadCallback(callbackContext);
              }
              appOpenAd.setOnPaidEventListener(adValue -> {
                long valueMicros = adValue.getValueMicros();String currencyCode = adValue.getCurrencyCode();int precision = adValue.getPrecisionType();String adUnitId = appOpenAd.getAdUnitId();JSONObject result = new JSONObject();
                try {
                  result.put("micros", valueMicros);
                  result.put("currency", currencyCode);
                  result.put("precision", precision);
                  result.put("adUnitId", adUnitId);
                  callbackContext.success(result);
                  cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.revenue');");
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
              });
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.loaded');");
              if (ResponseInfo) {
                JSONObject result = new JSONObject();
                ResponseInfo responseInfo = ad.getResponseInfo();
                try {
                  result.put("getResponseId", responseInfo.getResponseId());
                  result.put("getAdapterResponses", responseInfo.getAdapterResponses());
                  result.put("getResponseExtras", responseInfo.getResponseExtras());
                  result.put("getMediationAdapterClassName", responseInfo.getMediationAdapterClassName());
                  result.put("getBundleExtra", bundleExtra);
                  callbackContext.success(result);
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
              }
            }
            @Override public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
              isAppOpenAdShow = false;
              callbackContext.error(loadAdError.toString());
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.failed.loaded');");
            }
          });
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "showAppOpenAd":
      if (isAppOpenAdShow) {
        cordova.getActivity().runOnUiThread(() -> appOpenAd.show(mActivity));
        _appOpenAdLoadCallback(callbackContext);
      } else {
        callbackContext.error("The App Open Ad wasn't ready yet");
      }
      return true;
    case "loadInterstitialAd":
      cordova.getActivity().runOnUiThread(() -> {
        final String adUnitId = args.optString(0);final boolean autoShow = args.optBoolean(1);
        try {
          this.interstitialAdUnitId = adUnitId;
          this.intAutoShow = autoShow;
          Bundle bundleExtra = new Bundle();
          bundleExtra.putString("npa", this.Npa);
          bundleExtra.putInt("is_designed_for_families", this.SetTagForChildDirectedTreatment);
          bundleExtra.putBoolean("under_age_of_consent", this.SetTagForUnderAgeOfConsent);
          bundleExtra.putString("max_ad_content_rating", this.SetMaxAdContentRating);
          AdRequest adRequest = new AdRequest.Builder().addNetworkExtrasBundle(AdMobAdapter.class, bundleExtra).build();
          InterstitialAd.load(mActivity, this.interstitialAdUnitId, adRequest, new InterstitialAdLoadCallback() {
            @Override public void onAdLoaded(@NonNull InterstitialAd interstitialAd) {
              isinterstitialload = true;
              mInterstitialAd = interstitialAd;
              if (intAutoShow) {
                cordova.getActivity().runOnUiThread(() -> mInterstitialAd.show(mActivity));
                _interstitialAdLoadCallback(callbackContext);
              }
              Log.i(TAG, "onAdLoaded");
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.loaded');");
              if (ResponseInfo) {
                JSONObject result = new JSONObject();
                ResponseInfo responseInfo = mInterstitialAd.getResponseInfo();
                try {
                  result.put("getResponseId", responseInfo.getResponseId());
                  result.put("getAdapterResponses", responseInfo.getAdapterResponses());
                  result.put("getResponseExtras", responseInfo.getResponseExtras());
                  result.put("getMediationAdapterClassName", responseInfo.getMediationAdapterClassName());
                  result.put("getBundleExtra", bundleExtra);
                  callbackContext.success(result);
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
              }
              mInterstitialAd.setOnPaidEventListener(adValue -> {
                long valueMicros = adValue.getValueMicros();String currencyCode = adValue.getCurrencyCode();int precision = adValue.getPrecisionType();String adUnitId = mInterstitialAd.getAdUnitId();JSONObject result = new JSONObject();
                try {
                  result.put("micros", valueMicros);
                  result.put("currency", currencyCode);
                  result.put("precision", precision);
                  result.put("adUnitId", adUnitId);
                  callbackContext.success(result);
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.revenue');");
              });
            }
            @Override public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
              mInterstitialAd = null;
              isinterstitialload = false;
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.failed.load');");
              callbackContext.error(loadAdError.toString());
            }
          });
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "showInterstitialAd":
      if (isinterstitialload) {
        cordova.getActivity().runOnUiThread(() -> mInterstitialAd.show(mActivity));
        _interstitialAdLoadCallback(callbackContext);
      } else {
        callbackContext.error("The Interstitial ad wasn't ready yet");
      }
      return true;
    case "loadRewardedAd":
      cordova.getActivity().runOnUiThread(() -> {
        final String adUnitId = args.optString(0);final boolean autoShow = args.optBoolean(1);
        try {
          this.rewardedAdUnitId = adUnitId;
          this.rewardedAutoShow = autoShow;
          Bundle bundleExtra = new Bundle();
          bundleExtra.putString("npa", this.Npa);
          bundleExtra.putInt("is_designed_for_families", this.SetTagForChildDirectedTreatment);
          bundleExtra.putBoolean("under_age_of_consent", this.SetTagForUnderAgeOfConsent);
          bundleExtra.putString("max_ad_content_rating", this.SetMaxAdContentRating);
          AdRequest adRequest = new AdRequest.Builder().addNetworkExtrasBundle(AdMobAdapter.class, bundleExtra).build();
          RewardedAd.load(mActivity, this.rewardedAdUnitId, adRequest, new RewardedAdLoadCallback() {
            public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
              rewardedAd = null;
              isrewardedload = false;
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.failed.load');");
              callbackContext.error(loadAdError.toString());
            }
            @Override public void onAdLoaded(@NonNull RewardedAd ad) {
              rewardedAd = ad;
              isrewardedload = true;
              isAdSkip = 0;
              if (rewardedAutoShow) {
                isAdSkip = 1;
                rewardedAd.show(mActivity, rewardItem -> {
                  isAdSkip = 2;int rewardAmount = rewardItem.getAmount();String rewardType = rewardItem.getType();cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.reward.userEarnedReward');");callbackContext.success("rewardAmount:" + rewardAmount + "rewardType:" + rewardType);
                });
                _rewardedAdLoadCallback(callbackContext);
              }
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.loaded');");
              if (ResponseInfo) {
                JSONObject result = new JSONObject();
                ResponseInfo responseInfo = ad.getResponseInfo();
                try {
                  result.put("getResponseId", responseInfo.getResponseId());
                  result.put("getAdapterResponses", responseInfo.getAdapterResponses());
                  result.put("getResponseExtras", responseInfo.getResponseExtras());
                  result.put("getMediationAdapterClassName", responseInfo.getMediationAdapterClassName());
                  result.put("getBundleExtra", bundleExtra);
                  callbackContext.success(result);
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
              }
              rewardedAd.setOnPaidEventListener(adValue -> {
                long valueMicros = adValue.getValueMicros();String currencyCode = adValue.getCurrencyCode();int precision = adValue.getPrecisionType();String adUnitId = rewardedAd.getAdUnitId();JSONObject result = new JSONObject();
                try {
                  result.put("micros", valueMicros);
                  result.put("currency", currencyCode);
                  result.put("precision", precision);
                  result.put("adUnitId", adUnitId);
                  callbackContext.success(result);
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.revenue');");
              });
            }
          });
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "showRewardedAd":
      cordova.getActivity().runOnUiThread(() -> {
        if (isrewardedload) {
          isAdSkip = 1;
          rewardedAd.show(mActivity, rewardItem -> {
            isAdSkip = 2;int rewardAmount = rewardItem.getAmount();String rewardType = rewardItem.getType();cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.reward.userEarnedReward');");callbackContext.success("rewardAmount:" + rewardAmount + "rewardType:" + rewardType);
          });
          _rewardedAdLoadCallback(callbackContext);
        } else {
          callbackContext.error("The rewarded ad wasn't ready yet");
        }
      });
      return true;
    case "loadRewardedInterstitialAd":
      cordova.getActivity().runOnUiThread(() -> {
        final String adUnitId = args.optString(0);final boolean autoShow = args.optBoolean(1);
        try {
          this.rewardedInterstitialAdUnitId = adUnitId;
          this.rIntAutoShow = autoShow;
          Bundle bundleExtra = new Bundle();
          bundleExtra.putString("npa", this.Npa);
          bundleExtra.putInt("is_designed_for_families", this.SetTagForChildDirectedTreatment);
          bundleExtra.putBoolean("under_age_of_consent", this.SetTagForUnderAgeOfConsent);
          bundleExtra.putString("max_ad_content_rating", this.SetMaxAdContentRating);
          AdRequest adRequest = new AdRequest.Builder().addNetworkExtrasBundle(AdMobAdapter.class, bundleExtra).build();
          RewardedInterstitialAd.load(mActivity, this.rewardedInterstitialAdUnitId, adRequest, new RewardedInterstitialAdLoadCallback() {
            @Override public void onAdLoaded(@NonNull RewardedInterstitialAd ad) {
              rewardedInterstitialAd = ad;
              isrewardedInterstitialload = true;
              isAdSkip = 0;
              if (rIntAutoShow) {
                isAdSkip = 1;
                rewardedInterstitialAd.show(mActivity, rewardItem -> {
                  isAdSkip = 2;int rewardAmount = rewardItem.getAmount();String rewardType = rewardItem.getType();cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.userEarnedReward');");callbackContext.success("rewardAmount:" + rewardAmount + "rewardType:" + rewardType);
                });
                _rewardedInterstitialAdLoadCallback(callbackContext);
              }
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.loaded');");
              if (ResponseInfo) {
                JSONObject result = new JSONObject();
                ResponseInfo responseInfo = ad.getResponseInfo();
                try {
                  result.put("getResponseId", responseInfo.getResponseId());
                  result.put("getAdapterResponses", responseInfo.getAdapterResponses());
                  result.put("getResponseExtras", responseInfo.getResponseExtras());
                  result.put("getMediationAdapterClassName", responseInfo.getMediationAdapterClassName());
                  result.put("getBundleExtra", bundleExtra);
                  callbackContext.success(result);
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
              }
              rewardedInterstitialAd.setOnPaidEventListener(adValue -> {
                long valueMicros = adValue.getValueMicros();String currencyCode = adValue.getCurrencyCode();int precision = adValue.getPrecisionType();String adUnitId = rewardedInterstitialAd.getAdUnitId();JSONObject result = new JSONObject();
                try {
                  result.put("micros", valueMicros);
                  result.put("currency", currencyCode);
                  result.put("precision", precision);
                  result.put("adUnitId", adUnitId);
                  callbackContext.success(result);
                } catch (JSONException e) {
                  callbackContext.error(e.getMessage());
                }
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.revenue');");
              });
            }
            @Override public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
              rewardedInterstitialAd = null;
              isrewardedInterstitialload = false;
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.failed.load');");
              callbackContext.error(loadAdError.toString());
            }
          });
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "showRewardedInterstitialAd":
      cordova.getActivity().runOnUiThread(() -> {
        if (isrewardedInterstitialload) {
          isAdSkip = 1;
          rewardedInterstitialAd.show(mActivity, rewardItem -> {
            isAdSkip = 2;int rewardAmount = rewardItem.getAmount();String rewardType = rewardItem.getType();cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.userEarnedReward');");callbackContext.success("rewardAmount:" + rewardAmount + "rewardType:" + rewardType);
          });
        } else {
          callbackContext.error("The rewarded ad wasn't ready yet");
        }
        _rewardedInterstitialAdLoadCallback(callbackContext);
      });
      return true;
    case "loadBannerAd":
      cordova.getActivity().runOnUiThread(() -> {
        final String adUnitId = args.optString(0);final String position = args.optString(1);final String size = args.optString(2);final String collapsible = args.optString(3);final int adaptive_Width = args.optInt(4);final boolean autoShow = args.optBoolean(5);
        try {
          this.bannerAdUnitId = adUnitId;
          this.Position = position;
          this.Size = size;
          this.AdaptiveWidth = adaptive_Width;
          this.Collapsible = collapsible;
          this.bannerAutoShow = autoShow;
          if (lock) {
            _loadBannerAd(adUnitId, position, size, collapsible, adaptive_Width);
          }
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "getConsentRequest":
      cordova.getActivity().runOnUiThread(() -> {
        try {
          if (setDebugGeography) {
            ConsentDebugSettings debugSettings = new ConsentDebugSettings.Builder(mActivity).setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA).addTestDeviceHashedId(getDeviceId()).build();
            ConsentRequestParameters params = new ConsentRequestParameters.Builder().setConsentDebugSettings(debugSettings).build();
            consentInformation = UserMessagingPlatform.getConsentInformation(cordova.getContext());
            consentInformation.requestConsentInfoUpdate(cordova.getActivity(), params, () -> {
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.info.update');");
              if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.NOT_REQUIRED) {
                callbackContext.success(ConsentInformation.ConsentStatus.NOT_REQUIRED);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.not_required');");
              } else if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.OBTAINED) {
                callbackContext.success(ConsentInformation.ConsentStatus.OBTAINED);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.obtained');");
              } else if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.REQUIRED) {
                callbackContext.success(ConsentInformation.ConsentStatus.REQUIRED);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.required');");
                if (consentInformation.isConsentFormAvailable()) {
                  UserMessagingPlatform.loadConsentForm(cordova.getContext(), consentForm -> consentForm.show(cordova.getActivity(), formError -> {
                    cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.show');");callbackContext.error(String.valueOf(formError));
                  }), formError -> callbackContext.error(formError.toString()));
                  cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.load.from');");
                } else {
                  cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.form.not.available');");
                }
              } else if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.UNKNOWN) {
                callbackContext.success(ConsentInformation.ConsentStatus.UNKNOWN);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.unknown');");
              }
            }, formError -> {
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.info.update.failed');");callbackContext.error(formError.toString());
            });
          } else {
            ConsentRequestParameters params = new ConsentRequestParameters.Builder().setTagForUnderAgeOfConsent(this.SetTagForUnderAgeOfConsent).build();
            consentInformation = UserMessagingPlatform.getConsentInformation(cordova.getContext());
            consentInformation.requestConsentInfoUpdate(cordova.getActivity(), params, () -> {
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.info.update');");
              if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.NOT_REQUIRED) {
                callbackContext.success(ConsentInformation.ConsentStatus.NOT_REQUIRED);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.not_required');");
              } else if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.OBTAINED) {
                callbackContext.success(ConsentInformation.ConsentStatus.OBTAINED);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.obtained');");
              } else if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.REQUIRED) {
                callbackContext.success(ConsentInformation.ConsentStatus.REQUIRED);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.required');");
                if (consentInformation.isConsentFormAvailable()) {
                  UserMessagingPlatform.loadConsentForm(cordova.getContext(), consentForm -> consentForm.show(cordova.getActivity(), formError -> {
                    cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.show');");callbackContext.error(String.valueOf(formError));
                  }), formError -> callbackContext.error(formError.getMessage()));
                  cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.failed.load.from');");
                } else {
                  cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.form.not.available');");
                }
              } else if (consentInformation.getConsentStatus() == ConsentInformation.ConsentStatus.UNKNOWN) {
                callbackContext.success(ConsentInformation.ConsentStatus.UNKNOWN);
                cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.status.unknown');");
              }
            }, formError -> {
              cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.consent.info.update.failed');");callbackContext.error(formError.getMessage());
            });
          }
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "showPrivacyOptionsForm":
      cordova.getActivity().runOnUiThread(() -> {
        try {
          ConsentRequestParameters params = new ConsentRequestParameters.Builder().setTagForUnderAgeOfConsent(this.SetTagForUnderAgeOfConsent).build();
          consentInformation = UserMessagingPlatform.getConsentInformation(mContext);
          consentInformation.requestConsentInfoUpdate(mActivity, params, (ConsentInformation.OnConsentInfoUpdateSuccessListener)() -> {
            int status = consentInformation.getConsentStatus();PUBLIC_CALLBACKS.success(status);UserMessagingPlatform.loadAndShowConsentFormIfRequired(mActivity, (ConsentForm.OnConsentFormDismissedListener) loadAndShowError -> {
              if (loadAndShowError != null) {
                PUBLIC_CALLBACKS.error(loadAndShowError.toString());
              }
              if (isPrivacyOptionsRequired()) {
                UserMessagingPlatform.showPrivacyOptionsForm(mActivity, formError -> {
                  if (formError != null) {
                    PUBLIC_CALLBACKS.error(formError.toString());
                  }
                });
              }
            });
          }, (ConsentInformation.OnConsentInfoUpdateFailureListener) requestConsentError -> {
            PUBLIC_CALLBACKS.error(requestConsentError.toString());
          });
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "consentReset":
      cordova.getActivity().runOnUiThread(() -> {
        try {
          consentInformation.reset();
        } catch (Exception e) {
          callbackContext.error(e.toString());
        }
      });
      return true;
    case "getIabTfc":
      cordova.getActivity().runOnUiThread(() -> {
        int gdprApplies = mPreferences.getInt("IABTCF_gdprApplies", 0);String purposeConsents = mPreferences.getString("IABTCF_PurposeConsents", "");String vendorConsents = mPreferences.getString("IABTCF_VendorConsents", "");String consentString = mPreferences.getString("IABTCF_TCString", "");JSONObject userInfoJson = new JSONObject();
        try {
          userInfoJson.put("IABTCF_gdprApplies", gdprApplies);
          userInfoJson.put("IABTCF_PurposeConsents", purposeConsents);
          userInfoJson.put("IABTCF_VendorConsents", vendorConsents);
          userInfoJson.put("IABTCF_TCString", consentString);
          SharedPreferences.Editor editor = mPreferences.edit();
          editor.putString("IABTCF_TCString", consentString);
          editor.putLong(LAST_ACCESS_SUFFIX, System.currentTimeMillis());
          editor.apply();
          final String key = "IABTCF_TCString";
          getString(key);
          callbackContext.success(userInfoJson);
          cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.getIabTfc');");
        } catch (Exception e) {
          callbackContext.error(e.toString());
          cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.getIabTfc.error');");
        }
      });
      return true;
    case "showBannerAd":
      cordova.getActivity().runOnUiThread(() -> {
        if (isBannerPause == 0) {
          if (isBannerLoad) {
            try {
              bannerViewLayout.addView(bannerView);
              isBannerShow = true;
            } catch (Exception e) {
              lock = true;
              callbackContext.error(e.toString());
            }
          }
        } else if (isBannerPause == 1) {
          try {
            bannerView.setVisibility(View.VISIBLE);
            bannerView.resume();
          } catch (Exception e) {
            lock = true;
            callbackContext.error(e.toString());
          }
        }
      });
      return true;
    case "hideBannerAd":
      cordova.getActivity().runOnUiThread(() -> {
        if (isBannerShow) {
          try {
            bannerView.setVisibility(View.GONE);
            bannerView.pause();
            isBannerLoad = false;
            isBannerPause = 1;
          } catch (Exception e) {
            callbackContext.error(e.toString());
          }
        }
      });
      return true;
    case "removeBannerAd":
      cordova.getActivity().runOnUiThread(() -> {
        if (bannerView == null) return;RelativeLayout bannerViewLayout = (RelativeLayout) bannerView.getParent();
        if (bannerViewLayout != null) {
          bannerViewLayout.removeView(bannerView);
          bannerView.destroy();
          bannerView = null;
          isBannerLoad = false;
          isBannerShow = false;
          isBannerPause = 2;
          lock = true;
          bannerAdImpression = 0;
          cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.remove');");
        }
      });
      return true;
    }
    return false;
  }
  public String getDeviceId() throws NoSuchAlgorithmException {
    MessageDigest messageDigest = MessageDigest.getInstance("MD5");
    ContentResolver contentResolver = mContext.getContentResolver();
    @SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(contentResolver, "android_id");
    messageDigest.update(androidId.getBytes());
    byte[] by = messageDigest.digest();
    StringBuilder sb = new StringBuilder();
    int n = by.length;
    for (byte b: by) {
      StringBuilder emi = new StringBuilder(Integer.toHexString((int)(255 & b)));
      while (emi.length() < 2) {
        emi.insert(0, "0");
      }
      sb.append(emi);
    }
    String result = sb.toString();
    return result.toUpperCase();
  }
  public void getString(String key) {
    long lastAccessTime = mPreferences.getLong(key + LAST_ACCESS_SUFFIX, 0);
    long currentTime = System.currentTimeMillis();
    if (currentTime - lastAccessTime > EXPIRATION_TIME) {
      removeKey(key);
      cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.TCString.expired');");
    }
    SharedPreferences.Editor editor = mPreferences.edit();
    editor.putLong(key + LAST_ACCESS_SUFFIX, currentTime);
    editor.apply();
  }
  private void removeKey(String key) {
    SharedPreferences.Editor editor = mPreferences.edit();
    editor.remove(key);
    editor.remove(key + LAST_ACCESS_SUFFIX);
    editor.apply();
    cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.TCString.remove');");
  }
  private void _loadBannerAd(String adUnitId, String position, String size, String collapsible, int adaptive_Width) {
    try {
      if (bannerViewLayout == null) {
        bannerViewLayout = new RelativeLayout(mActivity);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        try {
          ((ViewGroup)(((View) Objects.requireNonNull(webView.getClass().getMethod("getView").invoke(webView))).getParent())).addView(bannerViewLayout, params);
        } catch (Exception e) {
          ((ViewGroup) webView).addView(bannerViewLayout, params);
        }
      }
      bannerView = new AdView(mActivity);
      if (Objects.equals(size, "BANNER")) {
        bannerView.setAdSize(AdSize.BANNER);
      } else if (Objects.equals(size, "LARGE_BANNER")) {
        bannerView.setAdSize(AdSize.LARGE_BANNER);
      } else if (Objects.equals(size, "MEDIUM_RECTANGLE")) {
        bannerView.setAdSize(AdSize.MEDIUM_RECTANGLE);
      } else if (Objects.equals(size, "FULL_BANNER")) {
        bannerView.setAdSize(AdSize.FULL_BANNER);
      } else if (Objects.equals(size, "LEADERBOARD")) {
        bannerView.setAdSize(AdSize.LEADERBOARD);
      } else if (Objects.equals(size, "FLUID")) {
        bannerView.setAdSize(AdSize.FLUID);
      } else if (Objects.equals(size, "ANCHORED")) {
        bannerView.setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(mActivity, adaptive_Width));
      } else if (Objects.equals(size, "IN_LINE")) {
        bannerView.setAdSize(AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(mActivity, adaptive_Width));
      } else if (Objects.equals(size, "FULL_WIDTH")) {
        bannerView.setAdSize(AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(mActivity, AdSize.FULL_WIDTH));
      } else {
        bannerView.setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(mActivity, AdSize.FULL_WIDTH));
      }
      bannerView.setAdUnitId(adUnitId);
      Bundle bundleExtra = new Bundle();
      if (isCollapsible) {
        bundleExtra.putString("collapsible", collapsible);
      }
      bundleExtra.putString("npa", this.Npa);
      bundleExtra.putInt("is_designed_for_families", this.SetTagForChildDirectedTreatment);
      bundleExtra.putBoolean("under_age_of_consent", this.SetTagForUnderAgeOfConsent);
      bundleExtra.putString("max_ad_content_rating", this.SetMaxAdContentRating);
      AdRequest adRequest = new AdRequest.Builder().addNetworkExtrasBundle(AdMobAdapter.class, bundleExtra).build();
      bannerView.loadAd(adRequest);
      bannerView.setAdListener(bannerAdListener);
      RelativeLayout.LayoutParams bannerParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
      switch (position) {
      case "top-right":
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        break;
      case "top-center":
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        bannerParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        break;
      case "left":
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        bannerParams.addRule(RelativeLayout.CENTER_VERTICAL);
        break;
      case "center":
        bannerParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        bannerParams.addRule(RelativeLayout.CENTER_VERTICAL);
        break;
      case "right":
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        bannerParams.addRule(RelativeLayout.CENTER_VERTICAL);
        break;
      case "bottom-center":
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        bannerParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        break;
      case "bottom-right":
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        break;
      default:
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        bannerParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        break;
      }
      bannerView.setLayoutParams(bannerParams);
      bannerViewLayout.bringToFront();
    } catch (Exception e) {
      PUBLIC_CALLBACKS.error(e.toString());
    }
  }
  private final AdListener bannerAdListener = new AdListener() {
    @Override public void onAdClicked() {
      cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.click');");
    }
    @Override public void onAdClosed() {
      cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.close');");
    }
    @Override public void onAdFailedToLoad(@NonNull LoadAdError adError) {
      cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.failed.load');");
      isBannerLoad = false;
      isBannerShow = false;
      lock = true;
      PUBLIC_CALLBACKS.error(adError.toString());
    }
    @Override public void onAdImpression() {
      cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.impression');");
    }
    @Override public void onAdLoaded() {
      isBannerLoad = true;
      bannerAdImpression = 1;
      isBannerPause = 0;
      lock = false;
      if (bannerAutoShow) {
        bannerViewLayout.addView(bannerView);
        isBannerPause = 0;
        isBannerLoad = true;
      }
      bannerView.setOnPaidEventListener(bannerPaidAdListener);
      cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.load');");
      if (ResponseInfo) {
        Bundle bundleExtra = new Bundle();
        bundleExtra.putString("npa", Npa);
        bundleExtra.putInt("is_designed_for_families", SetTagForChildDirectedTreatment);
        bundleExtra.putBoolean("under_age_of_consent", SetTagForUnderAgeOfConsent);
        bundleExtra.putString("max_ad_content_rating", SetMaxAdContentRating);
        JSONObject result = new JSONObject();
        ResponseInfo responseInfo = bannerView.getResponseInfo();
        try {
          assert responseInfo != null;
          result.put("getResponseId", responseInfo.getResponseId());
          result.put("getAdapterResponses", responseInfo.getAdapterResponses());
          result.put("getResponseExtras", responseInfo.getResponseExtras());
          result.put("getMediationAdapterClassName", responseInfo.getMediationAdapterClassName());
          result.put("getBundleExtra", bundleExtra);
          PUBLIC_CALLBACKS.success(result);
        } catch (JSONException e) {
          PUBLIC_CALLBACKS.error(e.getMessage());
        }
      }
    }
    @Override public void onAdOpened() {
      cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.open');");
    }
  };
  private final OnPaidEventListener bannerPaidAdListener = new OnPaidEventListener() {
    @Override public void onPaidEvent(@NonNull AdValue adValue) {
      long valueMicros = adValue.getValueMicros();
      String currencyCode = adValue.getCurrencyCode();
      int precision = adValue.getPrecisionType();
      String adUnitId = bannerView.getAdUnitId();
      JSONObject result = new JSONObject();
      try {
        result.put("micros", valueMicros);
        result.put("currency", currencyCode);
        result.put("precision", precision);
        result.put("adUnitId", adUnitId);
        isBannerLoad = false;
        PUBLIC_CALLBACKS.success(result);
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.banner.revenue');");
      } catch (JSONException e) {
        PUBLIC_CALLBACKS.error(e.getMessage());
      }
    }
  };
  public boolean isPrivacyOptionsRequired() {
    return consentInformation.getPrivacyOptionsRequirementStatus() == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED;
  }
  private void _appOpenAdLoadCallback(CallbackContext callbackContext) {
    appOpenAd.setFullScreenContentCallback(new FullScreenContentCallback() {
      @Override public void onAdDismissedFullScreenContent() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.dismissed');");
        View mainView = getView();
        if (mainView != null) {
          mainView.requestFocus();
        }
      }
      @Override public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.failed.show');");
        callbackContext.error(adError.toString());
        appOpenAd = null;
      }
      @Override public void onAdShowedFullScreenContent() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.appOpenAd.show');");
      }
    });
  }
  private void _interstitialAdLoadCallback(CallbackContext callbackContext) {
    mInterstitialAd.setFullScreenContentCallback(new FullScreenContentCallback() {
      @Override public void onAdClicked() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.click');");
      }
      @Override public void onAdDismissedFullScreenContent() {
        mInterstitialAd = null;
        isinterstitialload = false;
        View mainView = getView();
        if (mainView != null) {
          mainView.requestFocus();
        }
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.dismissed');");
      }
      @Override public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
        mInterstitialAd = null;
        isinterstitialload = false;
        callbackContext.error(adError.toString());
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.failed.show');");
      }
      @Override public void onAdImpression() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.impression');");
      }
      @Override public void onAdShowedFullScreenContent() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.interstitial.show');");
      }
    });
  }
  private void _rewardedAdLoadCallback(CallbackContext callbackContext) {
    rewardedAd.setFullScreenContentCallback(new FullScreenContentCallback() {
      @Override public void onAdClicked() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.click');");
      }
      @Override public void onAdDismissedFullScreenContent() {
        if (isAdSkip != 2) {
          rewardedAd = null;
          isrewardedload = false;
          View mainView = getView();
          if (mainView != null) {
            mainView.requestFocus();
          }
          cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.ad.skip');");
        }
        rewardedAd = null;
        isrewardedload = false;
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.dismissed');");
      }
      @Override public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
        rewardedAd = null;
        isrewardedload = false;
        callbackContext.error(adError.toString());
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.failed.show');");
      }
      @Override public void onAdImpression() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.impression');");
      }
      @Override public void onAdShowedFullScreenContent() {
        isAdSkip = 1;
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewarded.show');");
      }
    });
  }
  private void _rewardedInterstitialAdLoadCallback(CallbackContext callbackContext) {
    rewardedInterstitialAd.setFullScreenContentCallback(new FullScreenContentCallback() {
      @Override public void onAdClicked() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.click');");
      }
      @Override public void onAdDismissedFullScreenContent() {
        if (isAdSkip != 2) {
          rewardedInterstitialAd = null;
          isrewardedInterstitialload = false;
          cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.ad.skip');");
        }
        rewardedInterstitialAd = null;
        isrewardedInterstitialload = false;
        View mainView = getView();
        if (mainView != null) {
          mainView.requestFocus();
        }
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.dismissed');");
      }
      @Override public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
        rewardedInterstitialAd = null;
        isrewardedInterstitialload = false;
        callbackContext.error(adError.toString());
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.failed.show');");
      }
      @Override public void onAdImpression() {
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.impression');");
      }
      @Override public void onAdShowedFullScreenContent() {
        isAdSkip = 1;
        Log.d(TAG, "Ad showed fullscreen content.");
        cWebView.loadUrl("javascript:cordova.fireDocumentEvent('on.rewardedInt.showed');");
      }
    });
  }
  public void _globalSettings() {
    MobileAds.setAppMuted(this.SetAppMuted);
    MobileAds.setAppVolume(this.SetAppVolume);
    MobileAds.putPublisherFirstPartyIdEnabled(this.EnableSameAppKey);
  }
  public void _Targeting() {
    RequestConfiguration.Builder requestConfiguration = MobileAds.getRequestConfiguration().toBuilder();
    if (SetTagForChildDirectedTreatment == -1) {
      requestConfiguration.setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED);
    } else if (SetTagForChildDirectedTreatment == 0) {
      requestConfiguration.setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_FALSE);
    } else if (SetTagForChildDirectedTreatment == 1) {
      requestConfiguration.setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE);
    } else {
      requestConfiguration.setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED);
    }
    if (SetTagForUnderAgeOfConsent) {
      requestConfiguration.setTagForUnderAgeOfConsent(RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE);
    } else {
      requestConfiguration.setTagForUnderAgeOfConsent(RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_FALSE);
    }
    if (Objects.equals(SetMaxAdContentRating, "")) {
      requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_UNSPECIFIED);
    } else if (Objects.equals(SetMaxAdContentRating, "T")) {
      requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_T);
    } else if (Objects.equals(SetMaxAdContentRating, "PG")) {
      requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_PG);
    } else if (Objects.equals(SetMaxAdContentRating, "MA")) {
      requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_MA);
    } else if (Objects.equals(SetMaxAdContentRating, "G")) {
      requestConfiguration.setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_G);
    } else {
      requestConfiguration.setTagForUnderAgeOfConsent(RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED);
    }
    MobileAds.setRequestConfiguration(requestConfiguration.build());
  }
  private View getView() {
    if (View.class.isAssignableFrom(CordovaWebView.class)) {
      return (View) cWebView;
    }
    return cordova.getActivity().getWindow().getDecorView().findViewById(android.R.id.content);
  }
  @Override public void onPause(boolean multitasking) {
    if (bannerView != null) {
      bannerView.pause();
    }
    super.onPause(multitasking);
  }
  @Override public void onResume(boolean multitasking) {
    super.onResume(multitasking);
    if (bannerView != null) {
      bannerView.resume();
    }
  }
  @Override public void onDestroy() {
    if (bannerView != null) {
      bannerView.destroy();
      bannerView = null;
    }
    if (bannerViewLayout != null) {
      ViewGroup parentView = (ViewGroup) bannerViewLayout.getParent();
      if (parentView != null) {
        parentView.removeView(bannerViewLayout);
      }
      bannerViewLayout = null;
    }
    bannerAdImpression = 0;
    super.onDestroy();
  }
}
