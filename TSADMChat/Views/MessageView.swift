//
//  MessageView.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 3/2/24.
//

import SwiftUI
import PhotosUI
import SwiftData

/**
 # MessageView #
 A view to display the message in the chat. It contains the logic to show the image and to show the profile of the user.
 
 */
struct MessageView: View{
    let message: Message
    @State var showProfile: Bool = false
    @State var showImage: Bool = false
    
    var body: some View{
        if(message.user!.id == "__defaultOwner__"){
            HStack(alignment: .bottom) {
                Spacer()
                VStack(alignment: .leading){
                    Text(message.user!.name!)
                        .padding(.top, 4)
                        .padding(.leading,12)
                        .padding(.trailing, 12)
                        .frame(alignment: .leading)
                        .bold()
                        .font(.footnote)
                        .foregroundColor(.white)
                    if(message.image != nil){
                        Image(uiImage: message.getImageUI()!)
                            .resizable()
                            .cornerRadius(10)
                            .scaledToFit()
                            .padding(.horizontal, 8)
                            .onTapGesture {
                                showImage.toggle()
                            }
                            .sheet(isPresented: $showImage){
                                imagePopupView(imageData: message.image!)
                                    .presentationDragIndicator(.visible)
                                    .onTapGesture {
                                        showImage.toggle()
                                    }
                            }
                    }
                    Text(message.text!)
                        .padding(.top,0)
                        .padding(.bottom,8)
                        .padding(.horizontal, 12)
                        .foregroundColor(.white)
                        .frame(alignment: .leading)
                    
                }
                .background(Color(UIColor.systemBlue))
                .clipShape(BubbleShape(myMessage: true))
                .padding(.bottom,15)
                if(message.user!.image != nil){
                    Image(uiImage:message.user!.getImageUI()!)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .bottom)
                        .cornerRadius(20)
                        .onTapGesture {
                            showProfile.toggle()
                        }
                        .sheet(isPresented: $showProfile){
                            ProfileView(user: message.user!).presentationDragIndicator(.visible)
                        }
                }else{
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .bottom)
                        .cornerRadius(20)
                        .onTapGesture {
                            showProfile.toggle()
                        }
                        .sheet(isPresented: $showProfile){
                            ProfileView(user: message.user!).presentationDragIndicator(.visible)
                        }
                }
                
                
                
            }
            .padding(.leading, 55)
            .padding(.trailing, 3)
            
            
        }
        else{
            HStack(alignment: .bottom)  {
                if(message.user!.image != nil){
                    Image(uiImage:message.user!.getImageUI()!)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .bottom)
                        .cornerRadius(20)
                        .onTapGesture {
                            showProfile.toggle()
                        }
                        .sheet(isPresented: $showProfile){
                            ProfileView(user: message.user!).presentationDragIndicator(.visible)
                        }
                    
                }else{
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .bottom)
                        .cornerRadius(20)
                        .onTapGesture {
                            showProfile.toggle()
                        }
                        .sheet(isPresented: $showProfile){
                            ProfileView(user: message.user!).presentationDragIndicator(.visible)
                        }
                }
                VStack(alignment: .leading){
                    
                    Text(message.user!.name!)
                        .padding(.top, 4)
                        .padding(.leading,12)
                        .padding(.trailing, 12)
                        .frame(alignment: .leading)
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.white)
                    if(message.image != nil){
                        Image(uiImage: message.getImageUI()!)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.horizontal, 8)
                            .onTapGesture {
                                showImage.toggle()
                            }
                            .sheet(isPresented: $showImage){
                                imagePopupView(imageData: message.image!)
                                    .presentationDragIndicator(.visible)
                                    .onTapGesture {
                                        showImage.toggle()
                                    }
                            }
                        
                    }
                    Text(message.text!)
                        .padding(.top,0)
                        .padding(.bottom,8)
                        .padding(.horizontal, 12)
                        .foregroundColor(.white)
                        .frame(alignment: .leading)
                }.id("text")
                    .background(Color(UIColor.systemOrange))
                    .clipShape(BubbleShape(myMessage: false))
                    .padding(.bottom,15)
                Spacer()
            }
            .padding(.trailing, 55)
        }
        
    }
    
    
}

struct BubbleShape: Shape {
    var myMessage : Bool
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        let bezierPath = UIBezierPath()
        if !myMessage {
            bezierPath.move(to: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: width - 15, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height - 15), controlPoint1: CGPoint(x: width - 8, y: height), controlPoint2: CGPoint(x: width, y: height - 8))
            bezierPath.addLine(to: CGPoint(x: width, y: 15))
            bezierPath.addCurve(to: CGPoint(x: width - 15, y: 0), controlPoint1: CGPoint(x: width, y: 8), controlPoint2: CGPoint(x: width - 8, y: 0))
            bezierPath.addLine(to: CGPoint(x: 20, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 5, y: 15), controlPoint1: CGPoint(x: 12, y: 0), controlPoint2: CGPoint(x: 5, y: 8))
            bezierPath.addLine(to: CGPoint(x: 5, y: height - 10))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 5, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: -1, y: height))
            bezierPath.addCurve(to: CGPoint(x: 12, y: height - 4), controlPoint1: CGPoint(x: 4, y: height + 1), controlPoint2: CGPoint(x: 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: 20, y: height+15), controlPoint1: CGPoint(x: -10, y: height), controlPoint2: CGPoint(x: 20, y: height))
        } else {
            bezierPath.move(to: CGPoint(x: width - 20, y: height))
            bezierPath.addLine(to: CGPoint(x: 15, y: height))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height - 15), controlPoint1: CGPoint(x: 8, y: height), controlPoint2: CGPoint(x: 0, y: height - 8))
            bezierPath.addLine(to: CGPoint(x: 0, y: 15))
            bezierPath.addCurve(to: CGPoint(x: 15, y: 0), controlPoint1: CGPoint(x: 0, y: 8), controlPoint2: CGPoint(x: 8, y: 0))
            bezierPath.addLine(to: CGPoint(x: width - 20, y: 0))
            bezierPath.addCurve(to: CGPoint(x: width - 5, y: 15), controlPoint1: CGPoint(x: width - 12, y: 0), controlPoint2: CGPoint(x: width - 5, y: 8))
            bezierPath.addLine(to: CGPoint(x: width - 5, y: height - 12))
            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 5, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width + 1, y: height))
            bezierPath.addCurve(to: CGPoint(x: width - 12, y: height - 4), controlPoint1: CGPoint(x: width - 4, y: height + 1), controlPoint2: CGPoint(x: width - 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: width - 20, y: height), controlPoint1: CGPoint(x: width + 10, y: height+5), controlPoint2: CGPoint(x: width - 20, y: height))
        }
        return Path(bezierPath.cgPath)
    }
}


/*#Preview{
 MessageView(message: Message(id: "1", user: "Pedro", text: "Hola Soy pedro"))
 }*/
