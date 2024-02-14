//
//  ProfileView.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 14/2/24.
//

import SwiftUI

/**
 # ProfileView #
 A function that returns a view with the user profile. It contains the user image and the user name.
 */
func ProfileView(user: User)-> some View {
    return  VStack{
        if user.image != nil{
            Image(uiImage: user.getImageUI()!)
                .resizable()
                .frame(width: .infinity, height: nil, alignment: .center)
                .cornerRadius(20)
        }
        Text(user.name!)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .font(.system(size: 28, weight: .semibold))
    }
    .scaledToFill()
}

