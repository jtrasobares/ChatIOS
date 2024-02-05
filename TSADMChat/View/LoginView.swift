//
//  LoginView.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 5/2/24.
//

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
    @State private var avatarImage: Image?
    @State private var image = UIImage()
    @State private var showChangeImage = false
    @State private var showImagePopover = false
    @State var type: UIImagePickerController.SourceType = .photoLibrary
 
    @Environment(\.managedObjectContext) var context
    
    //Check if the user is stored
    func isUserStored() -> Bool {
        return UserDefaults.standard.string(forKey: "username") != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isUserStored() {
                    viewIsUserStored()
                }
                else {
                    viewNotUserStored()
                }
            }
            .navigationTitle("Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
    }
    
    func viewIsUserStored() -> some View {
        return VStack(spacing: 16) {
            Text("Welcome \(UserDefaults.standard.string(forKey: "username")!)")
            Image(uiImage: UIImage(data: UserDefaults.standard.data(forKey: "image")!)!)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100, alignment: .center)
        }.padding()
    }
    
    func viewNotUserStored() -> some View {
        return VStack(spacing: 16) {
            
            
            ZStack(alignment: .center, content: {
                
                if (avatarImage == nil) {
                    viewPickNewAvatar()
                }
                else {
                    viewEditAvatar()
                }
            })
            .onChange(of: avatarItem) {
                Task {
                    if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                        avatarImage = loaded
                    } else {
                        print("Failed")
                    }
                }
            }
        
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
        } label: {
            avatarImage?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100, alignment: .center)
                .cornerRadius(50)
        }
        .photosPicker(isPresented: $showChangeImage, selection: $avatarItem, matching: .images, photoLibrary: .shared())
        .popover(isPresented: $showImagePopover) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
        
    }
    
    func viewPickNewAvatar() -> some View {
        return PhotosPicker(selection: $avatarItem,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Image(systemName: "person.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 100))
                        .foregroundColor(.accentColor)
                        .padding()
            
                }
                .buttonStyle(.borderless)
                .padding(.top)
        
    }
    
    func loginNewUsername() {
        UserDefaults.standard.set(username, forKey: "username")
        
    }
    
    func SelectImage() {
        //Select the image from the gallery
        
    }
    
    func ImagePopupView(image: Image) -> some View {
        return VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: .infinity, alignment: .center)
                .cornerRadius(10)
                .padding()
        }
    }
}
 
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage
 
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
 
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
 
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
 
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
        var parent: ImagePicker
 
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
 
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
 
            parent.presentationMode.wrappedValue.dismiss()
        }
 
    }
}
 
//Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
