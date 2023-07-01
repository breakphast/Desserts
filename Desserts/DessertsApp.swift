//
//  DessertsApp.swift
//  Desserts
//
//  Created by Desmond Fitch on 6/29/23.
//

import SwiftUI

@main
struct DessertsApp: App {
    @StateObject var viewModel = DessertViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
