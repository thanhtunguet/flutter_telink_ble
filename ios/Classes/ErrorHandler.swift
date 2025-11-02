import Foundation
import Flutter

/**
 * Centralized error handling and recovery for Telink BLE operations
 */
class ErrorHandler {

    // Error codes
    static let ERROR_NOT_INITIALIZED = "NOT_INITIALIZED"
    static let ERROR_INVALID_ARGUMENT = "INVALID_ARGUMENT"
    static let ERROR_INIT_ERROR = "INIT_ERROR"
    static let ERROR_DISPOSE_ERROR = "DISPOSE_ERROR"
    static let ERROR_SCAN_ERROR = "SCAN_ERROR"
    static let ERROR_PROVISION_ERROR = "PROVISION_ERROR"
    static let ERROR_CONNECTION_ERROR = "CONNECTION_ERROR"
    static let ERROR_COMMAND_ERROR = "COMMAND_ERROR"
    static let ERROR_OTA_ERROR = "OTA_ERROR"
    static let ERROR_GROUP_ERROR = "GROUP_ERROR"
    static let ERROR_STORAGE_ERROR = "STORAGE_ERROR"
    static let ERROR_TIMEOUT = "TIMEOUT"
    static let ERROR_PERMISSION_DENIED = "PERMISSION_DENIED"
    static let ERROR_BLUETOOTH_OFF = "BLUETOOTH_OFF"
    static let ERROR_DEVICE_NOT_FOUND = "DEVICE_NOT_FOUND"

    /**
     * Handle error with automatic recovery attempt
     */
    static func handleError(
        error: Error,
        result: @escaping FlutterResult,
        errorCode: String = ERROR_COMMAND_ERROR,
        attemptRecovery: Bool = false,
        recoveryAction: (() -> Void)? = nil
    ) {
        NSLog("ErrorHandler: Error occurred: \(error.localizedDescription)")

        if attemptRecovery, let recovery = recoveryAction {
            NSLog("ErrorHandler: Attempting recovery...")
            do {
                recovery()
                return
            } catch {
                NSLog("ErrorHandler: Recovery failed: \(error.localizedDescription)")
            }
        }

        result(FlutterError(
            code: errorCode,
            message: error.localizedDescription,
            details: mapErrorDetails(error: error)
        ))
    }

    /**
     * Map error to detailed error information
     */
    private static func mapErrorDetails(error: Error) -> [String: Any] {
        let nsError = error as NSError
        return [
            "type": String(describing: type(of: error)),
            "domain": nsError.domain,
            "code": nsError.code,
            "timestamp": Date().timeIntervalSince1970
        ]
    }

    /**
     * Validate required parameters
     */
    static func validateParameters(
        params: [String: Any]?,
        requiredKeys: [String],
        result: @escaping FlutterResult
    ) -> Bool {
        guard let params = params else {
            result(FlutterError(
                code: ERROR_INVALID_ARGUMENT,
                message: "Parameters are required",
                details: nil
            ))
            return false
        }

        for key in requiredKeys {
            if params[key] == nil {
                result(FlutterError(
                    code: ERROR_INVALID_ARGUMENT,
                    message: "Parameter '\(key)' is required",
                    details: nil
                ))
                return false
            }
        }

        return true
    }

    /**
     * Execute with timeout and error handling
     */
    static func executeWithTimeout(
        timeoutSeconds: TimeInterval = 10.0,
        operation: @escaping () -> Void,
        onTimeout: @escaping () -> Void = {},
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        var isCompleted = false
        let lock = NSLock()

        queue.async {
            do {
                operation()
                lock.lock()
                isCompleted = true
                lock.unlock()
            } catch {
                onError(error)
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + timeoutSeconds) {
            lock.lock()
            let completed = isCompleted
            lock.unlock()

            if !completed {
                onTimeout()
            }
        }
    }

    /**
     * Retry operation with exponential backoff
     */
    static func retryWithBackoff(
        maxRetries: Int = 3,
        initialDelaySeconds: TimeInterval = 1.0,
        operation: @escaping () -> Bool,
        onSuccess: @escaping () -> Void = {},
        onFailure: @escaping () -> Void = {}
    ) {
        var attempt = 0
        var delay = initialDelaySeconds

        func attemptOperation() {
            if attempt >= maxRetries {
                onFailure()
                return
            }

            if operation() {
                onSuccess()
                return
            }

            attempt += 1
            NSLog("ErrorHandler: Retry attempt \(attempt) failed")

            if attempt < maxRetries {
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    delay *= 2 // Exponential backoff
                    attemptOperation()
                }
            } else {
                onFailure()
            }
        }

        attemptOperation()
    }
}
