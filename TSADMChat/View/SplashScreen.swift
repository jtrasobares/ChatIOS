//
//  SplashScreen.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//

import Foundation
import SwiftUI
import CloudKit
import LocalAuthentication

struct SplashScreen: View {
    @Environment(\.modelContext) var modelContext
    @State private var scale = 0.7
    @Binding var state: StateViewApp
    @State var loadingState: Bool = false
    
    
    //TODO: Get the username and image correctly
    var username: String = UserDefaults.standard.string(forKey: "username") ?? "UserTest"
    var avatarImage: Image = UserDefaults.standard.string(forKey: "avatar") != nil ? Image(uiImage: UIImage(data: UserDefaults.standard.data(forKey: "avatar")!)!) : Image(systemName: "person.circle.fill")
    
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
            avatarImage
                .resizable()
                .frame(width: 150, height: 150)
                .padding()
            Text("Welcome again, \(username)!")
                .font(.title)
                .padding([.top], 20)
                .padding([.bottom], 40)
        }.onAppear{
            loadingData()
        }
    }
    
    func loadingData(){
        if UserDefaults.standard.bool(forKey: "security"){
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                
                let reason = "We need to unlock your data."

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    if success {
                        checkAndDownloadData()
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
                let _ = await CloudKitHelper().downloadMessages(from: UserDefaults.standard.object(forKey: "date") as! Date?, perRecord: getMessageRecord)
                
                /*let newMessagesList = await CloudKitHelper().downloadMessages(from: UserDefaults.standard.object(forKey: "date") as! Date?)
                
                UserDefaults.standard.set(Date.now, forKey: "date")
                try modelContext.transaction {
                    newMessagesList.forEach{ message in
                        modelContext.insert(message)
                    }
                }*/
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
            withAnimation(.easeInOut(duration: 2)) {
                self.state = .registering
            }
        }
        
    }
    
    func getMessageRecord(_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>){
        switch recordResult {
        case .success(let record):
            
            if let text = record["text"] as String? , let user = record.creatorUserRecordID!.recordName as String? {
                do{
                    modelContext.insert(Message(id:recordID.recordName,user: user,text:text))
                    try modelContext.save()
                }catch{
                    print(error.localizedDescription)
                }
                UserDefaults.standard.set(Date.now, forKey: "date")
            }
            
        case .failure(let error):
            // Handle the error
            print("Error for Record ID \(recordID): \(error.localizedDescription)")
        }
    }

}

//Preview
struct TSADMChatApp_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(state: .constant(StateViewApp.registering))
    }
}
