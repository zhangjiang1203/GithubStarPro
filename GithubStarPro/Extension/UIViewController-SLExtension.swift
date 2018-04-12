//
//  UIViewController-SLExtension.swift
//  CarBusiness-ios
//
//  Created by Sljr on 2018/3/8.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit

extension UIViewController{
    
    class func getCurrentViewController() -> UIViewController {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindowLevelNormal{
            let windows = UIApplication.shared.windows
            for  tempwin in windows{
                if tempwin.windowLevel == UIWindowLevelNormal{
                    window = tempwin
                    break
                }
            }
        }
        let frontView = (window?.subviews)![0]
        let nextResponder = frontView.next
        if (nextResponder is UIViewController){
            return nextResponder as! UIViewController
        }else if (nextResponder is UINavigationController){
            return (nextResponder as! UINavigationController).visibleViewController!
        }else {
            if (window?.rootViewController) is UINavigationController{
                return ((window?.rootViewController) as! UINavigationController).visibleViewController!//只有这个是显示的controller 是可以的必须有nav才行
            }else if ((window?.rootViewController) is UITabBarController){
                return ((window?.rootViewController) as! UITabBarController).selectedViewController! //不行只是最三个开始的页面
            }
            return (window?.rootViewController)!
        }
    }
}
