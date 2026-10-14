# InkTheme

Black-and-white SwiftUI design system for iOS apps. Minimum deployment target is iOS 17.

## Add the package

In Xcode: File → Add Package Dependencies → Add Local, or depend on this repository:

```swift
.package(url: "https://github.com/your-org/InkTheme", from: "0.1.0")
```

Link the `InkTheme` library to the app target, then:

```swift
import InkTheme

@main
struct HostApp: App {
    @State private var appearanceStore = InkAppearanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appearanceStore)
                .inkAppearance(
                    appearanceStore.appearance,
                    accent: appearanceStore.accent,
                    ground: appearanceStore.ground,
                    radius: appearanceStore.radius
                )
        }
    }
}
```

The example app in `InkTheme/` is a catalog. It is not part of the library.

## Side effects

`InkAppearanceStore` reads and writes `UserDefaults.standard` under `ink.appearance`, `ink.accent`, `ink.ground`, and `ink.radius`. One process shares one set of keys. A second store in the same app overwrites the same values.

Changing appearance calls `UIApplication.shared` and sets `overrideUserInterfaceStyle` on every window in the connected scenes. The optional reveal animation snapshots the key window. This fits a normal iOS app. It does not apply in widgets, app extensions, or a scene that has no key window — those switches still update the store, without the window override or the blob.
