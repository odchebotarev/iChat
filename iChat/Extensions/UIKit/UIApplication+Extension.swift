//
//  UIApplication+Extension.swift
//  iChat
//
//  Created by Oleg Chebotarev on 24.10.2020.
//

import UIKit

extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = (UIApplication.shared.windows.first { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
    
}
