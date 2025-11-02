/// Result of a device provisioning operation
class ProvisionResult {
  /// Whether the provisioning was successful
  final bool success;

  /// Unicast address assigned to the device (if successful)
  final int? assignedAddress;

  /// Error message (if failed)
  final String? error;

  /// Time taken for provisioning in milliseconds
  final int? durationMs;

  const ProvisionResult({
    required this.success,
    this.assignedAddress,
    this.error,
    this.durationMs,
  });

  /// Create a successful result
  factory ProvisionResult.success({
    required int assignedAddress,
    int? durationMs,
  }) {
    return ProvisionResult(
      success: true,
      assignedAddress: assignedAddress,
      durationMs: durationMs,
    );
  }

  /// Create a failed result
  factory ProvisionResult.failure({
    required String error,
    int? durationMs,
  }) {
    return ProvisionResult(
      success: false,
      error: error,
      durationMs: durationMs,
    );
  }

  /// Create from map received from platform channel
  factory ProvisionResult.fromMap(Map<String, dynamic> map) {
    return ProvisionResult(
      success: map['success'] as bool,
      assignedAddress: map['assignedAddress'] as int?,
      error: map['error'] as String?,
      durationMs: map['durationMs'] as int?,
    );
  }

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'assignedAddress': assignedAddress,
      'error': error,
      'durationMs': durationMs,
    };
  }

  @override
  String toString() {
    if (success) {
      return 'ProvisionResult(success: true, '
          'address: 0x${assignedAddress?.toRadixString(16)}, '
          'duration: ${durationMs}ms)';
    } else {
      return 'ProvisionResult(success: false, error: $error)';
    }
  }
}
