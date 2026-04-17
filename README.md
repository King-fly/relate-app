# Relate App

A modern iOS application for tracking and managing relationships.

## Features

- **Check-ins**: Record and track interactions with contacts
- **Dates**: Manage important dates and anniversaries
- **Templates**: Create and use message templates for consistent communication
- **Thermometer**: Visualize relationship health with an interactive thermometer
- **Theming**: Customize app appearance with different themes

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/relate-app.git
   ```

2. Open the project in Xcode:
   ```bash
   cd relate-app
   open relate-app.xcodeproj
   ```

3. Build and run the app on your device or simulator.

## Project Structure

- `relate-app/` - Main application code
  - `Assets.xcassets/` - App icons and assets
  - `AppStore.swift` - App Store related functionality
  - `CheckinsView.swift` - Check-ins feature implementation
  - `ContentView.swift` - Main app view
  - `DatesView.swift` - Dates feature implementation
  - `Models.swift` - Data models
  - `TemplatesView.swift` - Templates feature implementation
  - `Theme.swift` - Theming functionality
  - `ThermometerView.swift` - Relationship health thermometer
  - `relate_appApp.swift` - App entry point

## Usage

1. **Check-ins**: Tap on the Checkins tab to record interactions with your contacts.
2. **Dates**: Tap on the Dates tab to view and manage important dates.
3. **Templates**: Tap on the Templates tab to create and use message templates.
4. **Thermometer**: View the relationship health status on the main screen.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- SwiftUI for the modern UI implementation
- Core Data for local data persistence
- Combine for reactive programming