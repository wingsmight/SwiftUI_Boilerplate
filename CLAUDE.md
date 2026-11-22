# Claude Code Instructions

This repository contains a production SwiftUI iOS application.

## Mandatory Project Instructions

The primary AI development instructions are located in:

**[AGENTS.md](AGENTS.md)**

Read and follow `AGENTS.md` before making changes.

The relevant technical documentation is located in:

- [Architecture](docs/architecture.md)
- [SwiftUI Guidelines](docs/swiftui-guidelines.md)
- [Testing Guidelines](docs/testing.md)

Read the documentation relevant to the current task.

## Working Principles

- Inspect existing code before implementing changes.
- Follow the established Feature-First MVVM architecture.
- Prefer minimal, focused modifications.
- Do not introduce unnecessary abstractions.
- Preserve existing behavior unless explicitly instructed otherwise.
- Respect Swift Concurrency and SwiftUI state ownership.
- Verify changes when build or test tools are available.
- Do not perform unrelated refactoring.

## Architectural Decisions

When a requested change requires an important architectural decision:

1. Check the existing project patterns.
2. Consult the relevant documentation.
3. Choose the simplest maintainable approach.
4. Explain significant tradeoffs when necessary.

Do not interpret architectural guidelines as permission to restructure unrelated code.

## Completion

After implementation, briefly report the changes, validation performed, and any remaining issues.

`AGENTS.md` is the canonical source of general agent instructions. Do not duplicate or override its rules here unnecessarily.