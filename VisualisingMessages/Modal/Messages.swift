//
//  Messages.swift
//  VisualisingMessages
//
//  Created by Esraa Ragab on 7/18/19.
//  Copyright © 2019 Esraa Ragab. All rights reserved.
//

import Foundation

class Messages : NSObject {
    
    // MARK: - properites
    var title: String!
    var displayedMessages: [Message]!
    
    // MARK: - init()
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        title = ((dictionary["title"] as! [String:Any])["$t"] as! String)
        let allEntries = dictionary["entry"] as! [[String:Any]]
        displayedMessages = []
        for i in 0 ..< allEntries.count {
            let message = (allEntries[i]["content"] as! [String:Any])["$t"] as! String
            displayedMessages.append(Message.init(fromString: message))
        }
        displayedMessages = displayedMessages.sorted(by: { $0.sentiment < $1.sentiment })
    }

}
