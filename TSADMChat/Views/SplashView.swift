//
//  SplashScreen.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//

import Foundation
import SwiftUI
import SwiftData
import CloudKit
import LocalAuthentication

struct SplashView: View {
    @Environment(\.modelContext) var modelContext
    @State private var scale = 0.7
    @Binding var state: StateViewApp
    @Query var users: [User]
    @State private var needsTryLogin = false

    @State var user: User?
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 16) {
                if UserDefaults.standard.string(forKey: "username") != nil {
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
        }
    }
    
    func ViewLoggedSplashScreen() -> some View {
        return VStack {
            if(user != nil){
                if user?.image != nil{
                    Image(uiImage: user!.getImageUI()!)
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFit()
                        .padding(.all,32)
                        
                }else{
                    Image("LogoTransparent")
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFit()
                        .padding(.all,32)
                }
                
                Text("Welcome again, \(user!.name!)!")
                    .font(.title)
                    .padding([.top], 20)
                    .padding([.bottom], 40)
                Button{
                    loadingData()
                } label:{
                    Text("Login")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                }.opacity(needsTryLogin ? 1 : 0)
                    .buttonStyle(.borderedProminent)
                    .font(.system(size: 28, weight: .semibold))
                    
            }
            
        }.onAppear{
            do{
                user = try users.filter(#Predicate<User>{ user in user.id == "__defaultOwner__"}).first
            }catch{
                print(error)
            }
            
            loadingData()
        }
    }
    
    func loadingData(){
        if UserDefaults.standard.bool(forKey: "security"){
            let context = LAContext()
            var error: NSError?
            needsTryLogin = false
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "We need to unlock your data."
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    if success {
                        checkAndDownloadData()
                        
                    }else{
                        needsTryLogin = true
                    }
                }
            }
        }else{
            checkAndDownloadData()
        }
        
    }
    
    func checkAndDownloadData(){
        Task{
            do{
                CloudKitHelper().requestNotificationPermissions()
                let _ = try await CloudKitHelper().checkForSubscriptions()
                let result = await CloudKitHelper().downloadMessages(from: UserDefaults.standard.object(forKey: "date") as! Date?)
                let newCKMessagesList = result.0
                let newUsers = result.1
                UserDefaults.standard.set(Date.now, forKey: "date")
                try modelContext.transaction {
                    newUsers.forEach{ newUser in
                        let idNewUser: String = newUser.id!
                        do{
                            if let user = try users.filter(#Predicate{ user in user.id == idNewUser}).first{
                                user.name = newUser.name
                                user.image = newUser.image
                            }
                            else{
                                modelContext.insert(newUser)
                            }
                        }catch{
                            print(error)
                        }
                    }
                }
                try modelContext.transaction {
                    newCKMessagesList.forEach{ ckMessage in
                        do{
                            let idNewUser: String = ckMessage.userID!
                            var message = Message(id: ckMessage.id,date: ckMessage.date,text: ckMessage.text, image: ckMessage.image)
                            if let user = try users.filter(#Predicate{ user in user.id == idNewUser}).first{
                                message.user = user
                            }
                            modelContext.insert(message)
                        }catch{
                            
                        }
                        
                    }
                }
                
                withAnimation(.easeInOut(duration: 1)) {
                    self.state = .working
                }
            }
        }
    }
    
    func ViewDefaultSplashScreen() -> some View {
        return VStack {
            //Default image for the app, OneThread
            Image("LogoTransparent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text("Welcome to OneThread!")
                .font(.title)
                .padding([.top], 40)
                .padding([.bottom], 40)
        }.onAppear{
            Task{
                do{
                    let result = await CloudKitHelper().getUser(recordID: try CloudKitHelper().myUserRecordID())
                    switch result{
                    case .success(let ownUser):
                        modelContext.insert(ownUser)
                    case .failure(let error):
                        print(error)
                    }
                } catch{
                    print(error)
                }
                    
                withAnimation(.easeInOut(duration: 2)) {
                    self.state = .registering
                }
            }
            
            
            
            
        }
        
    }

}

//Preview
struct TSADMChatApp_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(state: .constant(StateViewApp.registering))
    }
}
