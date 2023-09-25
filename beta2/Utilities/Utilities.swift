//
//  Utilities.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import UIKit
import Foundation

final class Utilities {
    
    static let shared = Utilities()
    
    private init() {}
    
    // This method fetches the topmost view controller
    func topViewController() -> UIViewController? {
        return topViewController(withRootViewController: UIApplication.shared.windows.first?.rootViewController)
    }
    
    private func topViewController(withRootViewController rootViewController: UIViewController?) -> UIViewController? {
        if let tabBarController = rootViewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return topViewController(withRootViewController: selectedViewController)
            }
        }
        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(withRootViewController: navigationController.visibleViewController)
        }
        if let presentedViewController = rootViewController?.presentedViewController {
            return topViewController(withRootViewController: presentedViewController)
        }
        return rootViewController
    }
}
