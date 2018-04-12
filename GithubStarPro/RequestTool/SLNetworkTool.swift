//
//  SLNetworkTool.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//
import UIKit
import Alamofire
import HandyJSON


/*
 usage:
 
 ///get request
 
     let from = RequestFrom.getRequestForm(url, parameters: parameters)
 
     SLNetworkTool.request(requestForm: from, successClosure: { (result) in
 
     }) { (errorStr) in
 
     }
 
 /// post request
     let from = RequestFrom.postRequestForm(url, parameters: parameters)
     SLNetworkTool.request(requestForm: from, successClosure: { (result) in
 
     }) { (errorStr) in
 
     }
 
 */

typealias Parameters = [String : Any]

class SLNetworkTool {
    
    static var data: Any?
    
    public private(set) var session: SessionManager!
    
    private var requests : NSMutableSet = NSMutableSet()
    
    static let shareInstance : SLNetworkTool = {
        let tool = SLNetworkTool()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        tool.session = Alamofire.SessionManager(configuration: config)
        return tool
    }()
}


extension SLNetworkTool {
    
    /// data 请求
    ///
    /// - Parameters:
    ///   - requestForm:
    ///   - successClosure: 成功回调
    ///   - failureClosure: 失败回调
    class func request(requestForm: RequestFromConvertible,
                       successClosure: @escaping (_ response: Any) -> (),
                       failureClosure: @escaping (_ error : Error)->())
    {
        let request =
        shareInstance.session
            .request(requestForm.url,
                     method: requestForm.method,
                     parameters: requestForm.parameters,
                     encoding: requestForm.encoding,
                     headers: requestForm.headers)
            .responseJSON { (response) in

                switch response.result{
                case .success(let value):
                    guard let value = value as? [String : Any] else { print("返回数据格式不正确"); return }
                    successClosure(value)
                case .failure(let error):
//                    var error = error as NSError
                    failureClosure(error)
                }
                SLNetworkTool.shareInstance.requests.remove(response.request as Any)
        }
        
        shareInstance.requests.add(request)
    }
    
    class func uploadImage(requestForm: RequestFromConvertible,
                          fileData: [UIImage],
                          successClosure: @escaping (_ response: Any) -> (),
                          failureClosure: @escaping (_ error : Error)->()) {
        shareInstance.session.upload(multipartFormData: { (data) in
            for image in fileData {
                guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {return}
                let date = Date.timeIntervalBetween1970AndReferenceDate
                data.append(imageData, withName: "multipartFiles", fileName: "\(date).JPEG", mimeType: "image/*")
            }
            
        }, to: requestForm.url, method: .post,
           headers: requestForm.headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { (response) in
                    switch response.result{
                    case .success(let value):
                        guard let value = value as? [String : Any] else { print("返回数据格式不正确"); return }
                        successClosure(value)
                    case .failure(let error):
                        failureClosure(error)
                    }
                    SLNetworkTool.shareInstance.requests.remove(response.request as Any)
                }
            case .failure(let err):
                print(err)
                break
            }
        }
        
    }
}

extension SLNetworkTool {
    /// 根据url取消请求
    ///
    /// - Parameter url: URL
    /// - Returns: 是否存在此请求
    @discardableResult
    class func cancel(for url: String) -> Bool {
        var targetRequest: Request?
        
        shareInstance.requests.forEach { (request) in
            let request = request as! Request
            if request.request?.url?.absoluteString == url {
                targetRequest = request
                return
            }
        }
        
        guard targetRequest != nil else { return false }
        targetRequest!.cancel()
        shareInstance.requests.remove(targetRequest as Any)
        return true
    }
    
    /// 取消所有请求
    class func cancelAll() {
        shareInstance.requests.forEach { (request) in
            let request = request as! Request
            request.cancel()
        }
        shareInstance.requests.removeAllObjects()
    }
}
