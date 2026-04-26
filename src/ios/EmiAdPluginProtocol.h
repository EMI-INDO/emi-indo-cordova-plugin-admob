#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@protocol EmiAdPluginProtocol <NSObject>

- (void)fireEvent:(NSString *)obj event:(NSString *)eventName withData:(NSString *)jsonStr;
- (UIViewController *)getPluginViewController;
- (id<CDVCommandDelegate>)getPluginCommandDelegate;
- (GADRequest *)getGlobalAdRequest;
- (BOOL)isResponseInfoEnabled;

@end
