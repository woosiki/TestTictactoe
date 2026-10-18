//
//  PlayerColor.swift
//  TestTictactoe
//

/// The palette of 12 colors a player can choose from.
nonisolated enum PlayerColor: String, CaseIterable, Identifiable, Equatable, Hashable, Sendable {
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown

    var id: String { rawValue }

    /// Human readable name used for accessibility.
    var displayName: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
}
