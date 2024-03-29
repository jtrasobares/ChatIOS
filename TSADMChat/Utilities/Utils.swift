//
//  Utils.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 7/2/24.
//

import SwiftUI

/**
 # Utils #
 This struct is used to create a set of utilities that can be used in SwiftUI views.
 */
func imagePopupView(imageData: Data, deleteDelegate: (() -> Void)? = nil, hideDelegate: (() -> Void)? = nil) -> some View {
    return VStack {
        Image(uiImage: UIImage(data: imageData)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: .infinity, height: nil, alignment: .center)
            .cornerRadius(10)
            .padding()
        // Show the hide and delete buttons
        if (deleteDelegate != nil || hideDelegate != nil) {
            HStack {
                if hideDelegate != nil {
                    Button {
                        hideDelegate?()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding()
                }
                if deleteDelegate != nil {
                    Spacer()
                    Button {
                        deleteDelegate?()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding()
                }
            }
        }
    }
}
