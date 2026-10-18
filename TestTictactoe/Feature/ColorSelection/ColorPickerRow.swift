//
//  ColorPickerRow.swift
//  TestTictactoe
//

import SwiftUI

/// Lets one player choose their color from the 12-color palette.
struct ColorPickerRow: View {
    let player: Player
    let selected: PlayerColor
    let isAvailable: (PlayerColor) -> Bool
    let onSelect: (PlayerColor) -> Void

    private let columnCount = 6

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(player.symbol)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(selected.color)
                .frame(width: 36)
                .accessibilityHidden(true)

            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(rows, id: \.first) { row in
                    GridRow {
                        ForEach(row) { color in
                            swatch(for: color)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 16))
    }

    /// The 12 colors split into rows of `columnCount`.
    private var rows: [[PlayerColor]] {
        stride(from: 0, to: PlayerColor.allCases.count, by: columnCount).map {
            Array(PlayerColor.allCases[$0..<min($0 + columnCount, PlayerColor.allCases.count)])
        }
    }

    private func swatch(for color: PlayerColor) -> some View {
        let isSelected = color == selected
        let available = isAvailable(color)
        return Button {
            onSelect(color)
        } label: {
            Circle()
                .fill(color.color)
                .frame(width: 30, height: 30)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    } else if !available {
                        Image(systemName: "xmark")
                            .font(.caption2.bold())
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .overlay {
                    Circle()
                        .strokeBorder(.primary, lineWidth: isSelected ? 2.5 : 0)
                        .padding(-4)
                }
                .opacity(available ? 1 : 0.3)
                .frame(maxWidth: .infinity, minHeight: 36)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!available)
        .accessibilityIdentifier("color_\(player.symbol)_\(color.rawValue)")
        .accessibilityLabel("Player \(player.symbol) \(color.displayName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
