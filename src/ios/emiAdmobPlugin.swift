import Foundation
import GoogleMobileAds
import UIKit

@objc(emiAdmobPlugin)
public class emiAdmobPlugin : CDVPlugin, GADFullScreenContentDelegate, GADBannerViewDelegate {
 
    private var bannerView: GADBannerView!
    private var interstitial: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
 
    var isBannerShowing = false
   

    @objc
    func initialize(_ command: CDVInvokedUrlCommand) {

        let ads = GADMobileAds.sharedInstance()
            ads.start { status in
              // Optional: Log each adapter's initialization latency.
              let adapterStatuses = status.adapterStatusesByClassName
              for adapter in adapterStatuses {
                let adapterStatus = adapter.value
                NSLog("Adapter Name: %@, Description: %@, Latency: %f", adapter.key,
                adapterStatus.description, adapterStatus.latency)
              }
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.SdkInitializationComplete")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
    }

    
    @objc
    func showBannerAd(_ command: CDVInvokedUrlCommand) {
        let bannerAdUnitId = command.arguments[0] as? String ?? ""
        let position = command.arguments[1] as? String ?? ""
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = bannerAdUnitId
        bannerView.rootViewController = self.viewController
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView, position, view: webView)
        bannerView.delegate = self
    }
    
    
    func addBannerViewToView(_ bannerView: GADBannerView, _ position: String, view: UIView?) {
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view?.addSubview(bannerView)
        if position == "top" {
         
            view?.addConstraints( 
             [NSLayoutConstraint(item: bannerView,
                                 attribute: .top,
                                 relatedBy: .equal,
                                 toItem: view?.safeAreaLayoutGuide,
                                 attribute: .top,
                                 multiplier: 1,
                                 constant: 0), 
              NSLayoutConstraint(item: bannerView,
                                 attribute: .centerX,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .centerX,
                                 multiplier: 1,
                                 constant: 0)
             ])
            
        } else if position == "top-Margin" {
           
            view?.addConstraints(
            
            [NSLayoutConstraint(item: bannerView,
                                 attribute: .topMargin,
                                 relatedBy: .equal,
                                 toItem: view?.safeAreaLayoutGuide,
                                 attribute: .topMargin,
                                 multiplier: 1,
                                 constant: 0),
              NSLayoutConstraint(item: bannerView,
                                 attribute: .centerX,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .centerX,
                                 multiplier: 1,
                                 constant: 0)
             ])
            
        } else if position == "bottom" {
            
            view?.addConstraints(
            
            [NSLayoutConstraint(item: bannerView,
                                 attribute: .bottom,
                                 relatedBy: .equal,
                                 toItem: view?.safeAreaLayoutGuide,
                                 attribute: .bottom,
                                 multiplier: 1,
                                 constant: 0),
              NSLayoutConstraint(item: bannerView,
                                 attribute: .centerX,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .centerX,
                                 multiplier: 1,
                                 constant: 0)
             ])
            
            
        } else if position == "bottom-Margin" {
            
            view?.addConstraints(
            
            [NSLayoutConstraint(item: bannerView,
                                 attribute: .bottomMargin,
                                 relatedBy: .equal,
                                 toItem: view?.safeAreaLayoutGuide,
                                 attribute: .bottomMargin,
                                 multiplier: 1,
                                 constant: 0),
              NSLayoutConstraint(item: bannerView,
                                 attribute: .centerX,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .centerX,
                                 multiplier: 1,
                                 constant: 0)
             ])
            
            
            
        } else {
            
            
            view?.addConstraints(
            
            [NSLayoutConstraint(item: bannerView,
                                 attribute: .bottomMargin,
                                 relatedBy: .equal,
                                 toItem: view?.safeAreaLayoutGuide,
                                 attribute: .bottomMargin,
                                 multiplier: 1,
                                 constant: 0),
              NSLayoutConstraint(item: bannerView,
                                 attribute: .centerX,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .centerX,
                                 multiplier: 1,
                                 constant: 0)
             ]) 
        }  
    }
    
    
    @objc
    func removeBannerAd(_ command: CDVInvokedUrlCommand) {
        
        if(bannerView != nil){
            self.isBannerShowing = true;
        }
        
        if(self.isBannerShowing){
            
          self.isBannerShowing = self.unLoadBanner(self.bannerView)
        }
    }
    
    func unLoadBanner(_ bannerView: UIView?) -> Bool{
            bannerView?.removeFromSuperview()
            return false
    }
 
 
    @objc
    func loadInterstitialAd(_ command: CDVInvokedUrlCommand) {
     
        let interstitialAdAdUnitId = command.arguments[0] as? String ?? ""
        
        let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: interstitialAdAdUnitId,
                                        request: request,
                              completionHandler: { [self] ad, error in
                                if let error = error {
                                  print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.InterstitialAdFailedToLoad")
                                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                                  return   
                                }

                               self.interstitial = ad
                               self.interstitial?.fullScreenContentDelegate = self
                              
                               let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.InterstitialAdLoaded")
                               self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                                
                              } )

    }
 
    @objc
    func showInterstitialAd(_ command: CDVInvokedUrlCommand) {
     if interstitial != nil {
        interstitial?.present(fromRootViewController: self.viewController)
      } else {
        print("Ad wasn't ready")  
      }
    }

    @objc
    func loadRewardedAd(_ command: CDVInvokedUrlCommand) {
        let rewardedAdAdUnitId = command.arguments[0] as? String ?? ""
        let request = GADRequest()
            GADRewardedAd.load(
            withAdUnitID:rewardedAdAdUnitId,
            request: request,
            completionHandler: {
            [self] ad, error in
              if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.RewardedAdFailedToLoad")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
              }
              rewardedAd = ad
              print("Rewarded ad loaded.")
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.RewardedAdLoaded")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId) 
            }
        )   
    }

    @objc
    func showRewardedAd(_ command: CDVInvokedUrlCommand) {
        
        if let ad = rewardedAd {
            ad.present(fromRootViewController: self.viewController) {
              let reward = ad.adReward
              print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
              // TODO: Reward the user.
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.rewarded.rewarded")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
          } else {
            print("Ad wasn't ready")
          } 
    }
    
    
    @objc
    func loadRewardedInterstitialAd(_ command: CDVInvokedUrlCommand) {
        let interstitialAdAdUnitId = command.arguments[0] as? String ?? ""
        GADRewardedInterstitialAd.load(
            withAdUnitID:interstitialAdAdUnitId,
            request: GADRequest()) { ad, error in
              if let error = error {
                return print("Failed to load rewarded interstitial ad with error: \(error.localizedDescription)")
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.RewardedInterstitialAdFailedToLoad")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              }
              self.rewardedInterstitialAd = ad
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.RewardedInterstitialAdLoaded")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } 
    }

    @objc
    func showRewardedInterstitialAd(_ command: CDVInvokedUrlCommand) {
        
        if rewardedInterstitialAd != nil {
            rewardedInterstitialAd?.present(fromRootViewController: self.viewController) {
             // let reward = rewardedInterstitialAd?.adReward
              // TODO: Reward the user!
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "on.rewardedInterstitial.rewarded")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
          } else {
            print("Ad wasn't ready")
          } 
    }
    
    
    
}
