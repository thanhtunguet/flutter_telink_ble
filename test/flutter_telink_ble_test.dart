import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telink_ble/flutter_telink_ble.dart';
import 'package:flutter_telink_ble/flutter_telink_ble_platform_interface.dart';
import 'package:flutter_telink_ble/flutter_telink_ble_method_channel.dart';
import 'package:flutter_telink_ble/models/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTelinkBlePlatform
    with MockPlatformInterfaceMixin
    implements FlutterTelinkBlePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> initialize(TelinkMeshConfig config) => Future.value(true);

  @override
  Future<void> dispose() => Future.value();

  @override
  Stream<UnprovisionedDevice> scanForDevices() => Stream.empty();

  @override
  Future<void> stopScan() => Future.value();

  @override
  Future<ProvisionResult> provisionDevice(DeviceProvisionConfig config) =>
      Future.value(ProvisionResult.success(assignedAddress: 1));

  @override
  Future<bool> connectToMesh() => Future.value(true);

  @override
  Future<void> disconnectFromMesh() => Future.value();

  @override
  Stream<MeshConnectionStateEvent> get connectionStateStream => Stream.empty();

  @override
  Future<void> sendOnOffCommand(int address, bool isOn) => Future.value();

  @override
  Future<void> sendLevelCommand(int address, int level) => Future.value();

  @override
  Future<void> sendColorCommand(int address, Color color) => Future.value();

  @override
  Future<void> addDeviceToGroup(int deviceAddress, int groupAddress) =>
      Future.value();

  @override
  Future<void> removeDeviceFromGroup(int deviceAddress, int groupAddress) =>
      Future.value();

  @override
  Future<void> startOTA(int deviceAddress, dynamic firmwareData) =>
      Future.value();

  @override
  Stream<OTAProgress> get otaProgressStream => Stream.empty();
}

void main() {
  final FlutterTelinkBlePlatform initialPlatform = FlutterTelinkBlePlatform.instance;

  test('$MethodChannelFlutterTelinkBle is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTelinkBle>());
  });

  test('getPlatformVersion', () async {
    FlutterTelinkBle flutterTelinkBlePlugin = FlutterTelinkBle();
    MockFlutterTelinkBlePlatform fakePlatform = MockFlutterTelinkBlePlatform();
    FlutterTelinkBlePlatform.instance = fakePlatform;

    expect(await flutterTelinkBlePlugin.getPlatformVersion(), '42');
  });
}
