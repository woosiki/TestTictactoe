//
//  BoardView.swift
//  TestTictactoe
//

import SwiftUI

/// The 3x3 grid of cells.
struct BoardView: View {
    let viewModel: GameViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: Board.size)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<Board.cellCount, id: \.self) { index in
                CellView(
                    mark: viewModel.mark(at: index),
                    markColor: viewModel.mark(at: index).map { viewModel.color(for: $0).color },
                    isWinning: viewModel.isWinningCell(index),
                    isDimmed: viewModel.state.status.winner != nil && !viewModel.isWinningCell(index),
                    index: index
                ) {
                    viewModel.tapCell(index)
                }
                .disabled(!viewModel.isCellEnabled(index))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        // Claim space before the surrounding spacers so the board keeps its size.
        .layoutPriority(1)
    }
}

private struct CellView: View {
    let mark: Player?
    let markColor: Color?
    let isWinning: Bool
    let isDimmed: Bool
    let index: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // The cell's size comes only from the shape; the mark is an overlay so it can never resize the board.
            RoundedRectangle(cornerRadius: 16)
                .fill(isWinning ? (markColor ?? .clear).opacity(0.25) : Color(.secondarySystemBackground))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isWinning ? (markColor ?? .clear) : .clear, lineWidth: 4)
                }
                .overlay {
                    if let mark {
                        Text(mark.symbol)
                            .font(.system(size: 64, weight: .heavy, design: .rounded))
                            .minimumScaleFactor(0.3)
                            .foregroundStyle(markColor ?? .primary)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            .opacity(isDimmed ? 0.4 : 1)
            .scaleEffect(isWinning ? 1.04 : 1)
            .animation(.spring(duration: 0.3), value: mark)
            .animation(.spring(duration: 0.4), value: isWinning)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("cell_\(index)")
        .accessibilityLabel("Row \(index / Board.size + 1), column \(index % Board.size + 1)")
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        guard let mark else { return "Empty" }
        return isWinning ? "\(mark.symbol), winning" : mark.symbol
    }
}
