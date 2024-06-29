import 'package:flutter_telink_ble/models/device.dart';
import 'package:flutter_telink_ble/models/device_type.dart';

class SocketDevice extends Device {
  SocketDevice({
    required super.id,
    required super.name,
    required super.traits,
  }) : super(type: DeviceType.socket);
}
