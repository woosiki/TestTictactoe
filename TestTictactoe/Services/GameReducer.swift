//
//  GameReducer.swift
//  TestTictactoe
//

/// The complete state of the app session.
nonisolated struct GameState: Equatable, Sendable {
    var screen: Screen = .home
    var board = Board()
    var currentPlayer: Player = .x
    var status: GameStatus = .inProgress
    var colors: [Player: PlayerColor] = [.x: .blue, .o: .red]

    func color(for player: Player) -> PlayerColor {
        colors[player] ?? (player == .x ? .blue : .red)
    }
}

/// Everything a user can do in the app.
nonisolated enum GameAction: Equatable, Sendable {
    case showColorSelection
    case showHome
    case startGame
    case play(index: Int)
    case selectColor(PlayerColor, for: Player)
    case newGame
}

nonisolated enum GameReducer {
    static func reduce(_ state: inout GameState, _ action: GameAction) {
        switch action {
        case .showColorSelection:
            state.screen = .colorSelection

        case .showHome:
            state.screen = .home

        case .startGame:
            resetBoard(&state)
            state.screen = .game

        case let .play(index):
            guard state.screen == .game,
                  !state.status.isFinished,
                  state.board.place(state.currentPlayer, at: index) else { return }
            state.status = GameRules.evaluate(state.board)
            if !state.status.isFinished {
                state.currentPlayer = state.currentPlayer.opponent
            }

        case let .selectColor(color, player):
            // Both players must stay distinguishable, so a taken color is rejected.
            guard state.color(for: player.opponent) != color else { return }
            state.colors[player] = color

        case .newGame:
            // Go back to color selection; the players' previous colors stay selected.
            resetBoard(&state)
            state.screen = .colorSelection
        }
    }

    private static func resetBoard(_ state: inout GameState) {
        state.board = Board()
        state.currentPlayer = .x
        state.status = .inProgress
    }
}
