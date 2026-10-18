//
//  GameView.swift
//  TestTictactoe
//

import SwiftUI

/// The board, turn indicator and New Game button.
struct GameView: View {
    let viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Tic-Tac-Toe")
                .font(.largeTitle.bold())

            Spacer(minLength: 0)

            statusView

            BoardView(viewModel: viewModel)

            Spacer(minLength: 0)

            Button {
                viewModel.newGame()
            } label: {
                Label("New Game", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.glassProminent)
            .accessibilityIdentifier("newGameButton")
        }
        .padding()
    }

    private var statusView: some View {
        VStack(spacing: 4) {
            Text(viewModel.statusText)
                .font(.title2.bold())
                .foregroundStyle(viewModel.statusColor?.color ?? .primary)
                .contentTransition(.opacity)
                .animation(.default, value: viewModel.statusText)
                .accessibilityIdentifier("statusLabel")
            Text(viewModel.isGameOver ? "Game over — tap New Game to play again" : " ")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("gameOverLabel")
        }
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
