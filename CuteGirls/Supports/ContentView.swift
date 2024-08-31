//
//  ContentView.swift
//  CuteGirls
//
//  Created by Coby Kim on 8/30/24.
//

import SwiftUI

import CobyDS
import ComposableArchitecture

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            HomeView(store: Store(initialState: HomeStore.State()) {
                HomeStore()
            })
        }
        .background(Color.backgroundNormalNormal)
        .loadCustomFonts()
        
    }
}

#Preview {
    ContentView()
}
