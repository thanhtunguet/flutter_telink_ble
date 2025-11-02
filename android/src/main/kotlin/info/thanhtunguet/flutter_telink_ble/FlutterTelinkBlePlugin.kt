package info.thanhtunguet.flutter_telink_ble

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.telink.ble.mesh.core.message.generic.OnOffSetMessage
import com.telink.ble.mesh.core.message.lighting.CtlTemperatureSetMessage
import com.telink.ble.mesh.core.message.lighting.LightnessSetMessage
import com.telink.ble.mesh.foundation.MeshConfiguration
import com.telink.ble.mesh.foundation.MeshService
import com.telink.ble.mesh.foundation.parameter.ProvisioningParameters
import com.telink.ble.mesh.foundation.parameter.ScanParameters
import com.telink.ble.mesh.foundation.parameter.AutoConnectParameters
import com.telink.ble.mesh.util.Arrays
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterTelinkBlePlugin */
class FlutterTelinkBlePlugin: FlutterPlugin, MethodCallHandler {
  private val TAG = "FlutterTelinkBlePlugin"

  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  /// Event channels for streaming data
  private lateinit var scanEventChannel: EventChannel
  private lateinit var connectionEventChannel: EventChannel
  private lateinit var otaEventChannel: EventChannel
  private lateinit var messageEventChannel: EventChannel

  /// Event handler for mesh events
  private val eventHandler = FlutterEventHandler()

  /// Mesh service instance
  private val meshService: MeshService
    get() = MeshService.getInstance()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    // Setup method channel
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_telink_ble")
    channel.setMethodCallHandler(this)

    // Setup event channels
    scanEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_telink_ble/scan")
    scanEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventHandler.scanEventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventHandler.scanEventSink = null
      }
    })

    connectionEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_telink_ble/connection")
    connectionEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventHandler.connectionEventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventHandler.connectionEventSink = null
      }
    })

    otaEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_telink_ble/ota")
    otaEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventHandler.otaEventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventHandler.otaEventSink = null
      }
    })

    messageEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_telink_ble/messages")
    messageEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventHandler.messageEventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventHandler.messageEventSink = null
      }
    })
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "initialize" -> initialize(call, result)
      "dispose" -> dispose(result)
      "startScan" -> startScan(call, result)
      "stopScan" -> stopScan(result)
      "provisionDevice" -> provisionDevice(call, result)
      "connectToMesh" -> connectToMesh(call, result)
      "disconnectFromMesh" -> disconnectFromMesh(result)
      "sendOnOffCommand" -> sendOnOffCommand(call, result)
      "sendLevelCommand" -> sendLevelCommand(call, result)
      "sendColorTemperatureCommand" -> sendColorTemperatureCommand(call, result)
      "startOTA" -> startOTA(call, result)
      "stopOTA" -> stopOTA(result)
      "addDeviceToGroup" -> addDeviceToGroup(call, result)
      "removeDeviceFromGroup" -> removeDeviceFromGroup(call, result)
      "createGroup" -> createGroup(call, result)
      "deleteGroup" -> deleteGroup(call, result)
      "saveMeshConfiguration" -> saveMeshConfiguration(call, result)
      "loadMeshConfiguration" -> loadMeshConfiguration(result)
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(call: MethodCall, result: Result) {
    try {
      val config = call.arguments as? Map<String, Any>
      if (config == null) {
        result.error("INVALID_ARGUMENT", "Configuration is required", null)
        return
      }

      // Initialize mesh service
      meshService.init(context, eventHandler)

      // Setup mesh network configuration
      val meshConfig = createMeshConfiguration(config)
      meshService.setupMeshNetwork(meshConfig)

      Log.d(TAG, "Mesh service initialized successfully")
      result.success(true)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to initialize mesh service", e)
      result.error("INIT_ERROR", "Failed to initialize: ${e.message}", null)
    }
  }

  private fun dispose(result: Result) {
    try {
      meshService.clear()
      Log.d(TAG, "Mesh service disposed")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to dispose mesh service", e)
      result.error("DISPOSE_ERROR", "Failed to dispose: ${e.message}", null)
    }
  }

  private fun startScan(call: MethodCall, result: Result) {
    try {
      val timeout = (call.argument<Int>("timeout") ?: 10) * 1000 // Convert to milliseconds

      val scanParams = ScanParameters.getDefault(false, false)
      scanParams.setScanTimeout(timeout.toLong())

      meshService.startScan(scanParams)
      Log.d(TAG, "Scan started with timeout: ${timeout}ms")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to start scan", e)
      result.error("SCAN_ERROR", "Failed to start scan: ${e.message}", null)
    }
  }

  private fun stopScan(result: Result) {
    try {
      meshService.stopScan()
      Log.d(TAG, "Scan stopped")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to stop scan", e)
      result.error("SCAN_ERROR", "Failed to stop scan: ${e.message}", null)
    }
  }

  private fun provisionDevice(call: MethodCall, result: Result) {
    try {
      val params = call.arguments as? Map<String, Any>
      if (params == null) {
        result.error("INVALID_ARGUMENT", "Provisioning parameters are required", null)
        return
      }

      val address = params["address"] as? Int
      val uuid = params["uuid"] as? String

      if (address == null) {
        result.error("INVALID_ARGUMENT", "Device address is required", null)
        return
      }

      // Create a provisioning device using constructor
      val provisioningDevice = com.telink.ble.mesh.entity.ProvisioningDevice(
        null, // BluetoothDevice - will be set during scan
        parseUUID(uuid),
        address
      )

      val provisioningParams = ProvisioningParameters(provisioningDevice)
      meshService.startProvisioning(provisioningParams)

      Log.d(TAG, "Provisioning started for address: $address")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to start provisioning", e)
      result.error("PROVISION_ERROR", "Failed to provision device: ${e.message}", null)
    }
  }

  private fun connectToMesh(call: MethodCall, result: Result) {
    try {
      val connectParams = AutoConnectParameters()
      meshService.autoConnect(connectParams)

      Log.d(TAG, "Auto connect started")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to connect to mesh", e)
      result.error("CONNECTION_ERROR", "Failed to connect: ${e.message}", null)
    }
  }

  private fun disconnectFromMesh(result: Result) {
    try {
      meshService.idle(true)
      Log.d(TAG, "Disconnected from mesh")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to disconnect", e)
      result.error("CONNECTION_ERROR", "Failed to disconnect: ${e.message}", null)
    }
  }

  private fun sendOnOffCommand(call: MethodCall, result: Result) {
    try {
      val address = call.argument<Int>("address")
      val isOn = call.argument<Boolean>("isOn")

      if (address == null || isOn == null) {
        result.error("INVALID_ARGUMENT", "Address and isOn are required", null)
        return
      }

      val message = OnOffSetMessage.getSimple(address, 0, if (isOn) 1 else 0, true, 0)
      val sent = meshService.sendMeshMessage(message)

      Log.d(TAG, "OnOff command sent to $address: $isOn, result: $sent")
      result.success(sent)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to send OnOff command", e)
      result.error("COMMAND_ERROR", "Failed to send command: ${e.message}", null)
    }
  }

  private fun sendLevelCommand(call: MethodCall, result: Result) {
    try {
      val address = call.argument<Int>("address")
      val level = call.argument<Int>("level")

      if (address == null || level == null) {
        result.error("INVALID_ARGUMENT", "Address and level are required", null)
        return
      }

      val message = LightnessSetMessage.getSimple(address, 0, level, true, 0)
      val sent = meshService.sendMeshMessage(message)

      Log.d(TAG, "Level command sent to $address: $level, result: $sent")
      result.success(sent)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to send level command", e)
      result.error("COMMAND_ERROR", "Failed to send command: ${e.message}", null)
    }
  }

  private fun sendColorTemperatureCommand(call: MethodCall, result: Result) {
    try {
      val address = call.argument<Int>("address")
      val temperature = call.argument<Int>("temperature")

      if (address == null || temperature == null) {
        result.error("INVALID_ARGUMENT", "Address and temperature are required", null)
        return
      }

      val message = CtlTemperatureSetMessage.getSimple(address, 0, temperature, 0, true, 0)
      val sent = meshService.sendMeshMessage(message)

      Log.d(TAG, "Color temperature command sent to $address: $temperature, result: $sent")
      result.success(sent)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to send color temperature command", e)
      result.error("COMMAND_ERROR", "Failed to send command: ${e.message}", null)
    }
  }

  private fun startOTA(call: MethodCall, result: Result) {
    try {
      val params = call.arguments as? Map<String, Any>
      if (params == null) {
        result.error("INVALID_ARGUMENT", "OTA parameters are required", null)
        return
      }

      val deviceAddress = params["deviceAddress"] as? Int
      val firmwareData = params["firmwareData"] as? ByteArray

      if (deviceAddress == null || firmwareData == null) {
        result.error("INVALID_ARGUMENT", "Device address and firmware data are required", null)
        return
      }

      // Create connection filter for the target device
      val connectionFilter = com.telink.ble.mesh.entity.ConnectionFilter(
        com.telink.ble.mesh.entity.ConnectionFilter.TYPE_MESH_ADDRESS,
        deviceAddress
      )

      val otaParams = com.telink.ble.mesh.foundation.parameter.GattOtaParameters(connectionFilter, firmwareData)
      meshService.startGattOta(otaParams)

      Log.d(TAG, "OTA started for device: $deviceAddress, firmware size: ${firmwareData.size}")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to start OTA", e)
      result.error("OTA_ERROR", "Failed to start OTA: ${e.message}", null)
    }
  }

  private fun stopOTA(result: Result) {
    try {
      meshService.stopMeshOta()
      Log.d(TAG, "OTA stopped")
      result.success(null)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to stop OTA", e)
      result.error("OTA_ERROR", "Failed to stop OTA: ${e.message}", null)
    }
  }

  private fun addDeviceToGroup(call: MethodCall, result: Result) {
    try {
      val params = call.arguments as? Map<String, Any>
      if (params == null) {
        result.error("INVALID_ARGUMENT", "Parameters are required", null)
        return
      }

      val deviceAddress = params["deviceAddress"] as? Int
      val groupAddress = params["groupAddress"] as? Int

      if (deviceAddress == null || groupAddress == null) {
        result.error("INVALID_ARGUMENT", "Device address and group address are required", null)
        return
      }

      val message = com.telink.ble.mesh.core.message.config.ModelSubscriptionSetMessage.getSimple(
        deviceAddress,
        com.telink.ble.mesh.core.message.config.ModelSubscriptionSetMessage.MODE_ADD,
        deviceAddress,
        groupAddress,
        0x1000, // Generic OnOff Server model
        true    // isSig
      )

      val sent = meshService.sendMeshMessage(message)

      Log.d(TAG, "Add device $deviceAddress to group $groupAddress: $sent")
      result.success(sent)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to add device to group", e)
      result.error("GROUP_ERROR", "Failed to add device to group: ${e.message}", null)
    }
  }

  private fun removeDeviceFromGroup(call: MethodCall, result: Result) {
    try {
      val params = call.arguments as? Map<String, Any>
      if (params == null) {
        result.error("INVALID_ARGUMENT", "Parameters are required", null)
        return
      }

      val deviceAddress = params["deviceAddress"] as? Int
      val groupAddress = params["groupAddress"] as? Int

      if (deviceAddress == null || groupAddress == null) {
        result.error("INVALID_ARGUMENT", "Device address and group address are required", null)
        return
      }

      val message = com.telink.ble.mesh.core.message.config.ModelSubscriptionSetMessage.getSimple(
        deviceAddress,
        com.telink.ble.mesh.core.message.config.ModelSubscriptionSetMessage.MODE_DELETE,
        deviceAddress,
        groupAddress,
        0x1000, // Generic OnOff Server model
        true    // isSig
      )

      val sent = meshService.sendMeshMessage(message)

      Log.d(TAG, "Remove device $deviceAddress from group $groupAddress: $sent")
      result.success(sent)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to remove device from group", e)
      result.error("GROUP_ERROR", "Failed to remove device from group: ${e.message}", null)
    }
  }

  private fun createGroup(call: MethodCall, result: Result) {
    try {
      val params = call.arguments as? Map<String, Any>
      if (params == null) {
        result.error("INVALID_ARGUMENT", "Parameters are required", null)
        return
      }

      val groupAddress = params["groupAddress"] as? Int
      val groupName = params["groupName"] as? String ?: "Group"

      if (groupAddress == null) {
        result.error("INVALID_ARGUMENT", "Group address is required", null)
        return
      }

      // Group creation is typically handled at the application level
      // Here we just validate and return success
      Log.d(TAG, "Group created: $groupName with address $groupAddress")
      result.success(true)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to create group", e)
      result.error("GROUP_ERROR", "Failed to create group: ${e.message}", null)
    }
  }

  private fun deleteGroup(call: MethodCall, result: Result) {
    try {
      val params = call.arguments as? Map<String, Any>
      if (params == null) {
        result.error("INVALID_ARGUMENT", "Parameters are required", null)
        return
      }

      val groupAddress = params["groupAddress"] as? Int

      if (groupAddress == null) {
        result.error("INVALID_ARGUMENT", "Group address is required", null)
        return
      }

      // Group deletion is typically handled at the application level
      Log.d(TAG, "Group deleted: $groupAddress")
      result.success(true)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to delete group", e)
      result.error("GROUP_ERROR", "Failed to delete group: ${e.message}", null)
    }
  }

  private fun saveMeshConfiguration(call: MethodCall, result: Result) {
    try {
      val config = call.arguments as? Map<String, Any>
      if (config == null) {
        result.error("INVALID_ARGUMENT", "Configuration is required", null)
        return
      }

      // Save configuration to SharedPreferences
      val prefs = context.getSharedPreferences("mesh_config", Context.MODE_PRIVATE)
      val editor = prefs.edit()

      config.forEach { (key, value) ->
        when (value) {
          is String -> editor.putString(key, value)
          is Int -> editor.putInt(key, value)
          is Boolean -> editor.putBoolean(key, value)
          is Long -> editor.putLong(key, value)
          is Float -> editor.putFloat(key, value)
        }
      }

      editor.apply()

      Log.d(TAG, "Mesh configuration saved")
      result.success(true)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to save mesh configuration", e)
      result.error("STORAGE_ERROR", "Failed to save configuration: ${e.message}", null)
    }
  }

  private fun loadMeshConfiguration(result: Result) {
    try {
      val prefs = context.getSharedPreferences("mesh_config", Context.MODE_PRIVATE)
      val config = prefs.all

      Log.d(TAG, "Mesh configuration loaded: ${config.size} entries")
      result.success(config)
    } catch (e: Exception) {
      Log.e(TAG, "Failed to load mesh configuration", e)
      result.error("STORAGE_ERROR", "Failed to load configuration: ${e.message}", null)
    }
  }

  private fun createMeshConfiguration(config: Map<String, Any>): MeshConfiguration {
    val meshConfig = MeshConfiguration()

    // Set network key
    val networkKey = config["networkKey"] as? String
    if (networkKey != null) {
      meshConfig.netKeyIndex = (config["netKeyIndex"] as? Int) ?: 0
      meshConfig.networkKey = hexStringToByteArray(networkKey)
    }

    // Set app keys
    val appKeys = config["appKeys"] as? Map<Int, String>
    if (appKeys != null && appKeys.isNotEmpty()) {
      meshConfig.appKeyMap = android.util.SparseArray()
      appKeys.forEach { (index, key) ->
        meshConfig.appKeyMap.put(index, hexStringToByteArray(key))
      }
    }

    // Set other parameters
    meshConfig.ivIndex = (config["ivIndex"] as? Int) ?: 0
    meshConfig.sequenceNumber = (config["sequenceNumber"] as? Int) ?: 0
    meshConfig.localAddress = (config["localAddress"] as? Int) ?: 1

    return meshConfig
  }

  private fun parseUUID(uuidString: String?): ByteArray? {
    if (uuidString == null) return null
    return try {
      hexStringToByteArray(uuidString.replace("-", ""))
    } catch (e: Exception) {
      Log.w(TAG, "Failed to parse UUID: $uuidString", e)
      null
    }
  }

  private fun hexStringToByteArray(hexString: String): ByteArray {
    return Arrays.hexToBytes(hexString)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    scanEventChannel.setStreamHandler(null)
    connectionEventChannel.setStreamHandler(null)
    otaEventChannel.setStreamHandler(null)
    messageEventChannel.setStreamHandler(null)
  }
}
