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
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dismiss
        case startCamera
        case stopCamera
        case frameReceived(CGImage)
        case switchCamera
    }
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.cameraManager) private var cameraManager
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .dismiss:
                return .run { _ in await self.dismiss() }
                
            case .startCamera:
                guard !state.isCameraRunning else { return .none }
                state.isCameraRunning = true
                return .run { send in
                    await cameraManager.startSession()
                    for await image in cameraManager.previewStream {
                        await send(.frameReceived(image))
                    }
                }
                
            case .stopCamera:
                guard state.isCameraRunning else { return .none }
                state.isCameraRunning = false
                return .run { _ in
                    await cameraManager.stopSession()
                }
                
            case .frameReceived(let image):
                state.currentFrame = image
                return .none
                
            case .switchCamera:
                cameraManager.switchCamera()
                return .none
            }
        }
    }
}
