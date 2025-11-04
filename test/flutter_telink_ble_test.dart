import 'dart:async';
import 'dart:typed_data';
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
  final FlutterTelinkBlePlatform initialPlatform =
      FlutterTelinkBlePlatform.instance;

  test('$MethodChannelFlutterTelinkBle is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTelinkBle>());
  });

  test('getPlatformVersion', () async {
    FlutterTelinkBle flutterTelinkBlePlugin = FlutterTelinkBle();
    MockFlutterTelinkBlePlatform fakePlatform = MockFlutterTelinkBlePlatform();
    FlutterTelinkBlePlatform.instance = fakePlatform;

    expect(await flutterTelinkBlePlugin.getPlatformVersion(), '42');
  });

  group('Initialization Tests', () {
    late FlutterTelinkBle plugin;
    late MockFlutterTelinkBlePlatform fakePlatform;

    setUp(() {
      plugin = FlutterTelinkBle();
      fakePlatform = MockFlutterTelinkBlePlatform();
      FlutterTelinkBlePlatform.instance = fakePlatform;
    });

    test('initialize with valid config', () async {
      final config = TelinkMeshConfig(
        networkKey: 'test_network_key',
        netKeyIndex: 0,
        appKeys: {0: 'test_app_key'},
        ivIndex: 0,
        sequenceNumber: 0,
        localAddress: 1,
      );

      final result = await plugin.initialize(config);
      expect(result, true);
    });

    test('dispose cleans up resources', () async {
      await expectLater(plugin.dispose(), completes);
    });
  });

  group('Device Scanning Tests', () {
    late FlutterTelinkBle plugin;
    late MockFlutterTelinkBlePlatform fakePlatform;

    setUp(() {
      plugin = FlutterTelinkBle();
      fakePlatform = MockFlutterTelinkBlePlatform();
      FlutterTelinkBlePlatform.instance = fakePlatform;
    });

    test('scanForDevices returns stream', () {
      final stream = plugin.scanForDevices();
      expect(stream, isA<Stream<UnprovisionedDevice>>());
    });

    test('stopScan completes successfully', () async {
      await expectLater(plugin.stopScan(), completes);
    });
  });

  group('Device Provisioning Tests', () {
    late FlutterTelinkBle plugin;
    late MockFlutterTelinkBlePlatform fakePlatform;

    setUp(() {
      plugin = FlutterTelinkBle();
      fakePlatform = MockFlutterTelinkBlePlatform();
      FlutterTelinkBlePlatform.instance = fakePlatform;
    });

    test('provisionDevice returns success result', () async {
      final config = DeviceProvisionConfig(
        deviceUuid: 'test-uuid',
        unicastAddress: 10,
      );

      final result = await plugin.provisionDevice(config);
      expect(result.success, true);
      expect(result.assignedAddress, 1);
    });
  });

  group('Mesh Connection Tests', () {
    late FlutterTelinkBle plugin;
    late MockFlutterTelinkBlePlatform fakePlatform;

    setUp(() {
      plugin = FlutterTelinkBle();
      fakePlatform = MockFlutterTelinkBlePlatform();
      FlutterTelinkBlePlatform.instance = fakePlatform;
    });

    test('connectToMesh succeeds', () async {
      final result = await plugin.connectToMesh();
      expect(result, true);
    });

    test('disconnectFromMesh completes', () async {
      await expectLater(plugin.disconnectFromMesh(), completes);
    });

    test('connectionStateStream returns stream', () {
      final stream = plugin.connectionStateStream;
      expect(stream, isA<Stream<MeshConnectionStateEvent>>());
    });
  });

  group('Device Control Tests', () {
    late FlutterTelinkBle plugin;
    late MockFlutterTelinkBlePlatform fakePlatform;

    setUp(() {
      plugin = FlutterTelinkBle();
      fakePlatform = MockFlutterTelinkBlePlatform();
      FlutterTelinkBlePlatform.instance = fakePlatform;
    });

    test('sendOnOffCommand completes', () async {
      await expectLater(plugin.sendOnOffCommand(10, true), completes);
    });

    test('sendLevelCommand completes', () async {
      await expectLater(plugin.sendLevelCommand(10, 50), completes);
    });

    test('sendColorCommand completes', () async {
      await expectLater(
        plugin.sendColorCommand(10, const Color(0xFFFF0000)),
        completes,
      );
    });
  });

  group('Group Management Tests', () {
    late FlutterTelinkBle plugin;
    late MockFlutterTelinkBlePlatform fakePlatform;

    setUp(() {
      plugin = FlutterTelinkBle();
      fakePlatform = MockFlutterTelinkBlePlatform();
      FlutterTelinkBlePlatform.instance = fakePlatform;
    });

    test('addDeviceToGroup completes', () async {
      await expectLater(plugin.addDeviceToGroup(10, 0xC000), completes);
    });

    test('removeDeviceFromGroup completes', () async {
      await expectLater(plugin.removeDeviceFromGroup(10, 0xC000), completes);
    });
  });

  group('OTA Update Tests', () {
    late FlutterTelinkBle plugin;
    late MockFlutterTelinkBlePlatform fakePlatform;

    setUp(() {
      plugin = FlutterTelinkBle();
      fakePlatform = MockFlutterTelinkBlePlatform();
      FlutterTelinkBlePlatform.instance = fakePlatform;
    });

    test('startOTA completes', () async {
      final firmwareData = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
      await expectLater(plugin.startOTA(10, firmwareData), completes);
    });

    test('otaProgressStream returns stream', () {
      final stream = plugin.otaProgressStream;
      expect(stream, isA<Stream<OTAProgress>>());
    });
  });
}
