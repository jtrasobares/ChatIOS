//
//  CKMessage.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 12/2/24.
//

import Foundation

/**
 # CKMessage #
 A class that represents a message in the chat.
 
 - parameter id: The id of the message.
 - parameter userID: The id of the user that sends the message.
 - parameter text: The text of the message.
 - parameter date: The date of the message.
 - parameter image: The image of the message.
 */
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
