//
//  Utils.swift
//  WayPoint3.0
//
//  Created by ruby carrasco on 5/7/20.
//  Copyright © 2020 SCU. All rights reserved.
//


import UIKit

class Utils {
    fileprivate init () { }

    class func getStoryboard(_ storyboard: String = "Main") -> UIStoryboard {
        return UIStoryboard(name: storyboard, bundle: Bundle.main)
    }

    class func createViewController<T: UIViewController>(_ identifier: String, storyboard: String = "Main") -> T {
        return Utils.getStoryboard(storyboard)
            .instantiateViewController(withIdentifier: identifier) as! T 
    }
}
