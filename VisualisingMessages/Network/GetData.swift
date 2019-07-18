//
//  GetData.swift
//  VisualisingMessages
//
//  Created by Abdelrahman Abu Sharkh on 7/18/19.
//  Copyright © 2019 Esraa Ragab. All rights reserved.
//

import UIKit

class GetData {
    
    static func getDataFromJSON(completion:@escaping ([String:Any])->Void) {
        do {
            let data = try Data(contentsOf: URL(string: "https://spreadsheets.google.com/feeds/list/0Ai2EnLApq68edEVRNU0xdW9QX1BqQXhHRl9sWDNfQXc/od6/public/basic?alt=json")!, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let feed = jsonResult["feed"] as? [String:Any] {
                completion(feed)
            }
        } catch {
            completion(["NOT_OK": true])
        }
    }
    
    static func getLatLng(message: String, completion:@escaping ([String:Any])->Void) {
        let escapedmessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        do {
            let data = try Data(contentsOf: URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(escapedmessage!)&key=\(Constants.APIKeys.googleAPI)")!, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let status = jsonResult["status"] as? String {
                if status == "OK" {
                    let results = jsonResult["results"] as? [[String:Any]]
                    let location = ((results![0]["geometry"] as! [String: Any])["location"] as! [String:Double])
                    
                    completion([
                        "lat": location["lat"]!,
                        "lng": location["lng"]!
                    ])
                } else {
                    completion(["NOT_OK": true])
                }
            }
        } catch {
            completion(["NOT_OK": true])
        }
    }
    
}
