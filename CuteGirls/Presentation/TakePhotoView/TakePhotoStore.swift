//
//  TakePhotoStore.swift
//  CuteGirls
//
//  Created by Coby on 9/1/24.
//

import UIKit
import CoreImage

import ComposableArchitecture

@Reducer
struct TakePhotoStore: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var currentFrame: CGImage?
        var isCameraRunning: Bool = false
        var isPhotoTaken: Bool = false
        var cameraManager: CameraManager? = nil
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dismiss
        case startCamera
        case stopCamera
        case takePhoto
        case retakePhoto
        case switchCamera
        case frameReceived(CGImage)
        case cameraStarted(CameraManager)
        case cameraStopped
    }
    
    @Dependency(\.dismiss) private var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .dismiss:
                return .run { [cameraManager = state.cameraManager] send in
                    if let cameraManager = cameraManager {
                        await cameraManager.terminateSession()
                    }
                    await self.dismiss()
                }
                
            case .startCamera:
                guard !state.isCameraRunning else { return .none }
                
                let cameraManager = CameraManager()
                return .run { send in
                    await cameraManager.startSession()
                    await send(.cameraStarted(cameraManager))
                    for await image in cameraManager.previewStream {
                        await send(.frameReceived(image))
                    }
                }
                
            case .cameraStarted(let cameraManager):
                state.cameraManager = cameraManager
                state.isCameraRunning = true
                return .none
                
            case .stopCamera:
                guard state.isCameraRunning else { return .none }
                state.isCameraRunning = false
                return .run { [cameraManager = state.cameraManager] send in
                    if let cameraManager = cameraManager {
                        await cameraManager.stopSession()
                    }
                    await send(.cameraStopped)
                }
                
            case .cameraStopped:
                state.isCameraRunning = false
                return .none
                
            case .takePhoto:
                state.isPhotoTaken = true
                return .send(.stopCamera)
                
            case .retakePhoto:
                state.isPhotoTaken = false
                return .send(.startCamera)
                
            case .switchCamera:
                return .run { [cameraManager = state.cameraManager] _ in
                    if let cameraManager = cameraManager {
                        await cameraManager.switchCamera()
                    }
                }
                
            case .frameReceived(let image):
                state.currentFrame = image
                return .none
            }
        }
    }
}
