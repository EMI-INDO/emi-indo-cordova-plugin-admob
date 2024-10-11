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

  BOOL setAdRequest =
      [[options valueForKey:@"isUsingAdManagerRequest"] boolValue];
  BOOL responseInfo = [[options valueForKey:@"isResponseInfo"] boolValue];
  BOOL setDebugGeography = [[options valueForKey:@"isConsentDebug"] boolValue];

  [self setUsingAdManagerRequest:setAdRequest];
  [self ResponseInfo:responseInfo];
  [self isDebugGeography:setDebugGeography];

  __block CDVPluginResult *pluginResult;
  NSString *callbackId = command.callbackId;
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
    // Request consent info update
    [UMPConsentInformation.sharedInstance
        requestConsentInfoUpdateWithParameters:parameters
                             completionHandler:^(
                                 NSError *_Nullable requestConsentError) {
                               if (requestConsentError) {
                                 // NSLog(@"Request consent error: %@",
                                 // requestConsentError.localizedDescription);
                                 pluginResult = [CDVPluginResult
                                     resultWithStatus:CDVCommandStatus_ERROR
                                      messageAsString:requestConsentError
                                                          .description];
                                 [self.commandDelegate
                                     sendPluginResult:pluginResult
                                           callbackId:callbackId];
                                 return;
                               }

                               // Check the consent status after update
                               UMPConsentStatus status =
                                   UMPConsentInformation.sharedInstance
                                       .consentStatus;
                               //  NSLog(@"Consent status: %ld", (long)status);

                               // Handle consent status
                               if (status == UMPConsentStatusRequired) {
                                 // If consent is required, load and display
                                 // consent form
                                 [UMPConsentForm loadWithCompletionHandler:^(
                                                     UMPConsentForm *form,
                                                     NSError *loadError) {
                                   if (loadError) {
                                     //  NSLog(@"Load consent form error: %@",
                                     //  loadError.localizedDescription);
                                     pluginResult = [CDVPluginResult
                                         resultWithStatus:CDVCommandStatus_ERROR
                                          messageAsString:loadError
                                                              .description];
                                     [self.commandDelegate
                                         sendPluginResult:pluginResult
                                               callbackId:callbackId];
                                   } else {
                                     // Present the consent form to the user
                                     [form
                                         presentFromViewController:
                                             [UIApplication sharedApplication]
                                                 .delegate.window
                                                 .rootViewController
                                                 completionHandler:^(
                                                     NSError
                                                         *_Nullable dismissError) {
                                                   if (dismissError) {
                                                     // NSLog(@"Dismiss consent
                                                     // form error: %@",
                                                     // dismissError.localizedDescription);
                                                     pluginResult = [CDVPluginResult
                                                         resultWithStatus:
                                                             CDVCommandStatus_ERROR
                                                          messageAsString:
                                                              dismissError
                                                                  .description];
                                                   } else {
                                                     //  NSLog(@"Consent form
                                                     //  successfully
                                                     //  presented.");
                                                     pluginResult = [CDVPluginResult
                                                         resultWithStatus:
                                                             CDVCommandStatus_OK
                                                          messageAsString:
                                                              @"Consent form "
                                                              @"displayed "
                                                              @"successfully."];
                                                   }
                                                   [self.commandDelegate
                                                       sendPluginResult:
                                                           pluginResult
                                                             callbackId:
                                                                 callbackId];
                                                 }];
                                   }

                                   if (UMPConsentInformation.sharedInstance
                                           .canRequestAds) {
                                     [self startGoogleMobileAdsSDK];
                                   }
                                 }];
                               } else if (status ==
                                              UMPConsentStatusNotRequired ||
                                          status == UMPConsentStatusObtained) {
                                 // If consent is not required or already
                                 // obtained, start the ads SDK
                                 if (UMPConsentInformation.sharedInstance
                                         .canRequestAds) {
                                   [self startGoogleMobileAdsSDK];
                                   pluginResult = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_OK
                                        messageAsString:@"Ads SDK started."];
                                 } else {
                                   pluginResult = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                        messageAsString:
                                            @"Cannot request ads, consent is "
                                            @"required."];
                                 }
                                 [self.commandDelegate
                                     sendPluginResult:pluginResult
                                           callbackId:callbackId];
                               } else {
                                 // NSLog(@"Consent status unknown or error.");
                                 pluginResult = [CDVPluginResult
                                     resultWithStatus:CDVCommandStatus_ERROR
                                      messageAsString:
                                          @"Consent status unknown."];
                                 [self.commandDelegate
                                     sendPluginResult:pluginResult
                                           callbackId:callbackId];
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

  // [UMPConsentInformation.sharedInstance reset];

  dispatch_async(dispatch_get_main_queue(), ^{
    [UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:
                                              parameters
                                                               completionHandler:^(
                                                                   NSError
                                                                       *_Nullable requestConsentError) {
                                                                 if (requestConsentError !=
                                                                     nil) {
                                                                   //  NSLog(@"Errors
                                                                   //  in
                                                                   //  updating
                                                                   //  consent
                                                                   //  information:
                                                                   //  %@",
                                                                   //  requestConsentError);
                                                                   CDVPluginResult
                                                                       *pluginResult = [CDVPluginResult
                                                                           resultWithStatus:
                                                                               CDVCommandStatus_ERROR
                                                                            messageAsString:
                                                                                requestConsentError
                                                                                    .description];
                                                                   [self.commandDelegate
                                                                       sendPluginResult:
                                                                           pluginResult
                                                                             callbackId:
                                                                                 command
                                                                                     .callbackId];
                                                                   return;
                                                                 }

                                                                 //  NSLog(@"Successful
                                                                 //  update of
                                                                 //  consent
                                                                 //  info.
                                                                 //  Continue to
                                                                 //  load and
                                                                 //  present
                                                                 //  consent
                                                                 //  form.");

                                                                 [UMPConsentForm loadAndPresentIfRequiredFromViewController:
                                                                                     self.viewController
                                                                                                          completionHandler:
                                                                                                              ^(NSError
                                                                                                                    *loadAndPresentError) {
                                                                                                                if (loadAndPresentError !=
                                                                                                                    nil) {
                                                                                                                  // NSLog(@"Error loading and presenting consent form: %@", loadAndPresentError);
                                                                                                                  CDVPluginResult
                                                                                                                      *pluginResult = [CDVPluginResult
                                                                                                                          resultWithStatus:
                                                                                                                              CDVCommandStatus_ERROR
                                                                                                                           messageAsString:
                                                                                                                               loadAndPresentError
                                                                                                                                   .description];
                                                                                                                  [self.commandDelegate
                                                                                                                      sendPluginResult:
                                                                                                                          pluginResult
                                                                                                                            callbackId:
                                                                                                                                command
                                                                                                                                    .callbackId];
                                                                                                                } else {
                                                                                                                  // NSLog(@"Consent form successfully loaded");
                                                                                                                  [UMPConsentForm
                                                                                                                      presentPrivacyOptionsFormFromViewController:
                                                                                                                          self.viewController
                                                                                                                                                completionHandler:^(
                                                                                                                                                    NSError
                                                                                                                                                        *_Nullable formError) {
                                                                                                                                                  if (formError) {
                                                                                                                                                    //  NSLog(@"Error when displaying the form: %@", formError);
                                                                                                                                                  } else {
                                                                                                                                                    // NSLog(@"The privacy options form is successfully displayed.");
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

    // NSLog(@"[showPrivacyOptionsForm] Using EEA debug geography for
    // consent.");
  }

  parameters.tagForUnderAgeOfConsent = UnderAgeOfConsent;

  dispatch_async(dispatch_get_main_queue(),
                 ^{
                   [UMPConsentInformation.sharedInstance requestConsentInfoUpdateWithParameters:
                                                             parameters
                                                                              completionHandler:^(
                                                                                  NSError
                                                                                      *_Nullable requestConsentError) {
                                                                                if (requestConsentError !=
                                                                                    nil) {
                                                                                  // NSLog(@"[showPrivacyOptionsForm] Error in updating consent info: %@", requestConsentError);
                                                                                  CDVPluginResult
                                                                                      *pluginResult = [CDVPluginResult
                                                                                          resultWithStatus:
                                                                                              CDVCommandStatus_ERROR
                                                                                           messageAsString:
                                                                                               requestConsentError
                                                                                                   .description];
                                                                                  [self.commandDelegate
                                                                                      sendPluginResult:
                                                                                          pluginResult
                                                                                            callbackId:
                                                                                                command
                                                                                                    .callbackId];
                                                                                  return;
                                                                                }

                                                                                // NSLog(@"[showPrivacyOptionsForm] Successful update of consent info. Continue to load and present consent form.");

                                                                                [UMPConsentForm
                                                                                    loadAndPresentIfRequiredFromViewController:
                                                                                        self.viewController
                                                                                                             completionHandler:^(
                                                                                                                 NSError
                                                                                                                     *loadAndPresentError) {
                                                                                                               if (loadAndPresentError) {
                                                                                                                 // NSLog(@"[showPrivacyOptionsForm] Error loading and presenting consent form: %@", loadAndPresentError);
                                                                                                                 CDVPluginResult
                                                                                                                     *pluginResult = [CDVPluginResult
                                                                                                                         resultWithStatus:
                                                                                                                             CDVCommandStatus_ERROR
                                                                                                                          messageAsString:
                                                                                                                              loadAndPresentError
                                                                                                                                  .description];
                                                                                                                 [self.commandDelegate
                                                                                                                     sendPluginResult:
                                                                                                                         pluginResult
                                                                                                                           callbackId:
                                                                                                                               command
                                                                                                                                   .callbackId];
                                                                                                               } else {
                                                                                                                 /// NSLog(@"[showPrivacyOptionsForm] Consent form successfully displayed.");
                                                                                                               }
                                                                                                             }];

                                                                                if ([self
                                                                                        isPrivacyOptionsRequired]) {
                                                                                  // NSLog(@"[isPrivacyOptionsRequired] Privacy options required.");
                                                                                  [self
                                                                                      privacyOptionsFormShow:
                                                                                          command];
                                                                                } else {
                                                                                  // NSLog(@"[isPrivacyOptionsRequired] Privacy option form not required.");
                                                                                  CDVPluginResult
                                                                                      *pluginResult = [CDVPluginResult
                                                                                          resultWithStatus:
                                                                                              CDVCommandStatus_OK
                                                                                           messageAsString:
                                                                                               @"The privacy option form is not required."];
                                                                                  [self.commandDelegate
                                                                                      sendPluginResult:
                                                                                          pluginResult
                                                                                            callbackId:
                                                                                                command
                                                                                                    .callbackId];
                                                                                }
                                                                              }];
                 });
}

- (void)privacyOptionsFormShow:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [UMPConsentForm
          presentPrivacyOptionsFormFromViewController:self.viewController
                                    completionHandler:^(
                                        NSError *_Nullable formError) {
                                      if (formError) {
                                        //  NSLog(@"[privacyOptionsFormShow]
                                        //  Error displaying the privacy options
                                        //  form: %@", formError);
                                        CDVPluginResult *pluginResult =
                                            [CDVPluginResult
                                                resultWithStatus:
                                                    CDVCommandStatus_ERROR
                                                 messageAsString:
                                                     formError.description];
                                        [self.commandDelegate
                                            sendPluginResult:pluginResult
                                                  callbackId:command
                                                                 .callbackId];
                                      } else {
                                        //  NSLog(@"[privacyOptionsFormShow] The
                                        //  privacy options form is successfully
                                        //  displayed.");
                                      }
                                    }];
    });
  }];
}

// Cek apakah opsi privasi diperlukan
- (BOOL)isPrivacyOptionsRequired {
  UMPPrivacyOptionsRequirementStatus status =
      UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus;
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
    NSNumber *CmpSdkID = [prefs valueForKey:@"IABT"
                                            @"CF_"
                                            @"CmpS"
                                            @"dkI"
                                            @"D"];
    NSString *gdprApplies = [prefs stringForKey:@"IABT"
                                                @"CF_"
                                                @"gdpr"
                                                @"Appl"
                                                @"ie"
                                                @"s"];
    NSString *PurposeConsents = [prefs stringForKey:@"IABT"
                                                    @"CF_"
                                                    @"Purp"
                                                    @"oseC"
                                                    @"onse"
                                                    @"nt"
                                                    @"s"];
    NSString *TCString = [prefs stringForKey:@"IABT"
                                             @"CF_"
                                             @"TCSt"
                                             @"rin"
                                             @"g"];
    result[@"IABTCF_"
           @"CmpSdkID"] = CmpSdkID;
    result[@"IABTCF_"
           @"gdprAppli"
           @"es"] = gdprApplies;
    result[@"IABTCF_"
           @"PurposeCo"
           @"nsents"] = PurposeConsents;
    result[@"IABTCF_"
           @"TCString"] = TCString;
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%@",  [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                 messageAsDictionary:result];
    [self fireEvent:@""
              event:@"on."
                    @"getI"
                    @"abTf"
                    @"c"
           withData:nil];
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
      //   extras.additionalParameters = @{@"npa" : Npa}; // Deprecated
      [request registerAdNetworkExtras:extras];
      [GADAppOpenAd
           loadWithAdUnitID:adUnitId
                    request:request
          completionHandler:^(GADAppOpenAd *ad, NSError *error) {
            if (error) {
              [self fireEvent:@""
                        event:@"on.appOpenAd.failed.loaded"
                     withData:nil];
             
              return;
            }
            self.appOpenAd = ad;
            self.appOpenAd.fullScreenContentDelegate = self;
            [self fireEvent:@"" event:@"on.appOpenAd.loaded" withData:nil];
            if (auto_Show) {
              if (self.appOpenAd &&
                  [self.appOpenAd
                      canPresentFromRootViewController:self.viewController
                                                 error:nil]) {
                [self.appOpenAd
                    presentFromRootViewController:self.viewController];
              } else {
                [self fireEvent:@""
                          event:@"on.appOpenAd.failed.show"
                       withData:nil];
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
      [GADInterstitialAd
           loadWithAdUnitID:adUnitId
                    request:request
          completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            if (error) {
              
            }
            self.interstitial = ad;
            self.interstitial.fullScreenContentDelegate = self;
            [self fireEvent:@"" event:@"on.interstitial.loaded" withData:nil];
            if (auto_Show) {
              if (self.interstitial &&
                  [self.interstitial
                      canPresentFromRootViewController:self.viewController
                                                 error:nil]) {
                [self.interstitial
                    presentFromRootViewController:self.viewController];
              } else {
                [self fireEvent:@""
                          event:@"on.interstitial.failed.show"
                       withData:nil];
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
  if (self.interstitial &&
      [self.interstitial canPresentFromRootViewController:self.viewController
                                                    error:nil]) {
    [self.interstitial presentFromRootViewController:self.viewController];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self fireEvent:@""
              event:@"on."
                    @"inte"
                    @"rsti"
                    @"tial"
                    @".fai"
                    @"led."
                    @"show"
           withData:nil];
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
      [GADRewardedInterstitialAd
           loadWithAdUnitID:adUnitId
                    request:request
          completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
            if (error) {
             /* NSLog(@"Rewarded ad failed to load with error: %@",
                    [error localizedDescription]); */
              return;
            }
            self.rewardedInterstitialAd = ad;
            isAdSkip = 1;
          //  NSLog(@"Rewarded ad loaded.");
            self.rewardedInterstitialAd.fullScreenContentDelegate = self;
            [self fireEvent:@"" event:@"on.rewardedInt.loaded" withData:nil];
            if (auto_Show) {
              if (self.rewardedInterstitialAd &&
                  [self.rewardedInterstitialAd
                      canPresentFromRootViewController:self.viewController
                                                 error:nil]) {
                [self.rewardedInterstitialAd
                    presentFromRootViewController:self.viewController
                         userDidEarnRewardHandler:^{
                           GADAdReward *reward =
                               self.rewardedInterstitialAd.adReward;
                           [self fireEvent:@""
                                     event:@"on.rewardedInt."
                                           @"userEarnedReward"
                                  withData:nil];
                           isAdSkip = 2;
                           NSString *rewardMessage = [NSString
                               stringWithFormat:@"Reward received with "
                                                @"currency %@ , amount %ld",
                                                reward.type,
                                                [reward.amount longValue]];
                           NSLog(@"%@", rewardMessage);
                         }];
              } else {
                [self fireEvent:@""
                          event:@"on.rewardedInt.failed.show"
                       withData:nil];
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
  if (self.rewardedInterstitialAd &&
      [self.rewardedInterstitialAd
          canPresentFromRootViewController:self.viewController
                                     error:nil]) {
    [self.rewardedInterstitialAd
        presentFromRootViewController:self.viewController
             userDidEarnRewardHandler:^{
               GADAdReward *reward = self.rewardedInterstitialAd.adReward;
               [self fireEvent:@""
                         event:@"on.rewardedInt.userEarnedReward"
                      withData:nil];
               isAdSkip = 2;
               NSString *rewardMessage = [NSString
                   stringWithFormat:@"Reward received with "
                                    @"currency %@ , amount %ld",
                                    reward.type, [reward.amount longValue]];
              NSLog(@"%"
                     @"@",
                     rewardMessage);
             }];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @"Int."
                    @"fail"
                    @"ed."
                    @"show"
           withData:nil];
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
      [GADRewardedAd
           loadWithAdUnitID:adUnitId
                    request:request
          completionHandler:^(GADRewardedAd *ad, NSError *error) {
            if (error) {
            /*  NSLog(@"Rewarded ad failed to load with error: %@",
                    [error localizedDescription]); */
              return;
            }
            self.rewardedAd = ad;
          //  NSLog(@"Rewarded ad loaded.");
            isAdSkip = 0;
            self.rewardedAd.fullScreenContentDelegate = self;
            [self fireEvent:@"" event:@"on.rewarded.loaded" withData:nil];
            if (auto_Show) {
              if (self.rewardedAd &&
                  [self.rewardedAd
                      canPresentFromRootViewController:self.viewController
                                                 error:nil]) {
                [self.rewardedAd
                    presentFromRootViewController:self.viewController
                         userDidEarnRewardHandler:^{
                           GADAdReward *reward = self.rewardedAd.adReward;
                           [self fireEvent:@""
                                     event:@"on.reward.userEarnedReward"
                                  withData:nil];
                           isAdSkip = 2;
                           NSString *rewardMessage = [NSString
                               stringWithFormat:
                                   @"Reward received with currency "
                                   @"%@ , amount %lf",
                                   reward.type, [reward.amount doubleValue]];
                           NSLog(@"%@", rewardMessage);
                         }];
              } else {
                [self fireEvent:@""
                          event:@"on.rewarded.failed.show"
                       withData:nil];
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
  if (self.rewardedAd &&
      [self.rewardedAd canPresentFromRootViewController:self.viewController
                                                  error:nil]) {
    [self.rewardedAd
        presentFromRootViewController:self.viewController
             userDidEarnRewardHandler:^{
               GADAdReward *reward = self.rewardedAd.adReward;
               [self fireEvent:@""
                         event:@"on.reward.userEarnedReward"
                      withData:nil];
               isAdSkip = 2;
               NSString *rewardMessage = [NSString
                   stringWithFormat:
                       @"Reward received with currency %@ , amount %lf",
                       reward.type, [reward.amount doubleValue]];
               NSLog(@"%"
                     @"@",
                     rewardMessage);
             }];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @".fai"
                    @"led."
                    @"show"
           withData:nil];
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

  NSString *collapsibleStatus =
      bannerView.isCollapsible ? @"collapsible" : @"not collapsible";
  NSDictionary *eventData = @{@"collapsible" : collapsibleStatus};
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:eventData
                                                     options:0
                                                       error:&error];

  if (!jsonData) {
  //  NSLog(@"Failed to serialize event data: %@", error);
  } else {
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    [self fireEvent:@"" event:@"on.is.collapsible" withData:jsonString];
  }

  [self fireEvent:@""
            event:@"on."
                  @"banner"
                  @".load"
         withData:nil];

  if (auto_Show) {
    if (self.bannerView) {
      [self addBannerViewToView:command];
      self.bannerView.hidden = NO;
    }
  } else {
    [self fireEvent:@""
              event:@"on."
                    @"bann"
                    @"er."
                    @"fail"
                    @"ed."
                    @"show"
           withData:nil];
  }
}
- (void)bannerView:(GADBannerView *)bannerView
    didFailToReceiveAdWithError:(NSError *)error {
  [self fireEvent:@""
            event:@"on."
                  @"banner"
                  @".faile"
                  @"d.load"
         withData:nil];

}
- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  [self fireEvent:@""
            event:@"on."
                  @"banner"
                  @".impre"
                  @"ssion"
         withData:nil];

}
- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  [self fireEvent:@""
            event:@"on."
                  @"banner"
                  @".open"
         withData:nil];

}
- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  [self fireEvent:@""
            event:@"on."
                  @"banner"
                  @".close"
         withData:nil];

}
- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  [self fireEvent:@""
            event:@"on."
                  @"banner"
                  @".did."
                  @"dismis"
                  @"s"
         withData:nil];
 
}
#pragma GADFullScreeContentDelegate implementation
- (void)adWillPresentFullScreenContent:(id)ad {
  if (adFormat == 1) {
    [self fireEvent:@""
              event:@"on."
                    @"appO"
                    @"penA"
                    @"d."
                    @"show"
           withData:nil];
  /*  NSLog(@"Ad will "
          @"present "
          @"full screen "
          @"content App "
          @"Open Ad.");
      */
  } else if (adFormat == 2) {
    [self fireEvent:@""
              event:@"on."
                    @"inte"
                    @"rsti"
                    @"tial"
                    @".sho"
                    @"w"
           withData:nil];
    [self fireEvent:@""
              event:@"onPr"
                    @"esen"
                    @"tAd"
           withData:nil];
  /*  NSLog(@"Ad will "
          @"present "
          @"full screen "
          @"content "
          @"interstitial"
          @"."); */
  } else if (adFormat == 3) {
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @".sho"
                    @"w"
           withData:nil];
    isAdSkip = 1;
   /* NSLog(@"Ad will "
          @"present "
          @"full screen "
          @"content "
          @"rewarded."); */
  } else if (adFormat == 4) {
    isAdSkip = 1;
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @"Int."
                    @"show"
                    @"ed"
           withData:nil];
   /* NSLog(@"Ad will "
          @"present "
          @"full screen "
          @"content "
          @"interstitial"
          @" rewarded."); */
  }
}
- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
  if (adFormat == 1) {
    [self fireEvent:@""
              event:@"on."
                    @"appO"
                    @"penA"
                    @"d."
                    @"fail"
                    @"ed."
                    @"load"
                    @"ed"
           withData:nil];
   /* NSLog(@"Ad failed "
          @"to present "
          @"full screen "
          @"content "
          @"with error "
          @"App Open Ad "
          @"%@.",
          [error localizedDescription]); */
  } else if (adFormat == 2) {
    [self fireEvent:@""
              event:@"on."
                    @"inte"
                    @"rsti"
                    @"tial"
                    @".fai"
                    @"led."
                    @"load"
           withData:nil];
   /* NSLog(@"Ad failed "
          @"to present "
          @"full screen "
          @"content "
          @"with error "
          @"interstitial"
          @" %@.",
          [error localizedDescription]); */
  } else if (adFormat == 3) {
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @".fai"
                    @"led."
                    @"load"
           withData:nil];
  /*  NSLog(@"Ad failed "
          @"to present "
          @"full screen "
          @"content "
          @"with error "
          @"rewarded "
          @"%@.",
          [error localizedDescription]); */
  } else if (adFormat == 4) {
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @"Int."
                    @"fail"
                    @"ed."
                    @"load"
           withData:nil];
  /*  NSLog(@"Ad failed "
          @"to present "
          @"full screen "
          @"content "
          @"with error "
          @"interstitial"
          @" "
          @"rewarded "
          @"%@.",
          [error localizedDescription]); */
  }
}

- (void)adDidDismissFullScreenContent:(id)ad {
  if (adFormat == 1) {
    [self fireEvent:@""
              event:@"on."
                    @"appO"
                    @"penA"
                    @"d."
                    @"dism"
                    @"isse"
                    @"d"
           withData:nil];
   /* NSLog(@"Ad did "
          @"dismiss "
          @"full screen "
          @"content App "
          @"Open Ad."); */
  } else if (adFormat == 2) {
    [self fireEvent:@""
              event:@"on."
                    @"inte"
                    @"rsti"
                    @"tial"
                    @".dis"
                    @"miss"
                    @"ed"
           withData:nil];
   /* NSLog(@"Ad did "
          @"dismiss "
          @"full screen "
          @"content "
          @"interstitial"
          @"."); */
  } else if (adFormat == 3) {
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @".dis"
                    @"miss"
                    @"ed"
           withData:nil];
    if (isAdSkip != 2) {
      [self fireEvent:@""
                event:@"on"
                      @".r"
                      @"ew"
                      @"ar"
                      @"de"
                      @"d."
                      @"ad"
                      @".s"
                      @"ki"
                      @"p"
             withData:nil];
    }
  /*  NSLog(@"Ad did "
          @"dismiss "
          @"full screen "
          @"content "
          @"rewarded."); */
  } else if (adFormat == 4) {
    if (isAdSkip != 2) {
      [self fireEvent:@""
                event:@"on"
                      @".r"
                      @"ew"
                      @"ar"
                      @"de"
                      @"dI"
                      @"nt"
                      @".a"
                      @"d."
                      @"sk"
                      @"ip"
             withData:nil];
    }
    [self fireEvent:@""
              event:@"on."
                    @"rewa"
                    @"rded"
                    @"Int."
                    @"dism"
                    @"isse"
                    @"d"
           withData:nil];
   /* NSLog(@"Ad did "
          @"dismiss "
          @"full screen "
          @"content "
          @"interstitial"
          @" rewarded."); */
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
