//
//  AdsManager.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 02/04/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

public enum AdsIdentifiers {
    case banner
    case rewarded
    case interstitial

    var value: String {
        switch self {
        case .banner:
            if BuildInfo.isDev {
                return "ca-app-pub-3940256099942544/2934735716"
            } else {
                return SuperSecretClass.bannerKey
            }
        case .rewarded:
            if BuildInfo.isDev {
                return "ca-app-pub-3940256099942544/1712485313"
            } else {
                return SuperSecretClass.rewardedKey
            }
        case .interstitial:
            if BuildInfo.isDev {
                return "ca-app-pub-3940256099942544/4411468910"
            } else {
                return SuperSecretClass.interstitialKey
            }
        }
    }
}

public class AdManager {
    private init() {
    }
    public static func start() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                _ = requestReady
                _ = rewardedAd
                _ = interstitialAd
            })
        } else {
            _ = requestReady
            _ = rewardedAd
            _ = interstitialAd
        }
    }

    //MARK: Commom to all ads
    private static let adQueue = DispatchQueue(label: "adLoading")

    private static var requestReady: GADRequest? = GADRequest()
    public static func getRequest() -> GADRequest {
        let aux: GADRequest
        if let request = requestReady {
            aux = request
            adQueue.async {
                requestReady = GADRequest()
            }
        } else {
            aux = GADRequest()
        }

        return aux
    }


    //MARK: Banner ads
    public static func getSizeFromView(view: UIView) -> GADAdSize {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
    }

    public static func loadBannerAd(into adView: GADBannerView, from presentingView: UIView) {
        adView.adSize = getSizeFromView(view: presentingView)
        adView.load(getRequest())
    }

    //MARK: Rewarded ads
    private static func createRewardedAd() -> GADRewardedAd {
        let newAd = GADRewardedAd(adUnitID: AdsIdentifiers.rewarded.value)
        newAd.load(getRequest(), completionHandler: nil)
        return newAd
    }
    private static var rewardedAd: GADRewardedAd? = createRewardedAd()

    public static func createAndLoadRewardedAd() -> GADRewardedAd {
        let aux: GADRewardedAd
        if let reward = rewardedAd {
            aux = reward
            adQueue.async {
                self.rewardedAd = self.createRewardedAd()
            }
        } else {
            aux = createRewardedAd()
        }

        return aux
    }

    //MARK: InterstitialAd
    private static func createInterstitialAd() -> GADInterstitial {
        let newAd = GADInterstitial(adUnitID: AdsIdentifiers.interstitial.value)
        newAd.load(getRequest())
        return newAd
    }
    private static var interstitialAd: GADInterstitial? = createInterstitialAd()

    public static func createAndLoadInterstitialAd() -> GADInterstitial {
        let aux: GADInterstitial
        if let interstitial = interstitialAd {
            aux = interstitial
            adQueue.async {
                self.interstitialAd = self.createInterstitialAd()
            }
        } else {
            aux = createInterstitialAd()
        }

        return aux
    }
}
