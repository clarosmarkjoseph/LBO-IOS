//
//  RotatableView.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/2/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation
/*
 This is an update to an example found on http://www.jairobjunior.com/blog/2016/03/05/how-to-rotate-only-one-view-controller-to-landscape-in-ios-slash-swift/
 The code there works, with some updating to the latest Swift, but the pattern isn't very Swifty. The following is what I found to be more helpful.
 */

/*
 First, create a protocol that UIViewController's can conform to.
 This is in opposition to using `Selector()` and checking for the presence of an empty function.
 */

/// UIViewControllers adopting this protocol will automatically be opted into rotating to all but bottom rotation.
///
/// - Important:
/// You must call resetToPortrait as the view controller is removed from view. Example:
///
/// ```
/// override func viewWillDisappear(_ animated: Bool) {
///   super.viewWillDisappear(animated)
///
///   if isMovingFromParentViewController {
///     resetToPortrait()
///   }
/// }
/// ```
protocol RotatableView: AnyObject {
    func resetToPortrait()
}

extension RotatableView where Self: UIViewController {
    func resetToPortrait() {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }
}

/*
 Next, extend AppDelegate to check for VCs that conform to Rotatable. If they do allow device rotation.
 Remember, it's up to the conforming VC to reset the device rotation back to portrait.
 */

// MARK: - Device rotation support
extension AppDelegate {
    // The app disables rotation for all view controllers except for a few that opt-in by conforming to the Rotatable protocol

    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController is PremiereCardPageviewController) {
                // Unlock landscape view orientations for this view controller
                return .landscapeLeft
            }
            if (rootViewController is TransactionPreviewAttachmentController) {
                // Unlock landscape view orientations for this view controller
                return .landscapeLeft
            }
            
        }
        // Only allow portrait (standard behaviour)
        return .portrait;
    }
   
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) {
            return nil
        }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        }
        else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        }
        else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
    
    
}
