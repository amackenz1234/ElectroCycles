# CLAUDE.md — ElectroCycles

## Project Overview

ElectroCycles (display name: "Electro Cycles") is a native iOS e-bike shopping app built entirely in **Swift** with **UIKit**. It features a product catalog, favorites, shopping cart, order tracking, and Apple Pay integration. There are zero third-party dependencies — the app uses only Apple frameworks (UIKit, Foundation, Combine, PassKit).

- **Bundle ID:** `com.electrocycles.app`
- **Minimum iOS:** 13.0+
- **Xcode project format:** objectVersion 77 (Xcode 14+)
- **Scheme name:** `Electro Cycles`

## Repository Structure

```
ElectroCycles/
├── .github/
│   ├── ISSUE_TEMPLATE/          # Bug report & feature request templates
│   ├── PULL_REQUEST_TEMPLATE.md # PR checklist template
│   └── workflows/
│       ├── ios.yml              # Primary CI: build, test, lint (macOS 14)
│       ├── swift.yml            # Fallback: swift build/test
│       └── testflight.yml      # TestFlight beta deployment
├── Assets.xcassets/             # Images, colors, app icon
├── xcshareddata/                # Shared Xcode schemes
├── project.pbxproj              # Xcode project file
├── Info.plist                   # App configuration
├── LaunchScreen.storyboard      # Launch screen (only storyboard)
├── ElectroCycles.entitlements   # Apple Pay entitlements
│
├── AppDelegate.swift            # App lifecycle, appearance config
├── SceneDelegate.swift          # Window/scene setup
├── MainTabBarController.swift   # Root tab bar (Shop, Favorites, Cart, Orders)
│
├── AppModels.swift              # Bike model, Catalog data, Formatting utilities
├── ElectroCyclesTypes.swift     # Type aliases for cross-module access
│
├── CatalogViewController.swift  # Product grid with compositional layout
├── BikeDetailViewController.swift # Product detail with Add to Cart / Apple Pay
├── CartViewController.swift     # Shopping cart with quantity editing
├── FavoritesViewController.swift # Favorited bikes list
├── OrdersViewController.swift   # Order history with status tracking
├── WhatsNewViewController.swift # What's New modal (+ variants 2, 3)
│
├── CartStore.swift              # Cart state management (singleton)
├── FavoritesStore.swift         # Favorites state management (singleton)
├── OrdersStore.swift            # Orders state management (singleton)
└── ApplePayManager.swift        # Apple Pay payment flow (singleton)
```

## Build & Run Commands

### Build (simulator, no code signing)

```bash
xcodebuild build \
  -project "$(find . -name '*.xcodeproj' -maxdepth 1 | head -1)" \
  -scheme "Electro Cycles" \
  -destination "generic/platform=iOS Simulator" \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES
```

### Run Unit Tests

```bash
xcodebuild test \
  -project "$(find . -name '*.xcodeproj' -maxdepth 1 | head -1)" \
  -scheme "Electro Cycles" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  -configuration Debug \
  -skip-testing:"Electro CyclesUITests" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

### Lint (SwiftLint)

```bash
# Install if needed: brew install swiftlint
swiftlint lint
```

SwiftLint disabled rules (configured in CI, no `.swiftlint.yml` committed):
- `trailing_whitespace`, `line_length`, `file_length`, `type_body_length`, `function_body_length`

## Architecture

### Pattern: UIKit MVC with Singleton Stores

The app follows a UIKit MVC pattern enhanced with observable singleton stores for state management:

- **View Controllers** — UIKit controllers with programmatic layout (no storyboards besides LaunchScreen). Each VC manages its own UI using `NSLayoutConstraint` Auto Layout.
- **Stores** — `CartStore.shared`, `FavoritesStore.shared`, `OrdersStore.shared`, `ApplePayManager.shared`. All are `@MainActor ObservableObject` singletons using `@Published` properties and `NotificationCenter` for change broadcasts.
- **Models** — `Bike`, `CartItem`, `Order`, `OrderItem`, `OrderStatus` — all `Codable` and `Identifiable`.
- **Persistence** — `UserDefaults` with `JSONEncoder`/`JSONDecoder` for all local data.

### Tab Structure

| Tab | Controller | Store |
|-----|-----------|-------|
| Shop | `CatalogViewController` | `Catalog` (static data) |
| Favorites | `FavoritesViewController` | `FavoritesStore` |
| Cart | `CartViewController` | `CartStore` |
| Orders | `OrdersViewController` | `OrdersStore` |

### Key Frameworks

| Framework | Usage |
|-----------|-------|
| UIKit | All UI (programmatic layout, no SwiftUI) |
| Combine | `@Published` properties on stores |
| PassKit | Apple Pay (merchant ID: `merchant.com.electrocycles.app`) |
| Foundation | Models, UserDefaults persistence, formatting |

## Code Conventions

### File Header Format

```swift
//
//  FileName.swift
//  Electro Cycles
//
//  Created by Assistant on YYYY-MM-DD.
//  Brief description of file purpose
//
```

### Naming Conventions

- **View Controllers:** `<Feature>ViewController` (e.g., `CatalogViewController`, `BikeDetailViewController`)
- **Stores:** `<Feature>Store` (e.g., `CartStore`, `FavoritesStore`)
- **Custom Cells:** Defined as nested classes or private classes within their parent VC files (e.g., `BikeCell`, `BannerCell`, `CartItemCell`, `OrderCell`)
- **Notifications:** Static `didChange` property on each store (e.g., `CartStore.didChange`)
- **MARK comments:** Used to separate sections (e.g., `// MARK: - Bike Model`)

### Patterns to Follow

- All stores use the **singleton pattern** with `.shared` accessor
- Stores are annotated `@MainActor` and conform to `ObservableObject`
- Store mutations broadcast via `NotificationCenter.default.post(name:)` and `@Published`
- UI is 100% programmatic — use `NSLayoutConstraint`, not storyboards
- Controllers use `final class` modifier
- Use SF Symbols for icons (e.g., `"bicycle"`, `"cart"`, `"heart"`, `"shippingbox"`)
- Dark mode support via system semantic colors (`.systemBackground`, `.label`, `.secondaryLabel`, etc.)
- All source files live in the project root (flat structure, no `Sources/` subdirectory)

### Things to Avoid

- Do not add third-party dependencies (CocoaPods, SPM, Carthage) — the project is deliberately dependency-free
- Do not introduce SwiftUI views — the project is UIKit-only
- Do not add storyboard files — all UI is programmatic
- Do not modify `project.pbxproj` by hand unless adding/removing files from the Xcode project

## CI/CD

### GitHub Actions (`.github/workflows/ios.yml`)

Triggers on push/PR to `main` and `develop` branches:

1. **Build job** — Builds with Xcode on `macos-14`, runs unit tests on iPhone 15 simulator, uploads `.xcresult` artifact
2. **Lint job** — Installs SwiftLint via Homebrew, runs lint with GitHub Actions reporter

Both jobs use `continue-on-error: true` so failures are reported but don't block.

Concurrency group configured to cancel in-progress runs on the same ref.

### Code Signing in CI

Code signing is fully disabled in CI builds:
```
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
```

### TestFlight Deployment (`.github/workflows/testflight.yml`)

Triggers on push to `main` or manual dispatch (`workflow_dispatch`).

**Pipeline:** Archive with Release config -> Export IPA -> Upload via `xcrun altool`

**Required GitHub Secrets (must be configured before use):**

| Secret | Description |
|--------|-------------|
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded `.p12` distribution certificate |
| `APPLE_CERTIFICATE_PASSWORD` | Password for the `.p12` certificate |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded App Store provisioning profile |
| `PROVISIONING_PROFILE_NAME` | Name of the provisioning profile in Apple Developer portal |
| `CODE_SIGN_IDENTITY` | Signing identity (e.g., `"Apple Distribution: Your Name (TEAM_ID)"`) |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect API issuer ID |
| `ASC_API_KEY` | App Store Connect API private key (`.p8` contents) |

**Setup steps:**
1. Create an App Store Connect API key at https://appstoreconnect.apple.com/access/integrations/api
2. Export your distribution certificate as `.p12` and base64-encode it: `base64 -i cert.p12 | pbcopy`
3. Download your App Store provisioning profile and base64-encode it: `base64 -i profile.mobileprovision | pbcopy`
4. Add all secrets to GitHub repository Settings > Secrets and variables > Actions

Build numbers auto-increment using `github.run_number`. The IPA is also uploaded as a GitHub artifact for 30 days.

## PR Workflow

When submitting a PR, follow the template at `.github/PULL_REQUEST_TEMPLATE.md`:

- Provide a summary and list of changes
- Mark the change type (bug fix, feature, breaking change, docs)
- Complete the testing checklist (simulator, device, unit tests, UI tests)
- Confirm style guidelines adherence and self-review

## Data Model Quick Reference

```swift
Bike        { id: UUID, name: String, description: String, price: Decimal, imageSystemName: String, assetImageName: String? }
CartItem    { id: UUID, bike: Bike, quantity: Int }
Order       { id: UUID, items: [OrderItem], totalPrice: Decimal, orderDate: Date, status: OrderStatus }
OrderItem   { id: UUID, bikeName: String, bikeId: UUID, quantity: Int, pricePerUnit: Decimal }
OrderStatus : String enum { confirmed, processing, shipped, delivered, cancelled }
```

Static catalog has 4 bikes with fixed UUIDs: Evoque Atom ($1,999), Lightning Bolt ($1,599), Urban Cruiser ($1,299), Mountain Explorer ($2,299).
