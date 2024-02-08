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
    @State private var isLogged = true//isUserStored()
    
    var body: some View {
        if isActive {
            ContentCoordinator()
        }else {
            SplashScreen(isActive: $isActive, isLogged: $isLogged)
        }
    }
}

struct ContentCoordinator: View {
    @State private var isLogged = true//isUserStored()

    var body: some View {
        if isLogged {
            ContentView()
        } else {
            LoginView(isLogged: $isLogged)
        }
    }
}

//TODO: Check if the user is stored
func isUserStored() -> Bool {
    return UserDefaults.standard.string(forKey: "username") != nil
}
