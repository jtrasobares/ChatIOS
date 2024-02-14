//
//  SettingsView.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 6/2/24.
//

import SwiftUI
import PhotosUI

struct SettingsView : View {
    @Binding var username: String
    @Binding var avatarImageData: Data?
    @State private var avatarItem: PhotosPickerItem?
    @State private var showChangeImage = false
    @State private var showImagePopover = false
    @State private var showCameraPop = false
    @State var type: UIImagePickerController.SourceType = .photoLibrary
    
    func editUsername() {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(avatarImageData, forKey: "avatar")
    }
    
    var body: some View {
        //TODO: Add return button
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    avatarModularIcon()
                
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(10)
                                     
                    Button {
                        editUsername()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Settings")
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
        }
    }
    
    func avatarModularIcon() -> some View {
        return ZStack(alignment: .center, content: {
            viewEditAvatar()
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
            imagePopupView(imageData: avatarImageData!, deleteDelegate: nil)
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
}

//Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(username: .constant("UserTest"), avatarImageData: .constant(Data()))
    }
}
