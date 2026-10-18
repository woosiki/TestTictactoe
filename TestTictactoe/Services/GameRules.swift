//
//  GameRules.swift
//  TestTictactoe
//

/// Pure rules for evaluating a Tic-Tac-Toe board.
nonisolated enum GameRules {
    /// All eight lines that win the game.
    static let winningLines: [WinningLine] = [
        // Rows
        WinningLine(indices: [0, 1, 2]),
        WinningLine(indices: [3, 4, 5]),
        WinningLine(indices: [6, 7, 8]),
        // Columns
        WinningLine(indices: [0, 3, 6]),
        WinningLine(indices: [1, 4, 7]),
        WinningLine(indices: [2, 5, 8]),
        // Diagonals
        WinningLine(indices: [0, 4, 8]),
        WinningLine(indices: [2, 4, 6]),
    ]

    /// Determines whether the board is won, drawn or still in progress.
    static func evaluate(_ board: Board) -> GameStatus {
        for line in winningLines {
            let marks = line.indices.map { board[$0] }
            if let first = marks[0], marks.allSatisfy({ $0 == first }) {
                return .won(first, line)
            }
        }
        return board.isFull ? .draw : .inProgress
    }
}
