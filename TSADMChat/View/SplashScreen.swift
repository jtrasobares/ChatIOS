//
//  SplashScreen.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//

import Foundation
import SwiftUI
import CloudKit

struct SplashScreen: View {
    @Environment(\.modelContext) var modelContext
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

            Task{
                do{
                    
                    let date = UserDefaults.standard.object(forKey: "date") as! Date?
                    if(date != nil){
                        print("Date: "+date!.formatted())
                    }
                    
                    CloudKitHelper().requestNotificationPermissions()
                    try await CloudKitHelper().checkForSubscriptions()
                    await CloudKitHelper().downloadMessages(from: date, perRecord: updateLastMessages)
                    UserDefaults.standard.set(Date.now, forKey: "date")
                }catch{
                    
                }
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
            //Default image for the app, OneThread
            Image("LogoTransparent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text("Welcome to OneThread!")
                .font(.title)
                .padding([.top], 40)
                .padding([.bottom], 40)
        }
    }
    
    public func updateLastMessages(_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>){
        switch recordResult {
        case .success(let record):
            let text = record["text"] as String?
            let user = record.creatorUserRecordID!.recordName
            if(text != nil){
                modelContext.insert(Message(id:recordID.recordName,user: user,text:text))
            }
            UserDefaults.standard.set(Date.now, forKey: "date")
        case .failure(let error):
            // Handle the error
            print("Error for Record ID \(recordID): \(error.localizedDescription)")
        }
    }
}

//Preview
struct TSADMChatApp_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(isActive: .constant(false), isLogged: .constant(false))
    }
}
