//
//  TestTictactoeUITests.swift
//  TestTictactoeUITests
//

import XCTest

final class TestTictactoeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        // Launch tests may leave the simulator rotated; these tests expect the portrait layout.
        MainActor.assumeIsolated {
            XCUIDevice.shared.orientation = .portrait
        }
    }

    // MARK: - Helpers

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    @MainActor
    private func homeScreen(in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["homeScreen"]
    }

    @MainActor
    private func openColorSelection(in app: XCUIApplication) {
        let home = homeScreen(in: app)
        XCTAssertTrue(home.waitForExistence(timeout: 5), "Home screen not shown")
        home.tap()
        XCTAssertTrue(app.buttons["startGameButton"].waitForExistence(timeout: 5), "Color selection not shown")
    }

    @MainActor
    private func startGame(in app: XCUIApplication) {
        app.buttons["startGameButton"].tap()
        XCTAssertTrue(app.buttons["cell_0"].waitForExistence(timeout: 5), "Game screen not shown")
    }

    /// Launches the app and navigates Home → Color Selection → Game.
    @MainActor
    private func launchIntoGame() -> XCUIApplication {
        let app = launch()
        openColorSelection(in: app)
        startGame(in: app)
        return app
    }

    @MainActor
    private func tapCells(_ indices: [Int], in app: XCUIApplication) {
        for index in indices {
            let cell = app.buttons["cell_\(index)"]
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "cell_\(index) not found")
            cell.tap()
        }
    }

    @MainActor
    private func status(in app: XCUIApplication) -> String {
        app.staticTexts["statusLabel"].label
    }

    @MainActor
    private func value(ofCell index: Int, in app: XCUIApplication) -> String {
        guard let value = app.buttons["cell_\(index)"].value as? String else {
            XCTFail("cell_\(index) has no string accessibility value")
            return ""
        }
        return value
    }

    // MARK: - Navigation

    @MainActor
    func testHomeOpensColorSelectionAndCloseReturnsHome() {
        let app = launch()
        openColorSelection(in: app)

        app.buttons["closeColorSelectionButton"].tap()

        XCTAssertTrue(homeScreen(in: app).waitForExistence(timeout: 5), "Close must return to the home screen")
        XCTAssertFalse(app.buttons["startGameButton"].exists)
    }

    @MainActor
    func testStartGameShowsGameScreen() {
        let app = launchIntoGame()
        XCTAssertEqual(status(in: app), "Player X's turn")
        XCTAssertFalse(app.buttons["startGameButton"].exists)
    }

    // MARK: - Game

    @MainActor
    func testBoardSizeStaysConstantAfterMoves() {
        let app = launchIntoGame()
        let initialFrames = (0..<9).map { app.buttons["cell_\($0)"].frame }
        let boardWidth = initialFrames[2].maxX - initialFrames[0].minX
        let screenWidth = app.windows.firstMatch.frame.width
        XCTAssertGreaterThan(boardWidth, screenWidth * 0.85, "Board should span nearly the full screen width")

        tapCells([0], in: app)
        // Let mark and layout animations settle.
        _ = app.buttons["cell_0"].waitForExistence(timeout: 1)
        Thread.sleep(forTimeInterval: 1)

        for index in 0..<9 {
            let frame = app.buttons["cell_\(index)"].frame
            XCTAssertEqual(frame.width, initialFrames[index].width, accuracy: 0.5, "cell_\(index) width changed")
            XCTAssertEqual(frame.height, initialFrames[index].height, accuracy: 0.5, "cell_\(index) height changed")
        }

        tapCells([4, 8], in: app)
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(app.buttons["cell_8"].frame.width, initialFrames[8].width, accuracy: 0.5, "Board shrank after more moves")
    }

    @MainActor
    func testXWinsAndHighlightsLine() {
        let app = launchIntoGame()
        tapCells([0, 3, 1, 4, 2], in: app)

        XCTAssertEqual(status(in: app), "Player X wins!")
        for index in [0, 1, 2] {
            XCTAssertEqual(value(ofCell: index, in: app), "X, winning")
        }
        XCTAssertEqual(value(ofCell: 3, in: app), "O")
        XCTAssertFalse(app.buttons["cell_8"].isEnabled, "Board must lock after a win")
    }

    @MainActor
    func testOWinsAndHighlightsLine() {
        let app = launchIntoGame()
        tapCells([0, 3, 1, 4, 8, 5], in: app)

        XCTAssertEqual(status(in: app), "Player O wins!")
        for index in [3, 4, 5] {
            XCTAssertEqual(value(ofCell: index, in: app), "O, winning")
        }
        XCTAssertEqual(value(ofCell: 0, in: app), "X")
    }

    @MainActor
    func testDraw() {
        let app = launchIntoGame()
        tapCells([0, 1, 2, 4, 3, 5, 7, 6, 8], in: app)

        XCTAssertEqual(status(in: app), "It's a draw!")
        for index in 0..<9 {
            XCTAssertFalse(value(ofCell: index, in: app).contains("winning"))
        }
    }

    @MainActor
    func testNewGameReturnsToColorSelectionWithPreviousColors() {
        let app = launch()
        openColorSelection(in: app)
        app.buttons["color_X_green"].tap()
        app.buttons["color_O_purple"].tap()
        startGame(in: app)
        tapCells([0, 3, 1, 4, 2], in: app)
        XCTAssertEqual(status(in: app), "Player X wins!")

        app.buttons["newGameButton"].tap()

        XCTAssertTrue(app.buttons["startGameButton"].waitForExistence(timeout: 5), "New Game must open color selection")
        XCTAssertTrue(app.buttons["color_X_green"].isSelected, "X's previous color must stay selected")
        XCTAssertTrue(app.buttons["color_O_purple"].isSelected, "O's previous color must stay selected")

        startGame(in: app)
        XCTAssertEqual(status(in: app), "Player X's turn")
        for index in 0..<9 {
            XCTAssertEqual(value(ofCell: index, in: app), "Empty")
            XCTAssertTrue(app.buttons["cell_\(index)"].isEnabled)
        }
    }

    @MainActor
    func testColorSelection() {
        let app = launch()
        openColorSelection(in: app)
        let green = app.buttons["color_X_green"]
        green.tap()
        XCTAssertTrue(green.isSelected)
        // O's default color (red) cannot be taken by X.
        XCTAssertFalse(app.buttons["color_X_red"].isEnabled)
    }

    // MARK: - Demo

    /// Plays a complete game slowly for screen recording.
    /// Runs only when the test runner gets `DEMO_MODE=1` (pass `TEST_RUNNER_DEMO_MODE=1` to xcodebuild).
    @MainActor
    func testDemoCompleteGame() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["DEMO_MODE"] == "1", "Demo runs only in DEMO_MODE")
        let delay: TimeInterval = 1.5
        let app = launch()
        Thread.sleep(forTimeInterval: delay * 2)

        // Home → Color Selection → close → Home again.
        openColorSelection(in: app)
        Thread.sleep(forTimeInterval: delay)
        app.buttons["closeColorSelectionButton"].tap()
        Thread.sleep(forTimeInterval: delay)
        openColorSelection(in: app)
        Thread.sleep(forTimeInterval: delay)

        for id in ["color_X_green", "color_O_purple"] {
            app.buttons[id].tap()
            Thread.sleep(forTimeInterval: delay)
        }
        startGame(in: app)
        Thread.sleep(forTimeInterval: delay)

        // X finally wins on the middle column (1, 4, 7) with the ninth move.
        for index in [4, 0, 2, 6, 3, 5, 1, 8, 7] {
            app.buttons["cell_\(index)"].tap()
            Thread.sleep(forTimeInterval: delay)
        }
        XCTAssertEqual(status(in: app), "Player X wins!")
        Thread.sleep(forTimeInterval: delay * 2)

        // New Game returns to color selection with the previous colors kept.
        app.buttons["newGameButton"].tap()
        Thread.sleep(forTimeInterval: delay * 2)
    }
}
