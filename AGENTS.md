# AI Agent Instructions

This repository contains a production iOS application built with Swift and SwiftUI.

These instructions apply to all AI-assisted development in this repository.

## 1. Project Architecture

The project follows **Feature-First MVVM** with explicit separation between presentation, domain, and infrastructure responsibilities where appropriate.

The architecture prioritizes:

- Correctness and maintainability.
- Feature ownership and modularity.
- Clear dependency boundaries.
- Explicit state ownership.
- Testability.
- Minimal unnecessary abstraction.
- Modern, idiomatic Swift.

Do not introduce architectural complexity without a concrete reason.

## 2. Required Documentation

Read the relevant documentation before implementing changes:

- [`docs/architecture.md`](docs/architecture.md) — project structure, feature boundaries, MVVM, dependency injection, services, and repositories.
- [`docs/swiftui-guidelines.md`](docs/swiftui-guidelines.md) — SwiftUI, state management, navigation, Observation, Swift Concurrency, and performance.
- [`docs/testing.md`](docs/testing.md) — testing expectations, validation, and safe refactoring.

For architectural or structural changes, read `docs/architecture.md`.

For SwiftUI or concurrency changes, read `docs/swiftui-guidelines.md`.

For changes affecting behavior, bug fixes, or refactoring, read `docs/testing.md`.

Do not assume that every document must be read in full for every trivial change. Read the relevant sections based on the task.

## 3. Source of Truth

Before modifying code:

1. Inspect the existing implementation.
2. Identify the feature responsible for the behavior.
3. Understand the relevant dependencies and state ownership.
4. Check existing conventions and patterns.
5. Determine the smallest correct change.

The actual codebase is the source of truth for its current implementation.

These guidelines describe the preferred direction for new code and intentional refactoring. They do not authorize unrelated restructuring.

If documentation conflicts with the actual project configuration, verify the configuration before proceeding.

## 4. Architectural Rules

**MUST:**

- Organize new functionality by feature.
- Keep presentation and infrastructure responsibilities separate.
- Use explicit ownership for mutable state.
- Respect existing feature boundaries.
- Keep dependencies understandable and testable.
- Follow the project's deployment target and Swift language mode.
- Preserve existing behavior unless changes are requested.
- Keep changes focused on the task.

**SHOULD:**

- Prefer constructor injection for required dependencies.
- Keep feature-specific code inside its owning feature.
- Keep SwiftUI Views focused on UI composition and interaction.
- Use ViewModels for meaningful presentation logic and workflows.
- Prefer modern Swift Concurrency when compatible with the project.
- Prefer composition over unnecessary abstraction.

**MUST NOT:**

- Introduce global mutable singletons as a default dependency strategy.
- Put substantial networking, persistence, or business logic inside SwiftUI Views.
- Create ViewModels for purely presentational components without need.
- Introduce protocols, repositories, or use cases mechanically.
- Couple unrelated features through their internal implementation details.
- Perform large unrelated refactors.
- Create directory hierarchies without organizational benefit.
- Hide compiler or concurrency issues using unsafe workarounds.

## 5. File Placement

Determine ownership before creating files.

- Feature-specific code → `Features/<Feature>/`
- Shared business concepts and contracts → `Domain/`, when needed
- Shared infrastructure → `Core/`
- Reusable presentation components → `Shared/UI/`
- Application initialization and composition → `App/`
- Tests → the appropriate test target, organized by feature or responsibility

Do not move code into shared directories merely because it might be reused in the future.

Small features may keep their files directly in the feature directory. Add subdirectories when they improve navigation.

## 6. Swift and SwiftUI

- Prefer value types where appropriate.
- Use access control deliberately.
- Prefer type-safe APIs.
- Avoid force unwrapping when values can be handled safely.
- Use Observation APIs when supported and appropriate.
- Respect actor isolation and Sendable requirements.
- Keep expensive work off the main actor.
- Handle cancellation and errors deliberately.
- Avoid unnecessary Tasks, state duplication, and abstractions.

See `docs/swiftui-guidelines.md` for detailed rules.

## 7. Change Management

Make the smallest coherent change that solves the requested problem.

Do not:

- Reformat unrelated files.
- Rename unrelated symbols.
- Reorganize entire features during focused bug fixes.
- Change public interfaces unnecessarily.
- Add dependencies without justification.
- Replace working architectural patterns solely for consistency with a newer preference.

When a broader refactor is necessary, explain the rationale and expected impact.

## 8. Validation

After making changes, perform appropriate validation when the environment allows it.

Depending on the task:

- Build the affected target.
- Run relevant tests.
- Check compiler diagnostics.
- Review concurrency warnings.
- Inspect the final diff.
- Verify file and target membership.

Never claim that code builds or tests pass unless verification was actually performed.

If validation cannot be performed, state what was not verified.

## 9. Decision Priorities

When multiple implementations are reasonable, prioritize:

1. Correctness.
2. Existing project conventions.
3. Clear ownership and responsibilities.
4. Simplicity.
5. Testability.
6. Maintainability.
7. Performance where relevant.
8. Minimal architectural overhead.

Do not prioritize theoretical architectural purity over a practical, maintainable solution.

## 10. Final Response Requirements

After implementing changes, summarize:

- What changed.
- Why the approach was chosen, if non-obvious.
- Files added or modified.
- Tests or build checks performed.
- Remaining limitations or risks.

Keep responses concise and factual.

**Core principle: Build the simplest maintainable solution that respects the project's architecture and existing behavior.**