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
        // Find the window scene that's currently being used.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        // Find the key window for this scene.
        guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        // Using the root view controller, find the top view controller.
        return topViewController(withRootViewController: rootViewController)
    }
    
    private func topViewController(withRootViewController rootViewController: UIViewController?) -> UIViewController? {
        // If it's a tab bar controller, recurse with the selected view controller.
        if let tabBarController = rootViewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            return topViewController(withRootViewController: selectedViewController)
        }
        // If it's a navigation controller, recurse with the visible view controller.
        if let navigationController = rootViewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController {
            return topViewController(withRootViewController: visibleViewController)
        }
        // If there's a presented view controller, recurse with it.
        if let presentedViewController = rootViewController?.presentedViewController {
            return topViewController(withRootViewController: presentedViewController)
        }
        // Otherwise, we've found the top view controller.
        return rootViewController
    }
}
