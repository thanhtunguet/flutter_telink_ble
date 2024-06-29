import 'package:flutter_telink_ble/models/device.dart';
import 'package:flutter_telink_ble/models/device_type.dart';

class LightDevice extends Device {
  LightDevice({
    required super.id,
    required super.name,
    required super.traits,
  }) : super(
          type: DeviceType.light,
        );
}
