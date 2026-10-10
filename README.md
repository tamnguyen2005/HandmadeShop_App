# Atelier Handmade Shop

A Flutter shopping app for handmade goods. The app includes product discovery, account access and profile management, shopping cart, checkout, order history, and order tracking. Product and shopping data are provided by a REST API backend.

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Requirements](#requirements)
- [Install and Run](#install-and-run)
- [Backend Configuration](#backend-configuration)
- [Project Structure](#project-structure)
- [Data Storage](#data-storage)
- [Build the App](#build-the-app)
- [Development Notes](#development-notes)

## Features

- Onboarding and a shopping interface with a visual style inspired by handmade leather goods.
- Browse products, view product details, search, and explore products by category or collection.
- Register, sign in, recover a password, verify an OTP, and reset a password.
- Manage the shopping cart, apply coupons, check out, and place orders.
- View order history, order details, and order status.
- Manage a personal profile, update profile details and avatar, change a password, and delete an account.
- Save favorite products and view available offers.
- Access settings and customer support/product care screens.

Features that require account or product data depend on the backend being available and reachable from the device running the app.

## Technology Stack

- Flutter and Dart (the SDK constraint in `pubspec.yaml` is `^3.10.1`).
- REST API requests with `http`.
- `shared_preferences` for locally stored tokens and user data.
- `image_picker` for selecting a profile image.
- `cached_network_image`, `google_fonts`, and `intl` for network images, typography, and Vietnamese date formatting.

## Requirements

- A Flutter SDK compatible with the Dart `3.10.1` or later constraint in this project.
- Android Studio or Xcode when developing or building for the corresponding mobile platform.
- A running Handmade Shop backend that is reachable from the device running the app.

Check your Flutter setup with:

```bash
flutter doctor
```

## Install and Run

From the project root, fetch dependencies and start the app:

```bash
flutter pub get
flutter devices
flutter run
```

To run on a specific target, replace `<device-id>` with an ID shown by `flutter devices`:

```bash
flutter run -d <device-id>
```

Common targets include:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

While the app is running in a terminal, press `r` for hot reload, `R` for hot restart, or `q` to quit.

## Backend Configuration

The API URL is currently hard-coded in `lib/services/APIClient.dart`:

```dart
String baseUrl = "http://192.168.50.18:5000/api";
```

Change this URL to an address reachable from the device before running the app. On a phone or emulator, `localhost` usually refers to the device itself rather than the computer hosting the backend. Use an appropriate LAN address or a platform-specific emulator address. The backend should provide the endpoint groups used by the app services:

- `/User`: sign-in, registration, profile, password, and account operations.
- `/Product`: product list, details, search, and filtering.
- `/Category`: categories, collections, and category details.
- `/Cart`: read, update, and clear the shopping cart.
- `/Coupon`: list coupons.
- `/Order`: create orders, list orders, and retrieve order details.

Authenticated requests send a Bearer token in the `Authorization` header. Sign-in, registration, forgot password, OTP verification, and password reset requests do not require a token.

## Project Structure

```text
lib/
├── main.dart                  # App entry point, locale setup, and onboarding screen
├── components/                # Reusable widgets: product cards, buttons, banners, etc.
├── configurations/            # Theme, colors, constants, and utilities
├── models/                    # API request and response models
├── screens/                   # App screens
└── services/                  # API client, feature services, and local storage

assets/
├── images/                    # Illustrations, banners, and UI images
└── icons/                     # App icons

android/                       # Android configuration
ios/                           # iOS configuration
web/                           # Web configuration
windows/                       # Windows configuration
linux/                         # Linux configuration
macos/                         # macOS configuration
test/                          # Flutter widget tests
```

## Data Storage

`SharedPreferencesService` stores the token, name/email, avatar, default shipping address, and favorite product IDs on the device. The app uses the API for cart, product, coupon, and order operations. Clearing app data or uninstalling the app may remove locally stored information.

## Build the App

```bash
flutter build apk
flutter build appbundle
flutter build ios
flutter build web
flutter build windows
```

Building for iOS requires macOS and Xcode. Desktop targets may need to be enabled in Flutter. Use the command for the platform you intend to release.

## Development Notes

- The API URL is currently hard-coded in the source and should be updated for the backend environment you use.
- `lib/configurations/constants.dart` also defines an `apiBaseUrl` constant, but `APIClient` currently uses the separate URL in `lib/services/APIClient.dart`.
- `test/widget_test.dart` is still the default counter sample and does not test the app UI.
- Asset directories are declared in `pubspec.yaml` (`assets/images/` and `assets/icons/`). Keep paths in sync when adding assets referenced by the code.
