
import 'flutter_telink_ble_platform_interface.dart';

class FlutterTelinkBle {
  Future<String?> getPlatformVersion() {
    return FlutterTelinkBlePlatform.instance.getPlatformVersion();
  }
}
