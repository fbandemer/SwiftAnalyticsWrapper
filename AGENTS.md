# Repository Guidelines

## Project Structure & Module Organization
This Swift Package is defined by `Package.swift` and resolves dependencies via `Package.resolved`. Core analytics logic lives under `Sources/Analytics`, with provider-specific glue in subfolders like `Superwall` and `RevenueCat`, shared verbs in `Analytics/AnalyticVerbs.swift`, and SwiftUI helpers inside `Views/`. Tests reside in `Tests/AnalyticsTests`, mirroring the public API surface. Keep new integrations isolated in their own subfolder to preserve a clear separation between service adapters, shared models, and UI utilities.

## Build, Test, and Development Commands
`swift build` compiles the package and verifies dependency compatibility. `swift test` runs the `AnalyticsTests` XCTest target; add `--enable-code-coverage` when validating coverage before release. Use `swift package generate-documentation` if you need DocC output while reviewing API additions.

## Coding Style & Naming Conventions
Follow Swift API Design Guidelines with 4-space indentation and trailing commas for multiline collections. Types and protocols use PascalCase (`SuperwallService`), methods and properties use camelCase (`trackEvent`). Keep analytics event identifiers descriptive and namespaced (`billing_invoicePaid`). Prefer extensions for provider-specific functionality to keep `Analytics.swift` focused on façade responsibilities.

## Testing Guidelines
Add new XCTest cases in `Tests/AnalyticsTests/AnalyticsTests.swift` or a sibling file that mirrors the module path. Name tests using the `test<Behavior>_<Condition>` pattern and include both provider stubs and façade-level expectations. Run `swift test` locally before pushing, and ensure any asynchronous behavior is covered with `XCTExpectations` to guard against regressions.

## Commit & Pull Request Guidelines
Recent history favors short, imperative subjects (e.g., `Update Analytics.swift`). Keep commits focused, referencing modules touched. Pull requests should describe the problem, summarize the solution, link related tasks, and note testing performed. Include screenshots or console logs only when UI or runtime behavior changes. Tag reviewers responsible for the affected provider integrations.

## Configuration & Secrets
Never commit real API keys or Sentry DSNs. Instead, update example placeholders in README snippets and document required environment keys in your PR description. When adding a new service, ensure fail-safe defaults so the package remains buildable without secrets.
