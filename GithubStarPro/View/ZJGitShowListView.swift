//
//  ZJGitShowListView.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit
import MJRefresh
class ZJGitShowListView: UIView {

    fileprivate let myCellIden = "ZJGitInfoCell"
    var isUpdate = false
    var dataCount = 0
    
    var headerFresh:MJRefreshNormalHeader!
    var footerFresh:MJRefreshBackStateFooter!
    
    
    ///跳转视图
    var parentVC:UIViewController!
    
    /// false 加载更多  true 刷新
    var refreshClouse :((_ isRefresh:Bool)->Void)!
    var myTableView:UITableView!
    var orderDataArr = [ZJGitInfoModel](){
        didSet{
            myTableView.reloadData()
        }
    }
    
    //  初始化列表
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        setUpMyOrderList()
    }
    
    //开始设置UI界面
    func setUpMyOrderList() {
        myTableView = UITableView.init(frame: self.frame)
        myTableView.showsVerticalScrollIndicator = false
        myTableView.showsHorizontalScrollIndicator = false
        myTableView.separatorStyle = .none
        myTableView.backgroundColor = UIColor.hexColor("#fafafa")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.register(UINib.init(nibName: myCellIden, bundle: nil), forCellReuseIdentifier: myCellIden)
        self.addSubview(myTableView)
        
        headerFresh = MJRefreshNormalHeader.init(refreshingBlock: {
            guard let block = self.refreshClouse else { return }
            block(true)
        });
        myTableView.mj_header = headerFresh
        footerFresh = MJRefreshBackStateFooter.init(refreshingBlock: {
            guard let block = self.refreshClouse else { return }
            if !self.isUpdate{
                block(false)
            }
        });
        myTableView.mj_footer = footerFresh
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ZJGitShowListView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: myCellIden) as! ZJGitInfoCell
        cell.selectionStyle = .none
        cell.gitModel = orderDataArr[indexPath.row]
        cell.clickBlock = {index in
            print("当前点击" + "\(index)")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return orderDataArr[indexPath.row].cellH
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //开始跳转视图
        myTableView.mj_footer.endRefreshing()
        myTableView.mj_header.endRefreshing()
        let model = orderDataArr[indexPath.row]
        let detailVC = ZJHubDetailViewController()
        detailVC.title = model.name
        detailVC.gitURL = model.html_url!
        self.parentVC.navigationController?.pushViewController(detailVC, animated: true)
    }

    //开始滚动到最后的几个开始加载数据
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if dataCount - indexPath.row < 8 && !isUpdate && dataCount > 0 {
            isUpdate = true
            //开始加载数据
            guard let block = self.refreshClouse else { return }
            block(false)
        }
    }
    
}
