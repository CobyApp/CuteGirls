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
        var isPhotoTaken: Bool = false // 사진이 찍혔는지 여부를 나타내는 상태 추가
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dismiss
        case startCamera
        case stopCamera
        case takePhoto
        case retakePhoto // 새로 찍기 액션 추가
        case frameReceived(CGImage)
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
                
            case .takePhoto:
                state.isPhotoTaken = true // 사진이 찍혔음을 표시
                return .send(.stopCamera)
                
            case .retakePhoto:
                state.isPhotoTaken = false // 사진 상태 초기화
                return .send(.startCamera)
                
            case .frameReceived(let image):
                state.currentFrame = image
                return .none
            }
        }
    }
}
