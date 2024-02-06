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
    @Binding var isLogged: Bool
    
    //TODO: Get the username and image correctly
    var username: String = UserDefaults.standard.string(forKey: "username") ?? "UserTest"
    
    var avatarImage: Image = UserDefaults.standard.string(forKey: "avatar") != nil ? Image(uiImage: UIImage(data: UserDefaults.standard.data(forKey: "avatar")!)!) : Image(systemName: "person.circle.fill")
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 16) {
                if isLogged {
                    ViewLoggedSplashScreen()
                } else {
                    ViewDefaultSplashScreen()
                }
            }.scaleEffect(scale)
            .onAppear{
                withAnimation(.easeIn(duration: 0.7)) {
                    self.scale = 0.9
                }
            }
        }.onAppear {
            //TODO: change the loading time to the API call to retrieve chats from cloud or local storage
            let time = 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                withAnimation(.easeInOut(duration: 1)) {
                    self.isActive = true
                }
            }
        }
    }
    
    func ViewLoggedSplashScreen() -> some View {
        return VStack {
            avatarImage
                .resizable()
                .frame(width: 150, height: 150)
                .padding()
            Text("Welcome again, \(username)!")
                .font(.title)
                .padding([.top], 20)
                .padding([.bottom], 40)
        }
    }
    
    func ViewDefaultSplashScreen() -> some View {
        return VStack {
            //Default image is Logo_Transparent from assets
            Image("Logo_Transparent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text("Welcome into the chat!")
                .font(.title)
                .padding([.top], 30)
                .padding([.bottom], 40)
        }
    }
}

//Preview
struct TSADMChatApp_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(isActive: .constant(false), isLogged: .constant(false))
    }
}
