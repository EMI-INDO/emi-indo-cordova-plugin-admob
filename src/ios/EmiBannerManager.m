#import "EmiBannerManager.h"

@implementation EmiBannerManager {
    NSString *_bannerSaveAdUnitId;
    NSString *_setPosition;
    CGFloat _paddingWebView;
    CGFloat _bannerHeightFinal;
    BOOL _isAutoResize;
    BOOL _isLoading;
    NSTimeInterval _lastLoadTime; 
    NSTimeInterval _minLoadInterval; 
}

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin {
    self = [super init];
    if (self) {
        _plugin = plugin;
        _setPosition = @"bottom-center";
        _bannerSaveAdUnitId = @"";
        _paddingWebView = 0;
        _bannerHeightFinal = 50;
        _isLoading = NO;
        _lastLoadTime = 0;
        _minLoadInterval = 5.0; 
        self.isBannerOpen = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLayoutWithDelay)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Smart Window Helper

- (UIWindow *)getKeyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in windowScene.windows) {
                    if (w.isKeyWindow) { window = w; break; }
                }
            }
            if (window) break;
        }
    }
    if (!window) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = [UIApplication sharedApplication].keyWindow;
        #pragma clang diagnostic pop
    }
    return window;
}

- (void)updateLayoutWithDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateBannerLayout];
    });
}

#pragma mark - THE DEFINITIVE LAYOUT ENGINE

- (void)updateBannerLayout {
    UIViewController *rootVC = [self.plugin getPluginViewController];
    UIView *webView = [self findWebViewInView:rootVC.view];
    if (!rootVC || !webView) return;

    UIWindow *window = [self getKeyWindow];
    UIEdgeInsets safeArea = (window) ? window.safeAreaInsets : UIEdgeInsetsZero;

    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;

    if (safeArea.bottom == 0 && screenH >= 812.0) safeArea.bottom = 34.0;
    if (safeArea.top == 0 && screenH >= 812.0) safeArea.top = 44.0;

    rootVC.view.backgroundColor = [UIColor blackColor];
    webView.superview.backgroundColor = [UIColor blackColor];

    CGRect fullScreenRect = CGRectMake(0, 0, screenW, screenH);

    if (self.isBannerOpen && self.bannerView && _bannerHeightFinal > 0) {

        CGSize adSize = self.bannerView.intrinsicContentSize;
        CGFloat bH = adSize.height > 0 ? adSize.height : _bannerHeightFinal;
        CGFloat bW = adSize.width > 0 ? adSize.width : self.bannerView.bounds.size.width;
        CGFloat bX = (screenW - bW) / 2.0;
        CGFloat bY = 0;

        if ([_setPosition isEqualToString:@"top-center"]) {
            bY = safeArea.top;
        } else {
            bY = screenH - safeArea.bottom - bH;
        }

        self.bannerView.frame = CGRectMake(bX, bY, bW, bH);
        self.bannerView.hidden = NO;

        if (!self.isOverlapping) {
            CGRect newWebFrame = fullScreenRect;
            if ([_setPosition isEqualToString:@"top-center"]) {
                newWebFrame.origin.y = bY + bH + _paddingWebView; 
                newWebFrame.size.height = screenH - newWebFrame.origin.y;
            } else {
                newWebFrame.origin.y = 0;
                newWebFrame.size.height = bY - _paddingWebView; 
            }
            webView.frame = newWebFrame;
        } else {
            webView.frame = fullScreenRect;
        }
    } else {
        if (self.bannerView) self.bannerView.hidden = YES;
        webView.frame = fullScreenRect;
    }

    if (self.bannerView && self.isBannerOpen) {
        [webView.superview bringSubviewToFront:self.bannerView];
    }
}

#pragma mark - Internal Controls

- (void)destroyBannerInternal {
    if (self.bannerView) {
        self.isBannerOpen = NO;
        _isLoading = NO;
        [self.bannerView removeFromSuperview];
        self.bannerView.delegate = nil;
        self.bannerView = nil;
        [self updateBannerLayout];
    }
}

#pragma mark - Cordova Commands

- (void)loadBannerAd:(CDVInvokedUrlCommand *)command {
    if (_isLoading) return;

    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    NSString *size = [options valueForKey:@"size"];

    if ([options objectForKey:@"padding"]) {
        _paddingWebView = [[options valueForKey:@"padding"] floatValue];
    } else {
        _paddingWebView = 0; 
    }

    if ([options objectForKey:@"loadInterval"]) {
        _minLoadInterval = [[options valueForKey:@"loadInterval"] doubleValue];
    } else {
        _minLoadInterval = 5.0; 
    }

    id collapsibleValue = [options valueForKey:@"collapsible"];
    BOOL isCollapsibleEnabled = NO;
    if ([collapsibleValue isKindOfClass:[NSNumber class]]) {
        isCollapsibleEnabled = [collapsibleValue boolValue];
    } else if ([collapsibleValue isKindOfClass:[NSString class]]) {
        NSString *valStr = [(NSString *)collapsibleValue lowercaseString];
        if ([valStr isEqualToString:@"true"] || [valStr isEqualToString:@"top"] || [valStr isEqualToString:@"bottom"]) {
            isCollapsibleEnabled = YES;
        }
    }
    self.isCollapsible = isCollapsibleEnabled;

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    if ([adUnitId isEqualToString:_bannerSaveAdUnitId] && self.bannerView != nil) {
        [self showBannerAd:command];
        return;
    }

    if (now - _lastLoadTime < _minLoadInterval) {

        return;
    }

    _isLoading = YES;
    _lastLoadTime = now;
    _bannerSaveAdUnitId = adUnitId;

    self.isAutoShowBanner = [[options valueForKey:@"autoShow"] boolValue];
    self.isOverlapping = [[options valueForKey:@"isOverlapping"] boolValue];
    _setPosition = [options valueForKey:@"position"] ?: @"bottom-center";

    dispatch_async(dispatch_get_main_queue(), ^{
        [self destroyBannerInternal];

        UIViewController *viewController = [self.plugin getPluginViewController];

        GADAdSize adSize;
        if (self.isCollapsible) {
            adSize = GADAdSizeBanner; 
        } else {
            adSize = [self getAdSizeFromString:size];
        }

        self.bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
        self.bannerView.adUnitID = adUnitId;
        self.bannerView.rootViewController = viewController;
        self.bannerView.delegate = self;
        self.bannerView.hidden = YES;

        [viewController.view addSubview:self.bannerView];

        GADRequest *request = [self.plugin getGlobalAdRequest];
        if (self.isCollapsible) {
            GADExtras *extras = [[GADExtras alloc] init];
            NSString *googleAnchor = [self->_setPosition containsString:@"top"] ? @"top" : @"bottom";
            extras.additionalParameters = @{@"collapsible" : googleAnchor};
            [request registerAdNetworkExtras:extras];
        }

        [self.bannerView loadRequest:request];
    });

    [[self.plugin getPluginCommandDelegate] sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)showBannerAd:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bannerView) {

            if (!self.isBannerOpen) {
                self.isBannerOpen = YES;
                [self updateBannerLayout];
            }
            if (command) {
                [[self.plugin getPluginCommandDelegate] sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
            }
        }
    });
}

- (void)hideBannerAd:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isBannerOpen) {
            self.isBannerOpen = NO;
            [self updateBannerLayout];
        }
        [self.plugin fireEvent:@"" event:@"on.banner.hide" withData:nil];
        [[self.plugin getPluginCommandDelegate] sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    });
}

- (void)removeBannerAd:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self destroyBannerInternal];
        self->_bannerSaveAdUnitId = @""; 
        [self.plugin fireEvent:@"" event:@"on.banner.remove" withData:nil];
        [[self.plugin getPluginCommandDelegate] sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    });
}

- (void)styleBannerAd:(CDVInvokedUrlCommand *)command {
    NSDictionary *options = [command.arguments objectAtIndex:0];
    self.isOverlapping = [[options valueForKey:@"isOverlapping"] boolValue];
    _paddingWebView = [[options valueForKey:@"paddingWebView"] floatValue];
    [self updateLayoutWithDelay];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {

    _isLoading = NO;

    NSString *collapsibleStatus = bannerView.isCollapsible ? @"collapsible" : @"not collapsible";
    NSDictionary *collapsibleData = @{@"collapsible" : collapsibleStatus};
    NSData *collapsibleJsonData = [NSJSONSerialization dataWithJSONObject:collapsibleData options:0 error:nil];
    if (collapsibleJsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:collapsibleJsonData encoding:NSUTF8StringEncoding];
        [self.plugin fireEvent:@"" event:@"on.is.collapsible" withData:jsonString];
    }

    _bannerHeightFinal = bannerView.bounds.size.height;
    NSDictionary *bannerLoadData = @{@"height" : @(_bannerHeightFinal)};
    NSData *loadJsonData = [NSJSONSerialization dataWithJSONObject:bannerLoadData options:0 error:nil];
    if (loadJsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:loadJsonData encoding:NSUTF8StringEncoding];
        [self.plugin fireEvent:@"" event:@"on.banner.load" withData:jsonString];
    }

    if ([self.plugin isResponseInfoEnabled]) {
        GADResponseInfo *responseInfo = bannerView.responseInfo;
        NSMutableArray *adNetworkInfoArray = [NSMutableArray array];

        for (GADAdNetworkResponseInfo *adNetworkResponseInfo in responseInfo.adNetworkInfoArray) {
            NSDictionary *adNetworkInfo = @{
                @"adSourceId": adNetworkResponseInfo.adSourceID ?: @"",
                @"adSourceInstanceId": adNetworkResponseInfo.adSourceInstanceID ?: @"",
                @"adSourceInstanceName": adNetworkResponseInfo.adSourceInstanceName ?: @"",
                @"adSourceName": adNetworkResponseInfo.adSourceName ?: @"",
                @"adNetworkClassName": adNetworkResponseInfo.adNetworkClassName ?: @"",
                @"adUnitMapping": adNetworkResponseInfo.adUnitMapping ?: @{},
                @"latency": @(adNetworkResponseInfo.latency)
            };
            [adNetworkInfoArray addObject:adNetworkInfo];
        }

        NSDictionary *responseInfoData = @{
            @"responseIdentifier": responseInfo.responseIdentifier ?: @"",
            @"adNetworkInfoArray": adNetworkInfoArray
        };

        NSData *jsonResponseData = [NSJSONSerialization dataWithJSONObject:responseInfoData options:0 error:nil];
        if (jsonResponseData) {
            NSString *jsonResponseString = [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding];
            [self.plugin fireEvent:@"" event:@"on.bannerAd.responseInfo" withData:jsonResponseString];
        }
    }

    __weak __typeof(self) weakSelf = self;
    bannerView.paidEventHandler = ^(GADAdValue *_Nonnull value) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        NSDictionary *data = @{
            @"value": value.value ?: [NSNull null],
            @"currencyCode": value.currencyCode ?: @"",
            @"precision": @(value.precision),
            @"adUnitId": strongSelf.bannerView.adUnitID ?: @""
        };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
        if (jsonData) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [strongSelf.plugin fireEvent:@"" event:@"on.banner.revenue" withData:jsonString];
        }
    };

    if (self.isAutoShowBanner && !self.isBannerOpen) {
        self.isBannerOpen = YES;
        [self updateLayoutWithDelay];
    } else {
        [self updateBannerLayout];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {

    _isLoading = NO;
    self.isBannerOpen = NO;
    [self updateBannerLayout];

    NSDictionary *errorData = @{
        @"code": @(error.code),
        @"message": error.localizedDescription
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.plugin fireEvent:@"" event:@"on.banner.failed.load" withData:jsonString];
    } else {
        [self.plugin fireEvent:@"" event:@"on.banner.failed.load" withData:error.localizedDescription];
    }
}

#pragma mark - Standard Lifecycle Events

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    [self.plugin fireEvent:@"" event:@"on.banner.impression" withData:nil];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    [self.plugin fireEvent:@"" event:@"on.banner.open" withData:nil];
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    [self.plugin fireEvent:@"" event:@"on.banner.close" withData:nil];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    [self.plugin fireEvent:@"" event:@"on.banner.did.dismiss" withData:nil];
}

#pragma mark - Utils

- (UIView*)findWebViewInView:(UIView*)view {
    if ([view isKindOfClass:NSClassFromString(@"WKWebView")] || [view isKindOfClass:NSClassFromString(@"UIWebView")]) return view;
    for (UIView* subview in view.subviews) {
        UIView* found = [self findWebViewInView:subview];
        if (found) return found;
    }
    return nil;
}

- (GADAdSize)getAdSizeFromString:(NSString *)size {
    if ([size isEqualToString:@"adaptive"]) return GADLargeAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.mainScreen.bounds.size.width);
    if ([size isEqualToString:@"banner"]) return GADAdSizeBanner;
    if ([size isEqualToString:@"large_banner"]) return GADAdSizeLargeBanner;
    if ([size isEqualToString:@"full_banner"]) return GADAdSizeFullBanner;
    if ([size isEqualToString:@"leaderboard"]) return GADAdSizeLeaderboard;
    if ([size isEqualToString:@"medium_rectangle"]) return GADAdSizeMediumRectangle;
    if ([size isEqualToString:@"fluid"]) return GADAdSizeFluid;

    return GADAdSizeBanner;
}

@end
