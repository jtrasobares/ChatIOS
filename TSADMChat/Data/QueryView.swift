//
//  QueryView.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 14/2/24.
//

import Foundation
import SwiftUI
import SwiftData

struct QueryView<Model: PersistentModel, Content: View>: View {
    
    @Query private var query: [Model]
    var type: Model.Type
    @ViewBuilder var content: ([Model]) -> (Content)
    
    var body: some View {
        content(query)
    }
    
}
