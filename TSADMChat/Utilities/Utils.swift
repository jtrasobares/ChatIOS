//
//  Utils.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 7/2/24.
//

import SwiftUI

func imagePopupView(imageData: Data) -> some View {
    return VStack {
        Image(uiImage: UIImage(data: imageData)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: .infinity, height: nil, alignment: .center)
            .cornerRadius(10)
            .padding()
            .presentationDragIndicator(.visible)
    }
}

