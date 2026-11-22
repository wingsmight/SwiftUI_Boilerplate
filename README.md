iOS SwiftUI Boilerplate
============================

The Boilerplate project based on SwiftUI. Code is grouped by feature, and each feature follows MVVM.

## Setup
1. Clone the repository.
2. Run `./init` from the recently created folder.
3. Initialize a new git repo and add your remote url.
4. Delete `./init` and `./init.swift` files.

## Dependencies
- [SwiftLint](https://github.com/SimplyDanny/SwiftLintPlugins)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [RNCryptor](https://github.com/RNCryptor/RNCryptor)
- [Slab](https://github.com/useradgents/slab)
- [SwiftfulRecursiveUI](https://github.com/SwiftfulThinking/SwiftfulRecursiveUI)
- [SwiftfulRouting](https://github.com/SwiftfulThinking/SwiftfulRouting)
- [SwiftfulUI](https://github.com/SwiftfulThinking/SwiftfulUI)

## Project Structure

Application sources live in `Boilerplate/`. `./init` renames that folder, and `BoilerplateApp.swift`, to the new project name.

```
Boilerplate/
├── App/
│   ├── BoilerplateApp.swift
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
│   ├── Editor/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   ├── Components/
│   │   └── Services/
│   │
│   └── Settings/
│       ├── Views/
│       └── ViewModels/
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
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.xcstrings
│   └── Fonts/
│
├── Tests/
│   ├── Features/
│   ├── Domain/
│   └── Core/
│
├── Preview Content/
│   └── Preview Assets.xcassets
│
└── Info.plist
```

| Name | Description |
| --- | --- |
| **App**/ | Entry point, dependency container, root router, and app configuration |
| **Features**/ | One folder per screen or feature. Views, view models, models, and feature-specific UI stay together |
| **Domain**/ | Models and contracts shared across features |
| **Core**/ | Networking, storage, app-wide services, and repositories |
| **Shared**/ | Reusable UI, extensions, and utilities |
| **Resources**/ | Asset catalog, string catalog, and fonts |
| **Tests**/ | Folder layout for unit tests, split the same way as Features, Domain, and Core. Add an Xcode test target when you write the first test |
| **Preview Content**/ | Assets used by SwiftUI previews |

Empty folders contain a `.gitkeep` file so Git keeps the template. Delete that file when you add the first real source file to the folder.
