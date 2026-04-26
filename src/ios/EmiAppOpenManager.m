#import "EmiAppOpenManager.h"

@implementation EmiAppOpenManager {
    BOOL _isLoading;
    NSTimeInterval _lastLoadTime;
    NSTimeInterval _minLoadInterval;
}

- (instancetype)initWithPlugin:(id<EmiAdPluginProtocol>)plugin {
    self = [super init];
    if (self) {
        _plugin = plugin;
        _isLoading = NO;
        _lastLoadTime = 0;
        _minLoadInterval = 5.0; 
    }
    return self;
}

- (void)loadAppOpenAd:(CDVInvokedUrlCommand *)command {

    if (_isLoading) {

        return;
    }

    id<CDVCommandDelegate> commandDelegate = [self.plugin getPluginCommandDelegate];
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    self.isAutoShowAppOpen = [[options valueForKey:@"autoShow"] boolValue];

    if ([options objectForKey:@"loadInterval"]) {
        _minLoadInterval = [[options valueForKey:@"loadInterval"] doubleValue];
    } else {
        _minLoadInterval = 5.0; 
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - _lastLoadTime < _minLoadInterval) {

        return;
    }

    _isLoading = YES;
    _lastLoadTime = now;
    self.appOpenAd = nil;

    dispatch_async(dispatch_get_main_queue(), ^{

        GADExtras *extras = [[GADExtras alloc] init];
        [[self.plugin getGlobalAdRequest] registerAdNetworkExtras:extras];

        [GADAppOpenAd loadWithAdUnitID:adUnitId
                               request:[self.plugin getGlobalAdRequest]
                     completionHandler:^(GADAppOpenAd *ad, NSError *error) {

            self->_isLoading = NO;

            if (error) {

                NSDictionary *errorData = @{@"error": error.localizedDescription ?: @"Unknown error"};
                NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];

                [self.plugin fireEvent:@"" event:@"on.appOpenAd.failed.loaded" withData:errorJsonString];
                return;
            }

            self.appOpenAd = ad;
            self.appOpenAd.fullScreenContentDelegate = self;
            [self.plugin fireEvent:@"" event:@"on.appOpenAd.loaded" withData:nil];

            __weak __typeof(self) weakSelf = self;
            self.appOpenAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;

                NSDecimalNumber *adValue = value.value;
                NSString *currencyCode = value.currencyCode;
                GADAdValuePrecision precision = value.precision;
                NSString *adUnitIdStr = strongSelf.appOpenAd.adUnitID;

                NSDictionary *data = @{
                    @"value": adValue ?: [NSNull null],
                    @"currencyCode": currencyCode ?: @"",
                    @"precision": @(precision),
                    @"adUnitId": adUnitIdStr ?: @""
                };

                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                [strongSelf.plugin fireEvent:@"" event:@"on.appOpenAd.revenue" withData:jsonString];
            };

            if (self.isAutoShowAppOpen) {
                NSError *presentError = nil;
                UIViewController *rootVC = [self.plugin getPluginViewController];

                if ([self.appOpenAd canPresentFromRootViewController:rootVC error:&presentError]) {
                    [self.appOpenAd presentFromRootViewController:rootVC];
                } else {

                    NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                    NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                    NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];

                    [self.plugin fireEvent:@"" event:@"on.appOpenAd.failed.show" withData:errorJsonString];
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
                    [self.plugin fireEvent:@"" event:@"on.appOpenAd.responseInfo" withData:jsonResponseString];
                } else {

                }
            }
        }];
    });

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showAppOpenAd:(CDVInvokedUrlCommand *)command {
    id<CDVCommandDelegate> commandDelegate = [self.plugin getPluginCommandDelegate];
    CDVPluginResult *pluginResult;

    UIViewController *rootVC = [self.plugin getPluginViewController];

    if (self.appOpenAd && [self.appOpenAd canPresentFromRootViewController:rootVC error:nil]) {
        [self.appOpenAd presentFromRootViewController:rootVC];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];

        [self.plugin fireEvent:@"" event:@"on.appOpened.failed.show" withData:nil];
    }

    [commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - GADFullScreenContentDelegate

- (void)adWillPresentFullScreenContent:(id)ad {
    [self.plugin fireEvent:@"" event:@"on.appOpenAd.show" withData:nil];
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSDictionary *errorData = @{
        @"code": @(error.code),
        @"message": error.localizedDescription
    };

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:&jsonError];
    NSString *jsonString = jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : error.localizedDescription;

    [self.plugin fireEvent:@"" event:@"on.appOpenAd.failed.loaded" withData:jsonString];
}

- (void)adDidDismissFullScreenContent:(id)ad {
    [self.plugin fireEvent:@"" event:@"on.appOpenAd.dismissed" withData:nil];
    self.appOpenAd = nil; 
}

@end
