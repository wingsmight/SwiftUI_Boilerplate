# Testing & Validation Guidelines

## 1. Testing Philosophy

Tests should protect meaningful behavior and enable safe changes.

Prioritize:

- Correctness.
- Determinism.
- Maintainability.
- Fast feedback.
- Clear failure diagnostics.
- Realistic coverage of important behavior.

Do not pursue test counts or coverage percentages at the expense of useful tests.

Use the project's established testing frameworks and conventions.

---

## 2. Test Organization

Prefer organizing tests by feature and responsibility.

Example:

```text
PersonaTests/
├── Features/
│   ├── Authentication/
│   │   └── LoginViewModelTests.swift
│   └── Profile/
│       └── ProfileViewModelTests.swift
├── Domain/
└── Core/
    ├── Networking/
    └── Repositories/
```

Test files should have clear names matching the behavior or type under test.

Test target names and locations must follow the actual Xcode project configuration.

Do not create a separate test target for every feature without a practical reason.

---

## 3. Testing Priorities

Prioritize tests for:

1. Business rules.
2. Important ViewModel state transitions.
3. Validation logic.
4. Error handling.
5. Data transformation.
6. Service and repository behavior.
7. Important integration boundaries.
8. Regressions for previously identified defects.

Purely presentational components may not require dedicated unit tests unless they contain meaningful behavior.

Use UI tests selectively for important end-to-end user flows.

---

## 4. ViewModel Testing

ViewModels should be testable without real network requests or persistent production state.

Use injected dependencies.

Example:

```swift
struct MockUserRepository: UserRepository {
    let result: Result<User, Error>

    func fetchUser() async throws -> User {
        try result.get()
    }
}
```

Test observable outcomes, such as:

- Data is loaded correctly.
- Loading state resets.
- Failures produce appropriate state.
- Successful actions update expected values.
- Validation prevents invalid submissions.
- Cancellation does not produce misleading errors.

Avoid testing private implementation details.

Example test using XCTest:

```swift
@MainActor
func testLoadProfileSuccess() async {
    let expectedUser = User(
        id: UUID(),
        name: "Taylor"
    )

    let repository = MockUserRepository(
        result: .success(expectedUser)
    )

    let viewModel = ProfileViewModel(
        repository: repository
    )

    await viewModel.loadProfile()

    XCTAssertEqual(viewModel.user?.id, expectedUser.id)
    XCTAssertFalse(viewModel.isLoading)
}
```

This example assumes the corresponding domain types and ViewModel contract defined in the architecture documentation.

Adapt examples to the actual project and test framework.

---

## 5. Test Doubles

Use mocks, stubs, or fakes when they make behavior deterministic.

Prefer small test doubles with focused behavior.

Avoid large mocking frameworks unless the project genuinely benefits from them.

Do not create production protocols solely to accommodate a single trivial test when a simpler testing seam exists.

Use controlled inputs and outputs.

Avoid hidden dependencies on global state.

---

## 6. Asynchronous Testing

For asynchronous code:

- Use async test functions where supported.
- Await completion directly.
- Control dependencies deterministically.
- Test cancellation when relevant.
- Avoid arbitrary sleeps.
- Avoid timing-dependent assertions when possible.

Do not use fixed delays to guess whether asynchronous work has completed.

Use expectations or other appropriate synchronization mechanisms when direct awaiting is insufficient.

Ensure tests respect actor isolation.

---

## 7. Networking Tests

Unit tests must not depend on live production API availability.

Prefer:

- Stubbed network responses.
- Mock transport implementations.
- Controlled HTTP errors.
- Controlled decoding failures.
- Deterministic fixtures.

Important scenarios may include:

- Successful response decoding.
- Invalid response handling.
- Authentication failures.
- Network failures.
- Cancellation.
- Request construction.
- Mapping between DTOs and domain models.

Use integration tests separately when real infrastructure interaction is required.

---

## 8. Persistence Tests

Tests involving persistence should avoid modifying production user data.

Prefer:

- In-memory storage.
- Temporary directories.
- Isolated test databases.
- Controlled fixtures.
- Explicit cleanup.

Test important persistence invariants and error scenarios.

Avoid depending on the execution order of tests.

---

## 9. Regression Testing

When fixing a significant bug:

1. Identify the behavior that failed.
2. Add a regression test when practical.
3. Verify the failure is represented by the test.
4. Implement the fix.
5. Verify the test passes.
6. Check related behavior for unintended changes.

Do not create brittle tests merely to satisfy a rule.

When a regression test is impractical, explain why.

---

## 10. Safe Refactoring

Refactoring should preserve observable behavior unless explicitly requested otherwise.

Before refactoring:

- Understand existing responsibilities.
- Identify callers and dependencies.
- Review relevant tests.
- Determine the intended architectural improvement.
- Keep the scope controlled.

During refactoring:

- Avoid unrelated formatting changes.
- Preserve APIs when possible.
- Update references consistently.
- Keep changes incremental.
- Avoid mixing major feature changes with structural cleanup.

After refactoring:

- Run relevant tests.
- Build affected targets where possible.
- Inspect compiler diagnostics.
- Review the final diff.

Do not claim behavioral equivalence without sufficient validation.

---

## 11. Build Validation

Use the repository's existing build configuration.

Before running build commands:

- Identify the correct workspace or project.
- Identify the intended scheme.
- Identify the available destination.
- Check for documented build scripts.
- Avoid modifying signing configuration unnecessarily.

An illustrative simulator build command:

```bash
xcodebuild \
  -project Persona.xcodeproj \
  -scheme Persona \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Replace example names with actual project values.

For projects using workspaces, use `-workspace` instead of `-project`.

Do not assume this command is appropriate for every repository.

---

## 12. Test Execution

Run the smallest relevant test scope first when practical.

For broader changes, expand validation to affected feature and integration tests.

An illustrative command:

```bash
xcodebuild \
  -project Persona.xcodeproj \
  -scheme Persona \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

The simulator name, scheme, and project must be verified before use.

Do not invent successful test results.

If the necessary simulator or Xcode environment is unavailable, report that limitation.

---

## 13. Static and Compiler Diagnostics

Pay attention to:

- Swift compiler warnings.
- Actor isolation diagnostics.
- Sendable violations.
- Availability warnings.
- Deprecated APIs.
- Unused code.
- Unreachable branches.
- Unsafe force operations.

Do not silence important diagnostics without understanding their cause.

Avoid unsafe concurrency annotations as a shortcut around correct isolation.

---

## 14. Diff Review

Before completing changes, review the final diff.

Check for:

- Unrelated modifications.
- Accidental formatting churn.
- Removed behavior.
- Duplicated logic.
- Unnecessary abstraction.
- Incorrect file placement.
- Missing test updates.
- Accidentally committed generated artifacts.
- Accidental secrets or credentials.

Do not modify generated project files or dependency lockfiles unless required by the task or tooling.

Do not revert unrelated user changes.

---

## 15. Scope Control

For small tasks:

- Make focused edits.
- Run targeted checks.
- Avoid architectural migrations.

For larger tasks:

- Identify affected layers.
- Consider compatibility.
- Update tests.
- Verify integration points.
- Document meaningful architectural changes.

The amount of validation should be proportional to the risk and scope of the change.

---

## 16. AI Agent Validation Report

After implementing code, report:

### Changes

Briefly describe the actual modifications.

### Files

Identify the main files created or modified.

### Validation

State which checks were actually performed.

Examples:

- Build succeeded.
- Relevant unit tests passed.
- Static review completed.
- Build not executed because Xcode was unavailable.

### Limitations

Report unresolved warnings, untested scenarios, or remaining risks.

Do not claim success based solely on code inspection.

---

## 17. Final Checklist

Before declaring a task complete:

- Does the code satisfy the requested behavior?
- Are responsibilities placed correctly?
- Are dependencies explicit?
- Is state ownership correct?
- Are important errors handled?
- Are relevant tests present or updated?
- Was available validation performed?
- Were unrelated changes avoided?
- Does the diff contain only intentional modifications?
- Are limitations reported accurately?

**Final principle: Tests and validation should make meaningful changes safer, not introduce unnecessary maintenance burden.**