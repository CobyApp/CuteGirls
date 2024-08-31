//
//  HomeStore.swift
//  CuteGirls
//
//  Created by Coby on 9/1/24.
//

import Foundation

import ComposableArchitecture

@Reducer
struct HomeStore: Reducer {
    
    @ObservableState
    struct State: Equatable {
        @Presents var takePhoto: TakePhotoStore.State?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case takePhoto(PresentationAction<TakePhotoStore.Action>)
        case showTakePhoto
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .takePhoto:
                return .none
            case .showTakePhoto:
                state.takePhoto = TakePhotoStore.State()
                return .none
            }
        }
        .ifLet(\.$takePhoto, action: \.takePhoto) {
            TakePhotoStore()
        }
    }
}
