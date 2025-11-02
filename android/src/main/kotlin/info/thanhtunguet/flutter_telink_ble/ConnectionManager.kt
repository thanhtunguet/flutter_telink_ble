package info.thanhtunguet.flutter_telink_ble

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.telink.ble.mesh.foundation.MeshService

/**
 * Manages BLE mesh connection with automatic recovery
 */
class ConnectionManager(private val meshService: MeshService) {

    private val TAG = "ConnectionManager"
    private val handler = Handler(Looper.getMainLooper())

    private var isConnected = false
    private var isReconnecting = false
    private var reconnectAttempts = 0
    private val maxReconnectAttempts = 5
    private val reconnectDelayMs = 2000L

    private var connectionStateListener: ((Boolean) -> Unit)? = null

    /**
     * Set connection state change listener
     */
    fun setConnectionStateListener(listener: (Boolean) -> Unit) {
        connectionStateListener = listener
    }

    /**
     * Handle connection state change
     */
    fun onConnectionStateChanged(connected: Boolean) {
        isConnected = connected

        if (!connected && !isReconnecting) {
            Log.w(TAG, "Connection lost, attempting automatic reconnection...")
            attemptReconnect()
        }

        connectionStateListener?.invoke(connected)
    }

    /**
     * Attempt to reconnect with exponential backoff
     */
    private fun attemptReconnect() {
        if (isReconnecting || reconnectAttempts >= maxReconnectAttempts) {
            if (reconnectAttempts >= maxReconnectAttempts) {
                Log.e(TAG, "Max reconnection attempts reached, giving up")
                reset()
            }
            return
        }

        isReconnecting = true
        reconnectAttempts++

        val delay = reconnectDelayMs * reconnectAttempts

        Log.d(TAG, "Reconnection attempt $reconnectAttempts in ${delay}ms")

        handler.postDelayed({
            try {
                Log.d(TAG, "Attempting to reconnect...")
                val connectParams = com.telink.ble.mesh.foundation.parameter.AutoConnectParameters()
                meshService.autoConnect(connectParams)

                // Wait for connection result
                handler.postDelayed({
                    if (!isConnected) {
                        isReconnecting = false
                        attemptReconnect()
                    } else {
                        Log.i(TAG, "Reconnection successful")
                        reset()
                    }
                }, 5000)

            } catch (e: Exception) {
                Log.e(TAG, "Reconnection attempt failed: ${e.message}")
                isReconnecting = false
                attemptReconnect()
            }
        }, delay)
    }

    /**
     * Reset reconnection state
     */
    fun reset() {
        isReconnecting = false
        reconnectAttempts = 0
    }

    /**
     * Force reconnect
     */
    fun forceReconnect() {
        reset()
        attemptReconnect()
    }

    /**
     * Check if currently connected
     */
    fun isConnected(): Boolean = isConnected

    /**
     * Check if reconnection is in progress
     */
    fun isReconnecting(): Boolean = isReconnecting

    /**
     * Cleanup
     */
    fun cleanup() {
        handler.removeCallbacksAndMessages(null)
        reset()
        connectionStateListener = null
    }
}
