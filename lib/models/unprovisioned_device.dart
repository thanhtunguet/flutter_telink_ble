/// Represents an unprovisioned BLE mesh device discovered during scanning
class UnprovisionedDevice {
  /// Device UUID (unique identifier)
  final String uuid;

  /// Device name (may be empty)
  final String name;

  /// Signal strength in dBm
  final int rssi;

  /// Advertisement data from BLE scan
  final Map<String, dynamic> advertisementData;

  /// MAC address (if available)
  final String? macAddress;

  const UnprovisionedDevice({
    required this.uuid,
    required this.name,
    required this.rssi,
    required this.advertisementData,
    this.macAddress,
  });

  /// Create from map received from platform channel
  factory UnprovisionedDevice.fromMap(Map<String, dynamic> map) {
    return UnprovisionedDevice(
      uuid: map['uuid'] as String,
      name: map['name'] as String? ?? '',
      rssi: map['rssi'] as int,
      advertisementData:
          Map<String, dynamic>.from(map['advertisementData'] as Map? ?? {}),
      macAddress: map['macAddress'] as String?,
    );
  }

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'rssi': rssi,
      'advertisementData': advertisementData,
      'macAddress': macAddress,
    };
  }

  @override
  String toString() {
    return 'UnprovisionedDevice(name: $name, uuid: ${uuid.substring(0, 8)}..., '
        'rssi: $rssi dBm, mac: $macAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UnprovisionedDevice && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}
