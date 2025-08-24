# ClipMaster 📋✨

A smart clipboard manager for macOS, supercharged by local language models via Ollama.

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

ClipMaster is more than just a clipboard history. It's a native macOS tool that lets you instantly process copied text using your own locally running AI models.

<!-- Insert a screenshot of the main application window here -->

## Key Features

*   **Clipboard History**: Access your recently copied items through a convenient panel, summoned by a hotkey.
*   **Ollama Integration**: Connects to your local Ollama server to process text.
*   **Custom Prompts**: Create, edit, and save your own prompts for quick text transformations (e.g., "Translate to English," "Fix grammar," "Rewrite in a professional tone").
*   **Flexible Configuration**:
    *   Set any URL for your Ollama API (local or network).
    *   Choose from any of your available Ollama models.
    *   Adjust the model's "temperature" to control response creativity.
*   **Native Experience**: Built with SwiftUI for a lightweight, fast, and seamless macOS experience.
*   **Menu Bar Access**: Lives in your menu bar for quick access to settings and features.

## Requirements

*   macOS 13.0+
*   [Ollama](https://ollama.com/) must be installed and running.
*   To build from source: Xcode 15.0+

## Installation

### For Users

1.  Go to the [Releases](https://github.com/YOUR_USERNAME/ClipMaster/releases) page (You will need to create this repository).
2.  Download the latest version of `ClipMaster.app.zip`.
3.  Unzip the archive and drag `ClipMaster.app` into your `/Applications` folder.

### For Developers

1.  Clone the repository:
    ```bash
    git clone https://github.com/YOUR_USERNAME/ClipMaster.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd ClipMaster
    ```
3.  Open `ClipMaster.xcodeproj` in Xcode.
4.  Press `Cmd+R` to build and run the project.

## How to Use

1.  **Launch ClipMaster**. The app icon will appear in your menu bar.
2.  **Configure the app**:
    *   Click the menu bar icon.
    *   Set your **Ollama API URL** (defaults to `http://localhost:11434`).
    *   Select the **Model** you wish to use.
    *   Adjust the **Temperature** if needed.
    *   Add your custom **Prompts** via the "Add New Prompt..." menu item.
3.  **Copy any text**.
4.  **Open the history panel**: Press the hotkey (default is `Cmd+Shift+V`).
    <!-- Insert a screenshot of the history panel here -->
5.  **Process the text**:
    *   Hover over an item in the history list.
    *   Click the "AI" icon to apply the currently active prompt.
    *   The processed result will be **automatically copied** to your clipboard.
6.  **Paste the result** wherever you need it.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
