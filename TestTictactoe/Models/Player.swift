//
//  Player.swift
//  TestTictactoe
//

/// One of the two local players.
nonisolated enum Player: String, CaseIterable, Equatable, Hashable, Sendable {
    case x = "X"
    case o = "O"

    /// The player who moves after `self`.
    var opponent: Player {
        switch self {
        case .x: .o
        case .o: .x
        }
    }

    /// The mark drawn on the board for this player.
    var symbol: String { rawValue }
}
