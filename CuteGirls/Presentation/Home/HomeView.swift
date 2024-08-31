//
//  HomeView.swift
//  CuteGirls
//
//  Created by Coby on 8/31/24.
//

import SwiftUI

import CobyDS
import ComposableArchitecture

struct HomeView: View {
    
    @Bindable private var store: StoreOf<HomeStore>
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    init(store: StoreOf<HomeStore>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarView(
                leftSide: .title,
                leftTitle: "오늘, 소녀",
                rightSide: .icon,
                rightIcon: UIImage.icCamera,
                rightAction: {
                    self.store.send(.showTakePhoto)
                }
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    TopRankerListView()
                    
                    Top100RankerListView()
                }
                
                Spacer()
            }
        }
        .navigationDestination(
            item: self.$store.scope(state: \.takePhoto, action: \.takePhoto)
        ) { store in
            TakePhotoView(store: store).navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func TopRankerListView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(1..<11) { number in
                    ThumbnailTitleView(
                        image: nil,
                        title: "123",
                        description: "#1"
                    )
                    .frame(width: BaseSize.fullWidth)
                    .scrollTransition(.interactive, axis: .horizontal) { effect, phase in
                        effect
                            .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                    }
                }
            }
            .padding(.horizontal, BaseSize.horizantalPadding)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
    }
    
    @ViewBuilder
    private func Top100RankerListView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top 11-100")
                .font(.pretendard(size: 18, weight: .semibold))
                .foregroundColor(Color.labelNormal)
            
            LazyVGrid(columns: self.columns, spacing: 12) {
                ForEach((0...19), id: \.self) { _ in
                    ThumbnailTitleView(
                        image: nil,
                        title: "123",
                        description: "#1"
                    )
                }
            }
        }
        .padding(.horizontal, BaseSize.horizantalPadding)
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeStore.State()) {
        HomeStore()
    })
}
