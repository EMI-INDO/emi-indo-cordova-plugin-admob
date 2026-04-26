#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Cordova/CDVPlugin.h>
#import "EmiAdPluginProtocol.h"

@interface EmiRewardedInterstitialManager : NSObject <GADFullScreenContentDelegate>

@property (nonatomic, weak) id<EmiAdPluginProtocol> plugin;
@property (nonatomic, strong) GADRewardedInterstitialAd *rewardedInterstitialAd;
@property (nonatomic, assign) BOOL isAutoShowRewardedInt;
@property (nonatomic, assign) int isAdSkip;

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin;
- (void)loadRewardedInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)showRewardedInterstitialAd:(CDVInvokedUrlCommand *)command;

@end
