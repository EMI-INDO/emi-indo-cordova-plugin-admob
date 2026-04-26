#import "EmiRewardedManager.h"

@implementation EmiRewardedManager {
    BOOL _isLoading;
    NSTimeInterval _lastLoadTime;
    NSTimeInterval _minLoadInterval;
    NSString *_lastAdUnitId;
}

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin {
    self = [super init];
    if (self) {
        _plugin = plugin;
        _isAdSkip = 0;
        _isLoading = NO;
        _lastLoadTime = 0;
        _minLoadInterval = 5.0; 
        _lastAdUnitId = @"";
    }
    return self;
}

- (void)loadRewardedAd:(CDVInvokedUrlCommand *)command {

    if (_isLoading) {

        return;
    }

    id<CDVCommandDelegate> commandDelegate = [self.plugin getPluginCommandDelegate];
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    self.isAutoShowRewardedAds = [[options valueForKey:@"autoShow"] boolValue];

    if ([options objectForKey:@"loadInterval"]) {
        _minLoadInterval = [[options valueForKey:@"loadInterval"] doubleValue];
    } else {
        _minLoadInterval = 5.0; 
    }

    if ([adUnitId isEqualToString:_lastAdUnitId] && self.rewardedAd != nil) {

        if (self.isAutoShowRewardedAds) {
            [self showRewardedAd:command]; 
        } else {
            [self.plugin fireEvent:@"" event:@"on.rewarded.loaded" withData:nil];
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
    self.rewardedAd = nil;
    self.isAdSkip = 0;

    dispatch_async(dispatch_get_main_queue(), ^{
        [GADRewardedAd loadWithAdUnitID:adUnitId
                                request:[self.plugin getGlobalAdRequest]
                      completionHandler:^(GADRewardedAd *ad, NSError *error) {

            self->_isLoading = NO;

            if (error) {
                NSDictionary *errorData = @{@"error": error.localizedDescription ?: @"Unknown error"};
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self.plugin fireEvent:@"" event:@"on.rewarded.failed.load" withData:jsonString];
                return;
            }

            self.rewardedAd = ad;
            self.rewardedAd.fullScreenContentDelegate = self;
            [self.plugin fireEvent:@"" event:@"on.rewarded.loaded" withData:nil];

            __weak __typeof(self) weakSelf = self;
            self.rewardedAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;

                NSDecimalNumber *adValue = value.value;
                NSString *currencyCode = value.currencyCode;
                GADAdValuePrecision precision = value.precision;
                NSString *adUnitIdStr = strongSelf.rewardedAd.adUnitID;

                NSDictionary *data = @{
                    @"value": adValue ?: [NSNull null],
                    @"currencyCode": currencyCode ?: @"",
                    @"precision": @(precision),
                    @"adUnitId": adUnitIdStr ?: @""
                };

                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                [strongSelf.plugin fireEvent:@"" event:@"on.rewarded.revenue" withData:jsonString];
            };

            if (self.isAutoShowRewardedAds) {
                NSError *presentError = nil;
                UIViewController *rootVC = [self.plugin getPluginViewController];

                if ([self.rewardedAd canPresentFromRootViewController:rootVC error:&presentError]) {
                    [self.rewardedAd presentFromRootViewController:rootVC userDidEarnRewardHandler:^{
                        GADAdReward *reward = self.rewardedAd.adReward;
                        NSDictionary *rewardData = @{
                            @"rewardType": reward.type,
                            @"rewardAmount": [reward.amount stringValue]
                        };
                        NSData *rewardJsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:nil];
                        NSString *rewardJsonString = [[NSString alloc] initWithData:rewardJsonData encoding:NSUTF8StringEncoding];

                        self.isAdSkip = 2; 
                        [self.plugin fireEvent:@"" event:@"on.reward.userEarnedReward" withData:rewardJsonString];
                    }];
                } else {
                    NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [self.plugin fireEvent:@"" event:@"on.rewarded.failed.show" withData:jsonString];
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
                    [self.plugin fireEvent:@"" event:@"on.rewardedAd.responseInfo" withData:jsonResponseString];
                } else {

                }
            }
        }];
    });

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showRewardedAd:(CDVInvokedUrlCommand *)command {
    id<CDVCommandDelegate> commandDelegate = [self.plugin getPluginCommandDelegate];
    CDVPluginResult *pluginResult;

    if (self.rewardedAd) {
        NSError *presentError = nil;
        UIViewController *rootVC = [self.plugin getPluginViewController];

        if ([self.rewardedAd canPresentFromRootViewController:rootVC error:&presentError]) {
            [self.rewardedAd presentFromRootViewController:rootVC userDidEarnRewardHandler:^{
                GADAdReward *reward = self.rewardedAd.adReward;
                NSDictionary *rewardData = @{
                    @"rewardType": reward.type,
                    @"rewardAmount": [reward.amount stringValue]
                };
                NSError *jsonError;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:&jsonError];

                if (jsonData) {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [self.plugin fireEvent:@"" event:@"on.reward.userEarnedReward" withData:jsonString];
                } else {
                    [self.plugin fireEvent:@"" event:@"on.reward.userEarnedReward" withData:nil];
                }

                self.isAdSkip = 2; 

            }];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
            NSError *jsonError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:&jsonError];

            if (jsonData && !jsonError) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self.plugin fireEvent:@"" event:@"on.rewarded.failed.show" withData:jsonString];
            } else {
                [self.plugin fireEvent:@"" event:@"on.rewarded.failed.show" withData:nil];
            }
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.plugin fireEvent:@"" event:@"on.rewarded.failed.show" withData:nil];
    }

    if (command) {
        [commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark - GADFullScreenContentDelegate

- (void)adWillPresentFullScreenContent:(id)ad {
    self.isAdSkip = 1; 
    [self.plugin fireEvent:@"" event:@"on.rewarded.show" withData:nil];
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSDictionary *errorData = @{
        @"code": @(error.code),
        @"message": error.localizedDescription
    };

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:&jsonError];
    NSString *jsonString = jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : error.localizedDescription;

    [self.plugin fireEvent:@"" event:@"on.rewarded.failed.load" withData:jsonString];
}

- (void)adDidDismissFullScreenContent:(id)ad {
    if (self.isAdSkip != 2) {
        [self.plugin fireEvent:@"" event:@"on.rewarded.ad.skip" withData:nil];
    } else {
        [self.plugin fireEvent:@"" event:@"on.rewarded.dismissed" withData:nil];
    }

    self.rewardedAd = nil;
    self->_lastAdUnitId = @"";
}

@end
