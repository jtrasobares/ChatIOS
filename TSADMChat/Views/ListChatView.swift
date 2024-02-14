//
//  ListChatView.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 14/2/24.
//

import SwiftUI
import SwiftData

/**
 # ListChatView #
 This view is used to show the list of messages in the chat
 */
struct ListChatView: View {
    
    var body: some View {
        QueryView(for: Message.self, sort: [SortDescriptor(\Message.date, order: .forward)], content: { messages in
            ScrollViewReader { proxy in
                List(messages, id: \.self) { inputMessage in
                    MessageView(message: inputMessage)
                        .id(inputMessage)
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
        })
    }
}

