//
//  ZJGitManager.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit

class ZJGitManager: NSObject {

    //添加绑定的数据
    fileprivate var indexsDataArr = [[ZJGitInfoModel]]()
    fileprivate var pagesArr = [NSInteger]()
    
    override init() {
        super.init()
        //初始化数据参数
//        let fiveZs = Array(repeating: "Z", count: 5)
        ///     print(fiveZs)
        ///     // Prints "["Z", "Z", "Z", "Z", "Z"]"

        pagesArr = Array(repeating: 1, count: 15)
        indexsDataArr = Array(repeating:[ZJGitInfoModel](),count:15)
    }
    
    /// 设置请求参数
    ///
    /// - Parameters:
    ///   - index: 当前对应的index
    ///   - isRefresh: 是否是刷新
    ///   - params: 返回的页面字符串
    fileprivate func setMyParams(index:NSInteger,isRefresh:Bool,params:(String,String)->Void) {
        var page = 1
        if !isRefresh {
            page = pagesArr[index]
            page += 1
            pagesArr[index] = page
        }
        params("\(page)",chooseLanguage[index])
    }
    
    /// 滚动设置
    ///
    /// - Parameters:
    ///   - index: 当前的index
    ///   - data: 返回的数据
    func requestMyGitInfo(index:NSInteger,data:@escaping (Array<ZJGitInfoModel>)->Void) {
        let dataArr = indexsDataArr[index]
        if dataArr.count > 0 {
            //有历史数据
            data(dataArr)
        }else{
            getMyGitListInfo(index: index, isRefresh: true) { (orderData,status,moreData) in
                if self.indexsDataArr[index].count > 0{
                    self.indexsDataArr[index] = [ZJGitInfoModel]()
                }
                //开始处理数据
                self.indexsDataArr[index].append(contentsOf:orderData)
                data(self.indexsDataArr[index])
            }
        }
    }
    
    /// 刷新订单信息
    ///
    /// - Parameters:
    ///   - index: 当前的index
    ///   - data: 对应返回的数据
    func refreshMyGitInfo(index:NSInteger,data:@escaping (Array<ZJGitInfoModel>,Bool,NSInteger)->Void) {
        getMyGitListInfo(index: index, isRefresh: true) { (orderData, status, isMoreData) in
            if self.indexsDataArr[index].count > 0{
                self.indexsDataArr[index] = [ZJGitInfoModel]()
            }
            
            self.indexsDataArr[index].append(contentsOf:orderData)
            data(self.indexsDataArr[index],status,isMoreData)
        }
    }
    
    /// 加载更多订单信息
    ///
    /// - Parameters:
    ///   - index: 当前的index
    ///   - data: 对应返回的数据 (订单数据,加载状态，是否是最后的数据)
    func loadMoreGitInfo(index:NSInteger,data:@escaping (Array<ZJGitInfoModel> ,Bool,NSInteger)->Void) {
        getMyGitListInfo(index: index, isRefresh: false) { (orderData, status, isMoreData) in
            self.indexsDataArr[index].append(contentsOf: orderData)
            data(self.indexsDataArr[index],status,isMoreData)
        }
    }
    
    
    /// 请求订单信息
    ///
    /// - Parameters:
    ///   - index: 当前的index
    ///   - isRefresh: 是否是刷新
    ///   - data: 对应返回的数据 (订单数据,加载状态，是否是最后的数据0 加载没有数据 1 加载有数据 2 加载失败)
    fileprivate func getMyGitListInfo(index:NSInteger,isRefresh:Bool,data:@escaping (Array<ZJGitInfoModel>,Bool,NSInteger)->Void)  {
        setMyParams(index: index, isRefresh: isRefresh) { (pageStr,language) in
            //开始网络请求信息
            let VC = UIViewController.getCurrentViewController()
            if isRefresh{
                VC.showLoading(title: nil)
            }
            print("开始请求网络信息" + (pageStr as String) + "当前的index：\(index)")
            let URL = "https://api.github.com/search/repositories?q=language:"+language+"&sort=stars&page="+pageStr
            let from = RequestFrom.getRequestForm(URL)
            SLNetworkTool.request(requestForm: from, successClosure: { (result) in
                VC.hiddenAllHUD()
                guard let result = result as? [String : Any] else {
                    data([],isRefresh,0)
                    return
                }
                guard let tempData = result["items"] as? [[String:Any]] else{
                    data([],isRefresh,0)
                    return
                }
                let dataArr:Array<ZJGitInfoModel> = tempData.map({ (dict)  in
                    ZJGitInfoModel.deserialize(from: dict)!
                })
                data(dataArr,isRefresh,dataArr.count>0 ? 1 : 0)
            }) { (error) in
                data([],isRefresh,2)
                VC.hiddenAllHUD()
                print(error.localizedDescription)
            } 
        }
    }
}
