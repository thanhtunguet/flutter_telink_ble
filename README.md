# Flutter Telink BLE

A comprehensive Flutter plugin for Telink BLE Mesh devices, providing seamless integration with Telink's BLE Mesh SDK for both Android and iOS platforms.

[![pub package](https://img.shields.io/pub/v/flutter_telink_ble.svg)](https://pub.dev/packages/flutter_telink_ble)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

Flutter Telink BLE enables Flutter applications to communicate with Telink BLE Mesh devices, supporting device provisioning, mesh network management, device control, group operations, and OTA firmware updates. This plugin wraps the native Telink BLE Mesh SDKs for Android and iOS, providing a clean, idiomatic Dart API.

## Features

✅ **Device Discovery & Provisioning**
- Scan for unprovisioned BLE mesh devices
- Provision devices into mesh network
- Configure device parameters

✅ **Mesh Network Management**
- Initialize and configure mesh networks
- Connect/disconnect from mesh
- Monitor connection state changes
- Persistent mesh configuration

✅ **Device Control**
- On/Off control
- Brightness/Level control
- Color temperature control
- Custom command support

✅ **Group Management**
- Create and delete groups
- Add/remove devices from groups
- Group-based control

✅ **OTA Updates**
- Over-the-air firmware updates
- Progress monitoring
- GATT and Mesh OTA support

✅ **Event Streams**
- Real-time device discovery
- Connection state updates
- OTA progress tracking
- Mesh message notifications

## Requirements

### Android
- Android 5.0 (API level 21) or higher
- BLE 4.0+ support
- Location permissions (for BLE scanning)
- Bluetooth permissions

### iOS
- iOS 9.0 or higher
- Core Bluetooth support
- Background mode capabilities (optional)

### Flutter
- Flutter SDK 3.3.0 or higher
- Dart SDK 3.6.2 or higher

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_telink_ble: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Android Setup

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```

### iOS Setup

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to communicate with BLE mesh devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to communicate with BLE mesh devices</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access for BLE scanning</string>
```

## Quick Start

### 1. Initialize the Mesh Network

```dart
import 'package:flutter_telink_ble/flutter_telink_ble.dart';

final telinkBle = FlutterTelinkBle();

// Configure your mesh network
final config = TelinkMeshConfig(
  networkKey: '7dd7364cd842ad18c17c2b820c84c3d6',  // 16-byte hex string
  netKeyIndex: 0,
  appKeys: {
    0: '63964771734fbd76e3b40519d1d94a48',  // App key index 0
  },
  ivIndex: 0,
  sequenceNumber: 0,
  localAddress: 0x0001,  // Your provisioner address
);

// Initialize
await telinkBle.initialize(config);
```

### 2. Scan for Devices

```dart
// Start scanning
telinkBle.scanForDevices().listen((device) {
  print('Found device: ${device.name} (${device.uuid})');
  print('Signal strength: ${device.rssi} dBm');
  print('MAC address: ${device.macAddress}');
});

// Stop scanning after 10 seconds
await Future.delayed(Duration(seconds: 10));
await telinkBle.stopScan();
```

### 3. Provision a Device

```dart
final provisionConfig = DeviceProvisionConfig(
  uuid: device.uuid,
  address: 0x0002,  // Unicast address for the new device
  macAddress: device.macAddress,
);

final result = await telinkBle.provisionDevice(provisionConfig);

if (result.success) {
  print('Device provisioned successfully!');
  print('Address: 0x${result.address.toRadixString(16)}');
} else {
  print('Provisioning failed: ${result.error}');
}
```

### 4. Connect to Mesh

```dart
// Connect to the mesh network
final connected = await telinkBle.connectToMesh();

if (connected) {
  print('Connected to mesh network');
}

// Listen for connection state changes
telinkBle.connectionStateStream.listen((state) {
  print('Connection state: ${state.state}');
  if (state.state == MeshConnectionState.connected) {
    print('Mesh network is ready');
  }
});
```

### 5. Control Devices

```dart
// Turn a device on/off
await telinkBle.sendOnOffCommand(0x0002, true);  // Turn on
await telinkBle.sendOnOffCommand(0x0002, false); // Turn off

// Set brightness (0-100)
await telinkBle.sendLevelCommand(0x0002, 75);

// Set color temperature
await telinkBle.sendColorCommand(0x0002, Colors.warmWhite);
```

### 6. Manage Groups

```dart
// Add device to a group
await telinkBle.addDeviceToGroup(
  deviceAddress: 0x0002,
  groupAddress: 0xC000,  // Group address
);

// Control all devices in the group
await telinkBle.sendOnOffCommand(0xC000, true);  // Turn on all devices in group
```

### 7. OTA Firmware Update

```dart
// Load firmware file
final firmwareData = await File('path/to/firmware.bin').readAsBytes();

// Start OTA update
await telinkBle.startOTA(0x0002, firmwareData);

// Monitor progress
telinkBle.otaProgressStream.listen((progress) {
  print('OTA Progress: ${progress.percentage}%');

  if (progress.state == OTAState.success) {
    print('OTA update completed successfully!');
  } else if (progress.state == OTAState.failed) {
    print('OTA update failed: ${progress.error}');
  }
});
```

## API Reference

### Core Classes

#### `FlutterTelinkBle`

Main plugin class providing access to all BLE mesh operations.

**Methods:**

- `Future<bool> initialize(TelinkMeshConfig config)` - Initialize mesh network
- `Future<void> dispose()` - Cleanup resources
- `Stream<UnprovisionedDevice> scanForDevices()` - Scan for unprovisioned devices
- `Future<void> stopScan()` - Stop device scanning
- `Future<ProvisionResult> provisionDevice(DeviceProvisionConfig config)` - Provision a device
- `Future<bool> connectToMesh()` - Connect to mesh network
- `Future<void> disconnectFromMesh()` - Disconnect from mesh
- `Stream<MeshConnectionStateEvent> get connectionStateStream` - Connection state updates
- `Future<void> sendOnOffCommand(int address, bool isOn)` - Send on/off command
- `Future<void> sendLevelCommand(int address, int level)` - Send brightness command
- `Future<void> sendColorCommand(int address, Color color)` - Send color command
- `Future<void> addDeviceToGroup(int deviceAddress, int groupAddress)` - Add device to group
- `Future<void> removeDeviceFromGroup(int deviceAddress, int groupAddress)` - Remove device from group
- `Future<void> startOTA(int deviceAddress, Uint8List firmwareData)` - Start OTA update
- `Stream<OTAProgress> get otaProgressStream` - OTA progress updates

### Data Models

#### `TelinkMeshConfig`

Configuration for mesh network initialization.

```dart
TelinkMeshConfig({
  required String networkKey,      // 32-char hex string (16 bytes)
  required int netKeyIndex,        // 0-4095
  required Map<int, String> appKeys, // App keys by index
  required int ivIndex,            // IV index
  required int sequenceNumber,     // Sequence number
  required int localAddress,       // Unicast address (0x0001-0x7FFF)
})
```

#### `UnprovisionedDevice`

Represents a discovered unprovisioned device.

```dart
UnprovisionedDevice({
  required String uuid,            // Device UUID
  required String name,            // Device name
  required int rssi,              // Signal strength
  required Map<String, dynamic> advertisementData,
  String? macAddress,             // MAC address
})
```

#### `DeviceProvisionConfig`

Configuration for provisioning a device.

```dart
DeviceProvisionConfig({
  required String uuid,           // Device UUID
  required int address,           // Unicast address to assign
  String? macAddress,            // Optional MAC address
})
```

#### `ProvisionResult`

Result of a provisioning operation.

```dart
ProvisionResult({
  required bool success,          // Success status
  required int address,           // Assigned address
  String? error,                 // Error message if failed
})
```

#### `MeshConnectionStateEvent`

Connection state change event.

```dart
enum MeshConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
}
```

#### `OTAProgress`

OTA update progress information.

```dart
enum OTAState {
  started,
  inProgress,
  success,
  failed,
}

OTAProgress({
  required OTAState state,
  required int percentage,        // 0-100
  String? error,                 // Error message if failed
})
```

## Address Ranges

BLE Mesh uses 16-bit addresses with specific ranges:

- **Unassigned**: `0x0000`
- **Unicast** (individual devices): `0x0001` - `0x7FFF`
- **Virtual**: `0x8000` - `0xBFFF`
- **Group**: `0xC000` - `0xFEFF`
- **All Proxies**: `0xFFFC`
- **All Friends**: `0xFFFD`
- **All Relays**: `0xFFFE`
- **All Nodes**: `0xFFFF`

## Example Application

Check out the [example](example/) directory for a complete demo application that demonstrates:

- Mesh network initialization
- Device scanning and provisioning
- Device control (on/off, brightness, color)
- Group management
- OTA firmware updates
- Connection state monitoring

To run the example:

```bash
cd example
flutter run
```

## Architecture

The plugin follows Flutter's standard plugin architecture:

```
lib/
├── flutter_telink_ble.dart           # Main plugin class
├── flutter_telink_ble_platform_interface.dart  # Platform interface
├── flutter_telink_ble_method_channel.dart      # Method channel implementation
└── models/                           # Data models

android/
└── src/main/kotlin/
    └── info/thanhtunguet/flutter_telink_ble/
        ├── FlutterTelinkBlePlugin.kt      # Android implementation
        ├── FlutterEventHandler.kt         # Event handling
        ├── ConnectionManager.kt           # Connection management
        └── TelinkBleMeshLib/             # Telink Android SDK

ios/
└── Classes/
    └── FlutterTelinkBlePlugin.swift      # iOS implementation (coming soon)
```

## Platform-Specific Implementation

### Android

The Android implementation uses [TelinkBleMeshLib](https://github.com/telink-semi/telink_sig_mesh_sdk) with the following key components:

- **MeshService**: Core mesh network service
- **EventHandler**: Handles mesh events and streams them to Flutter
- **ConnectionManager**: Manages mesh connections with auto-reconnect
- **Parameter classes**: Configuration for various operations

### iOS

iOS implementation is in progress and will use TelinkSigMeshLib.

## Troubleshooting

### Android

**Scanning doesn't find devices:**
- Ensure Bluetooth and Location services are enabled
- Check that all required permissions are granted at runtime
- Verify BLE hardware support on the device

**Connection fails:**
- Ensure device is provisioned with correct network key
- Check that device is in range
- Verify mesh configuration matches the device's provisioning

**Build errors:**
- Ensure you're using Android API level 21 or higher
- Check that all dependencies are properly included
- Clean and rebuild: `flutter clean && flutter pub get`

### iOS

**Coming soon**

## Performance Tips

1. **Scanning**: Stop scanning when you find the device you need to save battery
2. **Commands**: Avoid sending commands too rapidly; allow time for responses
3. **Groups**: Use group addresses to control multiple devices efficiently
4. **OTA**: Ensure strong signal strength (RSSI > -70 dBm) for reliable OTA updates
5. **Connections**: Disconnect from mesh when not in use to save battery

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/thanhtunguet/flutter_telink_ble.git
cd flutter_telink_ble

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Telink Semiconductor](http://www.telink-semi.com/) for their BLE Mesh SDK
- The Flutter team for the excellent plugin infrastructure
- Contributors and testers who help improve this plugin

## Support

- 📖 [Documentation](https://github.com/thanhtunguet/flutter_telink_ble/wiki)
- 🐛 [Issue Tracker](https://github.com/thanhtunguet/flutter_telink_ble/issues)
- 💬 [Discussions](https://github.com/thanhtunguet/flutter_telink_ble/discussions)

## Related Resources

- [Bluetooth Mesh Specification](https://www.bluetooth.com/specifications/mesh-specifications/)
- [Telink BLE Mesh SDK](https://wiki.telink-semi.cn/wiki/chip-series/TLSR825x-Series/)
- [Flutter Plugin Development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)

---

Made with ❤️ by [Thanh Tung Pham](https://github.com/thanhtunguet)
