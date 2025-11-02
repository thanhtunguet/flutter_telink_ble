/// Configuration for provisioning a new device into the mesh network
class DeviceProvisionConfig {
  /// UUID of the device to provision
  final String deviceUuid;

  /// Unicast address to assign to the device (must be unique in network)
  final int unicastAddress;

  /// Network key index to use
  final int netKeyIndex;

  /// Application key index to bind
  final int appKeyIndex;

  /// Use fast provisioning (Telink private protocol) if supported
  final bool useFastProvisioning;

  /// Timeout for provisioning operation in seconds
  final int timeoutSeconds;

  const DeviceProvisionConfig({
    required this.deviceUuid,
    required this.unicastAddress,
    this.netKeyIndex = 0,
    this.appKeyIndex = 0,
    this.useFastProvisioning = false,
    this.timeoutSeconds = 60,
  });

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'deviceUuid': deviceUuid,
      'unicastAddress': unicastAddress,
      'netKeyIndex': netKeyIndex,
      'appKeyIndex': appKeyIndex,
      'useFastProvisioning': useFastProvisioning,
      'timeoutSeconds': timeoutSeconds,
    };
  }

  /// Create from map received from platform channel
  factory DeviceProvisionConfig.fromMap(Map<String, dynamic> map) {
    return DeviceProvisionConfig(
      deviceUuid: map['deviceUuid'] as String,
      unicastAddress: map['unicastAddress'] as int,
      netKeyIndex: map['netKeyIndex'] as int? ?? 0,
      appKeyIndex: map['appKeyIndex'] as int? ?? 0,
      useFastProvisioning: map['useFastProvisioning'] as bool? ?? false,
      timeoutSeconds: map['timeoutSeconds'] as int? ?? 60,
    );
  }

  @override
  String toString() {
    return 'DeviceProvisionConfig(uuid: ${deviceUuid.substring(0, 8)}..., '
        'address: 0x${unicastAddress.toRadixString(16)}, '
        'netKeyIndex: $netKeyIndex, appKeyIndex: $appKeyIndex, '
        'fastProvisioning: $useFastProvisioning)';
  }
}
