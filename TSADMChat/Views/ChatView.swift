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
import SwiftData


struct ChatView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    @State private var message: String = ""
    @Query var messages: [Message]
    @Query var users: [User]
    @State var loading: Bool = true
    
    @Binding var state: StateViewApp
    
    
    
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
            }
            .navigationTitle("Chat")
            .toolbar{
                Button{
                    
                } label:{
                    Image(systemName: "gearshape")
                }
            }
        }.onChange(of: scenePhase) {
            if scenePhase == .active{
                if loading{
                    loading = false
                }
                else{
                    state = .loading
                }
            }
        }
        
        
    }
    
    public func sendAndShowMessage(text:String){
        do{
            Task{
                try await CloudKitHelper().sendMessage(text)
                UserDefaults.standard.set(Date.now, forKey: "date")
                message = ""
            }
            if let user = try users.filter(#Predicate{ user in user.id == "__defaultOwner__"}).first{
                    modelContext.insert(Message(id:"Local",user:user,text: message))
            }
            
        }catch{
            print(error)
        }
        
    }
    
    public func initialize(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Download"), object: nil, queue: .main, using: { notification in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                Task{
                    let result = await CloudKitHelper().downloadMessages(from: UserDefaults.standard.object(forKey: "date") as! Date?,usersSaved: users)
                    let newMessagesList = result.0
                    let newUsersList = result.1
                    try modelContext.transaction {
                        newMessagesList.forEach{ message in
                            modelContext.insert(message)
                        }
                    }
                    try modelContext.transaction {
                        newUsersList.forEach{ newUser in
                            let idNewUser: String = newUser.id!
                            do{
                                if try users.filter(#Predicate{ user in user.id == idNewUser}).isEmpty{
                                    modelContext.insert(newUser)
                                }
                            }catch{
                                print(error)
                            }
                        }
                    }
                    UserDefaults.standard.set(Date.now, forKey: "date")
                }
            }
        })
        
    }
    
    
}
