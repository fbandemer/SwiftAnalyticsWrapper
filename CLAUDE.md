# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands
- Build package: `swift build`
- Run all tests: `swift test`
- Run specific test: `swift test --filter AnalyticsTests/testExample`
- Format code: `swiftformat .` (if SwiftFormat is installed)
- Documentation: `swift package generate-documentation` (requires Swift-DocC plugin)

## Code Style Guidelines
- Use Swift 5.10+ features when appropriate
- Import statements: Group by framework, sorted alphabetically
- Formatting: 4 space indentation, opening braces on same line
- Types: Use Swift strong typing, prefer optional unwrapping with `if let`/`guard let`
- Naming: Follow Swift API Design Guidelines - descriptive, camelCase for variables/functions
- Documentation: Add comments for public APIs, explain complex logic
- Error Handling: Use try/catch with descriptive error messages, avoid force unwrapping
- Privacy: Mark properties as private/internal unless needed publicly
- Prefer composition over inheritance
- Target iOS 17+ only