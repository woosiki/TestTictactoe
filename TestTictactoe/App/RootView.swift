//
//  RootView.swift
//  TestTictactoe
//

import SwiftUI

/// Presents the screen selected in the store.
struct RootView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            switch viewModel.screen {
            case .home:
                HomeView(viewModel: viewModel)
                    .transition(.opacity)
            case .colorSelection:
                ColorSelectionView(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            case .game:
                GameView(viewModel: viewModel)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.screen)
    }
}

#Preview {
    RootView()
}
