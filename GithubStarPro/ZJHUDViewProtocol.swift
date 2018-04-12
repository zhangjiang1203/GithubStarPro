//
//  ZJHUDViewProtocol.swift
//  GithubStarPro
//
//  Created by 张江 on 2018/3/31.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol ZJHUDViewProtocol {
    
    /// 显示的视图
    var target:UIView{ get }
    
    /// 显示加载loading
    ///
    /// - Parameter title: 加载提示语
    /// - Returns: void
    func showLoading(title:String?) -> Void
    
    /// 显示提示信息
    ///
    /// - Parameters:
    ///   - message: message
    ///   - duration: 时长显示 不设置为默认值
    /// - Returns: void
    func show(message:String,duration:Double) -> Void
    
    /// 显示图片和提示语句
    ///
    /// - Parameters:
    ///   - message: message
    ///   - image: 图片名称
    ///   - duration:显示时间
    /// - Returns: void
    func showHUD(message:String,image:String,duration:Double) -> Void
    
    /// 隐藏所有的hud
    ///
    /// - Returns: void
    func hiddenAllHUD() -> Void
    
}

extension ZJHUDViewProtocol{
    var target:UIView {
        return UIApplication.shared.keyWindow!
    }
    
    func showLoading(title:String?) {
        hiddenAllHUD()
        let myHud = initMyHUDView()
        myHud.mode = .indeterminate
        if let title = title {
            myHud.label.text = title
            myHud.bezelView.frame = CGRect.init(x: 0, y: 0, width: 96, height: 96)
        }else{
            myHud.bezelView.frame = CGRect.init(x: 0, y: 0, width: 96, height: 96)
        }
    }
    
    func show(message:String,duration:Double) -> Void{
        let myHud = initMyHUDView()
        myHud.mode = .text
        myHud.margin = 14
        myHud.bezelView.frame = CGRect.init(x: 0, y: 0, width: 48, height: 48)
        myHud.label.numberOfLines = 0
        myHud.hide(animated: true, afterDelay: duration)
    }
    
    func showHUD(message:String,image:String,duration:Double){
        hiddenAllHUD()
        let myHud = initMyHUDView()
        myHud.mode = .customView
        myHud.minSize = CGSize.init(width: 96, height: 96)
        //设置属性
        myHud.label.text = message
        //自定义显示图片
        let imageView = UIImageView(image: UIImage(named: image))
        imageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        myHud.customView = imageView;

        myHud.hide(animated: true, afterDelay: duration)
    }
    
    func initMyHUDView() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: target, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.label.font = UIFont.systemFont(ofSize: 14)
        hud.label.textColor = UIColor.hexColor("#666666")
        hud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        hud.margin = 10
        return hud
    }
    
    func hiddenAllHUD() {
        MBProgressHUD.hide(for: target, animated: true)
    }
}

extension ZJHUDViewProtocol where Self : UIViewController{
    var target:UIView{ return self.view }
}

extension ZJHUDViewProtocol where Self : UIView {
    var target:UIView { return self}
}


extension UIViewController:ZJHUDViewProtocol{
}

extension UIView :ZJHUDViewProtocol{}

