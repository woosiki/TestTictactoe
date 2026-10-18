//
//  HomeView.swift
//  TestTictactoe
//

import SwiftUI

/// The initial screen. Tapping anywhere opens color selection.
struct HomeView: View {
    let viewModel: GameViewModel

    private let previewMarks: [Player?] = [.x, .o, .x, nil, .x, .o, .o, nil, .x]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Tic-Tac-Toe")
                .font(.system(size: 44, weight: .heavy, design: .rounded))

            previewBoard
                .frame(width: 180, height: 180)
                .accessibilityHidden(true)

            Spacer()

            Text("Tap anywhere to start")
                .font(.headline)
                .foregroundStyle(.secondary)
                .phaseAnimator([1.0, 0.4]) { content, opacity in
                    content.opacity(opacity)
                } animation: { _ in .easeInOut(duration: 1) }
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .onTapGesture { viewModel.openColorSelection() }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("homeScreen")
    }

    private var previewBoard: some View {
        Grid(horizontalSpacing: 6, verticalSpacing: 6) {
            ForEach(0..<Board.size, id: \.self) { row in
                GridRow {
                    ForEach(0..<Board.size, id: \.self) { column in
                        let mark = previewMarks[row * Board.size + column]
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                            .overlay {
                                if let mark {
                                    Text(mark.symbol)
                                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                                        .foregroundStyle(viewModel.color(for: mark).color)
                                }
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(viewModel: GameViewModel())
}
