//
//  SceneDelegate.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 03/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        SceneDelegate.willEnterForeground?()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let userDefaults = UserDefaults.standard
            let interfaceStyle = self.window?.traitCollection.userInterfaceStyle

            if !userDefaults.bool(forKey: UserDefaultsNames.notFirstTime.rawValue) && interfaceStyle == .dark {
                userDefaults.setValue(true, forKey: UserDefaultsNames.darkMode.rawValue)
                userDefaults.setValue(true, forKey: UserDefaultsNames.notFirstTime.rawValue)
                self.changeIcon(to: "DarkIcon")
                return
            }

            let isDarkMode = userDefaults.bool(forKey: UserDefaultsNames.darkMode.rawValue)

            if interfaceStyle == .dark && !isDarkMode {
                self.changeIcon(to: "DarkIcon")
                userDefaults.setValue(true, forKey: UserDefaultsNames.darkMode.rawValue)
            } else if interfaceStyle == .light && isDarkMode {
                self.changeIcon(to: nil)
                userDefaults.setValue(false, forKey: UserDefaultsNames.darkMode.rawValue)
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    internal static var willEnterForeground: (() -> Void)?

    private func changeIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        UIApplication.shared.setAlternateIconName(iconName)
    }
}

