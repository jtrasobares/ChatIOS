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
import PhotosUI

/**
 # ChatView #
 A view to display the chat between the user and the other users. It contains the list of messages and the bar to send a message. It also contains the logic to send the message and to show the image.
 */
struct ChatView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    @State private var messageText: String = ""
    @State private var attachement: Data? = nil
    @Query var users: [User]
    @State var loading: Bool = true
    
    @State var isAtachmentMenuOpen = false
    @State var showPicNewImage = false
    @State var showPicFromCamera = false
    @State var showImagePopover = false
    @State private var avatarItem: PhotosPickerItem?
    
    @Binding var state: StateViewApp
    
    var body: some View {
        NavigationView{
            mainChatView()
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
    
    func mainChatView() -> some View {
        return VStack {
            ListChatView()
            // text and send button
            sendMessageBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            initialize()
        }
        .navigationTitle("OneThread")
        .toolbar{
            Button{
                withAnimation(.easeInOut(duration: 1)) {
                    state = .registering
                }
            } label:{
                Image(systemName: "gearshape")
            }
        }
    }
    
    func sendMessageBar() -> some View {
        return HStack(alignment: .center) {
            ZStack (content: {
                attachmentMenu()
            })
            .onChange(of: avatarItem) {
                Task {
                    if let loaded = try? await avatarItem?.loadTransferable(type: Data.self) {
                        attachement = loaded
                    } else {
                        attachement = nil
                        print("Error loading image")
                    }
                }
            }
            
            messageBar()
            
            Button {
                guard messageText.count > 0 || attachement != nil  else {
                    return
                }
                sendAndShowMessage(text:messageText, attachment: attachement)
                
            } label: {
                //Paper plane icon that gets gray or blue depending on the message
                Image(systemName: "paperplane")
                    .foregroundColor(messageText.count > 0 || attachement != nil ? .blue : .gray)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .padding(.leading, 10)
            .disabled(messageText.count == 0 && attachement == nil)
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderless)
        .background(Color(.systemGray6))
    }
    
    func messageBar() -> some View {
        return RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray5))
            .frame(height: 40)
            .overlay(
                HStack {
                    if attachement != nil {
                        // Miniature of the image (attachment)
                        Image(systemName: "photo.fill")
                            .foregroundColor(.blue)
                            .padding(.leading, 10)
                            .onTapGesture {
                                showImagePopover.toggle()
                            }
                            .popover(isPresented: $showImagePopover, arrowEdge: .bottom, content: {
                                imagePopupView(imageData: attachement!,
                                               deleteDelegate: {
                                    attachement = nil
                                    avatarItem = nil
                                },
                                               hideDelegate: {
                                    showImagePopover.toggle()
                                })
                            })
                    }
                    TextField("Send a message", text: $messageText, axis: .vertical)
                        .padding(.horizontal, 8)
                }
            )
    }
    
    func attachmentMenu() -> some View {
        return Menu {
            Button {
                showPicFromCamera.toggle()
            } label: {
                Label("Take from camera", systemImage: "camera")
            }
            Button {
                //Change the image
                showPicNewImage.toggle()
            } label: {
                Label("Attach Image", systemImage: "pencil")
            }
        } label: {
            Button {
                isAtachmentMenuOpen.toggle()
            } label:{
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.borderless)
        }
        .photosPicker(isPresented: $showPicNewImage, selection: $avatarItem, matching: .images, photoLibrary: .shared())
        .fullScreenCover(isPresented: $showPicFromCamera) {
            CameraPickerView() { image in
                //UIImage to Data
                attachement = image.pngData()
            }
        }
        .padding([.leading, .trailing], 5)
    }
    
    public func sendAndShowMessage(text:String, attachment: Data? = nil){
        
            Task{
                do{
                    let record = try await CloudKitHelper().sendMessage(text, attachment)
                    UserDefaults.standard.set(Date.now, forKey: "date")
                    if let user = try users.filter(#Predicate{ user in user.id == "__defaultOwner__"}).first{
                        modelContext.insert(Message(id:record.recordID.recordName,date: record.creationDate!,text: text, image: attachment, user: user))
                    }
                    
                }catch{
                    print(error)
                }
                
            }
        messageText = ""
        attachement = nil
        avatarItem = nil
    }
    
    public func initialize(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Download"), object: nil, queue: .main, using: { notification in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                Task{
                    let result = await CloudKitHelper().downloadMessages(from: UserDefaults.standard.object(forKey: "date") as! Date?)
                    let newCKMessagesList = result.0
                    let newUsersList = result.1
                    UserDefaults.standard.set(Date.now, forKey: "date")
                    try modelContext.transaction {
                        newUsersList.forEach{ newUser in
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
                                let message = Message(id: ckMessage.id,date: ckMessage.date,text: ckMessage.text, image: ckMessage.image)
                                if let user = try users.filter(#Predicate{ user in user.id == idNewUser}).first{
                                    message.user = user
                                }
                                modelContext.insert(message)
                            } catch{
                                print(error)
                            }
                        }
                    }
                }
            }
        })
    }
}
