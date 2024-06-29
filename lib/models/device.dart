import 'package:flutter_telink_ble/models/device_type.dart';
import 'package:flutter_telink_ble/models/trait.dart';

abstract class Device {
  final String id;
  final String name;
  final DeviceType type;
  final List<Trait> traits;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.traits,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString().split('.').last,
        'traits': traits.map((trait) => trait.getTraitName()).toList(),
      };

  @override
  String toString() =>
      'Device(id: $id, name: $name, type: $type, traits: $traits)';
}
