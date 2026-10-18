# AGENTS.md

## Project Overview
This is a simple Tic Tac Toe game for iOS.

## Tech Stack
- Minimum OS Version: iOS 26
- Language : Swift
- UI : SwiftUI
- Dependencies : SPM only
- Architecture : MVVM + Redux

## Development Environment
- macos
- xCode
- Scheme: TestTictactoe

## Commands
- Build:
  `xcodebuild -project TestTictactoe.xcodeproj -scheme TestTictactoe -destination 'platform=iOS Simulator,name=<iPhone 17>' build`
- Test:
  `xcodebuild -project TestTictactoe.xcodeproj -scheme TestTictactoe -destination 'platform=iOS Simulator,name=<iPhone 17>' test`
- List available simulators: `xcrun simctl list devices available`
- Lint (if SwiftLint is installed): `swiftlint`

## Project Structure
- `TestTictactoe/App/` - app entry point
- `TestTictactoe/Models/` - data models
- `TestTictactoe/Services/` - networking, persistence
- `TestTictactoe/Feature/` - feature modules (one folder per feature)
- `doc/tasks/` - task specifications
- `TestTictactoeTests/` - unit tests

## Coding conventions
- Write all code, comments and documentation in English
- Follow the Swift API Design Guidelines
- Prefer `struct` over `class` unless reference semantics are needed.
- Use SwiftConcurrency first.
- Do not force unwrap (`!`). For test, please mark it as failed with comments when failed to unwrapping.
- Tasks are provided as files in `docs/tasks/`
- Use open source only for definitely needed. Please do not use for URLSession things.

## Do not
- Do not edit `project.pbxproj` by hand unless explicitly asked.
- Do not change signing, team, bundle identifier, or entitlements.
- Do not add Swift package without asking first.
- Do not commit secrets, API keys or `xcuserdata/`.
