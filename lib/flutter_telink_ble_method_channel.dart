import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_telink_ble_platform_interface.dart';
import 'models/models.dart';

/// An implementation of [FlutterTelinkBlePlatform] that uses method channels.
class MethodChannelFlutterTelinkBle extends FlutterTelinkBlePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_telink_ble');

  /// Event channel for device scanning
  static const EventChannel _scanEventChannel =
      EventChannel('flutter_telink_ble/scan');

  /// Event channel for mesh connection state
  static const EventChannel _connectionEventChannel =
      EventChannel('flutter_telink_ble/connection');

  /// Event channel for OTA progress
  static const EventChannel _otaEventChannel =
      EventChannel('flutter_telink_ble/ota');

  // Stream controllers for event channels
  StreamController<UnprovisionedDevice>? _scanStreamController;
  StreamController<MeshConnectionStateEvent>? _connectionStreamController;
  StreamController<OTAProgress>? _otaStreamController;

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // Initialization and lifecycle

  @override
  Future<bool> initialize(TelinkMeshConfig config) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'initialize',
        config.toMap(),
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize: ${e.message}');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await methodChannel.invokeMethod<void>('dispose');
      // Clean up stream controllers
      await _scanStreamController?.close();
      await _connectionStreamController?.close();
      await _otaStreamController?.close();
      _scanStreamController = null;
      _connectionStreamController = null;
      _otaStreamController = null;
    } on PlatformException catch (e) {
      debugPrint('Failed to dispose: ${e.message}');
    }
  }

  // Device scanning and provisioning

  @override
  Stream<UnprovisionedDevice> scanForDevices() {
    _scanStreamController?.close();
    _scanStreamController = StreamController<UnprovisionedDevice>.broadcast(
      onCancel: () {
        stopScan();
      },
    );

    _scanEventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          try {
            final device = UnprovisionedDevice.fromMap(
              Map<String, dynamic>.from(event),
            );
            _scanStreamController?.add(device);
          } catch (e) {
            debugPrint('Error parsing scanned device: $e');
          }
        }
      },
      onError: (dynamic error) {
        debugPrint('Scan stream error: $error');
        _scanStreamController?.addError(error);
      },
      onDone: () {
        _scanStreamController?.close();
      },
    );

    return _scanStreamController!.stream;
  }

  @override
  Future<void> stopScan() async {
    try {
      await methodChannel.invokeMethod<void>('stopScan');
    } on PlatformException catch (e) {
      debugPrint('Failed to stop scan: ${e.message}');
    }
  }

  @override
  Future<ProvisionResult> provisionDevice(DeviceProvisionConfig config) async {
    try {
      final result = await methodChannel.invokeMethod<Map>(
        'provisionDevice',
        config.toMap(),
      );
      return ProvisionResult.fromMap(Map<String, dynamic>.from(result ?? {}));
    } on PlatformException catch (e) {
      return ProvisionResult.failure(error: e.message ?? 'Unknown error');
    }
  }

  // Network management

  @override
  Future<bool> connectToMesh() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('connectToMesh');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to connect to mesh: ${e.message}');
      return false;
    }
  }

  @override
  Future<void> disconnectFromMesh() async {
    try {
      await methodChannel.invokeMethod<void>('disconnectFromMesh');
    } on PlatformException catch (e) {
      debugPrint('Failed to disconnect from mesh: ${e.message}');
    }
  }

  @override
  Stream<MeshConnectionStateEvent> get connectionStateStream {
    _connectionStreamController?.close();
    _connectionStreamController =
        StreamController<MeshConnectionStateEvent>.broadcast();

    _connectionEventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          try {
            final stateEvent = MeshConnectionStateEvent.fromMap(
              Map<String, dynamic>.from(event),
            );
            _connectionStreamController?.add(stateEvent);
          } catch (e) {
            debugPrint('Error parsing connection state: $e');
          }
        }
      },
      onError: (dynamic error) {
        debugPrint('Connection stream error: $error');
        _connectionStreamController?.addError(error);
      },
      onDone: () {
        _connectionStreamController?.close();
      },
    );

    return _connectionStreamController!.stream;
  }

  // Device control

  @override
  Future<void> sendOnOffCommand(int address, bool isOn) async {
    try {
      await methodChannel.invokeMethod<void>('sendOnOffCommand', {
        'address': address,
        'isOn': isOn,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to send on/off command: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> sendLevelCommand(int address, int level) async {
    try {
      await methodChannel.invokeMethod<void>('sendLevelCommand', {
        'address': address,
        'level': level,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to send level command: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> sendColorCommand(int address, Color color) async {
    try {
      await methodChannel.invokeMethod<void>('sendColorCommand', {
        'address': address,
        'red': color.r,
        'green': color.g,
        'blue': color.b,
        'alpha': color.a,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to send color command: ${e.message}');
      rethrow;
    }
  }

  // Group management

  @override
  Future<void> addDeviceToGroup(int deviceAddress, int groupAddress) async {
    try {
      await methodChannel.invokeMethod<void>('addDeviceToGroup', {
        'deviceAddress': deviceAddress,
        'groupAddress': groupAddress,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to add device to group: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> removeDeviceFromGroup(
      int deviceAddress, int groupAddress) async {
    try {
      await methodChannel.invokeMethod<void>('removeDeviceFromGroup', {
        'deviceAddress': deviceAddress,
        'groupAddress': groupAddress,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to remove device from group: ${e.message}');
      rethrow;
    }
  }

  // OTA updates

  @override
  Future<void> startOTA(int deviceAddress, Uint8List firmwareData) async {
    try {
      await methodChannel.invokeMethod<void>('startOTA', {
        'deviceAddress': deviceAddress,
        'firmwareData': firmwareData,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to start OTA: ${e.message}');
      rethrow;
    }
  }

  @override
  Stream<OTAProgress> get otaProgressStream {
    _otaStreamController?.close();
    _otaStreamController = StreamController<OTAProgress>.broadcast();

    _otaEventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          try {
            final progress =
                OTAProgress.fromMap(Map<String, dynamic>.from(event));
            _otaStreamController?.add(progress);
          } catch (e) {
            debugPrint('Error parsing OTA progress: $e');
          }
        }
      },
      onError: (dynamic error) {
        debugPrint('OTA stream error: $error');
        _otaStreamController?.addError(error);
      },
      onDone: () {
        _otaStreamController?.close();
      },
    );

    return _otaStreamController!.stream;
  }
}
