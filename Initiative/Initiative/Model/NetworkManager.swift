//
//  NetworkManager.swift
//  Initiative
//
//  Created by Andres Liu on 11/17/20.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    private init(){}
    static let shared = NetworkManager()
    
    public func getYears() -> [FilterBody] {
        var yearList = [FilterBody]()
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        for i in 2017...year{
            let newYear: FilterBody = FilterBody(id: i, name: String(i))
            yearList.append(newYear)
        }
        return yearList
    }
    
    public func getMonths() -> [FilterBody] {
        var monthList = [FilterBody]()
        let arrayMonth = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
        for i in 0..<12 {
            let newMonth: FilterBody = FilterBody(id: i + 1, name: arrayMonth[i])
            monthList.append(newMonth)
        }
        return monthList
    }
    
    public func getProviders() -> [FilterBody] {
        
        var providerList = [FilterBody]()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.integer(forKey: "idBrand")]
        serverManager.serverCallWithHeaders(url: serverManager.providerURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success providers")
                //print(jsonData)
                for provider in jsonData["providerList"].arrayValue {
                    let newProvider: FilterBody = FilterBody(id: provider["id"].int!, name: provider["name"].string!)
                    providerList.append(newProvider)
                }
            } else {
                print("Failure")
            }
        })
        return providerList
    }
    
    public func getMedia() -> [FilterBody] {
        
        var mediaList = [FilterBody]()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.integer(forKey: "idBrand")]
        serverManager.serverCallWithHeaders(url: serverManager.mediaURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success Media")
                //print(jsonData)
                for media in jsonData["mediaInversionList"].arrayValue {
                    let newMedia: FilterBody = FilterBody(id: media["id"].int!, name: media["name"].string!)
                    mediaList.append(newMedia)
                }
            } else {
                print("Failure")
            }
        })
        return mediaList
    }
    
    public func getCampaign() -> [FilterBody] {
        var campaignList = [FilterBody]()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.integer(forKey: "idBrand")]
        serverManager.serverCallWithHeaders(url: serverManager.campaignListURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success Campaign")
                //print(jsonData)
                for campaign in jsonData["campaignInversionList"].arrayValue {
                    let newCampaign: FilterBody = FilterBody(id: campaign["id"].int!, name: campaign["name"].string!)
                    campaignList.append(newCampaign)
                }
            } else {
                print("Failure")
            }
        })
        return campaignList
    }
}
