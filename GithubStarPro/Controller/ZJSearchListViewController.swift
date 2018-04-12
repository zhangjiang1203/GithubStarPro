//
//  ZJSearchListViewController.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import MJRefresh
class ZJSearchListViewController: UIViewController {
    fileprivate let bagDispose = DisposeBag()
    fileprivate let myCellIden = "ZJGitInfoCell"
    var page = 1
    var isUpdate = false
    var dataCount = 0
    fileprivate var searchBar = UISearchBar()
    @IBOutlet weak var myTableView: UITableView!
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,ZJGitInfoModel>>(configureCell:{_,tableview,indexPath,element in
        let cell = tableview.dequeueReusableCell(withIdentifier: "ZJGitInfoCell", for: indexPath) as! ZJGitInfoCell
        cell.selectionStyle = .none
        cell.gitModel = element
        return cell
    })
    var gitInfoArr:BehaviorSubject = BehaviorSubject.init(value: [SectionModel<String,ZJGitInfoModel>]())
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customeMySearchBar()
        myTableView.register(UINib.init(nibName: myCellIden, bundle: nil), forCellReuseIdentifier: myCellIden)
        myTableView.rx.setDelegate(self).disposed(by: bagDispose)
        myTableView.mj_footer = MJRefreshBackStateFooter.init(refreshingBlock: {
            //开始加载数据
            if let text = self.searchBar.text  {
                self.startSearchRepertoryList(text:text,isRefresh: false)
            }else{
                self.myTableView.mj_footer.endRefreshing()
            }
        })
        //绑定显示数据
        gitInfoArr.asObserver().bind(to: myTableView.rx.items(dataSource: dataSource)).disposed(by: bagDispose)
        myTableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            let data = try! self.gitInfoArr.value()
            let model = data[0].items[indexPath.row]
            let detailVC = ZJHubDetailViewController()
            detailVC.title = model.name
            detailVC.gitURL = model.html_url
            self.navigationController?.pushViewController(detailVC, animated: true)
        }).disposed(by: bagDispose)
        //开始滚动到最后的几个开始加载数据
        myTableView.rx.willDisplayCell.subscribe(onNext: { (cell,indexPath) in
            if let text = self.searchBar.text {
                if self.dataCount - indexPath.row < 8 && !self.isUpdate  && self.dataCount > 0{
                    self.isUpdate = true
                    //开始加载数据
                    self.startSearchRepertoryList(text:text,isRefresh: false)
                }
            }
        }).disposed(by: bagDispose)
    }
    
    //MARK: 设置搜索框和取消按钮
    func customeMySearchBar()  {
        searchBar = UISearchBar.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 30))
        searchBar.delegate = self
        searchBar.placeholder = "请输入仓库名称"
        self.searchBar.showsCancelButton = false
        searchBar.rx.text.orEmpty
            .throttle(0.4, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { (text) in
                if text.count > 0{
                    self.startSearchRepertoryList(text: text,isRefresh: true)
                }else{
                    self.gitInfoArr.onNext([])
                }
            }).disposed(by: bagDispose)
        searchBar.becomeFirstResponder()
        searchBar.returnKeyType = .search
        if #available(iOS 11.0, *) {
            searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        }
        self.navigationItem.titleView = searchBar
    }

   
    @IBAction func cancelButtonClick(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //开始搜索
    func startSearchRepertoryList(text:String,isRefresh:Bool) {
        if isRefresh {
            page = 1
        }else{
            page += 1
        }
        
        let URL = "https://api.github.com/search/repositories?q="+text+"&sort=stars&page="+"\(page)"
        let from = RequestFrom.getRequestForm(URL)
        SLNetworkTool.request(requestForm: from, successClosure: { (result) in
            guard let result = result as? [String : Any] else {
                self.gitInfoArr.onNext([])
                return
            }
            guard let tempData = result["items"] as? [[String:Any]] else{
                self.gitInfoArr.onNext([])
                return
            }
            let dataArr:Array<ZJGitInfoModel> = tempData.map({ (dict)  in
                ZJGitInfoModel.deserialize(from: dict)!
            })
            if isRefresh{
                self.dataCount = dataArr.count
                self.gitInfoArr.onNext([SectionModel.init(model: "first", items: dataArr)])
            }else{
                var arr = try! self.gitInfoArr.value()
                arr[0].items.append(contentsOf: dataArr)
                self.dataCount += dataArr.count
                self.gitInfoArr.onNext(arr)
                self.myTableView.mj_footer.endRefreshing()
            }
        }) { (error) in
            self.myTableView.mj_footer.endRefreshing()
            print(error.localizedDescription)
        }
    }
    
}

extension ZJSearchListViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //开始点击搜索
        if let text = searchBar.text {
            self.searchBar.endEditing(true)
            startSearchRepertoryList(text:text,isRefresh: true)
        }
    }
}

extension ZJSearchListViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dataArr = try! self.gitInfoArr.value()
        return dataArr[0].items[indexPath.row].cellH
    }
    
}
