//
//  RequestFrom.swift
//  GithubStarPro
//
//  Created by Zj on 2018/3/29.
//  Copyright © 2018年 zhangjiang. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestFromConvertible {
    var url: URLConvertible { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders? { get }
    
}

struct RequestFrom : RequestFromConvertible {
    
    var url: URLConvertible
    var method: HTTPMethod = .get
    var parameters: Parameters?
    var encoding: ParameterEncoding
    var headers: HTTPHeaders?
    
    static var defaultHeaders: HTTPHeaders {
        get {
            //设置头文件的默认值
            var alamofireHeaders = Alamofire.SessionManager.defaultHTTPHeaders
//            alamofireHeaders["Content-Type"] = "application/json"
            return alamofireHeaders
        }
    }
    
    init(url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
        self.headers = headers ?? RequestFrom.defaultHeaders
    }
    
    static func JsonRequestForm(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> RequestFromConvertible {
        
        return self.init(url: url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
    
    static func getRequestForm(_ url: URLConvertible, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> RequestFrom {
        return self.init(url: url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
    static func postRequestForm(_ url: URLConvertible, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> RequestFrom {
        return self.init(url: url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
}
