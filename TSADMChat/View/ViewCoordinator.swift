//
//  ViewCoordinator.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//

import SwiftUI

struct ViewCoordinator: View {
    @State private var state: StateViewApp = .loading
    
    var body: some View {
        switch state{
        case .loading:
            SplashScreen(state: $state)
        case .registering:
            LoginView(state: $state)
        case .working:
            ChatView(state: $state)
        }
    }
}
