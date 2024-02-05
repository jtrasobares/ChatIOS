//
//  SplashScreen.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    @State private var scale = 0.7
    @Binding var isActive: Bool
    
    var username: String = UserDefaults.standard.string(forKey: "username") ?? "UserTest"
    
    var avatarImage: Image = UserDefaults.standard.string(forKey: "avatar") != nil ? Image(uiImage: UIImage(data: UserDefaults.standard.data(forKey: "avatar")!)!) : Image(systemName: "person.circle.fill")
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 16) {
                // Image of the user
                avatarImage
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding()
                Text("Welcome, \(username)")
                    .font(.title)
                    .padding([.top], 20)
                    .padding([.bottom], 40)
            }.scaleEffect(scale)
            .onAppear{
                withAnimation(.easeIn(duration: 0.7)) {
                    self.scale = 0.9
                }
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

//Preview
struct TSADMChatApp_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(isActive: .constant(false))
    }
}
