


function showPrivacyOptionsForm() {
    
    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.showPrivacyOptionsForm(); // IOS | Android
    }
    
}




/*
There is a method to force the show Privacy Options Form

NOTE forceDisplayPrivacyForm

This method is not recommended, as no matter what country the form is in, it will still be displayed.
So this method must be called with an on-click, so that it is not triggered continuously.
use this method wisely.

*/


function forceDisplayPrivacyForm() {
    
    if (typeof cordova !== 'undefined') {
        cordova.plugins.emiAdmobPlugin.forceDisplayPrivacyForm(); // Only IOS
    }
    
}