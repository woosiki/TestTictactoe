//
//  GameReducerTests.swift
//  TestTictactoeTests
//

import Testing
@testable import TestTictactoe

struct GameReducerTests {
    /// A fresh state already on the game screen.
    private static var playing: GameState { GameState(screen: .game) }

    private func play(_ moves: [Int], from state: GameState = playing) -> GameState {
        var state = state
        moves.forEach { GameReducer.reduce(&state, .play(index: $0)) }
        return state
    }

    @Test func initialStateStartsOnHomeWithX() {
        let state = GameState()
        #expect(state.screen == .home)
        #expect(state.currentPlayer == .x)
        #expect(state.status == .inProgress)
        #expect(state.color(for: .x) != state.color(for: .o))
    }

    @Test func playAlternatesTurns() {
        let state = play([0])
        #expect(state.board[0] == .x)
        #expect(state.currentPlayer == .o)
        #expect(play([0, 1]).currentPlayer == .x)
    }

    @Test func playingOccupiedCellIsIgnored() {
        let state = play([0, 0])
        #expect(state.board[0] == .x)
        #expect(state.currentPlayer == .o)
    }

    @Test func xWinsTopRow() {
        let state = play([0, 3, 1, 4, 2])
        #expect(state.status == .won(.x, WinningLine(indices: [0, 1, 2])))
        #expect(state.currentPlayer == .x)
    }

    @Test func oWinsMiddleRow() {
        let state = play([0, 3, 1, 4, 8, 5])
        #expect(state.status == .won(.o, WinningLine(indices: [3, 4, 5])))
    }

    @Test func fullBoardWithoutWinnerIsDraw() {
        let state = play([0, 1, 2, 4, 3, 5, 7, 6, 8])
        #expect(state.status == .draw)
    }

    @Test func movesAfterGameOverAreIgnored() {
        let finished = play([0, 3, 1, 4, 2])
        let after = play([8], from: finished)
        #expect(after == finished)
    }

    @Test func newGameResetsBoardKeepsColorsAndReturnsToColorSelection() {
        var state = Self.playing
        GameReducer.reduce(&state, .selectColor(.green, for: .x))
        GameReducer.reduce(&state, .selectColor(.purple, for: .o))
        state = play([0, 3, 1, 4, 2], from: state)
        GameReducer.reduce(&state, .newGame)
        #expect(state.screen == .colorSelection)
        #expect(state.board == Board())
        #expect(state.status == .inProgress)
        #expect(state.currentPlayer == .x)
        #expect(state.color(for: .x) == .green)
        #expect(state.color(for: .o) == .purple)
    }

    @Test func movesAreIgnoredOutsideTheGameScreen() {
        let state = play([0], from: GameState())
        #expect(state.board == Board())
        #expect(state.currentPlayer == .x)
    }

    @Test func navigationFlowsHomeToColorSelectionToGame() {
        var state = GameState()
        GameReducer.reduce(&state, .showColorSelection)
        #expect(state.screen == .colorSelection)
        GameReducer.reduce(&state, .showHome)
        #expect(state.screen == .home)
        GameReducer.reduce(&state, .showColorSelection)
        GameReducer.reduce(&state, .startGame)
        #expect(state.screen == .game)
    }

    @Test func startGameBeginsWithEmptyBoard() {
        var state = play([0, 1])
        GameReducer.reduce(&state, .startGame)
        #expect(state.board == Board())
        #expect(state.currentPlayer == .x)
        #expect(state.screen == .game)
    }

    @Test(arguments: PlayerColor.allCases)
    func playerCanSelectAnyColorNotUsedByOpponent(color: PlayerColor) {
        var state = GameState()
        let opponentColor = state.color(for: .o)
        GameReducer.reduce(&state, .selectColor(color, for: .x))
        let expected = color == opponentColor ? GameState().color(for: .x) : color
        #expect(state.color(for: .x) == expected)
    }

    @Test func paletteHasTwelveColors() {
        #expect(PlayerColor.allCases.count == 12)
    }
}

@MainActor
struct StoreTests {
    @Test func sendRunsReducerAndUpdatesState() {
        let store = Store(initialState: GameState(), reducer: GameReducer.reduce)
        store.send(.startGame)
        store.send(.play(index: 4))
        #expect(store.state.board[4] == .x)
        store.send(.newGame)
        #expect(store.state.board == Board())
        #expect(store.state.screen == .colorSelection)
    }
}

@MainActor
struct GameViewModelTests {
    @Test func statusTextReflectsTurnWinAndDraw() {
        let viewModel = GameViewModel()
        viewModel.startGame()
        #expect(viewModel.statusText == "Player X's turn")
        viewModel.tapCell(0)
        #expect(viewModel.statusText == "Player O's turn")

        [3, 1, 4, 2].forEach(viewModel.tapCell)
        #expect(viewModel.statusText == "Player X wins!")
        #expect(viewModel.isGameOver)
        #expect(viewModel.isWinningCell(1))
        #expect(!viewModel.isWinningCell(3))
        #expect(!viewModel.isCellEnabled(8))

        viewModel.newGame()
        #expect(viewModel.screen == .colorSelection)
        viewModel.startGame()
        [0, 1, 2, 4, 3, 5, 7, 6, 8].forEach(viewModel.tapCell)
        #expect(viewModel.statusText == "It's a draw!")
    }

    @Test func screenNavigation() {
        let viewModel = GameViewModel()
        #expect(viewModel.screen == .home)
        viewModel.openColorSelection()
        #expect(viewModel.screen == .colorSelection)
        viewModel.closeColorSelection()
        #expect(viewModel.screen == .home)
    }

    @Test func colorTakenByOpponentIsUnavailable() {
        let viewModel = GameViewModel()
        let oColor = viewModel.color(for: .o)
        #expect(!viewModel.isColorAvailable(oColor, for: .x))
        viewModel.selectColor(oColor, for: .x)
        #expect(viewModel.color(for: .x) != oColor)
    }
}
