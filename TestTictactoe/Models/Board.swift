//
//  Board.swift
//  TestTictactoe
//

/// A 3x3 Tic-Tac-Toe board. Cells are indexed 0...8, row by row.
nonisolated struct Board: Equatable, Sendable {
    static let size = 3
    static let cellCount = size * size

    private(set) var cells: [Player?]

    init() {
        cells = Array(repeating: nil, count: Self.cellCount)
    }

    /// Creates a board from exactly nine cells. Returns `nil` for any other count.
    init?(cells: [Player?]) {
        guard cells.count == Self.cellCount else { return nil }
        self.cells = cells
    }

    subscript(index: Int) -> Player? {
        guard cells.indices.contains(index) else { return nil }
        return cells[index]
    }

    var isFull: Bool { cells.allSatisfy { $0 != nil } }

    func isEmpty(at index: Int) -> Bool {
        cells.indices.contains(index) && cells[index] == nil
    }

    /// Places `player` at `index`. Returns `false` if the index is invalid or occupied.
    @discardableResult
    mutating func place(_ player: Player, at index: Int) -> Bool {
        guard isEmpty(at: index) else { return false }
        cells[index] = player
        return true
    }
}
