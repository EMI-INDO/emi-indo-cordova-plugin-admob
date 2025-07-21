#import "emiAdmobPlugin.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <Cordova/CDVViewController.h>

@implementation emiAdmobPlugin

@synthesize appOpenAd;
@synthesize bannerView;
@synthesize interstitial;
@synthesize rewardedInterstitialAd;
@synthesize rewardedAd;
@synthesize command;
@synthesize responseInfo;
@synthesize isPrivacyOptionsRequired;

int attStatus = 0;

int Consent_Status = 0;
int adFormat = 0;
int adWidth = 320; // Default

// NSString *Npa = @"1"; // Deprecated
NSString *setPosition = @"bottom-center"; // Default
NSString *bannerSaveAdUnitId = @""; // autoResize dependency = true

BOOL isAutoResize = NO;

CGFloat paddingWebView = 0; // Default
CGFloat bannerHeightFinal = 50; // Default

int isAdSkip = 0;
BOOL UnderAgeOfConsent = NO;
BOOL isPrivacyOptions = NO;
BOOL isDebugGeography = NO;
BOOL isResponseInfo = NO;
BOOL isUsingAdManagerRequest = YES;


BOOL isCustomConsentManager = NO;
BOOL isEnabledKeyword = NO;
NSString *setKeyword = @"";


- (BOOL)canRequestAds {
  return UMPConsentInformation.sharedInstance.canRequestAds;
}
- (void)setUsingAdManagerRequest:(BOOL)value {
  isUsingAdManagerRequest = value;
}


- (void)setAdRequest {
    if (isUsingAdManagerRequest) {
        self.globalRequest = [GAMRequest request];
       // NSLog(@"Using AdManager request");
    } else {
        self.globalRequest = [GADRequest request];
      //  NSLog(@"Using AdMob request");
    }
    
    if (isEnabledKeyword && setKeyword.length > 0) {
            NSArray *keywords = [setKeyword componentsSeparatedByString:@","];
            for (NSString *keyword in keywords) {
                NSString *trimmedKeyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (trimmedKeyword.length > 0) {
                   // NSLog(@"Adding keyword: %@", trimmedKeyword);
                    [self.globalRequest setKeywords:[self.globalRequest.keywords arrayByAddingObject:trimmedKeyword]];
                }
            }
        }
    
}



- (void)isResponseInfo:(BOOL)value { isResponseInfo = value; }
- (void)isDebugGeography:(BOOL)value { isDebugGeography = value; }

- (void)initialize:(CDVInvokedUrlCommand *)command {

  NSDictionary *options = [command.arguments objectAtIndex:0];

  BOOL setAdRequest = [[options valueForKey:@"isUsingAdManagerRequest"] boolValue];
  BOOL responseInfo = [[options valueForKey:@"isResponseInfo"] boolValue];
  BOOL setDebugGeography = [[options valueForKey:@"isConsentDebug"] boolValue];

  [self setUsingAdManagerRequest:setAdRequest];
  [self isResponseInfo:responseInfo];
  [self isDebugGeography:setDebugGeography];
    
    if (isCustomConsentManager) {
        [self startGoogleMobileAdsSDK];
        [self fireEvent:@"" event:@"on.custom.consent.manager.used" withData:nil];
       return;
    }

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
    __block CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
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

      NSString *sdkVersion = GADGetStringFromVersionNumber(GADMobileAds.sharedInstance.versionNumber);
      int Consent_Status = (int)UMPConsentInformation.sharedInstance.consentStatus;
      int initAttStatus = (int)attStatus;

      NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      NSNumber *CmpSdkID = [prefs valueForKey:@"IABTCF_CmpSdkID"];
      NSString *gdprApplies = [prefs stringForKey:@"IABTCF_gdprApplies"];
      NSString *PurposeConsents = [prefs stringForKey:@"IABTCF_PurposeConsents"];
      NSString *TCString = [prefs stringForKey:@"IABTCF_TCString"];
      NSString *additionalConsent = [prefs stringForKey:@"IABTCF_AddtlConsent"];

      result[@"version"] = sdkVersion;
      result[@"consentStatus"] = @(Consent_Status);
      result[@"attStatus"] = @(initAttStatus);
      result[@"adapter"] = adaptersArray;
      result[@"CmpSdkID"] = CmpSdkID;
      result[@"gdprApplies"] = gdprApplies;
      result[@"PurposeConsents"] = PurposeConsents;
      result[@"TCString"] = TCString;
      result[@"additionalConsent"] = additionalConsent;

      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];

      if (!jsonData) {
        NSLog(@"Error converting result to JSON: %@", error.localizedDescription);
      } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
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
                             NSLog(@"Error when displaying the form: %@", formError);
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

    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:Consent_Status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)getIabTfc:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    

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
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
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
         NSLog(@"Unknown content rating: %@", contentRating);
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



- (void)orientationDidChange:(NSNotification *)notification {
    /*
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
          
        [self setAdRequest];
          

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
            [self.bannerViewLayout.heightAnchor constraintEqualToConstant:bannerHeightFinal]
              .active = YES;
        }

        self.bannerView = [[GADBannerView alloc]
            initWithAdSize:
                GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(
                    rootView.frame.size.width)];
        self.bannerView.adUnitID = bannerSaveAdUnitId;
        self.bannerView.delegate = self;
        [self.bannerView loadRequest:self.globalRequest];

        [self.bannerViewLayout addSubview:self.bannerView];
        [self.bannerViewLayout bringSubviewToFront:self.bannerView];
       
              if (self.isAutoShowBanner && self.bannerView) {
                  if (!self.isOverlapping){
                      self.bannerView.hidden = NO;
                      [self setBodyHeight:self.command];
                  } else {
                      self.bannerView.hidden = NO;
                  }
              }

      } @catch (NSException *exception) {
          NSLog(@"Exception: %@", exception.reason);
      }
    });
  }
 */
}



- (void)loadBannerAd:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  NSDictionary *options = [command.arguments objectAtIndex:0];
  NSString *adUnitId = [options valueForKey:@"adUnitId"];
  NSString *position = [options valueForKey:@"position"];
  NSString *collapsible = [options valueForKey:@"collapsible"];
  BOOL autoResize = [[options valueForKey:@"autoResize"] boolValue];
  NSString *size = [options valueForKey:@"size"];
  self.isAutoShowBanner = [[options valueForKey:@"autoShow"] boolValue];
  self.isOverlapping = [[options valueForKey:@"isOverlapping"] boolValue];

  bannerSaveAdUnitId = adUnitId;
  setPosition = position;
  adFormat = 5;

  if (adUnitId == nil || [adUnitId length] == 0) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                     messageAsString:@"Ad unit ID is required"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    return;
  }

 if (collapsible != nil && [collapsible length] > 0) {
    self.isCollapsible = YES;
  } else {
    self.isCollapsible = NO;
  }

  if (autoResize) {
    isAutoResize = YES;
  }
    
  [self setAdRequest];

    if (adFormat == 5 && !self.isBannerOpen) {
    dispatch_async(dispatch_get_main_queue(), ^{
    
        
      UIView *parentView = self.viewController.view;
      CGRect frame = self.bannerView.frame;

      if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = self.bannerView.safeAreaInsets;
        frame = UIEdgeInsetsInsetRect(frame, safeAreaInsets);
      }

      self.viewWidth = frame.size.width;
      
      adWidth = self.viewWidth;

      GADAdSize siz = [self __AdSizeFromString:size];
      self.bannerView = [[GADBannerView alloc] initWithAdSize:siz];

    CGSize bannerSize = self.bannerView.bounds.size;
    CGFloat screenWidth = parentView.bounds.size.width;
    CGFloat screenHeight = parentView.bounds.size.height;

    CGFloat originX = (screenWidth - bannerSize.width) / 2;
    CGFloat originY = 0;

    if ([setPosition isEqualToString:@"bottom-center"]) {
        originY = screenHeight - bannerSize.height;
    } else if ([setPosition isEqualToString:@"top-center"]) {
        originY = 0;
    }

    self.bannerView.frame = CGRectMake(originX, originY, bannerSize.width, bannerSize.height);


      GADExtras *extras = [[GADExtras alloc] init];

      if (self.isCollapsible) {
        extras.additionalParameters = @{@"collapsible" : collapsible};
   
        [self.globalRequest registerAdNetworkExtras:extras];
          
      }

      self.bannerView.adUnitID = adUnitId;
      self.bannerView.rootViewController = self.viewController;
      self.bannerView.delegate = self;
      [self.bannerView loadRequest:self.globalRequest];
      self.bannerView.hidden = YES;
      if (![parentView.subviews containsObject:self.bannerView]) {
         [parentView addSubview:self.bannerView];
         [parentView bringSubviewToFront:self.bannerView];
      }
    });

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }

  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}





- (void)showBannerAd:(CDVInvokedUrlCommand *)command {
    @try {
        if (self.bannerView) {
            
            
            UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
            UIViewController* rootViewController = keyWindow.rootViewController;
            
            if (!rootViewController) {
                NSLog(@"[showBannerAd] Root ViewController not found");
                return;
            }
            
            [rootViewController.view setNeedsLayout];
            [rootViewController.view layoutIfNeeded];
            
            CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
            CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
            
            
            //UIWindow *keyWindow = UIApplication.sharedApplication.delegate.window;
            UIEdgeInsets safeAreaInsets = keyWindow.safeAreaInsets;
            
            
            CGFloat bannerHeight = bannerHeightFinal; // reuse
            CGFloat originX = (screenWidth - self.bannerView.bounds.size.width) / 2;
            CGFloat originY = 0;
            
            if ([setPosition isEqualToString:@"bottom-center"]) {
                originY = screenHeight - bannerHeight - safeAreaInsets.bottom + paddingWebView;
            } else if ([setPosition isEqualToString:@"top-center"]) {
                originY = safeAreaInsets.top;
            }
            
            
            self.bannerView.frame = CGRectMake(originX, originY, self.bannerView.bounds.size.width, bannerHeight);
            
            if (!self.isOverlapping) {
                [self setBodyHeight:command];
            }
            
            [self.bannerView setNeedsLayout];
            [self.bannerView layoutIfNeeded];
            [rootViewController.view setNeedsLayout];
            [rootViewController.view layoutIfNeeded];
            
            self.bannerView.hidden = NO;
            self.isBannerOpen=true;
            
        } else {
            [self fireEvent:@"" event:@"on.banner.failed.show" withData:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[AdPlugin] Error in showBannerAd: %@", exception.reason);
    }
}




/*
- (void)showBannerAd:(CDVInvokedUrlCommand *)command {
    @try {
        
        if (self.bannerView && self.isBannerOpen) {
            
            if (!self.isOverlapping){
                self.bannerView.hidden = NO;
                [self setBodyHeight:command];
            } else {
                self.bannerView.hidden = NO;
            }
            
        } else if (self.bannerView && !self.isAutoShowBanner) {
            
            if (!self.isOverlapping){
                self.bannerView.hidden = NO;
                [self setBodyHeight:command];
            } else {
                self.bannerView.hidden = NO;
            }
            
        } else {
            [self fireEvent:@"" event:@"on.banner.failed.show" withData:nil];
        }
      
    }
    @catch (NSException *exception) {
        NSLog(@"[AdPlugin] Error in showBannerAd: %@", exception.reason);
    }
}
*/



- (UIView*)findWebViewInView:(UIView*)view {
    if ([view isKindOfClass:NSClassFromString(@"WKWebView")] || [view isKindOfClass:NSClassFromString(@"UIWebView")]) {
        return view;
    }

    for (UIView* subview in view.subviews) {
        UIView* found = [self findWebViewInView:subview];
        if (found) {
            return found;
        }
    }

    return nil;
}


- (void)setBodyHeight:(CDVInvokedUrlCommand*)command {
    if(!self.isBannerOpen){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @try {
                
                UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
                UIViewController* rootViewController = keyWindow.rootViewController;
                
                if (!rootViewController) {
                    CDVPluginResult* errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Root ViewController not found"];
                    [self.commandDelegate sendPluginResult:errorResult callbackId:command.callbackId];
                    return;
                }
                
                
                [rootViewController.view setNeedsLayout];
                [rootViewController.view layoutIfNeeded];
                
                UIEdgeInsets safeAreaInsets = rootViewController.view.safeAreaInsets;
                
                if (safeAreaInsets.bottom == 0) {
                    safeAreaInsets = keyWindow.safeAreaInsets;
                }
                
                CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
                CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
                CGFloat bannerHeight = bannerHeightFinal;
                CGFloat newHeight = screenHeight - bannerHeight;
                
                
                if (newHeight <= 0) {
                    
                    CDVPluginResult* errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid new height"];
                    [self.commandDelegate sendPluginResult:errorResult callbackId:command.callbackId];
                    return;
                }
                
                UIView *webView = [self findWebViewInView:rootViewController.view];
                if (webView) {
                    CGRect webViewFrame = webView.frame;
                    webViewFrame.size.height = newHeight;
                    webView.frame = webViewFrame;
                } else {
                    NSLog(@"[CordovaBodyHeight] WebView not found");
                }
                
                if ([setPosition isEqualToString:@"top-center"]) {
                    CGRect currentBannerFrame = self.bannerView.frame;
                    CGFloat expectedYPosition = safeAreaInsets.top;
                    
                    if (fabs(currentBannerFrame.origin.y - expectedYPosition) > 0.1) {
                        CGRect bannerFrame = CGRectMake(0, expectedYPosition, screenWidth, bannerHeight);
                        self.bannerView.frame = bannerFrame;
                        CGRect contentFrame = rootViewController.view.frame;
                        contentFrame.origin.y = bannerHeight + safeAreaInsets.top;
                        contentFrame.size.height = screenHeight - (bannerHeight + safeAreaInsets.top);
                        rootViewController.view.frame = contentFrame;
                    }
                } else if ([setPosition isEqualToString:@"bottom-center"]) {
                    
                    CGRect bannerFrame = CGRectMake(
                                                    0,
                                                    screenHeight - bannerHeight - safeAreaInsets.bottom + paddingWebView,
                                                    screenWidth,
                                                    bannerHeight
                                                    );
                    self.bannerView.frame = bannerFrame;
                    
                    CGRect contentFrame = rootViewController.view.frame;
                    contentFrame.origin.y = 0;
                    contentFrame.size.height = screenHeight - (bannerHeight + safeAreaInsets.bottom);
                    rootViewController.view.frame = contentFrame;
                    
                } else {
                    CGRect bannerFrame = CGRectMake(
                                                    0,
                                                    screenHeight - bannerHeight - safeAreaInsets.bottom + paddingWebView,
                                                    screenWidth,
                                                    bannerHeight
                                                    );
                    self.bannerView.frame = bannerFrame;
                    
                    CGRect contentFrame = rootViewController.view.frame;
                    contentFrame.origin.y = 0;
                    contentFrame.size.height = screenHeight - (bannerHeight + safeAreaInsets.bottom);
                    rootViewController.view.frame = contentFrame;
                    
                }
                
                [self.bannerView setNeedsLayout];
                [self.bannerView layoutIfNeeded];
                [rootViewController.view setNeedsLayout];
                [rootViewController.view layoutIfNeeded];
                
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:newHeight];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
            @catch (NSException* exception) {
                NSLog(@"[CordovaBodyHeight] Exception: %@", exception.reason);
            }
            
        });
    }
}



- (void)metaData:(CDVInvokedUrlCommand *)command {
    NSDictionary *options = [command.arguments objectAtIndex:0];
    BOOL useCustomConsentManager = [[options valueForKey:@"useCustomConsentManager"] boolValue];
    BOOL useCustomKeyword = [[options valueForKey:@"isEnabledKeyword"] boolValue];
    NSString *keywordValue = [options valueForKey:@"setKeyword"];

    isCustomConsentManager = useCustomConsentManager;
    isEnabledKeyword = useCustomKeyword;
    setKeyword = keywordValue;
    
}


- (void)styleBannerAd:(CDVInvokedUrlCommand *)command {
    NSDictionary *options = [command.arguments objectAtIndex:0];
    self.isOverlapping = [[options valueForKey:@"isOverlapping"] boolValue];
    CGFloat paddingContainer = [[options valueForKey:@"paddingWebView"] floatValue];

    paddingWebView = paddingContainer;

    dispatch_async(dispatch_get_main_queue(), ^{
        @try {

            UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
            UIViewController *rootViewController = keyWindow.rootViewController;

            if (!rootViewController) {
                CDVPluginResult *errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Root ViewController not found"];
                [self.commandDelegate sendPluginResult:errorResult callbackId:command.callbackId];
                return;
            }

            UIEdgeInsets safeAreaInsets = rootViewController.view.safeAreaInsets;

            if (safeAreaInsets.bottom == 0) {
                safeAreaInsets = keyWindow.safeAreaInsets;
            }

            CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
            CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;

            NSDictionary *data = @{
                @"screenHeight": @(screenHeight),
                @"screenWidth": @(screenWidth),
                @"safeAreaTop": @(safeAreaInsets.top),
                @"safeAreaBottom": @(safeAreaInsets.bottom)
            };

            NSError *jsonError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&jsonError];

            if (jsonError) {
                CDVPluginResult *errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error converting dictionary to JSON"];
                [self.commandDelegate sendPluginResult:errorResult callbackId:command.callbackId];
                return;
            }

            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

            [self fireEvent:@"" event:@"on.style.banner.ad" withData:jsonString];


        } @catch (NSException *exception) {
            NSLog(@"[CordovaBodyHeight] Exception: %@", exception.reason);

        }
    });
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




- (void)resetWebViewHeight {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
        UIViewController *rootViewController = keyWindow.rootViewController;

        if (!rootViewController) {
            NSLog(@"[CordovaBodyHeight] Root ViewController not found on reset");
            return;
        }

        UIEdgeInsets safeAreaInsets = rootViewController.view.safeAreaInsets;

        if (safeAreaInsets.bottom == 0) {
            safeAreaInsets = keyWindow.safeAreaInsets;
        }

        CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;

        CGRect contentFrame = rootViewController.view.frame;
        contentFrame.origin.y = 0;
        contentFrame.size.height = screenHeight - safeAreaInsets.bottom;
        rootViewController.view.frame = contentFrame;

        UIView *webView = [self findWebViewInView:rootViewController.view];
        if (webView) {
            CGRect webViewFrame = webView.frame;
            webViewFrame.origin.y = 0;
            webViewFrame.size.height = screenHeight - safeAreaInsets.bottom;
            webView.frame = webViewFrame;

        } else {
            NSLog(@"[CordovaBodyHeight] WebView not found on reset");
        }

        [rootViewController.view setNeedsLayout];
        [rootViewController.view layoutIfNeeded];
    });
}




- (void)hideBannerAd:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
  if (self.bannerView && self.isBannerOpen) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.bannerView.hidden = YES;
      self.isBannerOpen=false;
      [self resetWebViewHeight];
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
      self.isBannerOpen = NO;
      self.bannerView = nil;
     [self resetWebViewHeight];
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
    self.isAutoShowAppOpen = [[options valueForKey:@"autoShow"] boolValue];
    
    adFormat = 1;
    self.appOpenAd = nil;
    
    [self setAdRequest];
    
    if (adFormat == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{

            GADExtras *extras = [[GADExtras alloc] init];
            [self.globalRequest registerAdNetworkExtras:extras];
            
            [GADAppOpenAd loadWithAdUnitID:adUnitId request:self.globalRequest completionHandler:^(GADAppOpenAd *ad, NSError *error) {
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
                        @"value": adValue ?: [NSNull null],
                        @"currencyCode": currencyCode ?: @"",
                        @"precision": @(precision),
                        @"adUnitId": adUnitId ?: @""
                    };

                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.appOpenAd.revenue" withData:jsonString];
                };
                
                
                if (self.isAutoShowAppOpen) {
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
                
                
                if (isResponseInfo) {
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
  if (self.appOpenAd && [self.appOpenAd canPresentFromRootViewController:self.viewController error:nil]) {
    [self.appOpenAd presentFromRootViewController:self.viewController];
    adFormat = 1;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
      [self fireEvent:@"" event:@"on.appOpened.failed.show" withData:nil];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}


- (void)loadInterstitialAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *adUnitId = [options valueForKey:@"adUnitId"];
    self.isAutoShowInterstitial = [[options valueForKey:@"autoShow"] boolValue];
    
    adFormat = 2;
    [self setAdRequest];
    if (adFormat == 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [GADInterstitialAd loadWithAdUnitID:adUnitId request:self.globalRequest completionHandler:^(GADInterstitialAd *ad, NSError *error) {
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
                        @"value": adValue ?: [NSNull null],
                        @"currencyCode": currencyCode ?: @"",
                        @"precision": @(precision),
                        @"adUnitId": adUnitId ?: @""
                    };
                    
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.interstitial.revenue" withData:jsonString];
                };
                
                
                if (self.isAutoShowInterstitial) {
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
                    adFormat = 2;
                }
                
                
                
                if (isResponseInfo) {
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
        adFormat = 2;
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
    self.isAutoShowRewardedInt = [[options valueForKey:@"autoShow"] boolValue];
    
    adFormat = 4;
    [self setAdRequest];
    if (adFormat == 4) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [GADRewardedInterstitialAd loadWithAdUnitID:adUnitId request:self.globalRequest completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
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
                        @"value": adValue ?: [NSNull null],
                        @"currencyCode": currencyCode ?: @"",
                        @"precision": @(precision),
                        @"adUnitId": adUnitId ?: @""
                    };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.rewardedInt.revenue" withData:jsonString];
                };
                
                
                if (self.isAutoShowRewardedInt) {
                    NSError *presentError = nil;
                    if ([self.rewardedInterstitialAd canPresentFromRootViewController:self.viewController error:&presentError]) {
                        [self.rewardedInterstitialAd presentFromRootViewController:self.viewController userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.rewardedInterstitialAd.adReward;
                            
                            // Prepare reward data as JSON
                            NSDictionary *rewardData = @{
                                @"rewardType": reward.type,
                                @"rewardAmount": [reward.amount stringValue]
                            };
                            NSData *rewardJsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:nil];
                            NSString *rewardJsonString = [[NSString alloc] initWithData:rewardJsonData encoding:NSUTF8StringEncoding];
                            adFormat = 4;
                            isAdSkip = 2;
                            [self fireEvent:@"" event:@"on.rewardedInt.userEarnedReward" withData:rewardJsonString];
                            NSLog(@"Reward received with currency %@, amount %ld", reward.type, [reward.amount longValue]);
                        }];
                    } else {
                        // Send present error to event
                        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                        NSData *errorJsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                        NSString *errorJsonString = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
                        
                        [self fireEvent:@"" event:@"on.rewardedInt.failed.show" withData:errorJsonString];
                    }
                    
                    
                    if (isResponseInfo) {
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
                @"rewardType": reward.type,
                @"rewardAmount": [reward.amount stringValue]
            };
            NSData *rewardJsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:nil];
            NSString *rewardJsonString = [[NSString alloc] initWithData:rewardJsonData encoding:NSUTF8StringEncoding];
            isAdSkip = 2;
            adFormat = 4;
            [self fireEvent:@"" event:@"on.rewardedInt.userEarnedReward" withData:rewardJsonString];
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
    self.isAutoShowRewardedAds = [[options valueForKey:@"autoShow"] boolValue];
    
    adFormat = 3;
    [self setAdRequest];
    if (adFormat == 3) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [GADRewardedAd loadWithAdUnitID:adUnitId request:self.globalRequest completionHandler:^(GADRewardedAd *ad, NSError *error) {
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
                    if (!strongSelf) return;
                    
                    NSDecimalNumber *adValue = value.value;
                    NSString *currencyCode = value.currencyCode;
                    GADAdValuePrecision precision = value.precision;

                    NSString *adUnitId = strongSelf.rewardedAd.adUnitID;

                    NSDictionary *data = @{
                        @"value": adValue ?: [NSNull null],
                        @"currencyCode": currencyCode ?: @"",
                        @"precision": @(precision),
                        @"adUnitId": adUnitId ?: @""
                    };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    [strongSelf fireEvent:@"" event:@"on.rewarded.revenue" withData:jsonString];
                };
                
                

                if (self.isAutoShowRewardedAds) {
                    NSError *presentError = nil;
                    if ([self.rewardedAd canPresentFromRootViewController:self.viewController error:&presentError]) {
                        [self.rewardedAd presentFromRootViewController:self.viewController userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.rewardedAd.adReward;
                            adFormat = 3;
                            NSDictionary *rewardData = @{
                                @"rewardType": reward.type,
                                @"rewardAmount": [reward.amount stringValue]
                            };
                            NSData *rewardJsonData = [NSJSONSerialization dataWithJSONObject:rewardData options:0 error:nil];
                            NSString *rewardJsonString = [[NSString alloc] initWithData:rewardJsonData encoding:NSUTF8StringEncoding];
                            isAdSkip = 2;
                            [self fireEvent:@"" event:@"on.reward.userEarnedReward" withData:rewardJsonString];
                        
                        }];
                    } else {
                        NSDictionary *errorData = @{@"error": presentError.localizedDescription ?: @"Unknown error"};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorData options:0 error:nil];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [self fireEvent:@"" event:@"on.rewarded.failed.show" withData:jsonString];
                    }
                    
                    
                    if (isResponseInfo) {
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
                    @"rewardType": reward.type,
                    @"rewardAmount": [reward.amount stringValue]
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
                adFormat = 3;
           
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
    
    CGFloat bannerHeight = bannerView.bounds.size.height;
    bannerHeightFinal = bannerHeight;

    NSDictionary *bannerLoadData = @{@"height" : @(bannerHeight)};
    NSData *bannerLoadJsonData = [NSJSONSerialization dataWithJSONObject:bannerLoadData options:0 error:&error];
    NSString *bannerLoadJsonString = [[NSString alloc] initWithData:bannerLoadJsonData encoding:NSUTF8StringEncoding];
    
    [self fireEvent:@"" event:@"on.banner.load" withData:bannerLoadJsonString];
   
    
    
    if (self.isAutoShowBanner && self.bannerView && !self.isBannerOpen) {
            if (!self.isOverlapping){
                self.bannerView.hidden = NO;
                [self setBodyHeight:command];
            } else {
                self.bannerView.hidden = NO;
            }
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
            @"value": adValue ?: [NSNull null],
            @"currencyCode": currencyCode ?: @"",
            @"precision": @(precision),
            @"adUnitId": adUnitId ?: @""
        };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        [strongSelf fireEvent:@"" event:@"on.banner.revenue" withData:jsonString];
    };
    

    
    if (isResponseInfo) {
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
        self.isBannerOpen = NO;
    } else {
        // Fallback in case of JSON serialization failure
        self.isBannerOpen = NO;
        [self fireEvent:@"" event:@"on.banner.failed.load" withData:error.localizedDescription];
    }
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.impression" withData:nil];
    self.isBannerOpen = YES;
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.open" withData:nil];
    self.isBannerOpen = YES;
   
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.close" withData:nil];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    [self fireEvent:@"" event:@"on.banner.did.dismiss" withData:nil];
    
}

#pragma mark GADFullScreeContentDelegate implementation

- (void)adWillPresentFullScreenContent:(id)ad {
    if (adFormat == 1) {
        adFormat = 1;
        [self fireEvent:@"" event:@"on.appOpenAd.show" withData:nil];
    } else if (adFormat == 2) {
        adFormat = 2;
        [self fireEvent:@"" event:@"on.interstitial.show" withData:nil];
        [self fireEvent:@"" event:@"onPresentAd" withData:nil];
    } else if (adFormat == 3) {
        adFormat = 3;
        [self fireEvent:@"" event:@"on.rewarded.show" withData:nil];
        isAdSkip = 1;
    } else if (adFormat == 4) {
        isAdSkip = 1;
        adFormat = 4;
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
        if (isAdSkip != 2) {
            [self fireEvent:@"" event:@"on.rewarded.ad.skip" withData:nil];
        } else {
            [self fireEvent:@"" event:@"on.rewarded.dismissed" withData:nil];
        }
    } else if (adFormat == 4) {
        if (isAdSkip != 2) {
            [self fireEvent:@"" event:@"on.rewardedInt.ad.skip" withData:nil];
        } else {
            [self fireEvent:@"" event:@"on.rewardedInt.dismissed" withData:nil];
        }
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
