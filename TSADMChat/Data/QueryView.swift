//
//  QueryView.swift
//  TSADMChat
//
//  Created by Daniel Muñoz on 14/2/24.
//

import Foundation
import SwiftUI
import SwiftData

/**
 # QueryView #
 A view that represents a query to the database.
 
 - note: https://ihor.pro/implementing-a-swiftdata-query-view-as-the-most-convenient-way-to-fetch-data-in-swiftui-f69d59348783
 */
struct QueryView<Model: PersistentModel, Content: View>: View {
    
    @Query private var query: [Model]
    private var content: ([Model]) -> (Content)
    
    init(for type: Model.Type,
         sort: [SortDescriptor<Model>] = [],
         @ViewBuilder content: @escaping ([Model]) -> Content,
         filter: (() -> (Predicate<Model>))? = nil) {
        _query = Query(filter: filter?(), sort: sort)
        self.content = content
    }
    
    var body: some View {
        content(query)
    }
    
}
