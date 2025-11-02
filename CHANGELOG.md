# Changelog

All notable changes to the Flutter Telink BLE plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-11-02

### Added

#### Core Features
- Initial release of Flutter Telink BLE plugin
- Support for Telink BLE Mesh protocol on Android
- Singleton pattern implementation for plugin instance

#### Device Management
- Device scanning with real-time stream updates
- Device provisioning with configuration support
- Unprovisioned device discovery
- Device UUID and address management

#### Network Management
- Mesh network initialization with full configuration
- Network key and application key management
- IV index and sequence number tracking
- Local address configuration (provisioner)
- Connection state monitoring with stream updates
- Auto-connect and auto-reconnect capabilities

#### Device Control
- On/Off command support
- Brightness/Level control (0-100)
- Color temperature control
- Command addressing (unicast and group)

#### Group Management
- Add devices to groups
- Remove devices from groups
- Group-based device control
- Support for standard BLE Mesh group addresses

#### OTA Updates
- GATT OTA firmware updates
- Mesh OTA support
- Real-time progress tracking
- Success/failure notifications
- Error reporting

#### Event Streaming
- Device scan event stream
- Connection state change stream
- OTA progress stream
- Mesh message notification stream

#### Data Models
- `TelinkMeshConfig` - Mesh network configuration
- `UnprovisionedDevice` - Scanned device representation
- `DeviceProvisionConfig` - Provisioning parameters
- `ProvisionResult` - Provisioning outcome
- `MeshConnectionStateEvent` - Connection state changes
- `OTAProgress` - OTA update progress

#### Android Implementation
- Integration with TelinkBleMeshLib SDK
- Event handler for mesh events
- Connection manager with auto-reconnect
- Proper lifecycle management
- Permission handling
- Method channel implementation
- Event channel implementation

#### Error Handling
- Comprehensive error messages
- Exception handling in all operations
- Platform-specific error propagation
- Validation for parameters

#### Documentation
- Comprehensive README with examples
- API reference documentation
- Platform setup instructions
- Troubleshooting guide
- Performance tips
- BLE Mesh address range documentation

### Fixed
- All Kotlin compilation errors in Android implementation
- EventHandler interface implementation
- TelinkBleMeshLib API compatibility
- Parameter initialization patterns
- Event property access using getter methods
- Configuration mapping for mesh setup
- OTA parameter construction
- Group management message formatting

### Technical Details

#### Build Configuration
- Android Gradle Plugin: 8.3.0
- Gradle: 8.4
- Kotlin: 1.9.22
- Min Android SDK: 21 (Android 5.0)
- Compile Android SDK: 35
- Target iOS: 9.0+
- Flutter SDK: >=3.3.0
- Dart SDK: ^3.6.2

#### Dependencies
- `flutter`: SDK
- `plugin_platform_interface`: ^2.0.2

#### Dev Dependencies
- `flutter_test`: SDK
- `flutter_lints`: ^5.0.0

### Known Limitations
- iOS implementation not yet available (coming soon)
- Requires physical BLE mesh devices for testing
- Location permissions required on Android for BLE scanning
- Maximum 32,767 unicast addresses per mesh network

### Breaking Changes
None (initial release)

### Deprecated
None

### Security
- Network encryption using 128-bit keys
- Secure provisioning process
- Protected mesh communication

---

## [Unreleased]

### Planned Features
- iOS implementation using TelinkSigMeshLib
- Additional mesh commands (Scene, Scheduler, etc.)
- Enhanced device capabilities discovery
- Mesh topology mapping
- Network analyzer and diagnostics
- Batch operations for multiple devices
- Custom vendor model support
- Low power node support
- Friend and relay node configuration
- Network migration tools
- Background scanning support
- Persistent device database

### Under Consideration
- Web platform support
- Desktop platform support (Windows, macOS, Linux)
- Mesh network visualization
- Remote provisioning
- Mesh proxy advertising
- GATT bearer optimization
- Mesh beacon support
- Network performance monitoring

---

[0.0.1]: https://github.com/thanhtunguet/flutter_telink_ble/releases/tag/v0.0.1
