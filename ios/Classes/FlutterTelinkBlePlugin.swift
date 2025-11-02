import Flutter
import UIKit

public class FlutterTelinkBlePlugin: NSObject, FlutterPlugin {
    // Method channel
    private var methodChannel: FlutterMethodChannel?

    // Event channels and sinks
    private var scanEventChannel: FlutterEventChannel?
    private var scanEventSink: FlutterEventSink?

    private var connectionEventChannel: FlutterEventChannel?
    private var connectionEventSink: FlutterEventSink?

    private var otaEventChannel: FlutterEventChannel?
    private var otaEventSink: FlutterEventSink?

    private var messageEventChannel: FlutterEventChannel?
    private var messageEventSink: FlutterEventSink?

    // Mesh configuration
    private var isInitialized = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_telink_ble", binaryMessenger: registrar.messenger())
        let instance = FlutterTelinkBlePlugin()
        instance.methodChannel = channel

        // Setup event channels
        instance.scanEventChannel = FlutterEventChannel(name: "flutter_telink_ble/scan", binaryMessenger: registrar.messenger())
        instance.scanEventChannel?.setStreamHandler(ScanStreamHandler(plugin: instance))

        instance.connectionEventChannel = FlutterEventChannel(name: "flutter_telink_ble/connection", binaryMessenger: registrar.messenger())
        instance.connectionEventChannel?.setStreamHandler(ConnectionStreamHandler(plugin: instance))

        instance.otaEventChannel = FlutterEventChannel(name: "flutter_telink_ble/ota", binaryMessenger: registrar.messenger())
        instance.otaEventChannel?.setStreamHandler(OTAStreamHandler(plugin: instance))

        instance.messageEventChannel = FlutterEventChannel(name: "flutter_telink_ble/messages", binaryMessenger: registrar.messenger())
        instance.messageEventChannel?.setStreamHandler(MessageStreamHandler(plugin: instance))

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "initialize":
            handleInitialize(call: call, result: result)

        case "dispose":
            handleDispose(result: result)

        case "startScan":
            handleStartScan(call: call, result: result)

        case "stopScan":
            handleStopScan(result: result)

        case "provisionDevice":
            handleProvisionDevice(call: call, result: result)

        case "connectToMesh":
            handleConnectToMesh(call: call, result: result)

        case "disconnectFromMesh":
            handleDisconnectFromMesh(result: result)

        case "sendOnOffCommand":
            handleSendOnOffCommand(call: call, result: result)

        case "sendLevelCommand":
            handleSendLevelCommand(call: call, result: result)

        case "sendColorTemperatureCommand":
            handleSendColorTemperatureCommand(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Method Handlers

    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Configuration is required", details: nil))
            return
        }

        // Initialize SigMeshLib
        SDKLibCommand.startMeshSDK()

        // Configure mesh network
        if let networkKey = args["networkKey"] as? String,
           let netKeyIndex = args["netKeyIndex"] as? Int {
            // Setup network configuration
            // Note: Actual implementation would use SigDataSource to configure the mesh
            NSLog("Initializing mesh with netKeyIndex: \(netKeyIndex)")
        }

        isInitialized = true
        result(true)
    }

    private func handleDispose(result: @escaping FlutterResult) {
        // Cleanup mesh SDK
        isInitialized = false
        result(nil)
    }

    private func handleStartScan(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Plugin not initialized", details: nil))
            return
        }

        let timeout = (call.arguments as? [String: Any])?["timeout"] as? Int ?? 10

        // Start BLE scanning for unprovisioned devices
        // Note: This would use SigBluetooth or SigBearer to scan for devices
        NSLog("Starting scan with timeout: \(timeout)s")

        result(nil)
    }

    private func handleStopScan(result: @escaping FlutterResult) {
        // Stop BLE scanning
        NSLog("Stopping scan")
        result(nil)
    }

    private func handleProvisionDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Plugin not initialized", details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let address = args["address"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Device address is required", details: nil))
            return
        }

        NSLog("Starting provisioning for address: \(address)")

        // Use SigAddDeviceManager to provision the device
        // This would involve creating a SigAddConfigModel and calling startAddDeviceWithSigAddConfigModel

        result(nil)
    }

    private func handleConnectToMesh(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Plugin not initialized", details: nil))
            return
        }

        NSLog("Connecting to mesh network")
        // Start auto-connect to mesh proxy
        result(nil)
    }

    private func handleDisconnectFromMesh(result: @escaping FlutterResult) {
        NSLog("Disconnecting from mesh network")
        // Disconnect from mesh proxy
        result(nil)
    }

    private func handleSendOnOffCommand(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Plugin not initialized", details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let address = args["address"] as? Int,
              let isOn = args["isOn"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Address and isOn are required", details: nil))
            return
        }

        NSLog("Sending OnOff command to \(address): \(isOn)")

        // Use SDKLibCommand to send generic on/off message
        // SDKLibCommand.genericOnOffSet(destination:, isOn:, retryCount:, responseMaxCount:, ack:, successCallback:, resultCallback:)

        result(true)
    }

    private func handleSendLevelCommand(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Plugin not initialized", details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let address = args["address"] as? Int,
              let level = args["level"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Address and level are required", details: nil))
            return
        }

        NSLog("Sending Level command to \(address): \(level)")

        // Use SDKLibCommand to send lightness message
        result(true)
    }

    private func handleSendColorTemperatureCommand(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Plugin not initialized", details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let address = args["address"] as? Int,
              let temperature = args["temperature"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Address and temperature are required", details: nil))
            return
        }

        NSLog("Sending ColorTemperature command to \(address): \(temperature)")

        // Use SDKLibCommand to send CTL temperature message
        result(true)
    }
}

// MARK: - Event Stream Handlers

class ScanStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: FlutterTelinkBlePlugin?

    init(plugin: FlutterTelinkBlePlugin) {
        self.plugin = plugin
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.scanEventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.scanEventSink = nil
        return nil
    }
}

class ConnectionStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: FlutterTelinkBlePlugin?

    init(plugin: FlutterTelinkBlePlugin) {
        self.plugin = plugin
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.connectionEventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.connectionEventSink = nil
        return nil
    }
}

class OTAStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: FlutterTelinkBlePlugin?

    init(plugin: FlutterTelinkBlePlugin) {
        self.plugin = plugin
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.otaEventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.otaEventSink = nil
        return nil
    }
}

class MessageStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: FlutterTelinkBlePlugin?

    init(plugin: FlutterTelinkBlePlugin) {
        self.plugin = plugin
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.messageEventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.messageEventSink = nil
        return nil
    }
}
