#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
@interface emiAdmobPlugin : CDVPlugin<GADBannerViewDelegate, GADFullScreenContentDelegate>{}
@property(nonatomic, strong) GADAppOpenAd *appOpenAd;
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property(nonatomic, strong) GADRewardedInterstitialAd* rewardedInterstitialAd;
@property(nonatomic, strong) GADRewardedAd *rewardedAd;
@property(nonatomic, readonly) BOOL isPrivacyOptionsRequired;
@property(nonatomic, strong) CDVInvokedUrlCommand *command;
@property(nonatomic, strong) GADResponseInfo *responseInfo;
- (void)initialize:(CDVInvokedUrlCommand *)command;
- (void)requestIDFA:(CDVInvokedUrlCommand *)command;
- (void)showPrivacyOptionsForm:(CDVInvokedUrlCommand *)command;
- (void)getConsentRequest:(CDVInvokedUrlCommand *)command;
- (void)consentReset:(CDVInvokedUrlCommand *)command;
- (void)getIabTfc:(CDVInvokedUrlCommand *)command;
- (void)loadAppOpenAd:(CDVInvokedUrlCommand *)command;
- (void)showAppOpenAd:(CDVInvokedUrlCommand *)command;
- (void)loadBannerAd:(CDVInvokedUrlCommand *)command;
- (void)showBannerAd:(CDVInvokedUrlCommand *)command;
- (void)hideBannerAd:(CDVInvokedUrlCommand *)command;
- (void)removeBannerAd:(CDVInvokedUrlCommand *)command;
- (void)loadInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)showInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)loadRewardedInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)showRewardedInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)loadRewardedAd:(CDVInvokedUrlCommand *)command;
- (void)showRewardedAd:(CDVInvokedUrlCommand *)command;
- (void) fireEvent:(NSString *)obj event:(NSString *)eventName withData:(NSString *)jsonStr;
@end


