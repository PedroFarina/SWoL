//
//  DevicesMenuController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 02/04/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd
import GoogleMobileAds

public class DevicesMenuController: UIViewController, GADRewardedAdDelegate {
    weak var tableViewController: DevicesTableViewController?
    var selectedDevice: DeviceProtocol? {
        return tableViewController?.selectedDevice
    }
    @IBOutlet var bannerView: GADBannerView!
    var rewardAd: GADRewardedAd?

    public override func viewDidLoad() {
        super.viewDidLoad()
        rewardAd = AdManager.createAndLoadRewardedAd()

        bannerView.adUnitID = AdsIdentifiers.banner.value
        bannerView.rootViewController = self
        if !UserDefaults.standard.bool(forKey: "tutorial") {
            UserDefaults.standard.set(true, forKey: "tutorial")
            self.performSegue(withIdentifier: "tutorial", sender: self)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AdManager.loadBannerAd(into: bannerView, from: view)
    }

    public override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            AdManager.loadBannerAd(into: self.bannerView, from: self.view)
        })
    }

    @IBAction func newDeviceTap(_ sender: Any) {
        if (rewardAd?.isReady ?? false) && (!(tableViewController?.devices.isEmpty ?? true)) {
            rewardAd?.present(fromRootViewController: self, delegate: self)
        } else {
            self.performSegue(withIdentifier: "newDevice", sender: self)
        }
    }

    var rewarded: Bool = false
    public func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        rewarded = true
    }

    let rewardAdDismissAlert: UIAlertController = {
        let alert =  UIAlertController(title: "Oops!", message: "This app uses ads to support the developer, please consider watching them.".localized(), preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }()
    public func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if rewarded {
            self.performSegue(withIdentifier: "newDevice", sender: self)
        } else {
            self.present(rewardAdDismissAlert, animated: true)
        }
        self.rewardAd = AdManager.createAndLoadRewardedAd()
    }

    public func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        self.performSegue(withIdentifier: "newDevice", sender: self)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cont = segue.destination as? DevicesTableViewController {
            self.tableViewController = cont
        } else if let nav = segue.destination as? UINavigationController,
            let view = nav.topViewController as? AddingDeviceTableViewController {
            view.device = selectedDevice
        }
    }
}
