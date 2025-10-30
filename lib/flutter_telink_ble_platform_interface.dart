import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_telink_ble_method_channel.dart';

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
}
