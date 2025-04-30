//
//  ApiEndPoint.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import Foundation

import Alamofire

public protocol APIEndPoint {
    
    var apiPath: String {get}
    var method: HTTPMethod {get}
}

extension APIEndPoint {
    
    var urlPath: String {
        
        return ServerConfig.baseURL + apiPath
    }
}


enum BookEndPoint : APIEndPoint {
    
    
    case fetchBook
    
    var apiPath: String {
        switch self {
            
            
            
        case .fetchBook:
            return "books"
        }
        
        
        
    }
    
    var method: HTTPMethod {
        switch self {
            
            
        case .fetchBook:
            return .get
        }
    }
}


