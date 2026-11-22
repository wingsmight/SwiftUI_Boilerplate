# iOS Architecture Guidelines

## 1. Architectural Philosophy

The application follows **Feature-First MVVM**.

Feature ownership is the primary organizational principle. Technical layers are used within features only when they improve clarity.

The architecture should support:

- Independent development of features.
- Clear ownership of code and state.
- Limited coupling.
- Testable business and presentation logic.
- Reusable infrastructure.
- Incremental evolution.
- Straightforward code navigation.

**Avoid architecture for architecture's sake.**

Do not introduce additional layers merely to satisfy an architectural diagram.

---

## 2. Recommended Project Structure

```text
Project/
├── App/
│   ├── ProjectApp.swift
│   ├── AppContainer.swift
│   ├── AppRouter.swift
│   └── AppConfiguration.swift
│
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   ├── Components/
│   │   └── Services/
│   │
│   ├── Profile/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   └── Components/
│   │
│   └── Editor/
│       ├── Views/
│       ├── ViewModels/
│       ├── Models/
│       ├── Components/
│       └── Services/
│
├── Domain/
│   ├── Models/
│   └── Contracts/
│
├── Core/
│   ├── Networking/
│   ├── Storage/
│   ├── Services/
│   └── Repositories/
│
├── Shared/
│   ├── UI/
│   │   ├── Components/
│   │   ├── Modifiers/
│   │   └── Styles/
│   ├── Extensions/
│   └── Utilities/
│
└── Resources/
    ├── Assets.xcassets
    └── Localizable.xcstrings
```

This is a reference structure.

Not every feature requires every directory.

Do not create empty directories or placeholder types merely to match the example.

Test targets are typically organized separately from application source code.

---

## 3. Directory Responsibilities

### App

Contains application-level responsibilities:

- Application entry point.
- Application lifecycle integration.
- Root dependency composition.
- Top-level routing.
- Global application configuration.

`App/` should not become a storage location for unrelated business logic.

### Features

Contains user-facing functionality.

Each feature should own its presentation code and feature-specific behavior.

### Domain

Contains shared business concepts and stable contracts when justified.

Examples:

- User identity.
- Subscription entitlement.
- Shared business rules.
- Repository contracts shared across features.

Domain models should not depend on SwiftUI, networking implementations, or persistence frameworks.

`Domain/` is optional. Do not introduce it when feature-local models are sufficient.

### Core

Contains shared technical infrastructure.

Examples:

- HTTP clients.
- Authentication infrastructure.
- Keychain access.
- Database adapters.
- Shared repository implementations.
- Common infrastructure services.

Core should not become a collection of all code that does not fit elsewhere.

### Shared

Contains reusable UI and lightweight utilities.

Shared UI should not depend on the internal ViewModels of individual features.

---

## 4. Feature Organization

A feature owns the code implementing a cohesive product capability.

Example:

```text
Features/Profile/
├── Views/
│   ├── ProfileView.swift
│   └── EditProfileView.swift
├── ViewModels/
│   ├── ProfileViewModel.swift
│   └── EditProfileViewModel.swift
├── Components/
│   ├── ProfileHeader.swift
│   └── ProfileAvatar.swift
├── Models/
│   └── ProfileForm.swift
└── Services/
    └── ProfileImageProcessor.swift
```

### Feature rules

1. Prefer feature-local ownership.
2. Keep implementation details encapsulated.
3. Avoid importing another feature's internal presentation logic.
4. Communicate across features through deliberate interfaces.
5. Share code only when there is a meaningful shared responsibility.
6. Avoid circular dependencies.

### Small features

For a feature with only a few files:

```text
Features/Settings/
├── SettingsView.swift
└── SettingsViewModel.swift
```

This is preferable to unnecessary directory nesting.

Introduce `Views/`, `ViewModels/`, and `Components/` as complexity grows.

### Feature extraction

Do not move code to `Shared/` just because another feature might use it eventually.

Extract shared behavior when actual reuse or a clear shared ownership boundary exists.

---

## 5. MVVM Responsibilities

### View

A View is responsible for:

- Declaring UI.
- Rendering state.
- Handling lightweight local interaction.
- Binding user input.
- Forwarding meaningful user actions.
- Defining layout, transitions, and animations.

Views must not contain substantial business workflows, persistence implementations, or direct HTTP request logic.

Small UI-only components do not need ViewModels.

A View may own temporary presentation state such as:

- Sheet visibility.
- Local focus.
- Animation progress.
- Temporary selection.

### ViewModel

A ViewModel coordinates presentation state and screen behavior.

Responsibilities:

- Expose observable state.
- Handle screen actions.
- Coordinate asynchronous work.
- Invoke services or repositories.
- Convert results to presentation state.
- Handle loading, failure, and empty states.
- Perform presentation-level validation.

A ViewModel should not:

- Perform layout.
- Own raw HTTP implementation details.
- Directly access unrelated feature ViewModels.
- Perform expensive image or video processing on the main actor.
- Become a global application manager.

### Model

Models should reflect their actual purpose.

Distinguish between:

- Domain models.
- Network DTOs.
- Persistence models.
- Presentation models.

Avoid forcing one model to represent every layer when the representations have different requirements.

---

## 6. Domain Models and DTOs

Example domain model:

```swift
struct User: Identifiable, Sendable {
    let id: UUID
    let name: String
}
```

Example network DTO:

```swift
struct UserDTO: Decodable {
    let id: String
    let displayName: String
}
```

Example presentation model:

```swift
struct ProfileForm {
    var displayName = ""
    var biography = ""
}
```

DTOs should generally remain close to the transport boundary.

Introduce mapping when needed to separate business semantics from API representation.

Do not create mapping layers that provide no meaningful value.

---

## 7. Dependency Direction

Preferred conceptual architecture:

```text
Presentation
    |
    v
Domain contracts / service interfaces
    ^
    |
Infrastructure implementations
    |
    v
Networking / Persistence
```

Typical execution flow:

```text
View
  |
  v
ViewModel
  |
  v
Repository or Service Contract
  |
  v
Concrete Implementation
  |
  v
API Client / Storage
```

The implementation dependency points toward the contract, even though runtime execution flows from the ViewModel toward the concrete service.

### Rules

- Presentation should not depend unnecessarily on concrete infrastructure.
- Domain models should remain independent from UI frameworks.
- Shared infrastructure should not depend on feature-specific Views.
- Features should not manipulate the internal state of other features.
- Avoid cyclic dependencies.

Dependency rules become especially important when features are extracted into separate modules.

---

## 8. Dependency Injection

Prefer explicit constructor injection for required dependencies.

Example contract:

```swift
protocol UserRepository: Sendable {
    func fetchUser() async throws -> User
}
```

Example ViewModel:

```swift
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var user: User?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    @ObservationIgnored
    private let repository: any UserRepository

    init(repository: any UserRepository) {
        self.repository = repository
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            user = try await repository.fetchUser()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Unable to load profile."
        }
    }
}
```

This example assumes an iOS 17+ deployment target and a compatible Swift concurrency configuration.

### Composition root

Shared dependencies should generally be assembled in `App/` or appropriate feature composition boundaries.

Example:

```swift
@MainActor
final class AppContainer {
    let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(repository: userRepository)
    }
}
```

### Dependency injection rules

- Prefer explicit dependencies.
- Avoid global mutable singleton services.
- Do not instantiate production networking dependencies inside ViewModels.
- Use SwiftUI Environment when environment-scoped injection is appropriate.
- Do not pass the entire AppContainer everywhere as a service locator.
- Avoid introducing third-party DI frameworks without need.

---

## 9. Services and Repositories

Services and repositories have different typical responsibilities, but their boundaries are not universal.

### Service

A service performs a capability or workflow.

Examples:

- Image processing.
- Authentication operations.
- Exporting media.
- Subscription validation.

### Repository

A repository abstracts access to data or business entities.

Examples:

- Fetching a user.
- Saving profile settings.
- Retrieving cached projects.
- Synchronizing local and remote content.

### Rules

- Do not introduce a repository for every API endpoint.
- Do not introduce a protocol for every service automatically.
- Keep implementations cohesive.
- Prefer feature-local services when they are not shared.
- Put shared infrastructure implementations in Core when appropriate.
- Place contracts near the consumers or domain that own them.

Avoid giant generic managers combining unrelated responsibilities.

---

## 10. Navigation Architecture

Prefer SwiftUI navigation APIs for ordinary navigation.

Use a router or coordinator when the flow requires it.

Examples of appropriate router responsibilities:

- Authentication-to-main-app transitions.
- Deep-link navigation.
- Cross-feature flows.
- Complex navigation stack restoration.
- Centralized application-level routing.

Example:

```swift
enum AppRoute: Hashable {
    case profile(userID: UUID)
    case settings
    case editor
}
```

### Rules

- Keep local navigation local.
- Do not create a global router for every button.
- Avoid passing entire ViewModels as navigation arguments.
- Prefer stable IDs or lightweight input models.
- Keep navigation ownership explicit.
- Avoid coupling feature internals through navigation.

The navigation pattern should match the complexity of the application.

---

## 11. Shared State

Shared mutable state requires deliberate ownership.

Examples:

- Current authenticated session.
- Subscription entitlement state.
- Shared user preferences.

Prefer a clearly owned application-level service or observable model when state genuinely spans features.

Avoid:

- Duplicated sources of truth.
- Global ViewModels shared between unrelated screens.
- Feature-to-feature mutation of internal state.
- Uncontrolled mutable singletons.

A shared service should represent a clear capability or shared state boundary.

Do not move screen-specific state into global storage.

---

## 12. File Naming

Name files after their primary responsibility.

Preferred examples:

```text
ProfileView.swift
ProfileViewModel.swift
ProfileHeader.swift
ProfileForm.swift
UserRepository.swift
RemoteUserRepository.swift
APIClient.swift
AppRouter.swift
```

Avoid ambiguous names when a more specific name is possible:

```text
Manager.swift
Helper.swift
Common.swift
Utils.swift
DataHandler.swift
```

Guidelines:

- Prefer one primary type per file.
- Keep small private helper types nearby.
- Use descriptive names.
- Keep cohesive code together.
- Split files when responsibilities meaningfully diverge.
- Do not impose arbitrary file-length limits.

---

## 13. Access Control

Use the narrowest reasonable access level.

- `private` for implementation details.
- `fileprivate` when file-specific sharing is required.
- `internal` for module-level communication.
- `public` for intentional module APIs.

Do not expose implementation details merely to avoid designing appropriate boundaries.

When extracting Swift Packages, explicitly review the public API surface.

---

## 14. Protocol Design

A protocol should define a meaningful capability.

Introduce protocols when:

- A stable abstraction boundary is required.
- Multiple implementations exist or are expected for concrete reasons.
- Testing benefits from substituting a dependency.
- Module boundaries require separating interface and implementation.

Avoid:

- Protocols that merely mirror every method of one concrete type without purpose.
- Overly generic interfaces.
- Large interfaces serving unrelated consumers.
- Protocol hierarchies without meaningful behavior.

Prefer small, cohesive contracts.

---

## 15. Error Ownership

Errors should be translated at appropriate boundaries.

For example:

- Networking layer understands HTTP and transport failures.
- Repository understands data access failures.
- ViewModel understands presentation state and user-facing recovery.
- View renders relevant user-facing feedback.

Do not expose raw technical failure descriptions directly to users.

Avoid silently ignoring unexpected failures.

---

## 16. Modularization

A feature directory is not automatically a separate Swift module.

Consider extraction into a Swift Package or framework when:

- The boundary is stable.
- Independent testing or compilation has value.
- Ownership is clear.
- Dependencies are limited.
- Multiple consumers exist.
- Build performance or team workflows justify it.

Do not extract packages purely because the project has many files.

Maintain acyclic dependencies between modules.

---

## 17. Refactoring Policy

Refactor incrementally.

Before moving files or changing boundaries:

1. Understand existing behavior.
2. Identify real architectural problems.
3. Evaluate the scope of affected callers.
4. Preserve public interfaces when practical.
5. Update relevant tests.
6. Verify project and target configuration.
7. Avoid unrelated restructuring.

Do not treat architectural guidelines as an instruction to rewrite all legacy code.

---

## 18. Architecture Decision Checklist

Before creating a new type or directory, ask:

1. Which feature owns this behavior?
2. Is the responsibility presentation, domain, or infrastructure?
3. Is it genuinely shared?
4. Does it need observable state?
5. Does it require a ViewModel?
6. Does it need a service?
7. Would a repository provide a meaningful abstraction?
8. Does a protocol establish a useful boundary?
9. Is this the simplest solution?
10. Can it be tested without excessive setup?

If the proposed abstraction does not improve clarity, ownership, testability, or extensibility, reconsider it.

**Final principle: Prefer cohesive features, explicit ownership, and minimal useful abstractions over mechanically layered architecture.**