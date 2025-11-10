# Repository Guidelines

## Project Structure & Module Organization
This Swift Package is defined by `Package.swift` and resolves dependencies via `Package.resolved`. Core analytics logic (including crash-reporting implementations) lives under `Sources/AnalyticsManager` with its public contracts now provided by the external [`SwiftAnalyticsKitInterface`](https://github.com/fbandemer/SwiftAnalyticsKitInterface) package. Crash-specific types and defaults sit inside `Sources/AnalyticsManager/CrashManager`. Provider-specific glue stays in subfolders such as `Superwall`, `RevenueCat`, `CrashManager`, or `PostHogFeatureFlag`, while SwiftUI helpers sit inside `Sources/AnalyticsManager/Views`. Tests reside in `Tests/AnalyticsTests`, mirroring the public API surface. Keep new integrations isolated in their own subfolder to preserve a clear separation between service adapters, shared models, and UI utilities.

## Build, Test, and Development Commands
`swift build` compiles the package and verifies dependency compatibility. `swift test` runs the `AnalyticsTests` XCTest target; add `--enable-code-coverage` when validating coverage before release. Use `swift package generate-documentation` if you need DocC output while reviewing API additions.

## Coding Style & Naming Conventions
Follow Swift API Design Guidelines with 4-space indentation and trailing commas for multiline collections. Types and protocols use PascalCase (`SuperwallService`), methods and properties use camelCase (`trackEvent`). Keep analytics event identifiers descriptive and namespaced per the `{category}:{object}:{verb}` convention enforced by `AnalyticsVerb`. Prefer extensions for provider-specific functionality to keep the default `AnalyticsClient` focused on façade responsibilities.

## Testing Guidelines
Add new XCTest cases in `Tests/AnalyticsTests/AnalyticsTests.swift` or a sibling file that mirrors the module path. Name tests using the `test<Behavior>_<Condition>` pattern and include both provider stubs and façade-level expectations. Prefer the `AnalyticsManagerTesting` module for mocks (`MockAnalyticsManager`, `AnalyticsTestCategory`) instead of rolling ad-hoc doubles. Run `swift test` locally before pushing, and ensure any asynchronous behavior is covered with `XCTExpectations` to guard against regressions.

## Platform Notes
Superwall integrations compile only on iOS. macOS builds set `superwallID` to `nil` and rely on the SwiftUI buttons to execute actions directly, so guard any new Superwall code with `#if canImport(SuperwallKit)` to keep cross-platform builds green.


## Commit & Pull Request Guidelines
Recent history favors short, imperative subjects (e.g., `Update Analytics.swift`). Keep commits focused, referencing modules touched. Pull requests should describe the problem, summarize the solution, link related tasks, and note testing performed. Include screenshots or console logs only when UI or runtime behavior changes. Tag reviewers responsible for the affected provider integrations.

## Configuration & Secrets
Never commit real API keys or Sentry DSNs. Instead, update example placeholders in README snippets and document required environment keys in your PR description. When adding a new service, ensure fail-safe defaults so the package remains buildable without secrets.
