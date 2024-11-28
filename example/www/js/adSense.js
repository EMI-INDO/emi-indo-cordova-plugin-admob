

function registerWebView() {

    if (typeof cordova !== 'undefined') {

        cordova.plugins.emiAdmobPlugin.registerWebView(
            function(successMessage) {
                console.log("WebView registered successfully", successMessage);  
            },
            function(errorMessage) {
                console.error("If there is an error", errorMessage);  
            }
        );

    }
}



    
// test Ad https://webview-api-for-ads-test.glitch.me

function loadUrl() {

    if (typeof cordova !== 'undefined') {

        cordova.plugins.emiAdmobPlugin.loadUrl({
            url: "https://webview-api-for-ads-test.glitch.me"
            },
            function(successMessage) {
                console.log("URL loaded successfully", successMessage);  
            },
            function(errorMessage) {
                console.error("If there is an error", errorMessage);  
            }
        );

    }
}

  
    

