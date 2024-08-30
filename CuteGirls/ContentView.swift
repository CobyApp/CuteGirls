//
//  ContentView.swift
//  CuteGirls
//
//  Created by Coby Kim on 8/30/24.
//

import SwiftUI

struct ContentView: View {
    
    @State
    private var viewModel = ViewModel()
    
    var body: some View {
        CameraView(image: $viewModel.currentFrame)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
