/// Represents the connection state of the mesh network
enum MeshConnectionState {
  /// Not connected to any mesh network
  disconnected,

  /// Attempting to connect to mesh network
  connecting,

  /// Successfully connected to mesh network
  connected,

  /// Connection is being terminated
  disconnecting,

  /// Connection failed or encountered an error
  error;

  /// Create from string value
  static MeshConnectionState fromString(String value) {
    return MeshConnectionState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => MeshConnectionState.disconnected,
    );
  }

  /// Convert to string for platform channel communication
  String toValue() => name;
}

/// Event containing mesh connection state and optional details
class MeshConnectionStateEvent {
  /// Current connection state
  final MeshConnectionState state;

  /// Error message if state is error
  final String? error;

  /// Additional information about the state
  final String? details;

  const MeshConnectionStateEvent({
    required this.state,
    this.error,
    this.details,
  });

  /// Create from map received from platform channel
  factory MeshConnectionStateEvent.fromMap(Map<String, dynamic> map) {
    return MeshConnectionStateEvent(
      state: MeshConnectionState.fromString(map['state'] as String),
      error: map['error'] as String?,
      details: map['details'] as String?,
    );
  }

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'state': state.name,
      'error': error,
      'details': details,
    };
  }

  @override
  String toString() {
    if (state == MeshConnectionState.error && error != null) {
      return 'MeshConnectionStateEvent(state: $state, error: $error)';
    }
    return 'MeshConnectionStateEvent(state: $state, details: $details)';
  }
}
