//
//  GameRulesTests.swift
//  TestTictactoeTests
//

import Testing
@testable import TestTictactoe

/// Builds a board from a 9-character string where "X", "O" and "." mark cells.
func makeBoard(_ layout: String) throws -> Board {
    let cells: [Player?] = layout.map { Player(rawValue: String($0)) }
    // Fails the test with a message instead of force unwrapping.
    return try #require(Board(cells: cells), "Layout must contain exactly 9 cells: \(layout)")
}

struct GameRulesTests {
    @Test func emptyBoardIsInProgress() {
        #expect(GameRules.evaluate(Board()) == .inProgress)
    }

    @Test func thereAreEightWinningLines() {
        #expect(GameRules.winningLines.count == 8)
        #expect(Set(GameRules.winningLines).count == 8)
    }

    @Test(arguments: GameRules.winningLines)
    func everyLineWinsForX(line: WinningLine) throws {
        var cells = [Player?](repeating: nil, count: Board.cellCount)
        line.indices.forEach { cells[$0] = .x }
        let board = try #require(Board(cells: cells), "Failed to create board")
        #expect(GameRules.evaluate(board) == .won(.x, line))
    }

    @Test func detectsOWinningOnDiagonal() throws {
        let board = try makeBoard("OX." + "XO." + "X.O")
        #expect(GameRules.evaluate(board) == .won(.o, WinningLine(indices: [0, 4, 8])))
    }

    @Test func detectsDraw() throws {
        let board = try makeBoard("XOX" + "XOO" + "OXX")
        #expect(GameRules.evaluate(board) == .draw)
    }

    @Test func winOnFullBoardTakesPrecedenceOverDraw() throws {
        let board = try makeBoard("XXX" + "OOX" + "XOO")
        #expect(GameRules.evaluate(board) == .won(.x, WinningLine(indices: [0, 1, 2])))
    }

    @Test func partialBoardWithoutLineIsInProgress() throws {
        let board = try makeBoard("XO." + "..." + "...")
        #expect(GameRules.evaluate(board) == .inProgress)
    }
}

struct BoardTests {
    @Test func rejectsWrongCellCount() {
        #expect(Board(cells: [nil, nil]) == nil)
    }

    @Test func placeFillsEmptyCellOnly() {
        var board = Board()
        let first = board.place(.x, at: 4)
        let second = board.place(.o, at: 4)
        #expect(first)
        #expect(!second)
        #expect(board[4] == .x)
    }

    @Test func placeRejectsOutOfRangeIndex() {
        var board = Board()
        let negative = board.place(.x, at: -1)
        let tooLarge = board.place(.x, at: 9)
        #expect(!negative)
        #expect(!tooLarge)
        #expect(board == Board())
    }
}
