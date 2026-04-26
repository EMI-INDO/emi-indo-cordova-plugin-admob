#import "emiAdmobPlugin.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <Foundation/Foundation.h>
#import <Cordova/CDVViewController.h>

@implementation emiAdmobPlugin

@synthesize command;
@synthesize responseInfo;
@synthesize isPrivacyOptionsRequired;

int attStatus = 0;
int Consent_Status = 0;

BOOL UnderAgeOfConsent = NO;
BOOL isPrivacyOptions = NO;
BOOL isDebugGeography = NO;
BOOL isResponseInfoEnabledGlobal = NO;
BOOL isUsingAdManagerRequest = YES;
BOOL isCustomConsentManager = NO;
BOOL isEnabledKeyword = NO;
NSString *setKeyword = @"";

#pragma mark - EmiAdPluginProtocol Implementation

- (UIViewController *)getPluginViewController {
    return self.viewController;
}

- (id<CDVCommandDelegate>)getPluginCommandDelegate {
    return self.commandDelegate;
}

- (GADRequest *)getGlobalAdRequest {
    [self setAdRequest];
    return self.globalRequest;
}

- (BOOL)isResponseInfoEnabled {
    return isResponseInfoEnabledGlobal;
}

#pragma mark - Core AdRequest Configuration

- (BOOL)canRequestAds {
    return UMPConsentInformation.sharedInstance.canRequestAds;
}

- (void)setUsingAdManagerRequest:(BOOL)value {
    isUsingAdManagerRequest = value;
}

- (void)isResponseInfo:(BOOL)value {
    isResponseInfoEnabledGlobal = value;
}

- (void)isDebugGeography:(BOOL)value {
    isDebugGeography = value;
}

- (void)setAdRequest {
    if (isUsingAdManagerRequest) {
        self.globalRequest = [GAMRequest request];
    } else {
        self.globalRequest = [GADRequest request];
    }

    if (isEnabledKeyword && setKeyword.length > 0) {
        NSArray *keywords = [setKeyword componentsSeparatedByString:@","];
        for (NSString *keyword in keywords) {
            NSString *trimmedKeyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmedKeyword.length > 0) {
                [self.globalRequest setKeywords:[self.globalRequest.keywords arrayByAddingObject:trimmedKeyword]];
            }
        }
    }
}

#pragma mark - Initialization & Consent

- (void)pluginInitialize {
    [super pluginInitialize];

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSNumber *CmpSdkID = [prefs valueForKey:@"IABTCF_CmpSdkID"];
    NSString *gdprApplies = [prefs stringForKey:@"IABTCF_gdprApplies"];
    NSString *PurposeConsents = [prefs stringForKey:@"IABTCF_PurposeConsents"];
    NSString *TCString = [prefs stringForKey:@"IABTCF_TCString"];

    result[@"IABTCF_CmpSdkID"] = CmpSdkID;
    result[@"IABTCF_gdprApplies"] = gdprApplies;
    result[@"IABTCF_PurposeConsents"] = PurposeConsents;
    result[@"IABTCF_TCString"] = TCString;

    [prefs synchronize];
}

- (void)initialize:(CDVInvokedUrlCommand *)initCommand {
    NSDictionary *options = [initCommand.arguments objectAtIndex:0];

    BOOL setAdReq = [[options valueForKey:@"isUsingAdManagerRequest"] boolValue];
    BOOL respInfo = [[options valueForKey:@"isResponseInfo"] boolValue];
    BOOL setDebugGeography = [[options valueForKey:@"isConsentDebug"] boolValue];

    [self setUsingAdManagerRequest:setAdReq];
    [self isResponseInfo:respInfo];
    [self isDebugGeography:setDebugGeography];

    if (isCustomConsentManager) {
        [self startGoogleMobileAdsSDK];
        [self fireEvent:@"" event:@"on.custom.consent.manager.used" withData:nil];
        return;
    }

    __block CDVPluginResult *pluginResult;
    NSString *callbackId = initCommand.callbackId;
    NSString *deviceId = [self __getAdMobDeviceId];
    UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];

    if (setDebugGeography) {
        UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
        parameters.debugSettings = debugSettings;
        debugSettings.geography = UMPDebugGeographyEEA;
        debugSettings.testDeviceIdentifiers = @[ deviceId ];
    }
    parameters.tagForUnderAgeOfConsent = UnderAgeOfConsent;

    if (UMPConsentInformation.sharedInstance.canRequestAds) {
        [self startGoogleMobileAdsSDK];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:parameters completionHandler:^(NSError *_Nullable requestConsentError) {
            if (requestConsentError) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:requestConsentError.description];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                return;
            }

            UMPConsentStatus status = UMPConsentInformation.sharedInstance.consentStatus;

            if (status == UMPConsentStatusRequired) {
                [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *form, NSError *loadError) {
                    if (loadError) {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:loadError.description];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                    } else {
                        [form presentFromViewController:[UIApplication sharedApplication].delegate.window.rootViewController completionHandler:^(NSError *_Nullable dismissError) {
                            if (dismissError) {
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:dismissError.description];
                            } else {
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Consent form displayed successfully."];
                            }
                            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                        }];
                    }

                    if (UMPConsentInformation.sharedInstance.canRequestAds) {
                        [self startGoogleMobileAdsSDK];
                    }
                }];
            } else if (status == UMPConsentStatusNotRequired || status == UMPConsentStatusObtained) {
                if (UMPConsentInformation.sharedInstance.canRequestAds) {
                    [self startGoogleMobileAdsSDK];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Ads SDK started."];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot request ads, consent is required."];
                }
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Consent status unknown."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }
        }];
    });
}

- (void)startGoogleMobileAdsSDK {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GADMobileAds *ads = [GADMobileAds sharedInstance];
        [ads startWithCompletionHandler:^(GADInitializationStatus *status) {
            NSDictionary *adapterStatuses = [status adapterStatusesByClassName];
            NSMutableArray *adaptersArray = [NSMutableArray array];

            for (NSString *adapter in adapterStatuses) {

                NSDictionary *adapterInfo = @{@"name" : adapter};
                [adaptersArray addObject:adapterInfo];
            }

            NSString *sdkVersion = GADGetStringFromVersionNumber(GADMobileAds.sharedInstance.versionNumber);
            int consentStatusValue = (int)UMPConsentInformation.sharedInstance.consentStatus;
            int initAttStatus = (int)attStatus;

            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSNumber *CmpSdkID = [prefs valueForKey:@"IABTCF_CmpSdkID"];
            NSString *gdprApplies = [prefs stringForKey:@"IABTCF_gdprApplies"];
            NSString *PurposeConsents = [prefs stringForKey:@"IABTCF_PurposeConsents"];
            NSString *TCString = [prefs stringForKey:@"IABTCF_TCString"];
            NSString *additionalConsent = [prefs stringForKey:@"IABTCF_AddtlConsent"];

            result[@"version"] = sdkVersion;
            result[@"consentStatus"] = @(consentStatusValue);
            result[@"attStatus"] = @(initAttStatus);
            result[@"adapter"] = adaptersArray;
            result[@"CmpSdkID"] = CmpSdkID;
            result[@"gdprApplies"] = gdprApplies;
            result[@"PurposeConsents"] = PurposeConsents;
            result[@"TCString"] = TCString;
            result[@"additionalConsent"] = additionalConsent;

            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];

            if (jsonData) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self fireEvent:@"" event:@"on.sdkInitialization" withData:jsonString];
            }
            [prefs synchronize];
        }];
    });
}

- (void)requestIDFA:(CDVInvokedUrlCommand *)reqCommand {
    __block CDVPluginResult *pluginResult;
    NSString *callbackId = reqCommand.callbackId;

    if (@available(iOS 14, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if (status == ATTrackingManagerAuthorizationStatusDenied) {
                    attStatus = ATTrackingManagerAuthorizationStatusDenied;
                } else if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    attStatus = ATTrackingManagerAuthorizationStatusAuthorized;
                } else if (status == ATTrackingManagerAuthorizationStatusRestricted) {
                    attStatus = ATTrackingManagerAuthorizationStatusRestricted;
                } else if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
                    attStatus = ATTrackingManagerAuthorizationStatusNotDetermined;
                }
                [self fireEvent:@"" event:@"on.getIDFA.status" withData:nil];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:attStatus];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }];
        });
    } else {
        [self fireEvent:@"" event:@"on.getIDFA.error" withData:nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"iOS 14+ not found"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
}

- (void)forceDisplayPrivacyForm:(CDVInvokedUrlCommand *)cmd {
    NSString *deviceId = [self __getAdMobDeviceId];
    UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];

    if (isDebugGeography) {
        UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
        debugSettings.geography = UMPDebugGeographyEEA;
        debugSettings.testDeviceIdentifiers = @[ deviceId ];
        parameters.debugSettings = debugSettings;
    }
    parameters.tagForUnderAgeOfConsent = UnderAgeOfConsent;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:parameters completionHandler:^(NSError *_Nullable requestConsentError) {
            if (requestConsentError) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:requestConsentError.description];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
                return;
            }

            [UMPConsentForm loadAndPresentIfRequiredFromViewController:self.viewController completionHandler:^(NSError *loadAndPresentError) {
                if (loadAndPresentError) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:loadAndPresentError.description];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
                } else {
                    [UMPConsentForm presentPrivacyOptionsFormFromViewController:self.viewController completionHandler:^(NSError *_Nullable formError) {
                        if (formError) {

                        }
                    }];
                }
            }];
        }];
    });
}

- (void)showPrivacyOptionsForm:(CDVInvokedUrlCommand *)cmd {
    NSString *deviceId = [self __getAdMobDeviceId];
    UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];

    if (isDebugGeography) {
        UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
        parameters.debugSettings = debugSettings;
        debugSettings.geography = UMPDebugGeographyEEA;
        debugSettings.testDeviceIdentifiers = @[ deviceId ];
    }
    parameters.tagForUnderAgeOfConsent = UnderAgeOfConsent;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:parameters completionHandler:^(NSError *_Nullable requestConsentError) {
            if (requestConsentError) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:requestConsentError.description];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
                return;
            }

            [UMPConsentForm loadAndPresentIfRequiredFromViewController:self.viewController completionHandler:^(NSError *loadAndPresentError) {
                if (loadAndPresentError) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:loadAndPresentError.description];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
                }
            }];

            if ([self isPrivacyOptionsRequired]) {
                [self privacyOptionsFormShow:cmd];
            } else {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"The privacy option form is not required."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
            }
        }];
    });
}

- (void)privacyOptionsFormShow:(CDVInvokedUrlCommand *)cmd {
    [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UMPConsentForm presentPrivacyOptionsFormFromViewController:self.viewController completionHandler:^(NSError *_Nullable formError) {
                if (formError) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:formError.description];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
                }
            }];
        });
    }];
}

- (BOOL)isPrivacyOptionsRequired {
    UMPPrivacyOptionsRequirementStatus status = UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus;
    return status == UMPPrivacyOptionsRequirementStatusRequired;
}

- (void)readStatus:(CDVInvokedUrlCommand *)cmd {
    [self.commandDelegate runInBackground:^{
        Consent_Status = (int)UMPConsentInformation.sharedInstance.consentStatus;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:Consent_Status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
    }];
}

- (void)getIabTfc:(CDVInvokedUrlCommand *)cmd {
    CDVPluginResult *pluginResult;
    NSString *callbackId = cmd.callbackId;

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSNumber *CmpSdkID = [prefs valueForKey:@"IABTCF_CmpSdkID"];
    NSString *gdprApplies = [prefs stringForKey:@"IABTCF_gdprApplies"];
    NSString *PurposeConsents = [prefs stringForKey:@"IABTCF_PurposeConsents"];
    NSString *TCString = [prefs stringForKey:@"IABTCF_TCString"];

    result[@"IABTCF_CmpSdkID"] = CmpSdkID;
    result[@"IABTCF_gdprApplies"] = gdprApplies;
    result[@"IABTCF_PurposeConsents"] = PurposeConsents;
    result[@"IABTCF_TCString"] = TCString;

    [prefs synchronize];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self fireEvent:@"" event:@"onGetIabTfc" withData:nil];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)consentReset:(CDVInvokedUrlCommand *)cmd {
    CDVPluginResult *pluginResult;
    NSString *callbackId = cmd.callbackId;
    @try {
        [[UMPConsentInformation sharedInstance] reset];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)globalSettings:(CDVInvokedUrlCommand *)cmd {
    CDVPluginResult *pluginResult;
    NSString *callbackId = cmd.callbackId;
    NSDictionary *options = [cmd.arguments objectAtIndex:0];
    BOOL setAppMuted = [[options valueForKey:@"setAppMuted"] boolValue];
    BOOL setAppVolume = [[options valueForKey:@"setAppVolume"] boolValue];
    BOOL pubIdEnabled = [[options valueForKey:@"pubIdEnabled"] boolValue];
    @try {
        GADMobileAds.sharedInstance.applicationVolume = setAppVolume;
        GADMobileAds.sharedInstance.applicationMuted = setAppMuted;
        [GADMobileAds.sharedInstance.requestConfiguration setPublisherFirstPartyIDEnabled:pubIdEnabled];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)targeting:(CDVInvokedUrlCommand *)cmd {
    CDVPluginResult *pluginResult;
    NSString *callbackId = cmd.callbackId;
    NSDictionary *options = [cmd.arguments objectAtIndex:0];
    BOOL childDirectedTreatment = [[options valueForKey:@"childDirectedTreatment"] boolValue];
    BOOL underAgeOfConsent = [[options valueForKey:@"underAgeOfConsent"] boolValue];
    NSString *contentRating = [options valueForKey:@"contentRating"];

    @try {
        GADRequestConfiguration *requestConfiguration = GADMobileAds.sharedInstance.requestConfiguration;
        requestConfiguration.tagForChildDirectedTreatment = @(childDirectedTreatment);
        requestConfiguration.tagForUnderAgeOfConsent = @(underAgeOfConsent);

        if (contentRating != nil) {
            if ([contentRating isEqualToString:@"G"]) {
                requestConfiguration.maxAdContentRating = GADMaxAdContentRatingGeneral;
            } else if ([contentRating isEqualToString:@"PG"]) {
                requestConfiguration.maxAdContentRating = GADMaxAdContentRatingParentalGuidance;
            } else if ([contentRating isEqualToString:@"T"]) {
                requestConfiguration.maxAdContentRating = GADMaxAdContentRatingTeen;
            } else if ([contentRating isEqualToString:@"MA"]) {
                requestConfiguration.maxAdContentRating = GADMaxAdContentRatingMatureAudience;
            }
        }
        UnderAgeOfConsent = underAgeOfConsent;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)metaData:(CDVInvokedUrlCommand *)cmd {
    NSDictionary *options = [cmd.arguments objectAtIndex:0];
    isCustomConsentManager = [[options valueForKey:@"useCustomConsentManager"] boolValue];
    isEnabledKeyword = [[options valueForKey:@"isEnabledKeyword"] boolValue];
    setKeyword = [options valueForKey:@"setKeyword"];
}

#pragma mark - Helper Methods

- (NSString *)__getAdMobDeviceId {
    NSUUID *adid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    return [self __sha256:adid.UUIDString];
}

- (NSString *)__sha256:(NSString *)string {
    CC_SHA256_CTX sha256Context;
    CC_SHA256_Init(&sha256Context);
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA256_Update(&sha256Context, [data bytes], (CC_LONG)[data length]);
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &sha256Context);

    NSMutableString *hexString = [NSMutableString stringWithCapacity:(CC_SHA256_DIGEST_LENGTH * 2)];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hexString appendFormat:@"%02x", digest[i]];
    }
    return hexString;
}

- (void)fireEvent:(NSString *)obj event:(NSString *)eventName withData:(NSString *)jsonStr {
    NSString *js;
    if (obj && [obj isEqualToString:@"window"]) {
        js = [NSString stringWithFormat:@"var evt=document.createEvent(\"UIEvents\");evt.initUIEvent(\"%@\",true,false,window,0);window.dispatchEvent(evt);", eventName];
    } else if (jsonStr && [jsonStr length] > 0) {
        js = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@',%@);", eventName, jsonStr];
    } else {
        js = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@');", eventName];
    }
    [self.commandDelegate evalJs:js];
}

#pragma mark - Banner Routing

- (EmiBannerManager *)bannerManager {
    if (!_bannerManager) {
        _bannerManager = [[EmiBannerManager alloc] initWithPlugin:self];
    }
    return _bannerManager;
}

- (void)loadBannerAd:(CDVInvokedUrlCommand *)cmd { [self.bannerManager loadBannerAd:cmd]; }
- (void)showBannerAd:(CDVInvokedUrlCommand *)cmd { [self.bannerManager showBannerAd:cmd]; }
- (void)hideBannerAd:(CDVInvokedUrlCommand *)cmd { [self.bannerManager hideBannerAd:cmd]; }
- (void)removeBannerAd:(CDVInvokedUrlCommand *)cmd { [self.bannerManager removeBannerAd:cmd]; }
- (void)styleBannerAd:(CDVInvokedUrlCommand *)cmd { [self.bannerManager styleBannerAd:cmd]; }

#pragma mark - App Open Routing

- (EmiAppOpenManager *)appOpenManager {
    if (!_appOpenManager) {
        _appOpenManager = [[EmiAppOpenManager alloc] initWithPlugin:self];
    }
    return _appOpenManager;
}

- (void)loadAppOpenAd:(CDVInvokedUrlCommand *)cmd { [self.appOpenManager loadAppOpenAd:cmd]; }
- (void)showAppOpenAd:(CDVInvokedUrlCommand *)cmd { [self.appOpenManager showAppOpenAd:cmd]; }

#pragma mark - Interstitial Routing

- (EmiInterstitialManager *)interstitialManager {
    if (!_interstitialManager) {
        _interstitialManager = [[EmiInterstitialManager alloc] initWithPlugin:self];
    }
    return _interstitialManager;
}

- (void)loadInterstitialAd:(CDVInvokedUrlCommand *)cmd { [self.interstitialManager loadInterstitialAd:cmd]; }
- (void)showInterstitialAd:(CDVInvokedUrlCommand *)cmd { [self.interstitialManager showInterstitialAd:cmd]; }

#pragma mark - Rewarded Routing

- (EmiRewardedManager *)rewardedManager {
    if (!_rewardedManager) {
        _rewardedManager = [[EmiRewardedManager alloc] initWithPlugin:self];
    }
    return _rewardedManager;
}

- (void)loadRewardedAd:(CDVInvokedUrlCommand *)cmd { [self.rewardedManager loadRewardedAd:cmd]; }
- (void)showRewardedAd:(CDVInvokedUrlCommand *)cmd { [self.rewardedManager showRewardedAd:cmd]; }

#pragma mark - Rewarded Interstitial Routing

- (EmiRewardedInterstitialManager *)rewardedInterstitialManager {
    if (!_rewardedInterstitialManager) {
        _rewardedInterstitialManager = [[EmiRewardedInterstitialManager alloc] initWithPlugin:self];
    }
    return _rewardedInterstitialManager;
}

- (void)loadRewardedInterstitialAd:(CDVInvokedUrlCommand *)cmd { [self.rewardedInterstitialManager loadRewardedInterstitialAd:cmd]; }
- (void)showRewardedInterstitialAd:(CDVInvokedUrlCommand *)cmd { [self.rewardedInterstitialManager showRewardedInterstitialAd:cmd]; }

@end
