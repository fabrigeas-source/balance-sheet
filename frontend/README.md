# Balance Sheet App

This Flutter application is designed to manage a balance sheet, allowing users to track their financial items, including expenses and revenues. 

## Features

- Display a list of financial items with descriptions and amounts.
- Show the total sum of all items in a header.
- Expandable item details with options to edit and create sublists.
- Swipe-to-delete functionality with a confirmation dialog.
- Modal for adding new items with input fields for description, details, amount, and type (expense or revenue).

## Project Structure

```
balance_sheet_app
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── models
│   │   └── item.dart            # Defines the Item class
│   ├── screens
│   │   └── home_screen.dart      # Home screen displaying items
│   ├── widgets
│   │   ├── item_tile.dart        # Widget for displaying each item
│   │   ├── total_header.dart      # Widget for displaying total sum
│   │   └── new_item_modal.dart    # Modal for creating new items
│   ├── providers
│   │   └── item_provider.dart      # Manages item state
│   └── utils
│       └── formatters.dart        # Utility functions for formatting
├── test
│   └── widget_test.dart           # Widget tests for the application
├── pubspec.yaml                   # Flutter project configuration
├── analysis_options.yaml          # Dart analysis options
├── .gitignore                     # Files to ignore in version control
└── README.md                      # Project documentation
```

## Getting Started

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd balance_sheet_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run
   ```

## Usage

- Use the floating button to add new items.
- Tap on an item to expand and view details.
- Swipe left on an item to delete it.
- Edit existing items as needed.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes. 

## License

This project is licensed under the MIT License - see the LICENSE file for details.