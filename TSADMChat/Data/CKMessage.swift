//
//  CKMessage.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 12/2/24.
//

import Foundation
class CKMessage{
    var id: String?
    var userID: String?
    var text: String?
    var image: Data?
    
    init(id: String? = nil, userID: String? = nil, text: String? = nil,image: Data? = nil) {
        self.id = id
        self.userID = userID
        self.text = text
        self.image = image
    }
    
 }
