# AGENTS.md

## Project Overview

**Aqua Medium Icons** is a KWin window switcher (TabBox) theme that replicates the macOS-style window switcher layout for KDE Plasma on Linux. It displays open windows as large application icons in a horizontal strip, with app names rendered below each icon.

- **Type**: KWin TabBox Switcher plugin (KPackage)
- **Package Structure**: `KWin/WindowSwitcher`
- **Plugin ID**: `AquaMediumIcons`
- **License**: GPL-2.0-or-later

---

## Project Structure

```
AquaMediumIcons/
├── contents/
│   └── ui/
│       └── main.qml        # Primary UI file: the entire switcher layout
├── images/
│   ├── layout.png          # Screenshot of the switcher in action
│   └── settings.png        # Screenshot of the settings/configuration dialog
├── metadata.json           # KPackage plugin metadata (name, author, description)
├── LICENSE                 # GPL license text
└── README.md               # Human-facing installation instructions
```

---

## Technology Stack

- **QML / QtQuick 2.15** — UI declarative language used by KDE Plasma
- **QtQuick.Layouts 1.15** — Layout primitives (`ColumnLayout`, etc.)
- **KDE Frameworks**:
  - `org.kde.plasma.core` — Plasma dialog and type system
  - `org.kde.kirigami 2.20` — KDE HIG components (icons, units, spacing)
  - `org.kde.ksvg 1.0` — SVG-based framing (highlight item)
  - `org.kde.plasma.components 3.0` — Label and other Plasma UI components
  - `org.kde.kwin 3.0` — KWin TabBox switcher API (`KWin.TabBoxSwitcher`)
- **KPackage** — KDE package system used to install/distribute the theme

---

## Installation

No build step is required. This project is a declarative QML theme; it works by being placed in the correct KWin tabbox directory.

```bash
# Clone directly to the KWin tabbox themes directory
git clone https://github.com/harryxu/kde-aquamediumicons.git \
    ~/.local/share/kwin/tabbox/AquaMediumIcons
```

After installation, activate it in:
**System Settings → Window Management → Task Switcher → Visualization**

---

## Development Workflow

There is no build or compilation step. Editing `contents/ui/main.qml` takes effect the next time the window switcher is invoked (after reloading KWin or logging out and back in).

**Reload KWin without logging out:**
```bash
kwin_x11 --replace &
# or on Wayland:
kwin_wayland --replace &
```

**Quick test cycle:**
1. Edit `contents/ui/main.qml`
2. Run `kwin_x11 --replace &` (or Wayland equivalent) to reload KWin
3. Press `Alt+Tab` to invoke the switcher and verify changes

---

## Key Source File

### `contents/ui/main.qml`

This is the **only source file** of the project. All logic and layout lives here.

Key components:
- **`KWin.TabBoxSwitcher`** — Root element providing `model`, `currentIndex`, `screenGeometry`, and `visible` from KWin
- **`PlasmaCore.Dialog`** — Floating centered dialog container
- **`ListView` (`id: icons`)** — Horizontal list rendering one delegate per open window
  - `iconSize`: `Kirigami.Units.iconSizes.huge * 1.5` (large icons)
  - `delegateWidth` / `delegateHeight`: icon size plus generous padding
- **`Kirigami.Icon`** — Renders the application icon; uses `HoverHandler` for macOS-style hover-to-select
- **`TapHandler`** — Click to directly activate a window
- **`PlasmaComponents3.Label`** — Shows the application name below the icon (extracted from window caption using `—` or `-` as a separator)
- **`KSvg.FrameSvgItem`** — Plasma SVG highlight/selection indicator
- **`Connections`** — Keeps `ListView.currentIndex` in sync with `tabBox.currentIndex`
- **`Keys.onPressed`** — Left/Right arrow key navigation

---

## Coding Conventions

- **QML style**: Follow KDE/Plasma QML conventions
  - Use `Kirigami.Units.*` for all spacing and sizing (never hardcode pixel values)
  - Anchor-based layout inside delegates; `ColumnLayout` for the outer container
  - Keep property aliases and `readonly property` declarations at the top of their scope
- **No JavaScript files**: All logic is inline QML/JS within `main.qml`
- **No external assets**: Icons are sourced from `model.icon` (provided by KWin at runtime); do not bundle icon files
- **Comments**: Preserve existing SPDX license headers; add comments when non-obvious layout tricks are used

---

## metadata.json

Describes the plugin to the KPackage system. When modifying:
- `KPlugin.Name` — Display name shown in System Settings
- `KPlugin.Description` — Short description shown in System Settings
- `KPlugin.Id` — Must match the directory name (`AquaMediumIcons`)
- `KPackageStructure` — Must remain `"KWin/WindowSwitcher"`

---

## No Automated Tests

There is no test suite for this project. Verification is manual:
1. Invoke the switcher with `Alt+Tab` after installing/reloading KWin
2. Confirm icons display correctly and are sized appropriately
3. Verify hover-to-select behavior works (moving the mouse over an icon selects it)
4. Verify click-to-activate works (clicking an icon brings that window to focus)
5. Verify keyboard left/right arrow navigation works

---

## Contributing

- Keep the single-file approach — all UI in `contents/ui/main.qml`
- Test on both X11 and Wayland sessions if possible
- Update `images/layout.png` if the visual appearance changes significantly
- The original upstream project is at: https://github.com/adhec/aquamediumicons
