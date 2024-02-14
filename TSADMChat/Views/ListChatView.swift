//
//  ListChatView.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 14/2/24.
//

import SwiftUI
import SwiftData

struct ListChatView: View {

    @Query(sort: \Message.date, order: .forward, animation: .easeIn) var messages: [Message]
    
    var body: some View {
        ScrollViewReader { proxy in
            
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
            .onAppear{
                withAnimation {
                    proxy.scrollTo(messages.last, anchor: .bottom)
                }
            }
        }
    }
}
            
