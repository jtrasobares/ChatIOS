//
//  ContentView.swift
//  TSADMChat
//
//  Created by Gabriel Marro on 20/11/23.
// Based on article by Uday P.
// https://udaypatial.medium.com/scroll-to-bottom-of-a-list-of-items-swiftui-21ade9f2d46b
//

import SwiftUI
import CloudKit

struct ContentView: View {
    @State private var message: String = ""
    @State var messages: [Message] = []
    @State var userID: String = ""
    @State var subscription: CKSubscription?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack{
            ScrollViewReader { proxy in
                VStack {
                    List(messages, id: \.self) { message in
                        MessageView(message: message)
                            .id(message)
                            .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity)
                    .listStyle(.plain)
                    .background(Color.white)
                    .onChange(of: messages) { oldValue, newValue in
                        guard oldValue.count < newValue.count else { return }
                        withAnimation {
                            proxy.scrollTo(messages.last, anchor: .bottom)
                        }
                    }
                    // text and send button
                    HStack {
                        Button {
                            
                        } label:{
                            Image(systemName: "plus.circle")
                        }
                        TextField("Send a message", text: $message)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        
                            
                        Button {
                            guard message.count > 0 else {
                                return
                            }
                            sendAndShowMessage(text:message)
                            
                        } label: {
                            Image(systemName: "paperplane.fill")
                        }
                        .padding(.leading, 10)
                        .disabled(message.count == 0)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    initialize()
                    withAnimation {
                        proxy.scrollTo(messages.last, anchor: .bottom)
                    }
                }
                .background(colorScheme == .dark ? Color.black : Color.white)
            }
            .navigationTitle("Chat")
            .toolbar{
                Button{
                    
                } label:{
                    Image(systemName: "gearshape")
                }
            }
        }
        
    }
    
    public func sendAndShowMessage(text:String){
        Task{
            do{
                try await CloudKitHelper().sendMessage(text)
                messages.append(Message(id:"Local",user:"__defaultOwner__",text: message))
                message = ""
            }catch let error{
                print(error.localizedDescription)
            }
        }
        
    }
    
    public func initialize(){
        Task{
            do{
                userID = try await CloudKitHelper().myUserRecordID()
                CloudKitHelper().requestNotificationPermissions()
                subscription = try await CloudKitHelper().checkForSubscriptions()
                
                let _ = await CloudKitHelper().downloadMessages(from: nil, perRecord: updateMessages)
            }catch let error{
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    public func updateMessages(_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>){
        switch recordResult {
        case .success(let record):
            let text = record["text"]! as String
            let user = record.creatorUserRecordID!.recordName
            messages.append(Message(id:recordID.recordName,user: user,text:text))
            print(user)
        case .failure(let error):
            // Handle the error
            print("Error for Record ID \(recordID): \(error.localizedDescription)")
        }
    }
}
