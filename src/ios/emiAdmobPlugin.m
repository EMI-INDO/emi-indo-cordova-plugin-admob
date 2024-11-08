#import "emiAdmobPlugin.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
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
// int fromStatus = 0; // Deprecated
int Consent_Status = 0;
int adFormat = 0;
int adWidth = 320; // Default
BOOL auto_Show = NO;
// NSString *Npa = @"1"; // Deprecated
NSString *Position = @"bottom"; // Default
NSString *bannerSaveAdUnitId = @""; // autoResize dependency = true

BOOL enableCollapsible = NO;
BOOL isAutoResize = NO;

int isAdSkip = 0;
BOOL isIAB = NO;
BOOL UnderAgeOfConsent = NO;
BOOL isPrivacyOptions = NO;
BOOL isDebugGeography = NO;
BOOL ResponseInfo = NO;
BOOL isUsingAdManagerRequest = YES;

- (BOOL)canRequestAds {
  return UMPConsentInformation.sharedInstance.canRequestAds;
}
- (void)setUsingAdManagerRequest:(BOOL)value {
  isUsingAdManagerRequest = value;
}
- (void)ResponseInfo:(BOOL)value {
  ResponseInfo = value;
}
- (void)isDebugGeography:(BOOL)value {
  isDebugGeography = value;
}
- (void)initialize:(CDVInvokedUrlCommand *)command {

  NSDictionary *options = [command.arguments objectAtIndex:0];

  BOOL setAdRequest = [[options valueForKey:@"isUsingAdManagerRequest"] boolValue];
  BOOL responseInfo = [[options valueForKey:@"isResponseInfo"] boolValue];
  BOOL setDebugGeography = [[options valueForKey:@"isConsentDebug"] boolValue];

  [self setUsingAdManagerRequest:setAdRequest];
  [self ResponseInfo:responseInfo];
  [self isDebugGeography:setDebugGeography];

  __block CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
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


- (void)requestIDFA:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  if (@available(iOS 14, *)) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(
                             ATTrackingManagerAuthorizationStatus status) {
        if (status == ATTrackingManagerAuthorizationStatusDenied) {
          idfaStatus = ATTrackingManagerAuthorizationStatusDenied;
        } else if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
          idfaStatus = ATTrackingManagerAuthorizationStatusAuthorized;
        } else if (status == ATTrackingManagerAuthorizationStatusRestricted) {
          idfaStatus = ATTrackingManagerAuthorizationStatusRestricted;
        } else if (status ==
                   ATTrackingManagerAuthorizationStatusNotDetermined) {
          idfaStatus = ATTrackingManagerAuthorizationStatusNotDetermined;
        }
      }];
    });
    [self fireEvent:@""
              event:@"on."
                    @"getI"
                    @"DFA."
                    @"stat"
                    @"us"
           withData:nil];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                        messageAsInt:idfaStatus];
  } else {
    [self fireEvent:@""
              event:@"on."
                    @"getI"
                    @"DFA."
                    @"erro"
                    @"r"
           withData:nil];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}
/*
- (void)getConsentRequest:(CDVInvokedUrlCommand *)command {
}
*/
- (void)startGoogleMobileAdsSDK {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Initialize the Google Mobile Ads SDK.
    GADMobileAds *ads = [GADMobileAds sharedInstance];
    [ads startWithCompletionHandler:^(GADInitializationStatus *status) {
      NSDictionary *adapterStatuses = [status adapterStatusesByClassName];
      NSMutableArray *adaptersArray = [NSMutableArray array];

      for (NSString *adapter in adapterStatuses) {
        GADAdapterStatus *adapterStatus = adapterStatuses[adapter];
        NSLog(@"Adapter Name: %@, Description: %@, Latency: %f", adapter,
              adapterStatus.description, adapterStatus.latency);

        NSDictionary *adapterInfo = @{@"name" : adapter};

        [adaptersArray addObject:adapterInfo];
      }

      NSString *sdkVersion = GADGetStringFromVersionNumber(
          GADMobileAds.sharedInstance.versionNumber);
      int Consent_Status =
          (int)UMPConsentInformation.sharedInstance.consentStatus;

      NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      NSNumber *CmpSdkID = [prefs valueForKey:@"IABTCF_CmpSdkID"];
      NSString *gdprApplies = [prefs stringForKey:@"IABTCF_gdprApplies"];
      NSString *PurposeConsents =
          [prefs stringForKey:@"IABTCF_PurposeConsents"];
      NSString *TCString = [prefs stringForKey:@"IABTCF_TCString"];
      NSString *additionalConsent = [prefs stringForKey:@"IABTCF_AddtlConsent"];

      result[@"version"] = sdkVersion;
      result[@"consentStatus"] = @(Consent_Status);
      result[@"adapter"] = adaptersArray;
      result[@"CmpSdkID"] = CmpSdkID;
      result[@"gdprApplies"] = gdprApplies;
      result[@"PurposeConsents"] = PurposeConsents;
      result[@"TCString"] = TCString;
      result[@"additionalConsent"] = additionalConsent;

      // NSLog(@"Result dictionary: %@", result);consentStatus

      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result
                                                         options:0
                                                           error:&error];

      if (!jsonData) {
        NSLog(@"Error converting result to JSON: %@",
              error.localizedDescription);
      } else {
        NSString *jsonString =
            [[NSString alloc] initWithData:jsonData
                                  encoding:NSUTF8StringEncoding];

        // NSLog(@"JSON String: %@", jsonString);

        [self fireEvent:@"" event:@"on.sdkInitialization" withData:jsonString];
      }

      [prefs synchronize];
    }];
  });
}

- (void)forceDisplayPrivacyForm:(CDVInvokedUrlCommand *)command {
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
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }

            [UMPConsentForm loadAndPresentIfRequiredFromViewController:self.viewController completionHandler:^(NSError *loadAndPresentError) {
                if (loadAndPresentError) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:loadAndPresentError.description];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    [UMPConsentForm presentPrivacyOptionsFormFromViewController:self.viewController completionHandler:^(NSError *_Nullable formError) {
                        if (formError) {
                            // NSLog(@"Error when displaying the form: %@", formError);
                        }
                    }];
                }
            }];
        }];
    });
}

- (void)showPrivacyOptionsForm:(CDVInvokedUrlCommand *)command {
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
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }

            [UMPConsentForm loadAndPresentIfRequiredFromViewController:self.viewController completionHandler:^(NSError *loadAndPresentError) {
                if (loadAndPresentError) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:loadAndPresentError.description];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }];

            if ([self isPrivacyOptionsRequired]) {
                [self privacyOptionsFormShow:command];
            } else {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"The privacy option form is not required."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    });
}


- (void)privacyOptionsFormShow:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UMPConsentForm presentPrivacyOptionsFormFromViewController:self.viewController completionHandler:^(NSError *_Nullable formError) {
                if (formError) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:formError.description];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }];
        });
    }];
}



- (BOOL)isPrivacyOptionsRequired {
  UMPPrivacyOptionsRequirementStatus status = UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus;
  // NSLog(@"[isPrivacyOptionsRequired] Privacy option status: %ld",
  // (long)status);
  return status == UMPPrivacyOptionsRequirementStatusRequired;
}

- (void)readStatus:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    Consent_Status = (int)UMPConsentInformation.sharedInstance.consentStatus;

    if (Consent_Status == UMPConsentStatusUnknown) {

      Consent_Status = UMPConsentStatusUnknown;
    } else if (Consent_Status == UMPConsentStatusRequired) {

      Consent_Status = UMPConsentStatusRequired;
    } else if (Consent_Status == UMPConsentStatusNotRequired) {

      Consent_Status = UMPConsentStatusNotRequired;
    } else if (Consent_Status == UMPConsentStatusObtained) {

      Consent_Status = UMPConsentStatusObtained;
    }

  /*  NSLog(@"The Consent "
          @"Status %i",
          Consent_Status); */
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                             messageAsInt:Consent_Status];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
  }];
}

- (void)getIabTfc:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    if (isIAB == 1) {
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
        
        NSLog(@"%@", [prefs dictionaryRepresentation]);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [self fireEvent:@"" event:@"onGetIabTfc" withData:nil];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)consentReset:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  @try {
    [[UMPConsentInformation sharedInstance] reset];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } @catch (NSException *exception) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                     messageAsString:exception.reason];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)globalSettings:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  NSDictionary *options = [command.arguments objectAtIndex:0];
  BOOL setAppMuted = [[options valueForKey:@"setAppMuted"] boolValue];
  BOOL setAppVolume = [[options valueForKey:@"setAppVolume"] boolValue];
  BOOL pubIdEnabled = [[options valueForKey:@"pubIdEnabled"] boolValue];
  @try {
    GADMobileAds.sharedInstance.applicationVolume = setAppVolume;
    GADMobileAds.sharedInstance.applicationMuted = setAppMuted;
    [GADMobileAds.sharedInstance.requestConfiguration
        setPublisherFirstPartyIDEnabled:pubIdEnabled];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } @catch (NSException *exception) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                     messageAsString:exception.reason];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)targeting:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  NSDictionary *options = [command.arguments objectAtIndex:0];
  BOOL childDirectedTreatment =
      [[options valueForKey:@"childDirectedTreatment"] boolValue];
  BOOL underAgeOfConsent =
      [[options valueForKey:@"underAgeOfConsent"] boolValue];
  NSString *contentRating = [options valueForKey:@"contentRating"];
  @try {
    GADRequestConfiguration *requestConfiguration =
        GADMobileAds.sharedInstance.requestConfiguration;
    requestConfiguration.tagForChildDirectedTreatment =
        @(childDirectedTreatment);
    requestConfiguration.tagForUnderAgeOfConsent = @(underAgeOfConsent);

    if (contentRating != nil) {
      if ([contentRating isEqualToString:@"G"]) {
        requestConfiguration.maxAdContentRating = GADMaxAdContentRatingGeneral;
      } else if ([contentRating isEqualToString:@"PG"]) {
        requestConfiguration.maxAdContentRating =
            GADMaxAdContentRatingParentalGuidance;
      } else if ([contentRating isEqualToString:@"T"]) {
        requestConfiguration.maxAdContentRating = GADMaxAdContentRatingTeen;
      } else if ([contentRating isEqualToString:@"MA"]) {
        requestConfiguration.maxAdContentRating =
            GADMaxAdContentRatingMatureAudience;
      } else {
        // NSLog(@"Unknown content rating: %@", contentRating);
      }
    }

    UnderAgeOfConsent = underAgeOfConsent;

  } @catch (NSException *exception) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                     messageAsString:exception.reason];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)pluginInitialize {
  [super pluginInitialize];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(orientationDidChange:)
             name:UIDeviceOrientationDidChangeNotification
           object:nil];

  isIAB = YES;
  NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSNumber *CmpSdkID = [prefs valueForKey:@"IABTCF"
                                          @"_CmpSd"
                                          @"kID"];
  NSString *gdprApplies = [prefs stringForKey:@"IABTCF"
                                              @"_gdprA"
                                              @"pplie"
                                              @"s"];
  NSString *PurposeConsents = [prefs stringForKey:@"IABTCF"
                                                  @"_Purpo"
                                                  @"seCons"
                                                  @"ents"];
  NSString *TCString = [prefs stringForKey:@"IABTCF"
                                           @"_TCStr"
                                           @"ing"];
  result[@"IABTCF_"
         @"CmpSdkID"] = CmpSdkID;
  result[@"IABTCF_"
         @"gdprApplies"] = gdprApplies;
  result[@"IABTCF_"
         @"PurposeCons"
         @"ents"] = PurposeConsents;
  result[@"IABTCF_"
         @"TCString"] = TCString;
  // NSLog(@"%@",
  //   [[NSUserDefaults
  //   standardUserDefaults]
  //   dictionaryRepresentation]);
  [prefs synchronize];
}

- (void)orientationDidChange:(NSNotification *)notification {
  // NSLog(@"Orientation changed");
  [self fireEvent:@"" event:@"on.screen.rotated" withData:nil];
  if (isAutoResize) {
    dispatch_async(dispatch_get_main_queue(), ^{
      @try {

        if (self.bannerView) {
          UIView *parentView = self.bannerView.superview;
          if (parentView != nil) {
            [self.bannerView removeFromSuperview];
          }
        }

        self.bannerViewLayout = [[UIView alloc] initWithFrame:CGRectZero];
        self.bannerViewLayout.translatesAutoresizingMaskIntoConstraints = NO;

        UIView *rootView = self.viewController.view;
        if ([rootView isKindOfClass:[UIView class]]) {
          [rootView addSubview:self.bannerViewLayout];

          [self.bannerViewLayout.topAnchor
              constraintEqualToAnchor:rootView.topAnchor]
              .active = YES;
          [self.bannerViewLayout.leadingAnchor
              constraintEqualToAnchor:rootView.leadingAnchor]
              .active = YES;
          [self.bannerViewLayout.trailingAnchor
              constraintEqualToAnchor:rootView.trailingAnchor]
              .active = YES;
          [self.bannerViewLayout.heightAnchor constraintEqualToConstant:50]
              .active = YES;
        }

        self.bannerView = [[GADBannerView alloc]
            initWithAdSize:
                GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(
                    rootView.frame.size.width)];
        self.bannerView.adUnitID = bannerSaveAdUnitId;
        self.bannerView.delegate = self;
        [self.bannerView loadRequest:[GADRequest request]];

        [self.bannerViewLayout addSubview:self.bannerView];
        [self.bannerViewLayout bringSubviewToFront:self.bannerView];

      } @catch (NSException *exception) {
        // NSLog(@"Error adjusting banner size: %@", exception.reason);
        // PUBLIC_CALLBACKS.error([NSString stringWithFormat:@"Error adjusting
        // banner size: %@", exception.reason]);
      }
    });
  }
}

- (void)addBannerConstraints {
  self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;

  // Tambahkan constraint berdasarkan posisi
  if ([Position isEqualToString:@"bottom-center"]) {
    [self.viewController.view addConstraints:@[
      [NSLayoutConstraint
          constraintWithItem:self.bannerView
                   attribute:NSLayoutAttributeBottom
                   relatedBy:NSLayoutRelationEqual
                      toItem:self.viewController.view.safeAreaLayoutGuide
                   attribute:NSLayoutAttributeBottom
                  multiplier:1
                    constant:0],
      [NSLayoutConstraint constraintWithItem:self.bannerView
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:self.viewController.view
                                   attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                    constant:0]
    ]];
  } else if ([Position isEqualToString:@"top-center"]) {
    [self.viewController.view addConstraints:@[
      [NSLayoutConstraint
          constraintWithItem:self.bannerView
                   attribute:NSLayoutAttributeTop
                   relatedBy:NSLayoutRelationEqual
                      toItem:self.viewController.view.safeAreaLayoutGuide
                   attribute:NSLayoutAttributeTop
                  multiplier:1
                    constant:0],
      [NSLayoutConstraint constraintWithItem:self.bannerView
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:self.viewController.view
                                   attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                    constant:0]
    ]];
  }
}

- (void)loadBannerAd:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  adFormat = 3;
  NSDictionary *options = [command.arguments objectAtIndex:0];
  NSString *adUnitId = [options valueForKey:@"adUnitId"];
  NSString *position = [options valueForKey:@"position"];
  NSString *collapsible = [options valueForKey:@"collapsible"];
  BOOL autoResize = [[options valueForKey:@"autoResize"] boolValue];
  NSString *size = [options valueForKey:@"size"];
  BOOL autoShow = [[options valueForKey:@"autoShow"] boolValue];

  bannerSaveAdUnitId = adUnitId;

  if (adUnitId == nil || [adUnitId length] == 0) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                     messageAsString:@"Ad unit ID is required"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    return;
  }

  if (collapsible != nil && [collapsible length] > 0) {
    enableCollapsible = YES;
  } else {
    enableCollapsible = NO;
  }

  if (autoResize) {

    isAutoResize = YES;
  }

  if (adFormat == 3) {
    dispatch_async(dispatch_get_main_queue(), ^{
      UIView *parentView = [self.webView superview];
      CGRect frame = self.bannerView.frame;

      if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = self.bannerView.safeAreaInsets;
        frame = UIEdgeInsetsInsetRect(frame, safeAreaInsets);
      }

      self.viewWidth = frame.size.width;

      auto_Show = autoShow;
      adWidth = self.viewWidth;

      Position = position;

      GADAdSize sizes = [self __AdSizeFromString:size];
      self.bannerView = [[GADBannerView alloc] initWithAdSize:sizes];

      GADRequest *request = [GADRequest request];
      GADExtras *extras = [[GADExtras alloc] init];

      if (enableCollapsible) {
        extras.additionalParameters = @{@"collapsible" : collapsible};
      }

      [request registerAdNetworkExtras:extras];

      self.bannerView.adUnitID = adUnitId;
      self.bannerView.rootViewController = self.viewController;
      self.bannerView.delegate = self;
      [self.bannerView loadRequest:request];
      self.bannerView.hidden = YES;
      [parentView addSubview:self.bannerView];
      [parentView bringSubviewToFront:self.bannerView];
    });

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    //  NSLog(@"Admob Option invalid for banner");
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }

  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (GADAdSize)__AdSizeFromString:(NSString *)size {

  if (self.viewWidth == 0) {
    self.viewWidth = [UIScreen mainScreen].bounds.size.width;
  }

  if ([size isEqualToString:@"responsive_adaptive"]) {
    return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(
        self.viewWidth);
  } else if ([size isEqualToString:@"in_line_adaptive"]) {
    return GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(
        self.viewWidth);
  } else if ([size isEqualToString:@"banner"]) {
    return GADAdSizeBanner;
  } else if ([size isEqualToString:@"large_banner"]) {
    return GADAdSizeLargeBanner;
  } else if ([size isEqualToString:@"full_banner"]) {
    return GADAdSizeFullBanner;
  } else if ([size isEqualToString:@"leaderboard"]) {
    return GADAdSizeLeaderboard;
  } else {
    return GADAdSizeBanner;
  }
}

- (void)showBannerAd:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  if (self.bannerView) {
    self.bannerView.hidden = NO;
    [self addBannerViewToView:command];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    [self fireEvent:@""
              event:@"on."
                    @"bann"
                    @"er."
                    @"fail"
                    @"ed."
                    @"show"
           withData:nil];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)addBannerViewToView:(CDVInvokedUrlCommand *)command {
  bannerView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.viewController.view addSubview:bannerView];
  if ([Position isEqualToString:@"bottom-center"]) {
    [self.viewController.view addConstraints:@[
      [NSLayoutConstraint
          constraintWithItem:bannerView
                   attribute:NSLayoutAttributeBottom
                   relatedBy:NSLayoutRelationEqual
                      toItem:self.viewController.view.safeAreaLayoutGuide
                   attribute:NSLayoutAttributeBottom
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
  } else if ([Position isEqualToString:@"top-center"]) {

    [self.viewController.view addConstraints:@[
      [NSLayoutConstraint
          constraintWithItem:bannerView
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

  } else {
    [self.viewController.view addConstraints:@[
      [NSLayoutConstraint
          constraintWithItem:bannerView
                   attribute:NSLayoutAttributeBottom
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
  }
}
- (void)hideBannerAd:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  if (self.bannerView) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.bannerView.hidden = YES;
      [self fireEvent:@"" event:@"on.banner.hide" withData:nil];
    });
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}
- (void)removeBannerAd:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  if (self.bannerView) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.bannerView.hidden = YES;
      [self.bannerView removeFromSuperview];
      self.bannerView = nil;
      [self fireEvent:@"" event:@"on.banner.remove" withData:nil];
    });
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}
- (void)loadAppOpenAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    BOOL autoShow = [[options valueForKey:@"autoShow"] boolValue];
    
    auto_Show = autoShow;
    adFormat = 1;
    self.appOpenAd = nil;
    
    if (adFormat == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GADRequest *request = [GADRequest request];
            GADExtras *extras = [[GADExtras alloc] init];
            [request registerAdNetworkExtras:extras];
            
            [GADAppOpenAd loadWithAdUnitID:adUnitId request:request completionHandler:^(GADAppOpenAd *ad, NSError *error) {
                if (error) {
                    // Send load error to event
                    NSDictionary *errorData = @{@"error": error.localizedDescription ?: @"Unknown error"};
                    NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                    NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                    
                    [self fireEvent:@"" event:@"on.appOpenAd.failed.loaded" withData:errorJsonString];
                    return;
                }
                
                self.appOpenAd = ad;
                self.appOpenAd.fullScreenContentDelegate = self;
                [self fireEvent:@"" event:@"on.appOpenAd.loaded" withData:nil];
                
                
                
                __weak __typeof(self) weakSelf = self;
                self.appOpenAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) return;
                    
                    NSDecimalNumber *adValue = value.value;
                    NSString *currencyCode = value.currencyCode;
                    GADAdValuePrecision precision = value.precision;

                    NSString *adUnitId = strongSelf.appOpenAd.adUnitID;

                    NSDictionary *data = @{
                        @"value": adValue,
                        @"currencyCode": currencyCode,
                        @"precision": @(precision),
                        @"adUnitId": adUnitId
                    };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.appOpenAd.revenue" withData:jsonString];
                };
                
                
              
                
                
                if (auto_Show) {
                    NSError *presentError = nil;
                    if ([self.appOpenAd canPresentFromRootViewController:self.viewController error:&presentError]) {
                        [self.appOpenAd presentFromRootViewController:self.viewController];
                    } else {
                        // Send show error to event
                        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                        NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                        NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                        
                        [self fireEvent:@"" event:@"on.appOpenAd.failed.show" withData:errorJsonString];
                    }
                }
                
                
                if (ResponseInfo) {
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
                        [self fireEvent:@"" event:@"on.appOpenAd.responseInfo" withData:jsonResponseString];
                    } else {
                        NSLog(@"Error converting response info to JSON: %@", jsonError.localizedDescription);
                    }
                }
                
                
                
            }];
        });
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)showAppOpenAd:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  if (self.appOpenAd &&
      [self.appOpenAd canPresentFromRootViewController:self.viewController
                                                 error:nil]) {
    [self.appOpenAd presentFromRootViewController:self.viewController];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self fireEvent:@""
              event:@"on."
                    @"appO"
                    @"penA"
                    @"d."
                    @"fail"
                    @"ed."
                    @"show"
           withData:nil];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}
- (void)loadInterstitialAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    BOOL autoShow = [[options valueForKey:@"autoShow"] boolValue];
    
    auto_Show = autoShow;
    adFormat = 2;
    
    if (adFormat == 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GADRequest *request = [GADRequest request];
            [GADInterstitialAd loadWithAdUnitID:adUnitId request:request completionHandler:^(GADInterstitialAd *ad, NSError *error) {
                if (error) {
                    // Send load error to event
                    NSDictionary *errorData = @{@"error": error.localizedDescription ?: @"Unknown error"};
                    NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                    NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                    
                    [self fireEvent:@"" event:@"on.interstitial.failed.load" withData:errorJsonString];
                    return;
                }
                
                self.interstitial = ad;
                self.interstitial.fullScreenContentDelegate = self;
                [self fireEvent:@"" event:@"on.interstitial.loaded" withData:nil];
                
                
                __weak __typeof(self) weakSelf = self;
                self.interstitial.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) return;
                    
                    NSDecimalNumber *adValue = value.value;
                    NSString *currencyCode = value.currencyCode;
                    GADAdValuePrecision precision = value.precision;

                    NSString *adUnitId = strongSelf.interstitial.adUnitID;

                    NSDictionary *data = @{
                        @"value": adValue,
                        @"currencyCode": currencyCode,
                        @"precision": @(precision),
                        @"adUnitId": adUnitId
                    };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.interstitial.revenue" withData:jsonString];
                };
                
                
                if (auto_Show) {
                    NSError *presentError = nil;
                    if ([self.interstitial canPresentFromRootViewController:self.viewController error:&presentError]) {
                        [self.interstitial presentFromRootViewController:self.viewController];
                    } else {
                        // Send present error to event
                        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                        NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                        NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                        
                        [self fireEvent:@"" event:@"on.interstitial.failed.show" withData:errorJsonString];
                    }
                }
                
                
                
                if (ResponseInfo) {
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
                        [self fireEvent:@"" event:@"on.interstitialAd.responseInfo" withData:jsonResponseString];
                    } else {
                        NSLog(@"Error converting response info to JSON: %@", jsonError.localizedDescription);
                    }
                }
                
                
                
            }];
        });
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)showInterstitialAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    NSError *presentError = nil;
    if (self.interstitial && [self.interstitial canPresentFromRootViewController:self.viewController error:&presentError]) {
        [self.interstitial presentFromRootViewController:self.viewController];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        // Send show error to event
        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
        NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
        NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
        
        [self fireEvent:@"" event:@"on.interstitial.failed.show" withData:errorJsonString];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)loadRewardedInterstitialAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    BOOL autoShow = [[options valueForKey:@"autoShow"] boolValue];
    
    auto_Show = autoShow;
    adFormat = 4;
    
    if (adFormat == 4) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GADRequest *request = [GADRequest request];
            [GADRewardedInterstitialAd loadWithAdUnitID:adUnitId request:request completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
                if (error) {
                    // Send error data to event
                    NSDictionary *errorData = @{@"error": error.localizedDescription ?: @"Unknown error"};
                    NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                    NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                    
                    [self fireEvent:@"" event:@"on.rewardedInt.failed.load" withData:errorJsonString];
                    return;
                }
                
                self.rewardedInterstitialAd = ad;
                isAdSkip = 1;
                self.rewardedInterstitialAd.fullScreenContentDelegate = self;
                [self fireEvent:@"" event:@"on.rewardedInt.loaded" withData:nil];
                
                
                
                __weak __typeof(self) weakSelf = self;
                self.rewardedInterstitialAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) return;
                    
                    NSDecimalNumber *adValue = value.value;
                    NSString *currencyCode = value.currencyCode;
                    GADAdValuePrecision precision = value.precision;

                    NSString *adUnitId = strongSelf.rewardedInterstitialAd.adUnitID;

                    NSDictionary *data = @{
                        @"value": adValue,
                        @"currencyCode": currencyCode,
                        @"precision": @(precision),
                        @"adUnitId": adUnitId
                    };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.rewardedInt.revenue" withData:jsonString];
                };
                
                
                if (auto_Show) {
                    NSError *presentError = nil;
                    if ([self.rewardedInterstitialAd canPresentFromRootViewController:self.viewController error:&presentError]) {
                        [self.rewardedInterstitialAd presentFromRootViewController:self.viewController userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.rewardedInterstitialAd.adReward;
                            
                            // Prepare reward data as JSON
                            NSDictionary *rewardData = @{
                                @"currency": reward.type,
                                @"amount": [reward.amount stringValue]
                            };
                            NSData *rewardJsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:nil];
                            NSString *rewardJsonString = [[NSString alloc] initWithData:rewardJsonData encoding:NSUTF8StringEncoding];
                            
                            [self fireEvent:@"" event:@"on.rewardedInt.userEarnedReward" withData:rewardJsonString];
                            isAdSkip = 2;
                            NSLog(@"Reward received with currency %@, amount %ld", reward.type, [reward.amount longValue]);
                        }];
                    } else {
                        // Send present error to event
                        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                        NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                        NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                        
                        [self fireEvent:@"" event:@"on.rewardedInt.failed.show" withData:errorJsonString];
                    }
                    
                    
                    if (ResponseInfo) {
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
                            [self fireEvent:@"" event:@"on.rewardedIntAd.responseInfo" withData:jsonResponseString];
                        } else {
                            NSLog(@"Error converting response info to JSON: %@", jsonError.localizedDescription);
                        }
                    }
                    
                    
                    
                    
                }
            }];
        });
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)showRewardedInterstitialAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    NSError *presentError = nil;
    if (self.rewardedInterstitialAd &&
        [self.rewardedInterstitialAd canPresentFromRootViewController:self.viewController error:&presentError]) {
        
        [self.rewardedInterstitialAd presentFromRootViewController:self.viewController userDidEarnRewardHandler:^{
            GADAdReward *reward = self.rewardedInterstitialAd.adReward;
            
            // Prepare reward data as JSON
            NSDictionary *rewardData = @{
                @"currency": reward.type,
                @"amount": [reward.amount stringValue]
            };
            NSData *rewardJsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:nil];
            NSString *rewardJsonString = [[NSString alloc] initWithData:rewardJsonData encoding:NSUTF8StringEncoding];
            
            [self fireEvent:@"" event:@"on.rewardedInt.userEarnedReward" withData:rewardJsonString];
            isAdSkip = 2;
            NSLog(@"Reward received with currency %@, amount %ld", reward.type, [reward.amount longValue]);
        }];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        // Prepare error data as JSON
        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
        NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
        NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
        
        [self fireEvent:@"" event:@"on.rewardedInt.failed.show" withData:errorJsonString];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)loadRewardedAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    BOOL autoShow = [[options valueForKey:@"autoShow"] boolValue];
    auto_Show = autoShow;
    adFormat = 3;
    
    if (adFormat == 3) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GADRequest *request = [GADRequest request];
            
            [GADRewardedAd loadWithAdUnitID:adUnitId request:request completionHandler:^(GADRewardedAd *ad, NSError *error) {
                if (error) {
                    NSDictionary *errorData = @{@"error": error.localizedDescription ?: @"Unknown error"};
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [self fireEvent:@"" event:@"on.rewarded.failed.load" withData:jsonString];
                    return;
                }

                self.rewardedAd = ad;
                
                isAdSkip = 0;
                self.rewardedAd.fullScreenContentDelegate = self;
                [self fireEvent:@"" event:@"on.rewarded.loaded" withData:nil];
                
                __weak __typeof(self) weakSelf = self;
                self.rewardedAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) return; // Pastikan strongSelf tidak null
                    
                    // Mengambil data ad revenue
                    NSDecimalNumber *adValue = value.value;
                    NSString *currencyCode = value.currencyCode;
                    GADAdValuePrecision precision = value.precision;

                    // Mendapatkan ID unit iklan
                    NSString *adUnitId = strongSelf.rewardedAd.adUnitID;

                    // Mengirim data dalam format JSON
                    NSDictionary *data = @{
                        @"value": adValue,
                        @"currencyCode": currencyCode,
                        @"precision": @(precision),
                        @"adUnitId": adUnitId
                    };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.rewarded.revenue" withData:jsonString];
                };
                
                

                if (auto_Show) {
                    NSError *presentError = nil;
                    if ([self.rewardedAd canPresentFromRootViewController:self.viewController error:&presentError]) {
                        [self.rewardedAd presentFromRootViewController:self.viewController userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.rewardedAd.adReward;

                            NSDictionary *rewardData = @{
                                @"currency": reward.type,
                                @"amount": [reward.amount stringValue]
                            };
                            NSData *rewardJsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:nil];
                            NSString *rewardJsonString = [[NSString alloc] initWithData:rewardJsonData encoding:NSUTF8StringEncoding];
                            
                            [self fireEvent:@"" event:@"on.reward.userEarnedReward" withData:rewardJsonString];
                            isAdSkip = 2;
                          //  NSLog(@"Reward diterima dengan currency %@, amount %lf", reward.type, [reward.amount doubleValue]);
                        }];
                    } else {
                        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [self fireEvent:@"" event:@"on.rewarded.failed.show" withData:jsonString];
                    }
                    
                    
                    if (ResponseInfo) {
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
                            [self fireEvent:@"" event:@"on.rewardedAd.responseInfo" withData:jsonResponseString];
                        } else {
                            NSLog(@"Error converting response info to JSON: %@", jsonError.localizedDescription);
                        }
                    }
                    
                    
                }
            }];
        });
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)showRewardedAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;

    if (self.rewardedAd) {
        NSError *presentError = nil;
        if ([self.rewardedAd canPresentFromRootViewController:self.viewController error:&presentError]) {
            [self.rewardedAd presentFromRootViewController:self.viewController
                                  userDidEarnRewardHandler:^{
                GADAdReward *reward = self.rewardedAd.adReward;
                
                NSDictionary *rewardData = @{
                    @"currency": reward.type,
                    @"amount": [reward.amount stringValue]
                };
                NSError *jsonError;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:&jsonError];
                
                if (jsonData) {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [self fireEvent:@"" event:@"on.reward.userEarnedReward" withData:jsonString];
                } else {
                    [self fireEvent:@"" event:@"on.reward.userEarnedReward" withData:nil];
                }

                isAdSkip = 2;
                
           
                NSLog(@"Reward received with currency %@, amount %lf", reward.type, [reward.amount doubleValue]);
            }];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
            NSError *jsonError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:&jsonError];

            if (jsonData && !jsonError) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self fireEvent:@"" event:@"on.rewarded.failed.show" withData:jsonString];
            } else {
                [self fireEvent:@"" event:@"on.rewarded.failed.show" withData:nil];
            }
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self fireEvent:@"" event:@"on.rewarded.failed.show" withData:nil];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)fireEvent:(NSString *)obj
            event:(NSString *)eventName
         withData:(NSString *)jsonStr {
  NSString *js;
  if (obj && [obj isEqualToString:@"windo"
                                  @"w"]) {
    js = [NSString stringWithFormat:@"var "
                                    @"evt="
                                    @"document"
                                    @".createE"
                                    @"vent("
                                    @"\"UIEven"
                                    @"ts\");"
                                    @"evt."
                                    @"initUIEv"
                                    @"ent("
                                    @"\"%@\","
                                    @"true,"
                                    @"false,"
                                    @"window,"
                                    @"0);"
                                    @"window."
                                    @"dispatch"
                                    @"Event("
                                    @"evt);",
                                    eventName];
  } else if (jsonStr && [jsonStr length] > 0) {
    js = [NSString stringWithFormat:@"javascri"
                                    @"pt:"
                                    @"cordova."
                                    @"fireDocu"
                                    @"mentEven"
                                    @"t('%@',%"
                                    @"@);",
                                    eventName, jsonStr];
  } else {
    js = [NSString stringWithFormat:@"javascri"
                                    @"pt:"
                                    @"cordova."
                                    @"fireDocu"
                                    @"mentEven"
                                    @"t('%@')"
                                    @";",
                                    eventName];
  }
  [self.commandDelegate evalJs:js];
}

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

  NSMutableString *hexString =
      [NSMutableString stringWithCapacity:(CC_SHA256_DIGEST_LENGTH * 2)];
  for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
    [hexString appendFormat:@"%02x", digest[i]];
  }

  return hexString;
}

#pragma mark GADBannerViewDelegate implementation

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSString *collapsibleStatus = bannerView.isCollapsible ? @"collapsible" : @"not collapsible";
    NSDictionary *eventData = @{@"collapsible" : collapsibleStatus};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:eventData options:0 error:&error];

    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self fireEvent:@"" event:@"on.is.collapsible" withData:jsonString];
    }

    [self fireEvent:@"" event:@"on.banner.load" withData:nil];
    
    
    if (auto_Show && self.bannerView) {
        [self addBannerViewToView:command];
        self.bannerView.hidden = NO;
    } else {
        [self fireEvent:@"" event:@"on.banner.failed.show" withData:nil];
    }
    
    
    __weak __typeof(self) weakSelf = self;
    self.bannerView.paidEventHandler = ^(GADAdValue *_Nonnull value) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSDecimalNumber *adValue = value.value;
        NSString *currencyCode = value.currencyCode;
        GADAdValuePrecision precision = value.precision;

        NSString *adUnitId = strongSelf.bannerView.adUnitID;

        NSDictionary *data = @{
            @"value": adValue,
            @"currencyCode": currencyCode,
            @"precision": @(precision),
            @"adUnitId": adUnitId
        };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        [strongSelf fireEvent:@"" event:@"on.banner.revenue" withData:jsonString];
    };
    

    
    
    
    
    if (ResponseInfo) {
        GADResponseInfo *responseInfo = self.bannerView.responseInfo;
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
            [self fireEvent:@"" event:@"on.bannerAd.responseInfo" withData:jsonResponseString];
        } else {
            NSLog(@"Error converting response info to JSON: %@", jsonError.localizedDescription);
        }
    }
    
    
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSDictionary *errorData = @{
        @"code": @(error.code),
        @"message": error.localizedDescription
    };

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:&jsonError];

    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self fireEvent:@"" event:@"on.banner.failed.load" withData:jsonString];
    } else {
        // Fallback in case of JSON serialization failure
        [self fireEvent:@"" event:@"on.banner.failed.load" withData:error.localizedDescription];
    }
}


- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.impression" withData:nil];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.open" withData:nil];
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.close" withData:nil];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.did.dismiss" withData:nil];
}

#pragma GADFullScreeContentDelegate implementation

- (void)adWillPresentFullScreenContent:(id)ad {
    if (adFormat == 1) {
        [self fireEvent:@"" event:@"on.appOpenAd.show" withData:nil];
    } else if (adFormat == 2) {
        [self fireEvent:@"" event:@"on.interstitial.show" withData:nil];
        [self fireEvent:@"" event:@"onPresentAd" withData:nil];
    } else if (adFormat == 3) {
        [self fireEvent:@"" event:@"on.rewarded.show" withData:nil];
        isAdSkip = 1;
    } else if (adFormat == 4) {
        isAdSkip = 1;
        [self fireEvent:@"" event:@"on.rewardedInt.showed" withData:nil];
    }
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSDictionary *errorData = @{
        @"code": @(error.code),
        @"message": error.localizedDescription
    };
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:&jsonError];
    NSString *jsonString = jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : error.localizedDescription;

    if (adFormat == 1) {
        [self fireEvent:@"" event:@"on.appOpenAd.failed.loaded" withData:jsonString];
    } else if (adFormat == 2) {
        [self fireEvent:@"" event:@"on.interstitial.failed.load" withData:jsonString];
    } else if (adFormat == 3) {
        [self fireEvent:@"" event:@"on.rewarded.failed.load" withData:jsonString];
    } else if (adFormat == 4) {
        [self fireEvent:@"" event:@"on.rewardedInt.failed.load" withData:jsonString];
    }
}


- (void)adDidDismissFullScreenContent:(id)ad {
    if (adFormat == 1) {
        [self fireEvent:@"" event:@"on.appOpenAd.dismissed" withData:nil];
    } else if (adFormat == 2) {
        [self fireEvent:@"" event:@"on.interstitial.dismissed" withData:nil];
    } else if (adFormat == 3) {
        [self fireEvent:@"" event:@"on.rewarded.dismissed" withData:nil];
        if (isAdSkip != 2) {
            [self fireEvent:@"" event:@"on.rewarded.ad.skip" withData:nil];
        }
    } else if (adFormat == 4) {
        if (isAdSkip != 2) {
            [self fireEvent:@"" event:@"on.rewardedInt.ad.skip" withData:nil];
        }
        [self fireEvent:@"" event:@"on.rewardedInt.dismissed" withData:nil];
    }
}

#pragma mark Cleanup
- (void)dealloc {
  self.appOpenAd = nil;
  self.bannerView = nil;
  self.interstitial = nil;
  self.rewardedAd = nil;
  self.rewardedInterstitialAd = nil;
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIDeviceOrientationDidChangeNotification
              object:nil];
}
@end
