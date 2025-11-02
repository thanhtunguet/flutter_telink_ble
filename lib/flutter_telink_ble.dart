import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'flutter_telink_ble_platform_interface.dart';
import 'models/models.dart';

/// Main plugin class for Flutter Telink BLE mesh operations
class FlutterTelinkBle {
  /// Singleton instance
  static final FlutterTelinkBle _instance = FlutterTelinkBle._internal();

  /// Factory constructor returns the singleton instance
  factory FlutterTelinkBle() => _instance;

  FlutterTelinkBle._internal();

  /// Get the platform version (for testing)
  Future<String?> getPlatformVersion() {
    return FlutterTelinkBlePlatform.instance.getPlatformVersion();
  }

  /// Initialize the Telink mesh network with the given configuration
  ///
  /// Returns true if initialization was successful
  Future<bool> initialize(TelinkMeshConfig config) {
    return FlutterTelinkBlePlatform.instance.initialize(config);
  }

  /// Dispose and cleanup mesh network resources
  Future<void> dispose() {
    return FlutterTelinkBlePlatform.instance.dispose();
  }

  // Device scanning and provisioning

  /// Start scanning for unprovisioned BLE mesh devices
  ///
  /// Returns a stream of discovered devices
  Stream<UnprovisionedDevice> scanForDevices() {
    return FlutterTelinkBlePlatform.instance.scanForDevices();
  }

  /// Stop the ongoing device scan
  Future<void> stopScan() {
    return FlutterTelinkBlePlatform.instance.stopScan();
  }

  /// Provision a device into the mesh network
  ///
  /// [config] - Configuration for the provisioning operation
  /// Returns the result of the provisioning operation
  Future<ProvisionResult> provisionDevice(DeviceProvisionConfig config) {
    return FlutterTelinkBlePlatform.instance.provisionDevice(config);
  }

  // Network management

  /// Connect to the mesh network
  ///
  /// Returns true if connection was successful
  Future<bool> connectToMesh() {
    return FlutterTelinkBlePlatform.instance.connectToMesh();
  }

  /// Disconnect from the mesh network
  Future<void> disconnectFromMesh() {
    return FlutterTelinkBlePlatform.instance.disconnectFromMesh();
  }

  /// Stream of mesh connection state changes
  Stream<MeshConnectionStateEvent> get connectionStateStream {
    return FlutterTelinkBlePlatform.instance.connectionStateStream;
  }

  // Device control

  /// Send an on/off command to a device or group
  ///
  /// [address] - Unicast or group address
  /// [isOn] - true to turn on, false to turn off
  Future<void> sendOnOffCommand(int address, bool isOn) {
    return FlutterTelinkBlePlatform.instance.sendOnOffCommand(address, isOn);
  }

  /// Send a level control command to a device or group
  ///
  /// [address] - Unicast or group address
  /// [level] - Level value (0-100)
  Future<void> sendLevelCommand(int address, int level) {
    return FlutterTelinkBlePlatform.instance.sendLevelCommand(address, level);
  }

  /// Send a color control command to a device or group
  ///
  /// [address] - Unicast or group address
  /// [color] - Color to set
  Future<void> sendColorCommand(int address, Color color) {
    return FlutterTelinkBlePlatform.instance.sendColorCommand(address, color);
  }

  // Group management

  /// Add a device to a group
  ///
  /// [deviceAddress] - Unicast address of the device
  /// [groupAddress] - Group address to add the device to
  Future<void> addDeviceToGroup(int deviceAddress, int groupAddress) {
    return FlutterTelinkBlePlatform.instance
        .addDeviceToGroup(deviceAddress, groupAddress);
  }

  /// Remove a device from a group
  ///
  /// [deviceAddress] - Unicast address of the device
  /// [groupAddress] - Group address to remove the device from
  Future<void> removeDeviceFromGroup(int deviceAddress, int groupAddress) {
    return FlutterTelinkBlePlatform.instance
        .removeDeviceFromGroup(deviceAddress, groupAddress);
  }

  // OTA updates

  /// Start an OTA (Over-The-Air) firmware update
  ///
  /// [deviceAddress] - Unicast address of the device to update
  /// [firmwareData] - Firmware binary data
  Future<void> startOTA(int deviceAddress, Uint8List firmwareData) {
    return FlutterTelinkBlePlatform.instance
        .startOTA(deviceAddress, firmwareData);
  }

  /// Stream of OTA progress updates
  Stream<OTAProgress> get otaProgressStream {
    return FlutterTelinkBlePlatform.instance.otaProgressStream;
  }
}
