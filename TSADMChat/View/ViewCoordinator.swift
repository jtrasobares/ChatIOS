//
//  ViewCoordinator.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//

import Foundation
import SwiftUI

struct ViewCoordinator: View {
    @State private var isActive = false
    var body: some View {
        if isActive {
            ContentView()
        }else {
            SplashScreen(isActive: $isActive)
        }
    }
}

//TODO: Check if the user is stored
func isUserStored() -> Bool {
    return UserDefaults.standard.string(forKey: "username") != nil
}
