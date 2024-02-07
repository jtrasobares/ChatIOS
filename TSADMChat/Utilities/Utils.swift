//
//  Utils.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 7/2/24.
//

import Foundation
import SwiftUI

func imagePopupView(imageData: Data) -> some View {
    return VStack {
        Image(uiImage: UIImage(data: imageData)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            // The error message proved to be stale
            .frame(width: .infinity, height: nil, alignment: .center)
            .cornerRadius(10)
            .padding()
    }
}

