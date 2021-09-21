//
//  HttpRequest.swift
//  Initiative
//
//  Created by Andres Liu on 10/12/20.
//

import Foundation
import SwiftyJSON
import Alamofire

struct HttpRequest {
    func serverCallWithoutHeaders(url: String, params: Parameters, method: HTTPMethod, callback:@escaping (Int, JSON) -> Void) -> Void {
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
        ]
        
        //responseContentType: "text/html"
        //contentType: ["application/json"]
        Alamofire.request(url, method: method,parameters: params, encoding: JSONEncoding.prettyPrinted,   headers: headers).responseJSON { response in
            
            
            var code:Int = 2
            
            if response.response != nil && response.response?.statusCode != nil {
                if ((response.response?.statusCode)! >= 200 && (response.response?.statusCode)! < 300){
                    code = 1
                }
            }
            
            var returnResult: JSON = JSON.null
            if (response.result.value != nil){
                returnResult = JSON(response.result.value!)
            }
            
            callback(code, returnResult)
        }
        
    }
}
