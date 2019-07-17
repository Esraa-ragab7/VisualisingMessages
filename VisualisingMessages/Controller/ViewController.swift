//
//  ViewController.swift
//  VisualisingMessages
//
//  Created by Abdelrahman Abu Sharkh on 7/17/19.
//  Copyright © 2019 Esraa Ragab. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - properites
    let APIKey = "AIzaSyAbZ239oOQx0IO3-0T5XemXJ3SkMrfk5lA"
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView.camera = camera
        
        addMarker("esraaa","ragab")

        do {
            let data = try Data(contentsOf: URL(string: "https://spreadsheets.google.com/feeds/list/0Ai2EnLApq68edEVRNU0xdW9QX1BqQXhHRl9sWDNfQXc/od6/public/basic?alt=json")!, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let feed = jsonResult["feed"] as? [String:Any] {
                titleLabel.text = ((feed["title"] as! [String:Any])["$t"] as! String)
                let allEntries = feed["entry"] as! [[String:Any]]
                for entry in allEntries {
                    let message = (entry["content"] as! [String:Any])["$t"] as! String
                    getMessageDetailsObject(message)
                }
            }
        } catch {
            print("No InternetConnection")
            // handle error
        }
        
    }
    


}

// MARK: - private functions
extension ViewController {
    
    private func addMarker(_ title: String, _ sentiment: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = title
        marker.snippet = sentiment
        marker.map = mapView
    }
    
    private func getMessageDetailsObject(_ fullMessage: String) -> [String:String]{
        var messageObject : [String:String] = [:]
        var croppedMessage = String(fullMessage.dropFirst(11))
        let length = croppedMessage.count
        let firstSpaceIndex = croppedMessage.distance(from: croppedMessage.startIndex, to: croppedMessage.firstIndex(of: " ")!)
        let lastSpaceIndex = croppedMessage.distance(from: croppedMessage.startIndex, to: croppedMessage.lastIndex(of: " ")!)
        let index = croppedMessage.index(croppedMessage.endIndex, offsetBy: (length - lastSpaceIndex - 1) * -1)
        
        messageObject["sentiment"] = String(croppedMessage.suffix(from: index))
        messageObject["messageid"] = String(croppedMessage.prefix(firstSpaceIndex - 1))
        croppedMessage = String(croppedMessage.dropFirst(firstSpaceIndex + 10))
        messageObject["message"] = String(croppedMessage.prefix(lastSpaceIndex - (firstSpaceIndex + 10) - 12))
        
//        var message = fullMessage.replacingOccurrences(of: ",", with: "")
//        message = message.replacingOccurrences(of: ":", with: "")
//        message = message.replacingOccurrences(of: "The", with: "")
//        let arrStrings = message.split(separator: " ").map { String($0) }
        let escapedmessage = messageObject["message"]!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        do {
            let data = try Data(contentsOf: URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(escapedmessage!)&key=\(APIKey)")!, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let status = jsonResult["status"] as? String {
                if status == "OK" {
                    let results = jsonResult["results"] as? [[String:Any]]
                    let location = ((results![0]["geometry"] as! [String: Any])["location"] as! [String:String])
                    
                    messageObject["lat"] = location["lat"]
                    messageObject["lng"] = location["lng"]
                    
                    return messageObject
                }
            }
        } catch {
            return messageObject
            // handle error
        }
        return messageObject
    }
    
}
