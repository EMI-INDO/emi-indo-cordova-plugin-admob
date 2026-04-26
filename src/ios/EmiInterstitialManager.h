#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Cordova/CDVPlugin.h>
#import "EmiAdPluginProtocol.h"

@interface EmiInterstitialManager : NSObject <GADFullScreenContentDelegate>

@property (nonatomic, weak) id<EmiAdPluginProtocol> plugin;
@property (nonatomic, strong) GADInterstitialAd *interstitialAd;
@property (nonatomic, assign) BOOL isAutoShowInterstitial;

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin;
- (void)loadInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)showInterstitialAd:(CDVInvokedUrlCommand *)command;

@end
