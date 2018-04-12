//
//  ZJHubDetailViewController.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

class ZJHubDetailViewController: UIViewController {

    fileprivate let bagDispose = DisposeBag()

    var gitURL:String = ""
    var webView:WKWebView!
    var progressView:UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
 
        webView = WKWebView.init(frame: self.view.bounds)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        progressView = UIProgressView.init(frame: CGRect.init(x: 0, y: kNavBarH, width: kScreenW, height: 1))
        progressView.progress = 0
        progressView.progressTintColor = .blue;
        progressView.trackTintColor = .white;
        self.view.addSubview(progressView)
        
        webView.load(URLRequest.init(url: URL.init(string: gitURL)!))
        //观察webview的加载状态
        webView.rx.observe(Bool.self, "loading").subscribe(onNext: { (loading) in
            print("是否在加载",loading ?? 0)
            self.progressView.alpha = loading! ? 1 : 0
        }).disposed(by: bagDispose)
        
        webView.rx.observe(CGFloat.self, "estimatedProgress").subscribe(onNext: { (progress) in
            print(progress ?? 0)
            self.progressView.progress = Float(progress!)
        }).disposed(by: bagDispose)
    }
}

extension ZJHubDetailViewController:WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("加载完成")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("加载失败",error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        progressView.progress = 0;
        progressView.alpha = 1.0;
        decisionHandler(.allow)
    }
}
