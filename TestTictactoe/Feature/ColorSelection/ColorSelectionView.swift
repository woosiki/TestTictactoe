//
//  ColorSelectionView.swift
//  TestTictactoe
//

import SwiftUI

/// Lets both players pick their colors before starting a game.
struct ColorSelectionView: View {
    let viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button {
                    viewModel.closeColorSelection()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel("Close")
                .accessibilityIdentifier("closeColorSelectionButton")
            }

            Text("Choose Colors")
                .font(.largeTitle.bold())

            VStack(spacing: 12) {
                ForEach(Player.allCases, id: \.self) { player in
                    ColorPickerRow(
                        player: player,
                        selected: viewModel.color(for: player),
                        isAvailable: { viewModel.isColorAvailable($0, for: player) },
                        onSelect: { viewModel.selectColor($0, for: player) }
                    )
                }
            }

            Spacer()

            Button {
                viewModel.startGame()
            } label: {
                Label("Start Game", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.glassProminent)
            .accessibilityIdentifier("startGameButton")
        }
        .padding()
    }
}

#Preview {
    ColorSelectionView(viewModel: GameViewModel())
}
