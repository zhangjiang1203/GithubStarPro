//
//  ViewController.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit
import iCarousel

let segmentH:CGFloat = 40
class ViewController: UIViewController {
    
    //分段显示视图
    fileprivate var segmentView = ZJSegmentScrollView()
    //滚动视图
    fileprivate var icarouselView = iCarousel()
    
    var gitManager = ZJGitManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置样式
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.extendedLayoutIncludesOpaqueBars = false;
        self.modalPresentationCapturesStatusBarAppearance = false;
        
        setUpMyDataUI()
    }
    
    func setUpMyDataUI() {
        segmentView = ZJSegmentScrollView.init(frame: CGRect.init(x: 0, y: kNavBarH, width: kScreenW, height: segmentH))
        segmentView.segmentTitleArr = chooseLanguage as Array<NSString>
        segmentView.selectedColor = UIColor.hexColor("#FF9000")!
        segmentView.normalColor = UIColor.hexColor("#333333")!
        segmentView.buttonFont = UIFont.systemFont(ofSize: 15)
        segmentView.lineWidth = 42
        segmentView.lineHeight = 2
        segmentView.scrollClouse = { index in
            //设置请求数据
            self.gitManager.requestMyGitInfo(index: index, data: { (dataArr) in
                //返回的数据信息
                self.icarouselView.scrollToItem(at: index, animated: false)
                let pageView = self.icarouselView.itemView(at: index) as! ZJGitShowListView
                pageView.orderDataArr = dataArr
            })
        }
        self.view.addSubview(segmentView)
        
        //添加view
        icarouselView = iCarousel.init(frame: CGRect.init(x: 0, y: kNavBarH+segmentH, width: kScreenW, height: kScreenH-64-segmentH));
        icarouselView.delegate = self
        icarouselView.dataSource = self
        icarouselView.backgroundColor = UIColor.white
        icarouselView.type = .linear;
        icarouselView.decelerationRate = 0.75;
        icarouselView.isPagingEnabled = true;
        self.view.addSubview(icarouselView)
        
        segmentView.setScrollToIndex(index: 0)
        self.icarouselView.scrollToItem(at: 0, animated: false)
    }
}

extension ViewController:iCarouselDelegate,iCarouselDataSource{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 15
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let gitView = ZJGitShowListView.init(frame: carousel.bounds)
        gitView.parentVC = self
        gitView.refreshClouse = {
            refresh in
            if refresh {
                self.gitManager.refreshMyGitInfo(index: index, data: { (dataArr, refresh, moreData) in
                    let pageView = self.icarouselView.itemView(at: index) as! ZJGitShowListView
                    pageView.orderDataArr = dataArr
                    pageView.headerFresh.endRefreshing()
                })
            }else{
                self.gitManager.loadMoreGitInfo(index: index, data: { (dataArr, refresh, moreData) in
                    let pageView = self.icarouselView.itemView(at: index) as! ZJGitShowListView
                    pageView.orderDataArr = dataArr
                    pageView.footerFresh.endRefreshing()
                })
            }
        }
        return gitView
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        segmentView.setScrollToIndex(index: carousel.currentItemIndex)
    }
}


