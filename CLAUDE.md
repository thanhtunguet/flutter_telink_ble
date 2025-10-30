# Claude Code Guidelines for Flutter Telink BLE Plugin

## Project Overview
This is a Flutter plugin project that provides Telink BLE device support for Flutter applications. It implements native platform channels to communicate with Telink BLE devices on both Android and iOS.

## Coding Standards

### Dart Code
- Follow Flutter/Dart style guide conventions
- Use `dart format` and `dart analyze` for code quality
- Prefer explicit typing over `var` when type isn't obvious
- Use meaningful variable and function names
- Keep functions small and focused

### Plugin Architecture
- Follow Flutter plugin pattern with platform channels
- Implement separate platform-specific code in `android/` and `ios/` directories
- Use method channels for bidirectional communication
- Use event channels for streaming data (BLE notifications, scanning results)

### Native Code Standards

#### Android (Kotlin/Java)
- Follow Android coding conventions
- Use Kotlin where possible
- Implement proper lifecycle management for BLE operations
- Handle permissions properly (BLUETOOTH, LOCATION)

#### iOS (Swift/Objective-C)
- Follow iOS coding conventions
- Use Swift where possible
- Implement proper Core Bluetooth delegate patterns
- Handle iOS-specific BLE requirements

### BLE Implementation Guidelines
- Always check BLE availability before operations
- Implement proper connection state management
- Handle scanning timeouts appropriately
- Provide clear error messages for BLE failures
- Implement proper cleanup on disconnect

### Testing
- Run `flutter test` for unit tests
- Run `flutter analyze` for static analysis
- Test on both Android and iOS physical devices
- Test BLE functionality with actual Telink devices

### Documentation
- Document all public APIs with dart doc comments
- Include usage examples in README
- Document platform-specific requirements
- Keep API documentation up to date

## Build Commands
- `flutter pub get` - Install dependencies
- `flutter analyze` - Static analysis
- `flutter test` - Run unit tests
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS framework

## Platform Requirements
- Android: API level 18+ (BLE support)
- iOS: 9.0+ (Core Bluetooth support)
- Ensure proper BLE permissions in manifests

## Common Patterns
- Use async/await for BLE operations
- Implement proper stream controllers for continuous data
- Use isolates for heavy BLE data processing if needed
- Follow Flutter plugin boilerplate structure
