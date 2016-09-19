//
//  AppDelegate.swift
//  ChatBot
//
//  Created by Alexandr on 14.09.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreData = CoreDataStack.shared


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let storyboard = self.window?.rootViewController?.storyboard
        var root: UIViewController!
        if let _ = UserDefaults.standard.string(forKey: "user") {
            root = storyboard?.instantiateViewController(withIdentifier: "Chat")
        }
        else {
            root = storyboard?.instantiateViewController(withIdentifier: "Login")
        }
        
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        
        return true
    }


}

