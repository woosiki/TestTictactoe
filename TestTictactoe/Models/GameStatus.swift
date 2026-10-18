//
//  GameStatus.swift
//  TestTictactoe
//

/// Three cells that complete a row, column or diagonal.
nonisolated struct WinningLine: Equatable, Hashable, Sendable {
    let indices: [Int]

    func contains(_ index: Int) -> Bool { indices.contains(index) }
}

/// The outcome of the current game.
nonisolated enum GameStatus: Equatable, Sendable {
    case inProgress
    case won(Player, WinningLine)
    case draw

    /// `true` once the game has ended with a win or a draw.
    var isFinished: Bool { self != .inProgress }

    var winner: Player? {
        if case let .won(player, _) = self { return player }
        return nil
    }

    var winningLine: WinningLine? {
        if case let .won(_, line) = self { return line }
        return nil
    }
}
