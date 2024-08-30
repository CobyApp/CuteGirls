//
//  ViewModel.swift
//  CuteGirls
//
//  Created by Coby Kim on 8/30/24.
//

import Foundation
import CoreImage

@Observable
class ViewModel {
    
    var currentFrame: CGImage?
    
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}
