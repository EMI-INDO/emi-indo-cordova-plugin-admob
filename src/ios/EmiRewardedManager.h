#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Cordova/CDVPlugin.h>
#import "EmiAdPluginProtocol.h"

@interface EmiRewardedManager : NSObject <GADFullScreenContentDelegate>

@property (nonatomic, weak) id<EmiAdPluginProtocol> plugin;
@property (nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, assign) BOOL isAutoShowRewardedAds;
@property (nonatomic, assign) int isAdSkip;

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin;
- (void)loadRewardedAd:(CDVInvokedUrlCommand *)command;
- (void)showRewardedAd:(CDVInvokedUrlCommand *)command;

@end
