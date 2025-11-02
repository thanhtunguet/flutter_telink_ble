/// Configuration for Telink mesh network initialization
class TelinkMeshConfig {
  /// Network key for mesh network encryption (16 bytes)
  final String networkKey;

  /// Network key index (0-4095)
  final int netKeyIndex;

  /// Application keys mapped by their indices
  final Map<int, String> appKeys;

  /// IV index for network freshness (32-bit value)
  final int ivIndex;

  /// Sequence number for message ordering
  final int sequenceNumber;

  /// Local address for this node (unicast address)
  final int localAddress;

  const TelinkMeshConfig({
    required this.networkKey,
    required this.netKeyIndex,
    required this.appKeys,
    required this.ivIndex,
    required this.sequenceNumber,
    required this.localAddress,
  });

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'networkKey': networkKey,
      'netKeyIndex': netKeyIndex,
      'appKeys': appKeys,
      'ivIndex': ivIndex,
      'sequenceNumber': sequenceNumber,
      'localAddress': localAddress,
    };
  }

  /// Create from map received from platform channel
  factory TelinkMeshConfig.fromMap(Map<String, dynamic> map) {
    return TelinkMeshConfig(
      networkKey: map['networkKey'] as String,
      netKeyIndex: map['netKeyIndex'] as int,
      appKeys: Map<int, String>.from(map['appKeys'] as Map),
      ivIndex: map['ivIndex'] as int,
      sequenceNumber: map['sequenceNumber'] as int,
      localAddress: map['localAddress'] as int,
    );
  }

  @override
  String toString() {
    return 'TelinkMeshConfig(networkKey: ${networkKey.substring(0, 8)}..., '
        'netKeyIndex: $netKeyIndex, appKeys: ${appKeys.length} keys, '
        'ivIndex: $ivIndex, sequenceNumber: $sequenceNumber, '
        'localAddress: 0x${localAddress.toRadixString(16)})';
  }
}
