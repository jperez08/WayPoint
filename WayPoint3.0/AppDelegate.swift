//
//  AppDelegate.swift
//  WayPoint3.0
//
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

     func application(_ application: UIApplication, didFinishLaunchingWithOptions
         launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

         UIApplication.shared.isIdleTimerDisabled = true

         self.window = UIWindow(frame: UIScreen.main.bounds)

         self.window!.makeKeyAndVisible()

         if #available(iOS 11.0, *) {
             guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                 return false
             }
             self.window!.rootViewController = vc
         }
        return true
        
    }


    //Call when a new scene session is created
    //Use this method to select a configuration to create the new scene with
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  
    }
}
