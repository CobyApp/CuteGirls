//
//  TakePhotoView.swift
//  CuteGirls
//
//  Created by Coby on 9/1/24.
//

import SwiftUI
import CoreImage

import CobyDS
import ComposableArchitecture

struct TakePhotoView: View {
    
    @Bindable private var store: StoreOf<TakePhotoStore>
    
    init(store: StoreOf<TakePhotoStore>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 12) {
            TopBarView(
                leftAction: {
                    self.store.send(.dismiss)
                },
                title: "사진 찍기"
            )
            
            VStack(spacing: 20) {
                CameraView(image: self.$store.currentFrame)
                    .frame(width: BaseSize.fullWidth, height: BaseSize.fullWidth)
                
                if store.isPhotoTaken {
                    Button(action: {
                        self.store.send(.retakePhoto)
                    }) {
                        Text("사진 새로 찍기")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        self.store.send(.takePhoto)
                    }) {
                        Text("사진 찍기")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    self.store.send(.switchCamera)
                }) {
                    Image(systemName: "camera.rotate")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .padding()
                }
                .background(Color.white.opacity(0.7))
                .clipShape(Circle())
            }
            .padding(.horizontal, BaseSize.horizantalPadding)
            
            Spacer()
        }
        .onAppear {
            self.store.send(.startCamera)
        }
    }
}

#Preview {
    TakePhotoView(store: Store(initialState: TakePhotoStore.State()) {
        TakePhotoStore()
    })
}
