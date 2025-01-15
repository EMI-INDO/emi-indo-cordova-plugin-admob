
window.log = document.getElementById('log');

var App_Open_ID;
var Banner_ID;
var Interstitial_ID;
var Rewarded_ID;
var Rewarded_Interstitial_ID;

// Ad format	Demo ad unit ID
// https://developers.google.com/admob/android/test-ads
// https://developers.google.com/admob/ios/test-ads


/* https://support.google.com/admob/answer/9493252?hl=en
Best practice when using ad original ID unit, 
the app must be uploaded to the play store or app store, 
and you must upload it from there, 
otherwise you may be subject to ad serving restrictions, 
if it happens often, it is possible that your admob account will be permanently disabled.
*/

let isPlatformIOS = false;

if (window.cordova.platformId === 'ios') {

    App_Open_ID = 'ca-app-pub-3940256099942544/5575463023';
    Banner_ID = 'ca-app-pub-3940256099942544/2934735716';
    Interstitial_ID = 'ca-app-pub-3940256099942544/4411468910';
    Rewarded_ID = 'ca-app-pub-3940256099942544/1712485313';
    Rewarded_Interstitial_ID = 'ca-app-pub-3940256099942544/6978759866';

    isPlatformIOS = true;

} else {
    // Assume Android
    App_Open_ID = 'ca-app-pub-3940256099942544/9257395921';
    Banner_ID = 'ca-app-pub-3940256099942544/9214589741';
    Interstitial_ID = 'ca-app-pub-3940256099942544/1033173712';
    Rewarded_ID = 'ca-app-pub-3940256099942544/5224354917';
    Rewarded_Interstitial_ID = 'ca-app-pub-3940256099942544/5354046379';
}




function cleanText(){

    window.log.value = "";

    }



//////////////////////
// cordova deviceready
/////////////////////
document.addEventListener("deviceready", function () {


    // targeting
    cordova.plugins.emiAdmobPlugin.targeting({
        childDirectedTreatment: false, // default: false
        underAgeOfConsent: false, // default: false
        contentRating: "MA", // value: G | MA | PG | T | ""
    });



    // globalSettings 
    cordova.plugins.emiAdmobPlugin.globalSettings({
        setAppMuted: false, // Type Boolean default: false
        setAppVolume: 1.0, // Type float
        pubIdEnabled: false, // default: false
    });



    if (isPlatformIOS){
        
        cordova.plugins.emiAdmobPlugin.requestIDFA(); // requestTrackingAuthorization
        
    } 


   // (Optional IOS | ANDROID) 
   // Documentation: https://github.com/EMI-INDO/emi-indo-cordova-plugin-admob/discussions/54
    /*  
     cordova.plugins.emiAdmobPlugin.metaData({

            useCustomConsentManager: false, // deactivate Google's consent Default false (IOS | ANDROID)
            isEnabledKeyword: false, // Default false (IOS | ANDROID)
            setKeyword: "" // string separated by commas without spaces (IOS | ANDROID) 

    });
    */

    // AdMob Sdk initialize
    
    cordova.plugins.emiAdmobPlugin.initialize({

        isUsingAdManagerRequest: true, // true = AdManager | false = AdMob (Default true)
        isResponseInfo: true, // debug Default false
        isConsentDebug: true, // debug Default false

    });


    // SDK EVENT Initialization
    // Optional
    document.addEventListener('on.sdkInitialization', (data) => {
        // JSON.stringify(data)
        const sdkVersion = data.version;
        // const adAdapter = data.adapters;
        const conStatus = data.consentStatus;
        const attStatus = data.attStatus;
        // const gdprApplie = data.gdprApplies;
        // const purposeConsent = data.purposeConsents;
        // const vendorConsents = data.vendorConsents;
        // const conTCString = data.consentTCString;
        // const additionalConsent = data.additionalConsent;
        log.value += ("\n On Sdk Initialization version: " + sdkVersion);
        log.value += ("\n On Consent Status: " + conStatus);
        
        if (isPlatformIOS){
            
            log.value += ("\n On Authorization Status: " + attStatus);
        }

        loadBanner(); // auto show

    });



}, false);