//
//  Message.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 5/1/24.
//

import Foundation
import SwiftData

@Model
class Message{
    var id: String?
    var user: String?
    var text: String?
    
    init(id: String? = nil, user: String? = nil, text: String? = nil) {
        self.id = id
        self.user = user
        self.text = text
    }
    
 }
