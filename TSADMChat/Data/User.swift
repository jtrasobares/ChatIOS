//
//  User.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 12/2/24.
//

import SwiftUI
import SwiftData

/**
 # User #
 A class that represents a user.
 
 - parameter id: The id of the user.
 - parameter name: The name of the user.
 - parameter image: The image of the user.
 */
@Model
class User{
    var id: String?
    var name: String?
    var image: Data?
    @Transient var imageUI: UIImage?
    
    init(id: String? = nil, name: String? = nil, image: Data? = nil) {
        self.id = id
        self.name = name
        self.image = image
        imageUI = nil
    }
    
    
    func getImageUI()-> UIImage?{
        if imageUI == nil {
            imageUI = UIImage(data: image!)
        }
        
        return imageUI
    }
}
