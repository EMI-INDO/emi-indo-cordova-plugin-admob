#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Cordova/CDVPlugin.h>
#import "EmiAdPluginProtocol.h"

@interface EmiAppOpenManager : NSObject <GADFullScreenContentDelegate>

@property (nonatomic, weak) id<EmiAdPluginProtocol> plugin;
@property (nonatomic, strong) GADAppOpenAd *appOpenAd;
@property (nonatomic, assign) BOOL isAutoShowAppOpen;

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin;
- (void)loadAppOpenAd:(CDVInvokedUrlCommand *)command;
- (void)showAppOpenAd:(CDVInvokedUrlCommand *)command;

@end
