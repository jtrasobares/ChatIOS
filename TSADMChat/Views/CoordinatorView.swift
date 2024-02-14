//
//  ViewCoordinator.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//

import SwiftUI

/**
    # ViewCoordinator #
    This view is used to coordinate the different views of the app
 */
struct ViewCoordinator: View {
    @State private var state: StateViewApp = .loading
    
    var body: some View {
        switch state{
        case .loading:
            SplashView(state: $state)
        case .registering:
            LoginView(state: $state)
        case .working:
            ChatView(state: $state)
        }
    }
}
