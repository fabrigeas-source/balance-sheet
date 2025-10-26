# Balance Sheet PWA

This project is a Progressive Web App (PWA) for managing a balance sheet. It allows users to add, edit, and delete entries, and it utilizes local storage to persist data across sessions.

## Project Structure

- **balance-sheet.html**: The main HTML document for the PWA. It includes the structure of the app, links to the CSS and JavaScript files, and sets up local storage functionality.
  
- **manifest.json**: Contains metadata about the PWA, including the app name, icons, start URL, display mode, and theme colors. This file is used by browsers to install the app on devices.

- **service-worker.js**: Registers a service worker that enables offline capabilities and caching for the PWA. It intercepts network requests and serves cached resources when the network is unavailable.

- **styles/main.css**: Contains the CSS styles for the PWA, defining the layout, colors, fonts, and overall appearance of the app.

- **scripts/app.js**: Contains the JavaScript code for the PWA. It handles the app's logic, including local storage operations, event listeners, and dynamic updates to the HTML content.

## Features

- Add, edit, and delete balance sheet entries.
- Data is stored in local storage, allowing persistence across sessions.
- Offline capabilities through service worker caching.

## Setup Instructions

1. Clone the repository to your local machine.
2. Open `balance-sheet.html` in a web browser to run the app.
3. For a better experience, consider serving the app through a local server to enable service worker functionality.

## Usage

- Use the app to manage your balance sheet entries.
- Entries will be saved automatically in local storage.
- The app can be installed on your device for easy access.

## License

This project is open-source and available for use and modification.