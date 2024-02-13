//
//  LoginView.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 5/2/24.
//
 
import SwiftUI
import SwiftData
import PhotosUI
import LocalAuthentication
 
struct LoginView : View {
    @Binding var state: StateViewApp
    
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<User>{ user in user.id == "__defaultOwner__"}) var users: [User]
    @State private var actualUser: User? = nil
    @State private var username: String = ""
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImageData: Data? = nil
    @State private var showChangeImage = false
    @State private var showImagePopover = false
    @State private var showCameraPop = false
    @State private var securityEnable = false
    @State var type: UIImagePickerController.SourceType = .photoLibrary

    func loginNewUsername() {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(securityEnable, forKey: "security")
        Task{
            actualUser!.name = username
            actualUser!.image = avatarImageData
            modelContext.insert(actualUser!)
            do{
                try await CloudKitHelper().updateUser(newName:username,image:avatarImageData?.toCKAsset())
                state = .loading
            }catch{
                print(error)
            }
            
        }
        
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
                        .foregroundColor(.black)
                    Toggle(isOn: $securityEnable) {
                            Text("Security in the app")
                    }
                                    
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
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                }.padding()
            }
            .onAppear{
                if let userSelected = users.first{
                    actualUser = userSelected
                    
                }
                else{
                    actualUser = User(id:"__defaultOwner__",name:"")
                }
                username = actualUser!.name!
                if actualUser!.image != nil{
                    avatarImageData = actualUser!.image
                }
                
                
                
            }
            .navigationTitle("Create Account")
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
}
 
//Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(state: .constant(StateViewApp.registering))
    }
}