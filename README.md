# Srz Clipboard

A macOS clipboard manager that provides Windows-like clipboard history functionality with global hotkey support.

## Features

- **Global Hotkey**: Press `Cmd+Alt+V` anywhere to show clipboard history
- **Clipboard Monitoring**: Automatically tracks clipboard changes
- **Click to Append**: Click any item in history to append it to current clipboard
- **Search**: Search through clipboard history
- **Dark/Light Theme**: Toggle between themes with the theme switcher
- **Menu Bar Integration**: Runs in the background with menu bar icon
- **Persistent Storage**: History is saved between app restarts
- **Settings**: Configure max history items and other preferences

## How to Use

1. **Launch the App**: The app will appear in your menu bar with a clipboard icon
2. **Global Hotkey**: Press `Cmd+Alt+V` anywhere to show the clipboard history popup
3. **Append Text**: Click any item in the history to append it to your current clipboard
4. **Search**: Use the search bar to find specific clipboard items
5. **Delete Items**: Hover over items and click the trash icon to delete them
6. **Clear All**: Use the "Clear All" button to remove all history
7. **Settings**: Access settings through the menu bar or app preferences

## Installation

1. Open the project in Xcode
2. Build and run the project
3. The app will be installed and will start running in the background

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later

## Permissions

The app requires the following permissions:
- **Accessibility**: For global hotkey registration
- **Clipboard Access**: For monitoring clipboard changes

## Technical Details

- Built with SwiftUI for macOS
- Uses Carbon framework for global hotkey registration
- NSPasteboard for clipboard monitoring
- UserDefaults for persistent storage
- MenuBarExtra for background operation

## Author

Created by Md Sohag Islam

## Version

1.0.0
# srz-clipboard-macos
