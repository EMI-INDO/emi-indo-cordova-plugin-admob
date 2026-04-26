#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <CommonCrypto/CommonDigest.h>

#import "EmiAdPluginProtocol.h"
#import "EmiBannerManager.h"
#import "EmiAppOpenManager.h"
#import "EmiInterstitialManager.h"
#import "EmiRewardedManager.h"
#import "EmiRewardedInterstitialManager.h"

@interface emiAdmobPlugin : CDVPlugin <EmiAdPluginProtocol>

@property (nonatomic, strong) GADRequest *globalRequest;
@property (nonatomic, strong) CDVInvokedUrlCommand *command;
@property (nonatomic, strong) GADResponseInfo *responseInfo;
@property (nonatomic, readonly) BOOL isPrivacyOptionsRequired;
@property (nonatomic, readonly) BOOL canRequestAds;

@property (nonatomic, strong) EmiBannerManager *bannerManager;
@property (nonatomic, strong) EmiAppOpenManager *appOpenManager;
@property (nonatomic, strong) EmiInterstitialManager *interstitialManager;
@property (nonatomic, strong) EmiRewardedManager *rewardedManager;
@property (nonatomic, strong) EmiRewardedInterstitialManager *rewardedInterstitialManager;

- (void)initialize:(CDVInvokedUrlCommand *)command;
- (void)requestIDFA:(CDVInvokedUrlCommand *)command;
- (void)showPrivacyOptionsForm:(CDVInvokedUrlCommand *)command;
- (void)forceDisplayPrivacyForm:(CDVInvokedUrlCommand *)command;
- (void)consentReset:(CDVInvokedUrlCommand *)command;
- (void)metaData:(CDVInvokedUrlCommand *)command;
- (void)getIabTfc:(CDVInvokedUrlCommand *)command;
- (void)readStatus:(CDVInvokedUrlCommand *)command;
- (void)globalSettings:(CDVInvokedUrlCommand *)command;
- (void)targeting:(CDVInvokedUrlCommand *)command;

- (void)loadAppOpenAd:(CDVInvokedUrlCommand *)command;
- (void)showAppOpenAd:(CDVInvokedUrlCommand *)command;
- (void)styleBannerAd:(CDVInvokedUrlCommand *)command;
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

- (void)fireEvent:(NSString *)obj event:(NSString *)eventName withData:(NSString *)jsonStr;

@end
