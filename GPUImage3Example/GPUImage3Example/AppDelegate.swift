//
//  AppDelegate.swift
//  GPUImage3Example
//
//  Created by Ja on 2025/1/17.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.isEnabled = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let nav = UINavigationController(rootViewController: GPUImageProcessController())
        window?.rootViewController = nav
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

