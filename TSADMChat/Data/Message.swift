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
    var user: User?
    var text: String?
    var image: Data?
    @Transient var imageUI: UIImage?
    
    init(id: String? = nil, user: User? = nil, text: String? = nil,image: Data? = nil) {
        self.id = id
        self.user = user
        self.text = text
        self.image = image
    }
    
    func getImageUI()-> UIImage?{
        if imageUI == nil {
            imageUI = UIImage(data: image!)
        }
        
        return imageUI
    }
    
 }
