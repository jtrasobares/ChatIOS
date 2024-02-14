//
//  Message.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 5/1/24.
//

import SwiftUI
import SwiftData

@Model
class Message{
    var id: String?
    var text: String?
    var image: Data?
    @Transient var imageUI: UIImage?
    var user: User?
    
    init(id: String? = nil, text: String? = nil,image: Data? = nil, user: User? = nil) {
        self.id = id
        self.text = text
        self.image = image
        self.user = user
    }
    
    func getImageUI()-> UIImage?{
        if imageUI == nil {
            imageUI = UIImage(data: image!)
        }
        
        return imageUI
    }
    
 }
