#import "EmiInterstitialManager.h"

@implementation EmiInterstitialManager {
    BOOL _isLoading;
    NSTimeInterval _lastLoadTime;
    NSTimeInterval _minLoadInterval;
    NSString *_lastAdUnitId; 
}

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin {
    self = [super init];
    if (self) {
        _plugin = plugin;
        _isLoading = NO;
        _lastLoadTime = 0;
        _minLoadInterval = 5.0; 
        _lastAdUnitId = @"";
    }
    return self;
}

- (void)loadInterstitialAd:(CDVInvokedUrlCommand *)command {

    if (_isLoading) {

        return;
    }

    id<CDVCommandDelegate> commandDelegate = [self.plugin getPluginCommandDelegate];
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    self.isAutoShowInterstitial = [[options valueForKey:@"autoShow"] boolValue];

    if ([options objectForKey:@"loadInterval"]) {
        _minLoadInterval = [[options valueForKey:@"loadInterval"] doubleValue];
    } else {
        _minLoadInterval = 5.0; 
    }

    if ([adUnitId isEqualToString:_lastAdUnitId] && self.interstitialAd != nil) {

        if (self.isAutoShowInterstitial) {
            [self showInterstitialAd:command]; 
        } else {

            [self.plugin fireEvent:@"" event:@"on.interstitial.loaded" withData:nil];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        return;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - _lastLoadTime < _minLoadInterval) {

        return;
    }

    _isLoading = YES;
    _lastLoadTime = now;
    _lastAdUnitId = adUnitId;
    self.interstitialAd = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        [GADInterstitialAd loadWithAdUnitID:adUnitId
                                    request:[self.plugin getGlobalAdRequest]
                          completionHandler:^(GADInterstitialAd *ad, NSError *error) {

            self->_isLoading = NO;

            if (error) {
                NSDictionary *errorData = @{@"error": error.localizedDescription ?: @"Unknown error"};
                NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];

                [self.plugin fireEvent:@"" event:@"on.interstitial.failed.load" withData:errorJsonString];
                return;
            }

            self.interstitialAd = ad;
            self.interstitialAd.fullScreenContentDelegate = self;
            [self.plugin fireEvent:@"" event:@"on.interstitial.loaded" withData:nil];

            __weak __typeof(self) weakSelf = self;
            self.interstitialAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;

                NSDecimalNumber *adValue = value.value;
                NSString *currencyCode = value.currencyCode;
                GADAdValuePrecision precision = value.precision;
                NSString *adUnitIdStr = strongSelf.interstitialAd.adUnitID;

                NSDictionary *data = @{
                    @"value": adValue ?: [NSNull null],
                    @"currencyCode": currencyCode ?: @"",
                    @"precision": @(precision),
                    @"adUnitId": adUnitIdStr ?: @""
                };

                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                [strongSelf.plugin fireEvent:@"" event:@"on.interstitial.revenue" withData:jsonString];
            };

            if (self.isAutoShowInterstitial) {
                NSError *presentError = nil;
                UIViewController *rootVC = [self.plugin getPluginViewController];
                if ([self.interstitialAd canPresentFromRootViewController:rootVC error:&presentError]) {
                    [self.interstitialAd presentFromRootViewController:rootVC];
                } else {
                    NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                    NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                    NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                    [self.plugin fireEvent:@"" event:@"on.interstitial.failed.show" withData:errorJsonString];
                }
            }

            if ([self.plugin isResponseInfoEnabled]) {
                GADResponseInfo *responseInfo = ad.responseInfo;
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

                NSError *jsonError = nil;
                NSData *jsonResponseData = [NSJSONSerialization dataWithJSONObject:responseInfoData options:0 error:&jsonError];
                if (!jsonError) {
                    NSString *jsonResponseString = [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding];
                    [self.plugin fireEvent:@"" event:@"on.interstitialAd.responseInfo" withData:jsonResponseString];
                } else {

                }
            }
        }];
    });

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showInterstitialAd:(CDVInvokedUrlCommand *)command {
    id<CDVCommandDelegate> commandDelegate = [self.plugin getPluginCommandDelegate];
    CDVPluginResult *pluginResult;

    NSError *presentError = nil;
    UIViewController *rootVC = [self.plugin getPluginViewController];

    if (self.interstitialAd && [self.interstitialAd canPresentFromRootViewController:rootVC error:&presentError]) {
        [self.interstitialAd presentFromRootViewController:rootVC];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
        NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
        NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];

        [self.plugin fireEvent:@"" event:@"on.interstitial.failed.show" withData:errorJsonString];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    if (command) {
        [commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark - GADFullScreenContentDelegate

- (void)adWillPresentFullScreenContent:(id)ad {
    [self.plugin fireEvent:@"" event:@"on.interstitial.show" withData:nil];
    [self.plugin fireEvent:@"" event:@"onPresentAd" withData:nil];
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSDictionary *errorData = @{
        @"code": @(error.code),
        @"message": error.localizedDescription
    };

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:&jsonError];
    NSString *jsonString = jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : error.localizedDescription;

    [self.plugin fireEvent:@"" event:@"on.interstitial.failed.load" withData:jsonString];
}

- (void)adDidDismissFullScreenContent:(id)ad {
    [self.plugin fireEvent:@"" event:@"on.interstitial.dismissed" withData:nil];
    self.interstitialAd = nil; 
    self->_lastAdUnitId = @""; 
}

@end
