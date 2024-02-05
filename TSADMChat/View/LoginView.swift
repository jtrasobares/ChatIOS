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
    @State private var showChangeImage = false
    @State private var showImagePopover = false
    @State var type: UIImagePickerController.SourceType = .photoLibrary
 
    @Environment(\.managedObjectContext) var context
    
    
    
    func loginNewUsername() {
        UserDefaults.standard.set(username, forKey: "username")
        
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                viewNotUserStored()
            }
            .navigationTitle("Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
    }
    
    func viewIsUserStored(username: String, image: Image) -> some View {
        return VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()

                Text("Welcome, \(username)")
                    .font(.title)
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // Navigate to the chat view
                    // This is a temporary solution
                    // We'll use a navigation link in the future
                    Text("Navigating to chat view")
                }
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
                .frame(width: 120, height: 120, alignment: .center)
                .cornerRadius(50)
                .padding()
        }
        .photosPicker(isPresented: $showChangeImage, selection: $avatarItem, matching: .images, photoLibrary: .shared())
        .popover(isPresented: $showImagePopover) {
            ImagePopupView(image: avatarImage!)
                .onTapGesture {
                showImagePopover.toggle()
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
