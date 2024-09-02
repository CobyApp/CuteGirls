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
        VStack(spacing: 0) {
            TopBarView(
                leftAction: {
                    self.store.send(.dismiss)
                },
                title: "사진 찍기"
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    CameraView(image: self.$store.currentFrame)
                        .frame(width: BaseSize.fullWidth, height: BaseSize.fullWidth)
                    
                    CameraButtonsView()
                    
                    Spacer()
                }
                .padding(.horizontal, BaseSize.horizantalPadding)
                .padding(.vertical, 12)
            }
            
            Button {
                if self.store.isPhotoTaken {
                    
                }
            } label: {
                Text("다음")
            }
            .buttonStyle(
                CBButtonStyle(
                    isDisabled: !self.store.isPhotoTaken,
                    buttonColor: Color.pink50
                )
            )
            .padding(.horizontal, BaseSize.horizantalPadding)
            .padding(.bottom, 20)
        }
        .onAppear {
            self.store.send(.startCamera)
        }
    }
    
    @ViewBuilder
    private func CameraButtonsView() -> some View {
        HStack(spacing: 16) {
            Button(action: {
                self.store.send(.retakePhoto)
            }) {
                Image(uiImage: UIImage.icRefresh)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(16)
                    .background(Color.fillNormal)
                    .clipShape(Circle())
                    .foregroundColor(Color.labelNormal)
            }
            
            Button(action: {
                self.store.send(.takePhoto)
            }) {
                Image(uiImage: UIImage.icCamera)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(20)
                    .background(Color.fillNormal)
                    .clipShape(Circle())
                    .foregroundColor(Color.labelNormal)
            }
            
            Button(action: {
                self.store.send(.switchCamera)
            }) {
                Image(uiImage: UIImage.icCameraSwitch)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(16)
                    .background(Color.fillNormal)
                    .clipShape(Circle())
                    .foregroundColor(Color.labelNormal)
            }
        }
    }
}

#Preview {
    TakePhotoView(store: Store(initialState: TakePhotoStore.State()) {
        TakePhotoStore()
    })
}
