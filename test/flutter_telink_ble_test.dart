import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telink_ble/flutter_telink_ble.dart';
import 'package:flutter_telink_ble/flutter_telink_ble_platform_interface.dart';
import 'package:flutter_telink_ble/flutter_telink_ble_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTelinkBlePlatform
    with MockPlatformInterfaceMixin
    implements FlutterTelinkBlePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
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
