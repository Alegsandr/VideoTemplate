//
//  AppDelegate.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let videoTemplateViewController = TemplateConfigurator().configureModule()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = videoTemplateViewController
        
        return true
    }
}

