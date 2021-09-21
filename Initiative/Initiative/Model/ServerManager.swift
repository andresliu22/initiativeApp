//
//  MarcaManager.swift
//  Initiative
//
//  Created by Andres Liu on 10/12/20.
//

import Foundation
import SwiftyJSON
import Alamofire
import SwiftJWT
import Charts

struct ServerManager {
    
    let loginURL: String = "https://appservice.mbappsperu.com/api/LocalLogin"
    
    let tolenAuthURL: String = "https://appservice.mbappsperu.com/api/tolenAuth"
    
    let marcaURL: String = "https://appservice.mbappsperu.com/api/mybrands"

    let noticiaURL: String = "https://appservice.mbappsperu.com/api/stories"
    
    let reporteURL: String = "https://service.mbappsperu.com/api/Brand"
    
    let inversionURL: String = "https://service.mbappsperu.com/api/Inversion"
    
    let campaignURL: String = "https://service.mbappsperu.com/api/Campaign"
    
    let resumenDigitalURL: String = "https://service.mbappsperu.com/api/Digital/performance"
    
    let resumenDigitalVentasURL: String = "https://service.mbappsperu.com/api/Digital/sales"
    
    let providerURL: String = "https://service.mbappsperu.com/api/Inversion/provider"
    
    let mediaURL: String = "https://service.mbappsperu.com/api/Inversion/medium"
    
    let vehicleURL: String = "https://service.mbappsperu.com/api/Inversion/vehicle"
    
    let campaignListURL: String = "https://service.mbappsperu.com/api/Inversion/campaign"
    
    let reporteMercadoURL: String = "https://service.mbappsperu.com/api/Report/market"
    
    let estadoCuentaProyectadoURL: String = "https://service.mbappsperu.com/api/StatementAccount/projected"
    
    let estadoCuentaOrionURL: String = "https://service.mbappsperu.com/api/StatementAccount/orion"
    
    let estadoCuentaContratoURL: String = "https://service.mbappsperu.com/api/StatementAccount/contract"
    
    let facturacionURL: String = "https://service.mbappsperu.com/api/Billing"
    
    let changePassURL: String = "https://appservice.mbappsperu.com/api/ChangePassword"
    
    let resumenURL: String = "https://service.mbappsperu.com/api/Report/summary"
    
    let recoveryPassAppURL: String = "https://appservice.mbappsperu.com/api/RecoveryPassApp"
    let recoveryKeyAppURL: String = "https://appservice.mbappsperu.com/api/RecoveryKeyApp"
    
    let changeExternalPassURL: String = "https://appservice.mbappsperu.com/api/ChangeExternalPassword"
    
    let estadoCuentaProvidersURL: String = "https://service.mbappsperu.com/api/Provider/projected"
    
    let estadoCuentaContractProvidersURL: String = "https://service.mbappsperu.com/api/Provider/contract"
    
    let implementacionCampaignsURL: String = "https://service.mbappsperu.com/api/Campaign/implementation"
    
    let resumenDigitalPerformanceCampaignsURL: String = "https://service.mbappsperu.com/api/Digital/performance/campaign"
    
    let resumenDigitalSalesCampaignsURL: String = "https://service.mbappsperu.com/api/Digital/sales/campaign"
    
    let myProfileURL: String = "https://appservice.mbappsperu.com/api/MyProfile"
    
    let infoURL: String = "https://appservice.mbappsperu.com/api/paraset/in"
    
    func serverCallWithoutHeaders(url: String, params: Parameters, method: HTTPMethod, callback:@escaping (Int, JSON) -> Void) -> Void {
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
        ]
        
        Alamofire.request(url, method: method, encoding: JSONEncoding.prettyPrinted,   headers: headers).responseJSON { response in
            
            
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
    
    func serverCallWithHeaders(url: String, params: Parameters, method: HTTPMethod, callback:@escaping (Int, JSON) -> Void) -> Void {
        
        let auth = UserDefaults.standard.string(forKey: "userToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Authorization": auth
        ]
        Alamofire.request(url, method: method, parameters: params, encoding: JSONEncoding.prettyPrinted,  headers: headers).responseJSON { response in
            
            var code:Int = 2
                    
            if response.response != nil && response.response?.statusCode != nil {
                if ((response.response?.statusCode)! >= 200 && (response.response?.statusCode)! < 400){
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
    
    
    func serverCallWithHeadersGET(url: String, params: Parameters, method: HTTPMethod, callback:@escaping (Int, JSON) -> Void) -> Void {
        
        let auth = UserDefaults.standard.string(forKey: "userToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Authorization": auth
        ]
        Alamofire.request(url, method: method, parameters: nil, encoding: JSONEncoding.prettyPrinted,  headers: headers).responseJSON { response in
            
            var code:Int = 2
                    
            if response.response != nil && response.response?.statusCode != nil {
                if ((response.response?.statusCode)! >= 200 && (response.response?.statusCode)! < 400){
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
    
    func serverCallWithHeadersRecoveryPass(url: String, params: Parameters, method: HTTPMethod, callback:@escaping (Int, JSON) -> Void) -> Void {
        
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
        ]
        Alamofire.request(url, method: method, parameters: params, encoding: JSONEncoding.prettyPrinted,  headers: headers).responseJSON { response in
            
            var code:Int = 2
                    
            if response.response != nil && response.response?.statusCode != nil {
                if ((response.response?.statusCode)! >= 200 && (response.response?.statusCode)! < 400){
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
    
    func serverCallWithHeadersRecovery(url: String, params: Parameters, method: HTTPMethod, callback:@escaping (Int, JSON) -> Void) -> Void {
        
        let auth = UserDefaults.standard.string(forKey: "recoveryToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Authorization": auth
        ]
        Alamofire.request(url, method: method, parameters: params, encoding: JSONEncoding.prettyPrinted,  headers: headers).responseJSON { response in
            
            var code:Int = 2
                    
            if response.response != nil && response.response?.statusCode != nil {
                if ((response.response?.statusCode)! >= 200 && (response.response?.statusCode)! < 400){
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
