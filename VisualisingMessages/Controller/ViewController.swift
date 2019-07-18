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
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var filterLabel: UILabel!
    
    // MARK: - properites
    let APIKey = "AIzaSyAbZ239oOQx0IO3-0T5XemXJ3SkMrfk5lA"
    var displayedMessages : [[String:String]] = []
    let pickerData = ["All", "Positive", "Neutral", "Negative"]
    let picker: UIPickerView = UIPickerView()
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        filterTextField.inputView = picker
        addToolBarTOPicker()
        
        getDataFromJSON()
        
    }
    
}

// MARK: - UIPickerViewDataSource
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
}

// Mark: -
extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

// MARK: - toolBar
extension ViewController {
    
    private func addToolBarTOPicker() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 34/255, green: 92/255, blue: 124/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: "doneClick")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: "cancelClick")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        filterTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        mapView.clear()
        let Selected = pickerData[picker.selectedRow(inComponent: 0)]
        let filteredArr = Selected == "All" ? displayedMessages : displayedMessages.filter({ $0["sentiment"]! == Selected })
        for message in filteredArr {
            addMarker(message["message"]!, message["sentiment"]!, (Double(message["lat"]!))!, lng: (Double(message["lng"]!))!)
        }
        filterLabel.text = "\(Selected) ➣"
        filterTextField.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        filterTextField.resignFirstResponder()
    }
    
}

// MARK: - private functions
extension ViewController {
    
    private func addMarker(_ title: String, _ sentiment: String, _ lat: Double, lng: Double) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.title = title
        marker.snippet = sentiment
        marker.map = mapView
        marker.icon = sentiment == "Negative" ? UIImage(named: "angry30") : sentiment == "Positive" ? UIImage(named: "happy30") : UIImage(named: "ne30")
    }
    
    private func displayAlert(_ message: String, completion: ((UIAlertAction)->Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,handler:completion)
        alert.addAction(okAction)
        
        self.present(alert , animated:true)
    }
    
    private func getMessageDetailsObject(_ fullMessage: String) {
        var messageObject : [String:String] = [:]
        var temp = ""
        let arrOfWords = fullMessage.split(separator: " ").map { String($0) }
        for i in 3 ..< arrOfWords.count - 2 {
            temp = "\(temp) \(arrOfWords[i]) "
        }
        messageObject["sentiment"] = arrOfWords[arrOfWords.count - 1]
        messageObject["messageid"] = arrOfWords[1]
        messageObject["message"] = temp
        
        displayedMessages.append(messageObject)
    }
    
}

// MARK: - Get Data Functions
extension ViewController {
    
    private func getDataFromJSON() {
        do {
            let data = try Data(contentsOf: URL(string: "https://spreadsheets.google.com/feeds/list/0Ai2EnLApq68edEVRNU0xdW9QX1BqQXhHRl9sWDNfQXc/od6/public/basic?alt=json")!, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let feed = jsonResult["feed"] as? [String:Any] {
                titleLabel.text = ((feed["title"] as! [String:Any])["$t"] as! String)
                let allEntries = feed["entry"] as! [[String:Any]]
                for i in 0 ..< allEntries.count {
                    let message = (allEntries[i]["content"] as! [String:Any])["$t"] as! String
                    getMessageDetailsObject(message)
                }
                displayedMessages = displayedMessages.sorted(by: { $0["sentiment"]! < $1["sentiment"]! })
                getLatLng()
            }
        } catch {
            displayAlert("No InternetConnection")
        }
    }
    
    private func getLatLng() {
        for index in 0 ..< displayedMessages.count {
            var message = displayedMessages[index]
            let escapedmessage = message["message"]!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            do {
                let data = try Data(contentsOf: URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(escapedmessage!)&key=\(APIKey)")!, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let status = jsonResult["status"] as? String {
                    if status == "OK" {
                        let results = jsonResult["results"] as? [[String:Any]]
                        let location = ((results![0]["geometry"] as! [String: Any])["location"] as! [String:Double])
                        displayedMessages[index]["lat"] = "\(location["lat"]!)"
                        displayedMessages[index]["lng"] = "\(location["lng"]!)"
                    } else if status == "OVER_QUERY_LIMIT" {
                        displayedMessages[index]["lat"] = "\(Double.random(in: -50.0 ..< 160.0))"
                        displayedMessages[index]["lng"] = "\(Double.random(in: -50.0 ..< 160.0))"
                        addMarker(displayedMessages[index]["message"]!, displayedMessages[index]["sentiment"]!, (Double(displayedMessages[index]["lat"]!))!, lng: (Double(displayedMessages[index]["lng"]!))!)
                    }
                }
            } catch {
                displayAlert("No InternetConnection")
            }
        }
    }
    
}
