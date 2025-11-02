import 'dart:typed_data';

/// Represents the state of an OTA (Over-The-Air) update
enum OTAState {
  /// OTA update is preparing
  preparing,

  /// OTA update is in progress
  inProgress,

  /// OTA update completed successfully
  completed,

  /// OTA update failed
  failed,

  /// OTA update was cancelled
  cancelled;

  /// Create from string value
  static OTAState fromString(String value) {
    return OTAState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => OTAState.preparing,
    );
  }

  /// Convert to string for platform channel communication
  String toValue() => name;
}

/// Progress information for an OTA update operation
class OTAProgress {
  /// Target device address
  final int deviceAddress;

  /// Current state of the OTA update
  final OTAState state;

  /// Progress percentage (0-100)
  final int progressPercent;

  /// Number of bytes transferred
  final int bytesTransferred;

  /// Total number of bytes to transfer
  final int totalBytes;

  /// Error message if state is failed
  final String? error;

  /// Estimated time remaining in seconds
  final int? estimatedSecondsRemaining;

  const OTAProgress({
    required this.deviceAddress,
    required this.state,
    this.progressPercent = 0,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.error,
    this.estimatedSecondsRemaining,
  });

  /// Create from map received from platform channel
  factory OTAProgress.fromMap(Map<String, dynamic> map) {
    return OTAProgress(
      deviceAddress: map['deviceAddress'] as int,
      state: OTAState.fromString(map['state'] as String),
      progressPercent: map['progressPercent'] as int? ?? 0,
      bytesTransferred: map['bytesTransferred'] as int? ?? 0,
      totalBytes: map['totalBytes'] as int? ?? 0,
      error: map['error'] as String?,
      estimatedSecondsRemaining: map['estimatedSecondsRemaining'] as int?,
    );
  }

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'deviceAddress': deviceAddress,
      'state': state.name,
      'progressPercent': progressPercent,
      'bytesTransferred': bytesTransferred,
      'totalBytes': totalBytes,
      'error': error,
      'estimatedSecondsRemaining': estimatedSecondsRemaining,
    };
  }

  @override
  String toString() {
    return 'OTAProgress(address: 0x${deviceAddress.toRadixString(16)}, '
        'state: $state, progress: $progressPercent%, '
        'bytes: $bytesTransferred/$totalBytes, error: $error)';
  }
}

/// Configuration for starting an OTA update
class OTAConfig {
  /// Target device address
  final int deviceAddress;

  /// Firmware data to upload
  final Uint8List firmwareData;

  /// Use mesh OTA instead of GATT OTA
  final bool useMeshOta;

  /// Timeout for OTA operation in seconds
  final int timeoutSeconds;

  const OTAConfig({
    required this.deviceAddress,
    required this.firmwareData,
    this.useMeshOta = false,
    this.timeoutSeconds = 300,
  });

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'deviceAddress': deviceAddress,
      'firmwareData': firmwareData,
      'useMeshOta': useMeshOta,
      'timeoutSeconds': timeoutSeconds,
    };
  }

  @override
  String toString() {
    return 'OTAConfig(address: 0x${deviceAddress.toRadixString(16)}, '
        'firmwareSize: ${firmwareData.length} bytes, '
        'useMeshOta: $useMeshOta)';
  }
}
