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
    var displayedMessages : [Message] = []
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
        
        getJSONData()
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

// Mark: - UIPickerViewDelegate
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
        let filteredArr = Selected == "All" ? displayedMessages : displayedMessages.filter({ $0.sentiment == Selected })
        for message in filteredArr {
            addMarker(message.message, message.sentiment, message.lat, lng: message.lng)
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
    
    private func displayAlert(_ title: String, _ message: String, completion: ((UIAlertAction)->Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,handler:completion)
        alert.addAction(okAction)
        
        self.present(alert , animated:true)
    }
    
    private func getJSONData() {
        GetData.getDataFromJSON { (result) in
            if result["NOT_OK"] as? Bool ?? false {
                self.displayAlert("Error!", "No InternetConnection")
                return
            }
            
            let res = Messages.init(fromDictionary: result)
            self.titleLabel.text = res.title
            self.displayedMessages = res.displayedMessages
            
            for message in self.displayedMessages {
                GetData.getLatLng(message: message.message, completion: { (result) in
                    if result["NOT_OK"] as? Bool ?? false {
                        self.displayAlert("Error!", "No InternetConnection")
                        return
                    }
                    message.lat = result["lat"] as? Double
                    message.lng = result["lng"] as? Double
                })
            }
            
        }
    }
    
}
