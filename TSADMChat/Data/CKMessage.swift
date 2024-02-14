//
//  CKMessage.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 12/2/24.
//

import Foundation
class CKMessage{
    var id: String
    var userID: String?
    var text: String?
    var date: Date
    var image: Data?
    
    init(id: String,date: Date, userID: String? = nil, text: String? = nil,image: Data? = nil) {
        self.id = id
        self.userID = userID
        self.text = text
        self.image = image
        self.date = date
    }
    
 }
