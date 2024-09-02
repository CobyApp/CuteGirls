//
//  CameraView.swift
//  CuteGirls
//
//  Created by Coby Kim on 8/30/24.
//

import SwiftUI

struct CameraView: View {
    
    @Binding var image: CGImage?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                ContentUnavailableView("Camera feed interrupted", systemImage: "xmark.circle.fill")
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .contentShape(Rectangle())
    }
}

#Preview {
    CameraView(image: .constant(nil))
}
