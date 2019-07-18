//
//  Message.swift
//  VisualisingMessages
//
//  Created by Esraa Ragab on 7/18/19.
//  Copyright © 2019 Esraa Ragab. All rights reserved.
//

import Foundation

class Message : NSObject {
    
    // MARK: - properites
    var message: String!
    var sentiment: String!
    var messageid: String!
    var lat: Double!
    var lng: Double!
    
    // MARK: - init()
    init(fromString str: String){
        var temp = ""
        let arrOfWords = str.split(separator: " ").map { String($0) }
        for i in 3 ..< arrOfWords.count - 2 {
            temp = "\(temp) \(arrOfWords[i]) "
        }
        message = temp
        sentiment = arrOfWords[arrOfWords.count - 1]
        messageid = arrOfWords[1]
        lat = Double.random(in: -50.0 ..< 160.0)
        lng = Double.random(in: -50.0 ..< 160.0)
    }
    
}
