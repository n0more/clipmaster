# ClipMaster

ClipMaster is a lightweight and efficient clipboard manager for macOS. It runs in the menu bar, keeping a history of everything you copy, so you can quickly find and reuse it.

## Features

- **Clipboard History**: Automatically saves a history of text and images you copy.
- **Menu Bar Access**: Lives in your menu bar for quick access without cluttering your Dock.
- **Hotkey Popup**: Instantly access your clipboard history from anywhere with a global hotkey (`Control + Shift + K`). The history window appears right under your cursor.
- **Keyboard Navigation**: Navigate your history using arrow keys and press `Enter` to copy an item back to your clipboard.
- **Image Support**: Previews images directly in the history view.

## How to Build and Run

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later

### Instructions

#### Using Xcode (Recommended)

1.  Open the `Package.swift` file in Xcode.
2.  Xcode will automatically resolve all dependencies.
3.  Press the **Run** button (or `⌘R`) to build and run the application.

#### Using the Command Line

1.  Open a terminal and navigate to the project's root directory.
2.  Run the following command:
    ```bash
    swift run
    ```
    This will build and run the application.

## Technologies Used

- **Swift**: The core programming language.
- **SwiftUI**: Used for building the user interface of the history and permission windows.
- **AppKit**: Used for robustly managing the application's lifecycle, menu bar icon (`NSStatusItem`), and pop-up window (`NSPanel`).
- **SwiftData**: For persisting the clipboard history locally.
- **HotKey**: A Swift package for managing global keyboard shortcuts.
