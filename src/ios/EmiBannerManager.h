#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Cordova/CDVPlugin.h>
#import "EmiAdPluginProtocol.h"

@interface EmiBannerManager : NSObject <GADBannerViewDelegate>

@property (nonatomic, weak) id<EmiAdPluginProtocol> plugin;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, assign) BOOL isBannerOpen;
@property (nonatomic, assign) BOOL isAutoShowBanner;
@property (nonatomic, assign) BOOL isOverlapping;
@property (nonatomic, assign) BOOL isCollapsible;
@property (nonatomic, assign) CGFloat viewWidth;

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin;
- (void)loadBannerAd:(CDVInvokedUrlCommand *)command;
- (void)showBannerAd:(CDVInvokedUrlCommand *)command;
- (void)hideBannerAd:(CDVInvokedUrlCommand *)command;
- (void)removeBannerAd:(CDVInvokedUrlCommand *)command;
- (void)styleBannerAd:(CDVInvokedUrlCommand *)command;

@end
