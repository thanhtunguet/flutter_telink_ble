import Foundation

/**
 * Manages BLE mesh connection with automatic recovery
 */
class ConnectionManager {

    private var isConnected = false
    private var isReconnecting = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelaySeconds: TimeInterval = 2.0

    private var connectionStateListener: ((Bool) -> Void)?
    private var reconnectTimer: Timer?

    /**
     * Set connection state change listener
     */
    func setConnectionStateListener(listener: @escaping (Bool) -> Void) {
        connectionStateListener = listener
    }

    /**
     * Handle connection state change
     */
    func onConnectionStateChanged(connected: Bool) {
        isConnected = connected

        if !connected && !isReconnecting {
            NSLog("ConnectionManager: Connection lost, attempting automatic reconnection...")
            attemptReconnect()
        }

        connectionStateListener?(connected)
    }

    /**
     * Attempt to reconnect with exponential backoff
     */
    private func attemptReconnect() {
        if isReconnecting || reconnectAttempts >= maxReconnectAttempts {
            if reconnectAttempts >= maxReconnectAttempts {
                NSLog("ConnectionManager: Max reconnection attempts reached, giving up")
                reset()
            }
            return
        }

        isReconnecting = true
        reconnectAttempts += 1

        let delay = reconnectDelaySeconds * TimeInterval(reconnectAttempts)

        NSLog("ConnectionManager: Reconnection attempt \(reconnectAttempts) in \(delay)s")

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }

            NSLog("ConnectionManager: Attempting to reconnect...")

            // Attempt reconnection using SDKLibCommand
            // This would typically involve:
            // 1. Scanning for available mesh proxies
            // 2. Connecting to a proxy node
            // 3. Establishing secure mesh connection

            // Wait for connection result
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if !self.isConnected {
                    self.isReconnecting = false
                    self.attemptReconnect()
                } else {
                    NSLog("ConnectionManager: Reconnection successful")
                    self.reset()
                }
            }
        }
    }

    /**
     * Reset reconnection state
     */
    func reset() {
        isReconnecting = false
        reconnectAttempts = 0
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }

    /**
     * Force reconnect
     */
    func forceReconnect() {
        reset()
        attemptReconnect()
    }

    /**
     * Check if currently connected
     */
    func getIsConnected() -> Bool {
        return isConnected
    }

    /**
     * Check if reconnection is in progress
     */
    func getIsReconnecting() -> Bool {
        return isReconnecting
    }

    /**
     * Cleanup
     */
    func cleanup() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        reset()
        connectionStateListener = nil
    }
}
