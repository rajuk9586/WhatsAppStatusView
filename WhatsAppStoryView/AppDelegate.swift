//
//  AppDelegate.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setHomeController()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func setHomeController() {
        let storyboard = UIStoryboard(name: "Story", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "UpdatesVC") as? UpdatesVC else {
            fatalError("Storyboard does not contain the view controller...")
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.interactivePopGestureRecognizer?.isEnabled = true
        
        // Check if the window property is not nil before using it
        if let window = self.window {
            UIView.transition(with: window, duration: 0.5, options: .curveEaseInOut) {
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        } else {
            fatalError("Window is nil")
        }
    }
}

