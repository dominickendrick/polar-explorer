

https://github.com/user-attachments/assets/dc49641e-7f7c-4047-8f14-f05aa35690d1

# Polar Explorer

A Flutter application for connecting to Polar heart rate monitors and tracking real-time heart rate data.

## Features

- **Bluetooth Device Scanning** - Automatically scans for nearby Polar heart rate devices
- **Real-time Heart Rate Monitoring** - Displays live heart rate data from connected devices
- **Heart Rate Zones** - Categorizes heart rate into zones:
  - Resting (< 60 bpm)
  - Active (60-80 bpm)
  - Exertion (> 80 bpm)
- **Visual Zone Indicator** - Dynamic progress bar with position marker that moves based on current heart rate

## Requirements

- Flutter SDK
- iOS or Android device with Bluetooth support
- Polar heart rate monitor

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect your device and run `flutter run` - Note this needs to run on a physical device that supports bluetooth

## Permissions

The app requires Bluetooth permissions to scan for and connect to heart rate devices.
