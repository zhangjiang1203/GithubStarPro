//
//  ZJGitInfoModel.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit
import HandyJSON
@objcMembers
class ZJGitInfoModel: HandyJSON {
    
    var id:Int!// : 313419,
    var name:String! //:  SDWebImage ,
    var full_name:String! //:  rs/SDWebImage ,
    var html_url:String! //:  https://github.com/rs/SDWebImage ,
    var description:String! //:  Asynchronous image downloader with cache support as a UIImageView category ,
    var stargazers_count:Int = 0// : 19611,
    var watchers_count:Int = 0 //: 19611,
    var forks_count:Int = 0 //: 5100,
    var language :String! // Objective-C ,
    var owner:ZJOwner!
    var updated_at:String!
    
    var cellH :CGFloat{
        get{
            if let name = self.description {
                let name1:NSString = name as NSString
                let detailH = name1.boundingRect(with: CGSize(width: kScreenW-30, height: CGFloat(MAXFLOAT))
                    , options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 13)], context: nil).size.height
                return detailH + 132

            }else{
                return 132
            }
        }
    }
    
    
    required init() {
        
    }
}


class ZJOwner : HandyJSON{
    
    var login: String!// :  SnapKit ,
    var id : String!//: 7809696,
    var avatar_url: String!// :  https://avatars1.githubusercontent.com/u/7809696?v=4 ,
    var gravatar_id : String!//:   ,
   
    required init() {
        
    }
}
