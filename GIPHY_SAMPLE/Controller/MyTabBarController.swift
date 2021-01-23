//
//  MyTabBarController.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/17.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navi = viewController as? UINavigationController {
            navi.popToRootViewController(animated: false)
        }
    } 
}
