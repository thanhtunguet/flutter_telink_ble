# Telink BLE Control Plugin

The Telink BLE Control Plugin allows you to connect to and control Bluetooth-enabled lights, sockets, and switches using the Telink BLE chipset. This plugin provides an easy-to-use interface for managing BLE devices and handling real-time status updates.

## Features

- Scan for BLE devices
- Connect and disconnect from devices
- Discover services and characteristics
- Read and write characteristic values
- Subscribe to and unsubscribe from characteristic notifications
- Control lights, sockets, and switches via BLE

## Installation

To install the plugin, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  telink_ble_control: ^1.0.0
```

Then, run `flutter pub get` to fetch the package.

## Usage

### Import the Plugin

```dart
import 'package:telink_ble_control/telink_ble_control.dart';
```

### Initialize the Plugin

Before using any BLE functionality, initialize the plugin:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TelinkBleControl.initialize();
  runApp(MyApp());
}
```

### Scan for Devices

Start scanning for BLE devices:

```dart
TelinkBleControl.startScan(timeout: Duration(seconds: 10));
```

Stop scanning:

```dart
TelinkBleControl.stopScan();
```

Listen for discovered devices:

```dart
TelinkBleControl.onDeviceDiscovered.listen((device) {
  print('Discovered device: ${device.name}');
});
```

### Connect to a Device

```dart
TelinkBleControl.connect(deviceId).then((_) {
  print('Connected to device: $deviceId');
}).catchError((error) {
  print('Failed to connect: $error');
});
```

### Disconnect from a Device

```dart
TelinkBleControl.disconnect(deviceId).then((_) {
  print('Disconnected from device: $deviceId');
}).catchError((error) {
  print('Failed to disconnect: $error');
});
```

### Discover Services and Characteristics

```dart
TelinkBleControl.discoverServices(deviceId).then((services) {
  services.forEach((service) {
    print('Service: ${service.id}');
  });
}).catchError((error) {
  print('Failed to discover services: $error');
});
```

### Read a Characteristic

```dart
TelinkBleControl.readCharacteristic(deviceId, serviceId, characteristicId).then((value) {
  print('Read value: $value');
}).catchError((error) {
  print('Failed to read characteristic: $error');
});
```

### Write a Characteristic

```dart
TelinkBleControl.writeCharacteristic(deviceId, serviceId, characteristicId, value).then((_) {
  print('Characteristic written');
}).catchError((error) {
  print('Failed to write characteristic: $error');
});
```

### Subscribe to Notifications

```dart
TelinkBleControl.subscribeToCharacteristic(deviceId, serviceId, characteristicId).then((_) {
  print('Subscribed to notifications');
}).catchError((error) {
  print('Failed to subscribe: $error');
});

TelinkBleControl.onCharacteristicNotified.listen((notification) {
  print('Notification received: ${notification.value}');
});
```

### Unsubscribe from Notifications

```dart
TelinkBleControl.unsubscribeFromCharacteristic(deviceId, serviceId, characteristicId).then((_) {
  print('Unsubscribed from notifications');
}).catchError((error) {
  print('Failed to unsubscribe: $error');
});
```

### Control Devices

#### Control Light

```dart
TelinkBleControl.controlLight(deviceId, LightCommand.turnOn()).then((_) {
  print('Light turned on');
}).catchError((error) {
  print('Failed to control light: $error');
});
```

#### Control Socket

```dart
TelinkBleControl.controlSocket(deviceId, SocketCommand.turnOff()).then((_) {
  print('Socket turned off');
}).catchError((error) {
  print('Failed to control socket: $error');
});
```

#### Control Switch

```dart
TelinkBleControl.controlSwitch(deviceId, SwitchCommand.toggle()).then((_) {
  print('Switch toggled');
}).catchError((error) {
  print('Failed to control switch: $error');
});
```

### Listen for Status Updates

#### Light Status

```dart
TelinkBleControl.onLightStatusChanged.listen((status) {
  print('Light status changed: $status');
});
```

#### Socket Status

```dart
TelinkBleControl.onSocketStatusChanged.listen((status) {
  print('Socket status changed: $status');
});
```

#### Switch Status

```dart
TelinkBleControl.onSwitchStatusChanged.listen((status) {
  print('Switch status changed: $status');
});
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```
