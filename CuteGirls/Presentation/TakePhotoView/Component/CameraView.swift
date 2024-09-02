//
//  CameraView.swift
//  CuteGirls
//
//  Created by Coby Kim on 8/30/24.
//

import SwiftUI

import CobyDS

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
                Image(uiImage: UIImage.icImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(Color.labelAlternative)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.fillStrong)
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .contentShape(Rectangle())
    }
}

#Preview {
    CameraView(image: .constant(nil))
}
