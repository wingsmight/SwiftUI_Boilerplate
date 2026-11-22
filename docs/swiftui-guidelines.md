# SwiftUI Development Guidelines

## 1. General Principles

Write idiomatic, declarative SwiftUI.

Prioritize:

- Predictable state ownership.
- Small, cohesive Views.
- Correct concurrency.
- Readable data flow.
- Stable identity.
- Efficient rendering.
- Simple composition.
- Native platform behavior.

Follow the project's actual minimum deployment target and Swift language mode.

Do not adopt newer APIs that are unavailable to supported operating system versions without appropriate availability handling.

---

## 2. View Responsibilities

SwiftUI Views should focus on describing UI.

A View may:

- Render state.
- Handle local interaction.
- Declare layout and animations.
- Pass actions to a ViewModel or parent.
- Own temporary UI state.
- Compose reusable components.

Avoid:

- Substantial business logic inside `body`.
- Direct database access.
- Direct HTTP request implementation.
- Large asynchronous workflows inside button closures.
- Expensive computation during rendering.
- Direct manipulation of unrelated feature state.

A small View does not automatically require a ViewModel.

---

## 3. State Management

Use appropriate state-management mechanisms based on ownership.

| API | Usage |
|---|---|
| `@State` | Local View-owned state |
| `@Binding` | Two-way access to externally owned state |
| `@Environment` | Environment-provided values and dependencies |
| `@Observable` | Observable reference models |
| `@Bindable` | Binding to mutable properties of observable models |
| `@StateObject` | Legacy ObservableObject ownership |
| `@ObservedObject` | Observing a legacy externally owned object |

For iOS 17+, prefer Observation when appropriate.

Do not migrate existing code solely to replace `ObservableObject` if there is no practical benefit or the project has compatibility constraints.

### Single source of truth

Each mutable state value should have clear ownership.

Avoid maintaining multiple synchronized copies of the same information.

Prefer computed properties for cheap derived values.

---

## 4. Observable ViewModels

For iOS 17+:

```swift
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var username = ""
    private(set) var isLoading = false

    @ObservationIgnored
    private let service: any ProfileService

    init(service: any ProfileService) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            username = try await service.fetchUsername()
        } catch is CancellationError {
            return
        } catch {
            // Update the appropriate error state.
        }
    }
}
```

The referenced `ProfileService` is an illustrative dependency contract.

### Rules

- Keep UI-observed mutable ViewModel state main-actor isolated.
- Expose mutable properties only as widely as needed.
- Prefer explicit actions over arbitrary external state mutation.
- Keep dependencies private.
- Mark implementation-only stored dependencies with `@ObservationIgnored` when appropriate.
- Avoid mixing unrelated workflows inside one ViewModel.

Do not use `@Observable` on every model indiscriminately.

Value types remain preferable for many immutable or simple data models.

---

## 5. ViewModel Ownership

A ViewModel's lifecycle must be intentional.

If a View owns an observable ViewModel, `@State` is generally appropriate with Observation.

Example:

```swift
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    init(service: any ProfileService) {
        _viewModel = State(
            initialValue: ProfileViewModel(service: service)
        )
    }

    var body: some View {
        VStack {
            Text(viewModel.username)
        }
        .task {
            await viewModel.load()
        }
    }
}
```

The View initializer and dependency lifetime must be designed so that changes to input dependencies do not accidentally leave an existing `@State` instance using obsolete dependencies.

When a parent owns the ViewModel, pass that existing instance to the child instead of creating another owner.

Avoid creating observable ViewModels repeatedly during normal View rendering.

---

## 6. Local State vs ViewModel State

Keep lightweight presentation concerns inside Views when appropriate.

Examples:

```swift
@State private var isSheetPresented = false
@State private var selectedTab = 0
@FocusState private var isFocused: Bool
```

Use ViewModels for:

- Data loading.
- Validation.
- Submission workflows.
- Long-lived screen behavior.
- Business-dependent presentation state.
- Error and loading coordination.

Do not move every boolean into a ViewModel merely because the screen uses MVVM.

---

## 7. Bindings

Use `@Binding` when a child needs to read and modify state owned by its parent.

Prefer a value and action closure when the child only needs to communicate an event.

Avoid exposing entire ViewModels to small reusable components when a few properties and closures are sufficient.

For `@Observable` models, use `@Bindable` when bindings to observable properties are needed.

Avoid creating unnecessary two-way bindings for read-only values.

---

## 8. Swift Concurrency

Prefer:

- `async/await`
- Structured concurrency
- Actors for shared mutable state when needed
- Explicit actor isolation
- Task cancellation
- Typed error handling when appropriate

Avoid callback-based concurrency for new code when modern concurrency is available and interoperable.

### Main actor

ViewModels coordinating UI state should generally be `@MainActor`.

Do not run CPU-intensive processing on the main actor.

Examples of operations that may require separate execution:

- Image processing.
- Video transcoding.
- Complex filtering.
- Large data transformations.
- Media rendering.
- Expensive file operations.

Moving work into an async function does not automatically move it off the main actor.

Choose a concurrency boundary that actually isolates heavy work.

### Tasks

Prefer structured concurrency when possible.

Avoid unnecessary:

```swift
Task {
    await operation()
}
```

when already operating in an appropriate asynchronous context.

Do not introduce detached tasks without a concrete isolation or lifetime requirement.

### Cancellation

Respect cancellation for operations tied to a screen or workflow.

Do not convert expected cancellation into user-visible failures.

Use cancellation-aware APIs and propagate cancellation where appropriate.

---

## 9. SwiftUI Lifecycle Tasks

Use `.task` for asynchronous work associated with a View's lifecycle.

Example:

```swift
.task {
    await viewModel.load()
}
```

Use `.task(id:)` when work should restart in response to a meaningful input change.

Do not automatically start data loading in every ViewModel initializer.

Avoid unintended duplicate requests caused by unstable View identity or repeated task creation.

When a task must outlive a View, assign its ownership to the appropriate service or application workflow.

---

## 10. Error and Loading States

Represent UI states intentionally.

For simple screens, separate properties may be sufficient:

```swift
private(set) var isLoading = false
private(set) var errorMessage: String?
```

For mutually exclusive complex states, an enum may improve clarity:

```swift
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}
```

Do not introduce generic state machines for trivial screens.

Avoid impossible combinations such as simultaneous success and error states when a single enum would prevent them.

Do not display raw localized descriptions from arbitrary infrastructure errors directly to users.

---

## 11. Navigation

Prefer native SwiftUI navigation APIs.

Use:

- `NavigationStack`
- `navigationDestination`
- `sheet`
- `fullScreenCover`

when appropriate.

Navigation ownership should be explicit.

Simple navigation may remain inside a feature.

Use an application router or coordinator for genuinely complex cross-feature navigation.

Avoid coupling unrelated ViewModels through navigation state.

---

## 12. View Composition

Extract subviews when doing so improves readability or reuse.

Good reasons:

- A section has meaningful independent responsibility.
- The parent View becomes difficult to understand.
- The component is reused.
- A complex UI section benefits from local encapsulation.

Avoid extracting every individual modifier chain into a separate type.

Do not create excessive abstraction layers around straightforward SwiftUI declarations.

Prefer descriptive component names.

---

## 13. Performance

Keep `body` computations inexpensive.

### Avoid

- Expensive synchronous transformations in `body`.
- Repeated decoding during rendering.
- Unnecessary collection allocations.
- Unstable identifiers.
- Broad observable dependencies.
- Redundant state updates.
- Long-running operations on the main actor.

### Prefer

- Stable identity in collections.
- Lazy containers when suitable.
- Cached or precomputed expensive results.
- Narrow state ownership.
- Efficient data transformations.
- Profiling before speculative optimization.

Do not add caching without a clear lifetime and invalidation strategy.

---

## 14. Lists and Identity

Use stable identifiers for dynamic collections.

Prefer model identity:

```swift
ForEach(users) { user in
    UserRow(user: user)
}
```

Avoid using array indices as identity when elements may be inserted, removed, or reordered.

Avoid generating new UUIDs during rendering to identify existing elements.

Identity stability affects state preservation, animations, and rendering correctness.

---

## 15. Animations

Keep animation ownership close to the relevant UI interaction.

Use explicit animation when it makes the behavior easier to understand.

Avoid broad animation modifiers that unintentionally animate unrelated changes.

Do not introduce expensive animations that interfere with responsiveness.

Respect accessibility settings such as reduced motion when appropriate.

---

## 16. Reusable Components

Shared components should be configurable through focused APIs.

Prefer:

- Plain values.
- Bindings where necessary.
- Action closures.
- Specific configuration types when complexity warrants them.

Avoid requiring a reusable button or card to know about a feature's ViewModel.

Do not create components with excessive unrelated configuration flags.

---

## 17. Accessibility and Localization

When implementing UI:

- Use localized strings for user-facing text.
- Provide appropriate accessibility labels.
- Preserve Dynamic Type behavior.
- Avoid hardcoded dimensions that break larger text sizes.
- Respect system appearance and accessibility preferences.
- Avoid encoding meaning exclusively through color.
- Ensure controls have appropriate interaction targets.

Follow existing project localization and design-system conventions.

---

## 18. Swift Style

### Naming

- UpperCamelCase for types.
- lowerCamelCase for properties and methods.
- Clear, descriptive names.
- Avoid unnecessary abbreviations.

### Type design

- Prefer `struct` for value semantics.
- Use `class` for reference identity or shared mutable behavior where justified.
- Use `actor` when actor isolation is needed.
- Avoid unnecessary inheritance.
- Prefer immutability when practical.

### Error handling

- Avoid force unwrapping unless a strong invariant is documented.
- Avoid silently discarded errors.
- Handle expected failures explicitly.
- Prefer clear error propagation over excessive wrappers.

### Access control

Use the narrowest practical visibility.

---

## 19. Legacy Compatibility

Respect the existing deployment target, language mode, and architectural conventions.

Do not introduce iOS 17-only Observation APIs into code required to support earlier iOS versions without appropriate compatibility design.

Do not perform large-scale `ObservableObject` migrations as a side effect of unrelated feature work.

Avoid mixing multiple state-management patterns within the same workflow without a clear reason.

---

## 20. SwiftUI Review Checklist

Before completing SwiftUI changes, verify:

- Is state ownership clear?
- Is the View sufficiently declarative?
- Is business logic in the correct layer?
- Are asynchronous operations cancellation-aware?
- Is heavy work kept off the main actor?
- Are View identities stable?
- Are bindings necessary and correctly scoped?
- Are loading and failure states handled?
- Is navigation ownership appropriate?
- Are accessibility and localization preserved?
- Does the implementation respect the minimum deployment target?

**Final principle: SwiftUI should describe the interface, while state and behavior should have explicit and predictable ownership.**