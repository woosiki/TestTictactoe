//
//  GameViewModel.swift
//  TestTictactoe
//

import Observation

/// Bridges the game store to the views: exposes display-ready values and turns user intents into actions.
@Observable
final class GameViewModel {
    @ObservationIgnored private let store: Store<GameState, GameAction>

    init(store: Store<GameState, GameAction> = Store(initialState: GameState(), reducer: GameReducer.reduce)) {
        self.store = store
    }

    var state: GameState { store.state }

    var statusText: String {
        switch state.status {
        case .inProgress: "Player \(state.currentPlayer.symbol)'s turn"
        case let .won(player, _): "Player \(player.symbol) wins!"
        case .draw: "It's a draw!"
        }
    }

    /// The color that should tint the status message.
    var statusColor: PlayerColor? {
        switch state.status {
        case .inProgress: state.color(for: state.currentPlayer)
        case let .won(player, _): state.color(for: player)
        case .draw: nil
        }
    }

    var isGameOver: Bool { state.status.isFinished }

    func mark(at index: Int) -> Player? { state.board[index] }

    func isWinningCell(_ index: Int) -> Bool {
        state.status.winningLine?.contains(index) ?? false
    }

    func isCellEnabled(_ index: Int) -> Bool {
        !isGameOver && state.board.isEmpty(at: index)
    }

    func color(for player: Player) -> PlayerColor { state.color(for: player) }

    /// A color is unavailable to `player` when the opponent already uses it.
    func isColorAvailable(_ color: PlayerColor, for player: Player) -> Bool {
        state.color(for: player.opponent) != color
    }

    func tapCell(_ index: Int) { store.send(.play(index: index)) }

    func selectColor(_ color: PlayerColor, for player: Player) {
        store.send(.selectColor(color, for: player))
    }

    func newGame() { store.send(.newGame) }

    var screen: Screen { state.screen }

    func openColorSelection() { store.send(.showColorSelection) }

    func closeColorSelection() { store.send(.showHome) }

    func startGame() { store.send(.startGame) }
}
