// cordova.plugins.emiAdmobPlugin.styleBannerAd({ padding: 50, margins: 50 });  // (Optional only android)
//cordova.plugins.emiAdmobPlugin.loadBannerAd({config});
//cordova.plugins.emiAdmobPlugin.showBannerAd(); // default
//cordova.plugins.emiAdmobPlugin.hideBannerAd(); // default
//cordova.plugins.emiAdmobPlugin.removeBannerAd(); // default



function loadBanner() {

    if (typeof cordova !== 'undefined') {

        cordova.plugins.emiAdmobPlugin.loadBannerAd({
            adUnitId: Banner_ID, //Banner_ID,
            position: "bottom-center",
            size: "responsive_adaptive", // autoResize: true (only responsive_adaptive)
            collapsible: "bottom", // position: top | bottom (disable, empty string)
            autoResize: true, // on.screen.rotated === orientation.portrait || on.screen.rotated === orientation.landscape
            autoShow: true, // boolean

        });
    }

}


/* bannerAd position 

(ANDROID)

top-right
top-center
left
center
right
bottom-center
bottom-right

(IOS)

bottom-center
top-center

*/

/* bannerAd size

(ANDROID)

responsive_adaptive
anchored_adaptive
full_width_adaptive
in_line_adaptive
banner
large_banner
medium_rectangle
full_banner
leaderboard
fluid

(IOS)

responsive_adaptive
in_line_adaptive
banner
large_banner
full_banner
leaderboard



*/

/* banner event
on.banner.load
on.banner.failed.load
on.banner.click
on.banner.close
on.banner.impression
on.banner.open
 // new
on.banner.revenue
on.banner.remove
on.banner.hide
 // new
 on.is.collapsible

 */




// EVENT

document.addEventListener('on.banner.load', () => {
    console.log("on banner load");
});


document.addEventListener('on.is.collapsible', function (event) {
    // bannerConfig collapsible: "bottom", // position: top | bottom (disable, empty string)
    console.log("Collapsible Status: " + event.collapsible);


});

document.addEventListener('on.banner.failed.load', (error) => {
    console.log("on.banner.failed.load" + JSON.stringify(error));
});