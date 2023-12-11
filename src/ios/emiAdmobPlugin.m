#import "emiAdmobPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import <Foundation/Foundation.h>
@implementation emiAdmobPlugin
@synthesize appOpenAd;
@synthesize bannerView;
@synthesize interstitial;
@synthesize rewardedInterstitialAd;
@synthesize rewardedAd;
@synthesize command;
@synthesize responseInfo;
@synthesize isPrivacyOptionsRequired;
int idfaStatus = 0;
int fromStatus = 0;
int adFormat = 0;
int adWidth = 320;
BOOL auto_Show = NO;
NSString *Npa = @"1";
NSString *Position = @"bottom";
BOOL EnableCollapsible = NO;
BOOL ResponseInfo = NO;
int isAdSkip = 0;
BOOL isIAB = NO;
BOOL UnderAgeOfConsent = NO;- (void)initialize:(CDVInvokedUrlCommand*)command {    GADMobileAds *ads = [GADMobileAds sharedInstance];
    [ads startWithCompletionHandler:^(GADInitializationStatus *status) {
        // Optional: Log each adapter's initialization latency.
        NSDictionary *adapterStatuses = [status adapterStatusesByClassName];
        for (NSString *adapter in adapterStatuses) {
            GADAdapterStatus *adapterStatus = adapterStatuses[adapter];
            NSLog(@"Adapter Name: %@, Description: %@, Latency: %f", adapter,
                  adapterStatus.description, adapterStatus.latency);        }        [self fireEvent:@"" event:@"on.sdkInitialization" withData:nil];    }];}- (void)requestIDFA:(CDVInvokedUrlCommand*)command {    CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;    if (@available(iOS 14, *)) {
                    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                        if (status == ATTrackingManagerAuthorizationStatusDenied) {                idfaStatus = ATTrackingManagerAuthorizationStatusDenied;
                        } else if (status == ATTrackingManagerAuthorizationStatusAuthorized) {                idfaStatus = ATTrackingManagerAuthorizationStatusAuthorized;
                        } else if (status == ATTrackingManagerAuthorizationStatusRestricted) {                idfaStatus = ATTrackingManagerAuthorizationStatusRestricted;
                        } else if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {                idfaStatus = ATTrackingManagerAuthorizationStatusNotDetermined;
                        }
                    }];        [self fireEvent:@"" event:@"on.getIDFA.status" withData:nil];        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:idfaStatus];
                } else {        [self fireEvent:@"" event:@"on.getIDFA.error" withData:nil];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];    }    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }- (void)getConsentRequest:(CDVInvokedUrlCommand*)command {
                CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
                // UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
                // debugSettings.testDeviceIdentifiers = @[@"59156CDC-B042-4D81-A9FA-900869782912"];
                // parameters.debugSettings = debugSettings;
                // debugSettings.geography = UMPDebugGeographyEEA;
                // BOOL tagForUnderAgeOfConsent = [[command argumentAtIndex:0] boolValue];
                parameters.tagForUnderAgeOfConsent = UnderAgeOfConsent;    [UMPConsentInformation.sharedInstance
                                                                            requestConsentInfoUpdateWithParameters:parameters
                                                                            completionHandler:^(NSError *_Nullable requestConsentError) {
                    if (requestConsentError) {
                        // Consent gathering failed.
                        NSLog(@"Error: %@", requestConsentError.localizedDescription);
                        return;
                    }        [UMPConsentForm loadAndPresentIfRequiredFromViewController:self.viewController
                                                                      completionHandler:^(NSError *loadAndPresentError) {
                        if (loadAndPresentError) {
                            // Consent gathering failed.
                            NSLog(@"Error: %@", loadAndPresentError.localizedDescription);
                            return;
                        }            UMPFormStatus formStatus = UMPConsentInformation.sharedInstance.formStatus;            if (formStatus == UMPFormStatusUnknown) {                fromStatus = 0;            } else if (formStatus == UMPFormStatusAvailable) {                fromStatus = 1;            } else if (formStatus == UMPFormStatusUnavailable) {                fromStatus = 2;
                        }            [self fireEvent:@"" event:@"on.get.from.status" withData:nil];        }];    }];    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:fromStatus];    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }- (void)showPrivacyOptionsForm:(CDVInvokedUrlCommand*)command {    UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
                // UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
                // debugSettings.testDeviceIdentifiers = @[@"59156CDC-B042-4D81-A9FA-900869782912"];
                // parameters.debugSettings = debugSettings;
                // debugSettings.geography = UMPDebugGeographyEEA;
                // BOOL tagForUnderAgeOfConsent = [[command argumentAtIndex:0] boolValue];
                parameters.tagForUnderAgeOfConsent = UnderAgeOfConsent;
                [UMPConsentInformation.sharedInstance
                 requestConsentInfoUpdateWithParameters:parameters
                 completionHandler:^(NSError *_Nullable requestConsentError) {
                    // ...
                    [UMPConsentForm loadAndPresentIfRequiredFromViewController:self.viewController
                                                             completionHandler:^(NSError *loadAndPresentError) {        }];        [self isPrivacyOptionsRequired];    }];    [UMPConsentForm presentPrivacyOptionsFormFromViewController:self.viewController completionHandler:^(NSError * _Nullable formError) {
                        if (formError) {
                            // Handle the error.
                            NSLog(@"Error: %@", formError.localizedDescription);
                            [self fireEvent:@"" event:@"on.getPrivacyOptionsFrom.error" withData:nil];
                        }
                    }];}- (BOOL)isPrivacyOptionsRequired {
                        return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus ==
                        UMPPrivacyOptionsRequirementStatusRequired;
                    }- (void)pluginInitialize {    isIAB = YES;    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    NSNumber* CmpSdkID = [prefs valueForKey:@"IABTCF_CmpSdkID"];
                        NSString *gdprApplies = [prefs stringForKey:@"IABTCF_gdprApplies"];
                        NSString *PurposeConsents = [prefs stringForKey:@"IABTCF_PurposeConsents"];
                        NSString *TCString = [prefs stringForKey:@"IABTCF_TCString"];
                        result[@"IABTCF_CmpSdkID"] = CmpSdkID;
                        result[@"IABTCF_gdprApplies"] = gdprApplies;
                        result[@"IABTCF_PurposeConsents"] = PurposeConsents;
                        result[@"IABTCF_TCString"] = TCString;    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
                        [prefs synchronize];}- (void)getIabTfc:(CDVInvokedUrlCommand*)command {
                            CDVPluginResult *pluginResult;
                            NSString *callbackId = command.callbackId;
                            if (isIAB == 1) {
                                NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];        NSNumber* CmpSdkID = [prefs valueForKey:@"IABTCF_CmpSdkID"];
                                NSString *gdprApplies = [prefs stringForKey:@"IABTCF_gdprApplies"];
                                NSString *PurposeConsents = [prefs stringForKey:@"IABTCF_PurposeConsents"];
                                NSString *TCString = [prefs stringForKey:@"IABTCF_TCString"];        result[@"IABTCF_CmpSdkID"] = CmpSdkID;
                                result[@"IABTCF_gdprApplies"] = gdprApplies;
                                result[@"IABTCF_PurposeConsents"] = PurposeConsents;
                                result[@"IABTCF_TCString"] = TCString;        [[NSUserDefaults standardUserDefaults] synchronize];        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                                [self fireEvent:@"" event:@"on.getIabTfc" withData:nil];    } else {        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                                }    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                        }- (void)consentReset:(CDVInvokedUrlCommand*)command {
                            CDVPluginResult *pluginResult;
                            NSString *callbackId = command.callbackId;
                            @try {
                                [[UMPConsentInformation sharedInstance] reset];
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                            }@catch (NSException *exception) {
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
                            }
                            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                        }- (void)setPublisherFirstPartyIDEnabled:(BOOL)enabled{};- (void)globalSettings:(CDVInvokedUrlCommand*)command {
                            CDVPluginResult *pluginResult;
                            NSString *callbackId = command.callbackId;
                            BOOL setAppMuted = [[command argumentAtIndex:0] boolValue];
                            float setAppVolume = [[command argumentAtIndex:1] floatValue];
                            BOOL publisherFirstPartyIdEnabled = [[command argumentAtIndex:3] boolValue];
                            NSString* npa = [command.arguments objectAtIndex:2];
                            BOOL enableCollapsible = [[command argumentAtIndex:3] boolValue];
                            BOOL responseInfo = [[command argumentAtIndex:4] boolValue];
                            @try {
                                GADMobileAds.sharedInstance.applicationVolume = setAppVolume;
                                GADMobileAds.sharedInstance.applicationMuted = setAppMuted;
                                [self setPublisherFirstPartyIDEnabled:publisherFirstPartyIdEnabled];
                                Npa = npa;
                                EnableCollapsible = enableCollapsible;
                                ResponseInfo = responseInfo;
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                            }@catch (NSException *exception) {
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
                            }
                            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                        }- (void)targeting:(CDVInvokedUrlCommand*)command {
                            CDVPluginResult *pluginResult;
                            NSString *callbackId = command.callbackId;
                            NSNumber *childDirectedTreatment = [command argumentAtIndex:0];
                            NSNumber *underAgeOfConsent = [command argumentAtIndex:1];
                            NSString *contentRating = [command argumentAtIndex:2];
                            @try {
                                GADRequestConfiguration *requestConfiguration = GADMobileAds.sharedInstance.requestConfiguration;
                                requestConfiguration.tagForChildDirectedTreatment = childDirectedTreatment;
                                requestConfiguration.tagForUnderAgeOfConsent = underAgeOfConsent;
                                requestConfiguration.maxAdContentRating = contentRating;
                                UnderAgeOfConsent = underAgeOfConsent;
                            }@catch (NSException *exception) {
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
                            }    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];}- (GADAdSize)__AdSizeFromString:(NSString *)size
{
    if ([size isEqualToString:@"ANCHORED"]) {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(adWidth);
    } else if ([size isEqualToString:@"IN_LINE"]) {
        return  GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(adWidth);
    } else if ([size isEqualToString:@"BANNER"]) {
        return GADAdSizeBanner;
    } else if ([size isEqualToString:@"LARGE_BANNER"]) {
        return GADAdSizeLargeBanner;
    } else if ([size isEqualToString:@"FULL_BANNER"]) {
        return GADAdSizeFullBanner;
    } else if ([size isEqualToString:@"LEADERBOARD"]) {
        return GADAdSizeLeaderboard;
    }  else {
        return GADAdSizeBanner;
    }
}- (void)loadBannerAd:(CDVInvokedUrlCommand*)command {
    if(self.bannerView) {
        NSLog(@"Admob banner has been initing");
        return;
    }
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;    adFormat = 3;    if (adFormat == 3) {        UIView *parentView = [self.webView superview];        NSString* adUnitId = [command.arguments objectAtIndex:0];
        // NSNumber* x = [command.arguments objectAtIndex:1];
        //  NSNumber* y = [command.arguments objectAtIndex:2];
        NSString* position = [command.arguments objectAtIndex:1];
        NSString* size = [command.arguments objectAtIndex:2];        NSString* collapsible = [command.arguments objectAtIndex:3];
        NSNumber* adaptive_Width = [command.arguments objectAtIndex:4];
        BOOL autoShow = [[command argumentAtIndex:5] boolValue];
        auto_Show = autoShow;
        int intValue = [adaptive_Width intValue];
        adWidth = intValue;
        Position = position;
        //  float posX = [x floatValue];
        //   float posY = [y floatValue];
        GADAdSize sizes = [self __AdSizeFromString:size];        //  CGPoint origin = CGPointMake(posX,posY);
        self.bannerView = [[GADBannerView alloc]
    initWithAdSize:sizes];        GADRequest *request = [GADRequest request];
        GADExtras *extras = [[GADExtras alloc] init];
        if (EnableCollapsible){
            extras.additionalParameters = @{@"collapsible" : collapsible};
        }
        extras.additionalParameters = @{@"npa": Npa};
        [request registerAdNetworkExtras:extras];
        self.bannerView.adUnitID = adUnitId;
        self.bannerView.rootViewController = self.viewController;
        self.bannerView.delegate = self;
        [self.bannerView loadRequest:request];
        self.bannerView.hidden = YES;
        [parentView addSubview:self.bannerView];
        [parentView bringSubviewToFront:self.bannerView];        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        NSLog(@"Admob Option invalid for banner");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}- (void)showBannerAd:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    if(self.bannerView) {
        self.bannerView.hidden = NO;        [self addBannerViewToView:command];        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        [self fireEvent:@"" event:@"on.banner.failed.show" withData:nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}- (void)addBannerViewToView:(CDVInvokedUrlCommand*)command{    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.viewController.view addSubview:bannerView];
    if ([Position isEqualToString:@"bottom-center"]){
        [self.viewController.view addConstraints:@[
            [NSLayoutConstraint constraintWithItem:bannerView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.viewController.view.safeAreaLayoutGuide
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0            ],
            [NSLayoutConstraint constraintWithItem:bannerView
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.viewController.view
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:1
                                          constant:0]
        ]];
    } else {
        [self.viewController.view addConstraints:@[
            [NSLayoutConstraint constraintWithItem:bannerView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.viewController.view.safeAreaLayoutGuide
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:bannerView
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.viewController.view
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:1
                                          constant:0]
        ]];
    }}- (void)hideBannerAd:(CDVInvokedUrlCommand*)command {
        CDVPluginResult *pluginResult;
        NSString *callbackId = command.callbackId;
        if(self.bannerView) {
            self.bannerView.hidden = YES;
            [self fireEvent:@"" event:@"on.banner.hide" withData:nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }- (void)removeBannerAd:(CDVInvokedUrlCommand*)command {
        CDVPluginResult *pluginResult;
        NSString *callbackId = command.callbackId;
        if(self.bannerView) {
            self.bannerView.hidden = YES;
            [self.bannerView removeFromSuperview];
            self.bannerView = nil;
            [self fireEvent:@"" event:@"on.banner.remove" withData:nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];}- (void)loadAppOpenAd:(CDVInvokedUrlCommand *)command {
            CDVPluginResult *pluginResult;
            NSString *callbackId = command.callbackId;
            NSString* adUnitId = [command.arguments objectAtIndex:0];
            BOOL autoShow = [[command argumentAtIndex:1] boolValue];
            auto_Show = autoShow;
            adFormat = 1;
            self.appOpenAd = nil;
            if (adFormat == 1){
                GADRequest *request = [GADRequest request];
                GADExtras *extras = [[GADExtras alloc] init];
                extras.additionalParameters = @{@"npa": Npa};
                [request registerAdNetworkExtras:extras];
                [GADAppOpenAd loadWithAdUnitID:adUnitId
                                       request:request
                                   orientation:UIInterfaceOrientationPortrait
                             completionHandler:^(GADAppOpenAd *ad, NSError *error) {
                    if (error) {
                        [self fireEvent:@"" event:@"on.appOpenAd.failed.loaded" withData:nil];
                        NSLog(@"Failed to load App Open Ad ad with error: %@", [error localizedDescription]);                return;
                    }
                    self.appOpenAd = ad;
                    self.appOpenAd.fullScreenContentDelegate = self;
                    [self fireEvent:@"" event:@"on.appOpenAd.loaded" withData:nil];
                    if (auto_Show){                if (self.appOpenAd && [self.appOpenAd
                                                                          canPresentFromRootViewController:self.viewController
                                                                          error:nil]) { [self.appOpenAd presentFromRootViewController:self.viewController];                } else {
                        [self fireEvent:@"" event:@"on.appOpenAd.failed.show" withData:nil];
                    }}
                }];        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];}- (void)showAppOpenAd:(CDVInvokedUrlCommand *)command {
                CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                if (self.appOpenAd && [self.appOpenAd
                                       canPresentFromRootViewController:self.viewController
                                       error:nil]) { [self.appOpenAd presentFromRootViewController:self.viewController];        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    } else {        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                    [self fireEvent:@"" event:@"on.appOpenAd.failed.show" withData:nil];
                }
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }- (void)loadInterstitialAd:(CDVInvokedUrlCommand *)command {
                CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                NSString* adUnitId = [command.arguments objectAtIndex:0];
                BOOL autoShow = [[command argumentAtIndex:1] boolValue];
                auto_Show = autoShow;
                adFormat = 2;
                if (adFormat == 2){
                    GADRequest *request = [GADRequest request];
                    [GADInterstitialAd
                     loadWithAdUnitID:adUnitId
                     request:request
                     completionHandler:^(GADInterstitialAd *ad, NSError *error) {
                        if (error) {                NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
                            // [self fireEvent:@"" event:@"on.interstitial.failed.load" withData:nil];                return;
                        }            self.interstitial = ad;
                        self.interstitial.fullScreenContentDelegate = self;
                        [self fireEvent:@"" event:@"on.interstitial.loaded" withData:nil];            if (auto_Show){                if (self.interstitial && [self.interstitial
                                                                                                                                                               canPresentFromRootViewController:self.viewController error:nil]) {                    [self.interstitial presentFromRootViewController:self.viewController];                } else {                    [self fireEvent:@"" event:@"on.interstitial.failed.show" withData:nil];
                        }            }        }];
                }    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }- (void)showInterstitialAd:(CDVInvokedUrlCommand *)command {
                CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                if (self.interstitial && [self.interstitial
                                          canPresentFromRootViewController:self.viewController error:nil]) {        [self.interstitial presentFromRootViewController:self.viewController];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                    [self fireEvent:@"" event:@"on.interstitial.failed.show" withData:nil];
                }    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }- (void)loadRewardedInterstitialAd:(CDVInvokedUrlCommand*)command {    CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                NSString* adUnitId = [command.arguments objectAtIndex:0];
                BOOL autoShow = [[command argumentAtIndex:1] boolValue];
                auto_Show = autoShow;
                adFormat = 4;
                if (adFormat == 4){        GADRequest *request = [GADRequest request];
                    [GADRewardedInterstitialAd
                     loadWithAdUnitID:adUnitId
                     request:request
                     completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
                        if (error) {
                            NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
                            return;
                        }
                        self.rewardedInterstitialAd = ad;            isAdSkip = 1;
                        NSLog(@"Rewarded ad loaded.");
                        self.rewardedInterstitialAd.fullScreenContentDelegate = self;
                        [self fireEvent:@"" event:@"on.rewardedInt.loaded" withData:nil];            if (auto_Show){                if (self.rewardedInterstitialAd && [self.rewardedInterstitialAd canPresentFromRootViewController:self.viewController error:nil]) {                    [self.rewardedInterstitialAd presentFromRootViewController:self.viewController
                                                                                                                                                                                                                                                                                                                            userDidEarnRewardHandler:^{
                            GADAdReward *reward =
                            self.rewardedInterstitialAd.adReward;
                            [self fireEvent:@"" event:@"on.rewardedInt.userEarnedReward" withData:nil];
                            isAdSkip = 2;
                            NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with "
                                                       @"currency %@ , amount %ld",
                                                       reward.type, [reward.amount longValue]];
                            NSLog(@"%@", rewardMessage);                    }];                } else {                    [self fireEvent:@"" event:@"on.rewardedInt.failed.show" withData:nil];
                            }            }        }];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }-(void)showRewardedInterstitialAd:(CDVInvokedUrlCommand *)command {
                CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                if (self.rewardedInterstitialAd && [self.rewardedInterstitialAd canPresentFromRootViewController:self.viewController error:nil]) {        [self.rewardedInterstitialAd presentFromRootViewController:self.viewController
                                                                                                                                                                                            userDidEarnRewardHandler:^{
                    GADAdReward *reward =
                    self.rewardedInterstitialAd.adReward;
                    [self fireEvent:@"" event:@"on.rewardedInt.userEarnedReward" withData:nil];
                    isAdSkip = 2;
                    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with "
                                               @"currency %@ , amount %ld",
                                               reward.type, [reward.amount longValue]];
                    NSLog(@"%@", rewardMessage);        }];        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    } else {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                        [self fireEvent:@"" event:@"on.rewardedInt.failed.show" withData:nil];
                    }    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }- (void)loadRewardedAd:(CDVInvokedUrlCommand*)command {    CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                NSString* adUnitId = [command.arguments objectAtIndex:0];
                BOOL autoShow = [[command argumentAtIndex:1] boolValue];
                auto_Show = autoShow;
                adFormat = 3;
                if (adFormat == 3){
                    GADRequest *request = [GADRequest request];
                    [GADRewardedAd
                     loadWithAdUnitID:adUnitId
                     request:request
                     completionHandler:^(GADRewardedAd *ad, NSError *error) {
                        if (error) {
                            NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
                            return;
                        }
                        self.rewardedAd = ad;
                        NSLog(@"Rewarded ad loaded.");
                        isAdSkip = 0;
                        self.rewardedAd.fullScreenContentDelegate = self;
                        [self fireEvent:@"" event:@"on.rewarded.loaded" withData:nil];            if (auto_Show){                if (self.rewardedAd && [self.rewardedAd canPresentFromRootViewController:self.viewController error:nil]) {                    [self.rewardedAd presentFromRootViewController:self.viewController
                                                                                                                                                                                                                                                                                     userDidEarnRewardHandler:^{
                            GADAdReward *reward =
                            self.rewardedAd.adReward;
                            [self fireEvent:@"" event:@"on.reward.userEarnedReward" withData:nil];
                            isAdSkip = 2;
                            NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]];
                            NSLog(@"%@", rewardMessage);                    }];                } else {                    [self fireEvent:@"" event:@"on.rewarded.failed.show" withData:nil];
                            }            }        }];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }-(void)showRewardedAd:(CDVInvokedUrlCommand *)command {
                CDVPluginResult *pluginResult;
                NSString *callbackId = command.callbackId;
                if (self.rewardedAd && [self.rewardedAd canPresentFromRootViewController:self.viewController error:nil]) {        [self.rewardedAd presentFromRootViewController:self.viewController
                                                                                                                                                        userDidEarnRewardHandler:^{
                    GADAdReward *reward =
                    self.rewardedAd.adReward;
                    [self fireEvent:@"" event:@"on.reward.userEarnedReward" withData:nil];
                    isAdSkip = 2;
                    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]];
                    NSLog(@"%@", rewardMessage);        }];        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    } else {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                        [self fireEvent:@"" event:@"on.rewarded.failed.show" withData:nil];
                    }    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }- (void) fireEvent:(NSString *)obj event:(NSString *)eventName withData:(NSString *)jsonStr {
                NSString* js;
                if(obj && [obj isEqualToString:@"window"]) {
                    js = [NSString stringWithFormat:@"var evt=document.createEvent(\"UIEvents\");evt.initUIEvent(\"%@\",true,false,window,0);window.dispatchEvent(evt);", eventName];
                } else if(jsonStr && [jsonStr length]>0) {
                    js = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@',%@);", eventName, jsonStr];
                } else {
                    js = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@');", eventName];
                }
                [self.commandDelegate evalJs:js];
            }
#pragma mark GADBannerViewDelegate implementation
-(void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.load" withData:nil];
    NSLog(@"bannerViewDidReceiveAd");
    if (auto_Show){
        if(self.bannerView) {
            [self addBannerViewToView:command];
            self.bannerView.hidden = NO;
        }
    } else {        [self fireEvent:@"" event:@"on.banner.failed.show" withData:nil];
    }}- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
        [self fireEvent:@"" event:@"on.banner.failed.load" withData:nil];
        NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    }- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
        [self fireEvent:@"" event:@"on.banner.impression" withData:nil];
        NSLog(@"bannerViewDidRecordImpression");
    }- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
        [self fireEvent:@"" event:@"on.banner.open" withData:nil];
        NSLog(@"bannerViewWillPresentScreen");
    }- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
        [self fireEvent:@"" event:@"on.banner.close" withData:nil];
        NSLog(@"bannerViewWillDismissScreen");
    }- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
        [self fireEvent:@"" event:@"on.banner.did.dismiss" withData:nil];
        NSLog(@"bannerViewDidDismissScreen");
    }
#pragma GADFullScreeContentDelegate implementation
- (void)adWillPresentFullScreenContent:(id)ad {    if (adFormat == 1){        [self fireEvent:@"" event:@"on.appOpenAd.show" withData:nil];
    NSLog(@"Ad will present full screen content App Open Ad.");    } else if (adFormat == 2){        [self fireEvent:@"" event:@"on.interstitial.show" withData:nil];
        [self fireEvent:@"" event:@"onPresentAd" withData:nil];
        NSLog(@"Ad will present full screen content interstitial.");    } else if (adFormat == 3) {        [self fireEvent:@"" event:@"on.rewarded.show" withData:nil];
            isAdSkip = 1;
            NSLog(@"Ad will present full screen content rewarded.");    } else if (adFormat == 4) {
                isAdSkip = 1;
                [self fireEvent:@"" event:@"on.rewardedInt.showed" withData:nil];
                NSLog(@"Ad will present full screen content interstitial rewarded.");
            }}- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {    if (adFormat == 1){        [self fireEvent:@"" event:@"on.appOpenAd.failed.loaded" withData:nil];
                NSLog(@"Ad failed to present full screen content with error App Open Ad %@.", [error localizedDescription]);    } else if (adFormat == 2){
                    [self fireEvent:@"" event:@"on.interstitial.failed.load" withData:nil];
                    NSLog(@"Ad failed to present full screen content with error interstitial %@.", [error localizedDescription]);
                } else if (adFormat == 3) {        [self fireEvent:@"" event:@"on.rewarded.failed.load" withData:nil];
                    NSLog(@"Ad failed to present full screen content with error rewarded %@.", [error localizedDescription]);    } else if (adFormat == 4) {        [self fireEvent:@"" event:@"on.rewardedInt.failed.load" withData:nil];
                        NSLog(@"Ad failed to present full screen content with error interstitial rewarded %@.", [error localizedDescription]);    }}- (void)adDidDismissFullScreenContent:(id)ad {    if (adFormat == 1){        [self fireEvent:@"" event:@"on.appOpenAd.dismissed" withData:nil];
                            NSLog(@"Ad did dismiss full screen content App Open Ad.");    } else if (adFormat == 2){
                                [self fireEvent:@"" event:@"on.interstitial.dismissed" withData:nil];
                                NSLog(@"Ad did dismiss full screen content interstitial.");
                            } else if (adFormat == 3) {        [self fireEvent:@"" event:@"on.rewarded.dismissed" withData:nil];        if (isAdSkip != 2) {
                                [self fireEvent:@"" event:@"on.rewarded.ad.skip" withData:nil];
                            }
                                NSLog(@"Ad did dismiss full screen content rewarded.");    } else if (adFormat == 4) {
                                    if (isAdSkip != 2) {
                                        [self fireEvent:@"" event:@"on.rewardedInt.ad.skip" withData:nil];
                                    }
                                    [self fireEvent:@"" event:@"on.rewardedInt.dismissed" withData:nil];
                                    NSLog(@"Ad did dismiss full screen content interstitial rewarded.");    }}
#pragma mark Cleanup
- (void)dealloc {
    self.appOpenAd = nil;
    self.bannerView = nil;
    self.interstitial = nil;
    self.rewardedAd = nil;
    self.rewardedInterstitialAd = nil;
}
@end
