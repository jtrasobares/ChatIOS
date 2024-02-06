//
//  LoginView.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//
 
import Foundation
import SwiftUI
import PhotosUI
 
struct LoginView : View {
    //It'll have a username and an image
    //Both will be requested if they're not saved "isUserStored()"
    @State private var username: String = ""
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImageData: Data? = nil
    @State private var showChangeImage = false
    @State private var showImagePopover = false
    @State private var showCameraPop = false
    @State var type: UIImagePickerController.SourceType = .photoLibrary
    
    @Binding var isLogged: Bool
 
    @Environment(\.managedObjectContext) var context
    
    //TODO: Log the user properly
    func loginNewUsername() {
        UserDefaults.standard.set(username, forKey: "username")
        isLogged = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    avatarModularIcon()
                
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(10)
                                    
                    Button {
                        loginNewUsername()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                         .cornerRadius(10)
                        
                    }
                }.padding()
            }
            .navigationTitle("Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
    }
    
    func avatarModularIcon() -> some View {
        return ZStack(alignment: .center, content: {
            if (avatarImageData == nil) {
                viewPickNewAvatar()
            }
            else {
                viewEditAvatar()
            }
        })
        .onChange(of: avatarItem) {
            Task {
                if let loaded = try? await avatarItem?.loadTransferable(type: Data.self) {
                    avatarImageData = loaded
                } else {
                    avatarImageData = nil
                    print("Error loading image")
                }
            }
        }
    }
    
    func viewEditAvatar() -> some View {
        return Menu {
            Button {
                //Show the image in a pop up
                showImagePopover.toggle()
            } label: {
                Label("See Image", systemImage: "eye")
            }
            Button {
                //Change the image
                showChangeImage.toggle()
            } label: {
                Label("Change Image", systemImage: "pencil")
            }
            Button {
                showCameraPop.toggle()
            } label: {
                Label("Take from camera", systemImage: "camera")
            }
        } label: {
            if let avatarImageData,
            let uiAvatar = UIImage(data: avatarImageData) {
                Image(uiImage: uiAvatar)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120, alignment: .center)
                    .cornerRadius(50)
                    .padding()
            }
        }
        .photosPicker(isPresented: $showChangeImage, selection: $avatarItem, matching: .images, photoLibrary: .shared())
        .popover(isPresented: $showImagePopover) {
            imagePopupView(imageData: avatarImageData!)
                .onTapGesture {
                showImagePopover.toggle()
            }
        }
        .fullScreenCover(isPresented: $showCameraPop) {
            CameraPickerView() { image in
                //UIImage to Data
                avatarImageData = image.pngData()
            }
        }
        .padding(.top)
        
    }
    
    func viewPickNewAvatar() -> some View {
        return PhotosPicker(selection: $avatarItem,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(50)
                        .padding()
                        .foregroundColor(.accentColor)
            
                }
                .buttonStyle(.borderless)
                .padding(.top)
        
    }
    
    func imagePopupView(imageData: Data) -> some View {
        return VStack {
            Image(uiImage: UIImage(data: imageData)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                // The error message proved to be stale
                .frame(width: .infinity, height: nil, alignment: .center)
                .cornerRadius(10)
                .padding()
        }
    }
}
 
//Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLogged: .constant(false))
    }
}
