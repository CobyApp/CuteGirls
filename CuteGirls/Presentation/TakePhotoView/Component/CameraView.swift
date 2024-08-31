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
            let sideLength = min(geometry.size.width, geometry.size.height)
            
            if let image = image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .frame(width: sideLength, height: sideLength)
                    .clipped()
            } else {
                ContentUnavailableView("Camera feed interrupted", systemImage: "xmark.circle.fill")
                    .frame(width: sideLength, height: sideLength)
                    .clipped()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CameraView(image: .constant(nil))
}
