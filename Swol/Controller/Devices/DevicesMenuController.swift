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

public class DevicesMenuController: UIViewController {
    weak var tableViewController: DevicesTableViewController?
    var selectedDevice: DeviceProtocol? {
        return tableViewController?.selectedDevice
    }
    @IBOutlet var bannerView: GADBannerView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBannerAd()
    }

    public override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
    }

    func loadBannerAd() {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
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
