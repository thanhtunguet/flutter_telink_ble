package info.thanhtunguet.flutter_telink_ble

import io.flutter.plugin.common.MethodChannel.Result

/**
 * Centralized error handling and recovery for Telink BLE operations
 */
object ErrorHandler {

    // Error codes
    const val ERROR_NOT_INITIALIZED = "NOT_INITIALIZED"
    const val ERROR_INVALID_ARGUMENT = "INVALID_ARGUMENT"
    const val ERROR_INIT_ERROR = "INIT_ERROR"
    const val ERROR_DISPOSE_ERROR = "DISPOSE_ERROR"
    const val ERROR_SCAN_ERROR = "SCAN_ERROR"
    const val ERROR_PROVISION_ERROR = "PROVISION_ERROR"
    const val ERROR_CONNECTION_ERROR = "CONNECTION_ERROR"
    const val ERROR_COMMAND_ERROR = "COMMAND_ERROR"
    const val ERROR_OTA_ERROR = "OTA_ERROR"
    const val ERROR_GROUP_ERROR = "GROUP_ERROR"
    const val ERROR_STORAGE_ERROR = "STORAGE_ERROR"
    const val ERROR_TIMEOUT = "TIMEOUT"
    const val ERROR_PERMISSION_DENIED = "PERMISSION_DENIED"
    const val ERROR_BLUETOOTH_OFF = "BLUETOOTH_OFF"
    const val ERROR_DEVICE_NOT_FOUND = "DEVICE_NOT_FOUND"

    /**
     * Handle error with automatic recovery attempt
     */
    fun handleError(
        error: Exception,
        result: Result,
        errorCode: String = ERROR_COMMAND_ERROR,
        attemptRecovery: Boolean = false,
        recoveryAction: (() -> Unit)? = null
    ) {
        android.util.Log.e("ErrorHandler", "Error occurred: ${error.message}", error)

        if (attemptRecovery && recoveryAction != null) {
            try {
                android.util.Log.d("ErrorHandler", "Attempting recovery...")
                recoveryAction.invoke()
                return
            } catch (e: Exception) {
                android.util.Log.e("ErrorHandler", "Recovery failed: ${e.message}", e)
            }
        }

        result.error(errorCode, error.message ?: "Unknown error", mapErrorDetails(error))
    }

    /**
     * Map exception to detailed error information
     */
    private fun mapErrorDetails(error: Exception): Map<String, Any> {
        return mapOf(
            "type" to error.javaClass.simpleName,
            "stackTrace" to (error.stackTrace.firstOrNull()?.toString() ?: ""),
            "timestamp" to System.currentTimeMillis()
        )
    }

    /**
     * Validate required parameters
     */
    fun validateParameters(
        params: Map<String, Any>?,
        requiredKeys: List<String>,
        result: Result
    ): Boolean {
        if (params == null) {
            result.error(ERROR_INVALID_ARGUMENT, "Parameters are required", null)
            return false
        }

        for (key in requiredKeys) {
            if (!params.containsKey(key) || params[key] == null) {
                result.error(ERROR_INVALID_ARGUMENT, "Parameter '$key' is required", null)
                return false
            }
        }

        return true
    }

    /**
     * Execute with timeout and error handling
     */
    fun executeWithTimeout(
        timeoutMs: Long = 10000,
        operation: () -> Unit,
        onTimeout: () -> Unit = {},
        onError: (Exception) -> Unit = {}
    ) {
        try {
            val thread = Thread {
                try {
                    operation()
                } catch (e: Exception) {
                    onError(e)
                }
            }

            thread.start()
            thread.join(timeoutMs)

            if (thread.isAlive) {
                thread.interrupt()
                onTimeout()
            }
        } catch (e: Exception) {
            onError(e)
        }
    }

    /**
     * Retry operation with exponential backoff
     */
    fun retryWithBackoff(
        maxRetries: Int = 3,
        initialDelayMs: Long = 1000,
        operation: () -> Boolean,
        onSuccess: () -> Unit = {},
        onFailure: () -> Unit = {}
    ) {
        var attempt = 0
        var delay = initialDelayMs

        while (attempt < maxRetries) {
            try {
                if (operation()) {
                    onSuccess()
                    return
                }
            } catch (e: Exception) {
                android.util.Log.w("ErrorHandler", "Retry attempt $attempt failed: ${e.message}")
            }

            attempt++
            if (attempt < maxRetries) {
                Thread.sleep(delay)
                delay *= 2 // Exponential backoff
            }
        }

        onFailure()
    }
}
