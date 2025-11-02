import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_telink_ble_method_channel.dart';
import 'models/models.dart';

abstract class FlutterTelinkBlePlatform extends PlatformInterface {
  /// Constructs a FlutterTelinkBlePlatform.
  FlutterTelinkBlePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTelinkBlePlatform _instance = MethodChannelFlutterTelinkBle();

  /// The default instance of [FlutterTelinkBlePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTelinkBle].
  static FlutterTelinkBlePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTelinkBlePlatform] when
  /// they register themselves.
  static set instance(FlutterTelinkBlePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // Initialization and lifecycle

  Future<bool> initialize(TelinkMeshConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  // Device scanning and provisioning

  Stream<UnprovisionedDevice> scanForDevices() {
    throw UnimplementedError('scanForDevices() has not been implemented.');
  }

  Future<void> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Future<ProvisionResult> provisionDevice(DeviceProvisionConfig config) {
    throw UnimplementedError('provisionDevice() has not been implemented.');
  }

  // Network management

  Future<bool> connectToMesh() {
    throw UnimplementedError('connectToMesh() has not been implemented.');
  }

  Future<void> disconnectFromMesh() {
    throw UnimplementedError('disconnectFromMesh() has not been implemented.');
  }

  Stream<MeshConnectionStateEvent> get connectionStateStream {
    throw UnimplementedError(
        'connectionStateStream has not been implemented.');
  }

  // Device control

  Future<void> sendOnOffCommand(int address, bool isOn) {
    throw UnimplementedError('sendOnOffCommand() has not been implemented.');
  }

  Future<void> sendLevelCommand(int address, int level) {
    throw UnimplementedError('sendLevelCommand() has not been implemented.');
  }

  Future<void> sendColorCommand(int address, Color color) {
    throw UnimplementedError('sendColorCommand() has not been implemented.');
  }

  // Group management

  Future<void> addDeviceToGroup(int deviceAddress, int groupAddress) {
    throw UnimplementedError('addDeviceToGroup() has not been implemented.');
  }

  Future<void> removeDeviceFromGroup(int deviceAddress, int groupAddress) {
    throw UnimplementedError(
        'removeDeviceFromGroup() has not been implemented.');
  }

  // OTA updates

  Future<void> startOTA(int deviceAddress, Uint8List firmwareData) {
    throw UnimplementedError('startOTA() has not been implemented.');
  }

  Stream<OTAProgress> get otaProgressStream {
    throw UnimplementedError('otaProgressStream has not been implemented.');
  }
}
