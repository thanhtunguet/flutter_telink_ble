package info.thanhtunguet.flutter_telink_ble

import com.telink.ble.mesh.foundation.Event
import com.telink.ble.mesh.foundation.EventHandler
import com.telink.ble.mesh.foundation.event.*
import io.flutter.plugin.common.EventChannel

/**
 * Event handler for Telink Mesh events
 * Bridges native mesh events to Flutter event streams
 */
class FlutterEventHandler : EventHandler<String> {

    var scanEventSink: EventChannel.EventSink? = null
    var connectionEventSink: EventChannel.EventSink? = null
    var otaEventSink: EventChannel.EventSink? = null
    var messageEventSink: EventChannel.EventSink? = null

    override fun onEventPub(event: Event<String>) {
        when (event) {
            is ScanEvent -> handleScanEvent(event)
            is ProvisioningEvent -> handleProvisioningEvent(event)
            is BindingEvent -> handleBindingEvent(event)
            is StatusNotificationEvent -> handleStatusNotificationEvent(event)
            is MeshEvent -> handleMeshEvent(event)
            is GattConnectionEvent -> handleConnectionEvent(event)
            is GattOtaEvent -> handleOtaEvent(event)
            is FirmwareUpdatingEvent -> handleFirmwareUpdatingEvent(event)
            else -> {
                // Log unhandled event types
                android.util.Log.d("FlutterEventHandler", "Unhandled event: ${event.type}")
            }
        }
    }

    private fun handleScanEvent(event: ScanEvent) {
        when (event.type) {
            ScanEvent.EVENT_TYPE_DEVICE_FOUND -> {
                event.advertisingDevice?.let { device ->
                    scanEventSink?.success(mapOf(
                        "type" to "deviceFound",
                        "device" to mapOf(
                            "name" to (device.device?.name ?: "Unknown"),
                            "macAddress" to device.device?.address,
                            "rssi" to device.rssi,
                            "deviceUuid" to device.deviceUUID?.toString(),
                            "meshUuid" to device.meshUUID?.toString(),
                            "oob" to device.oob,
                            "productUUID" to device.productUUID
                        )
                    ))
                }
            }
            ScanEvent.EVENT_TYPE_SCAN_TIMEOUT -> {
                scanEventSink?.success(mapOf(
                    "type" to "scanTimeout"
                ))
            }
            ScanEvent.EVENT_TYPE_SCAN_FAIL -> {
                scanEventSink?.success(mapOf(
                    "type" to "scanFail"
                ))
            }
            ScanEvent.EVENT_TYPE_SCAN_LOCATION_WARNING -> {
                scanEventSink?.success(mapOf(
                    "type" to "scanLocationWarning"
                ))
            }
        }
    }

    private fun handleProvisioningEvent(event: ProvisioningEvent) {
        messageEventSink?.success(mapOf(
            "type" to "provisioning",
            "state" to event.state.toString(),
            "desc" to event.desc
        ))
    }

    private fun handleBindingEvent(event: BindingEvent) {
        messageEventSink?.success(mapOf(
            "type" to "binding",
            "state" to event.state.toString(),
            "desc" to event.desc
        ))
    }

    private fun handleStatusNotificationEvent(event: StatusNotificationEvent) {
        messageEventSink?.success(mapOf(
            "type" to "statusNotification",
            "src" to event.notification.src,
            "dst" to event.notification.dst,
            "opcode" to event.notification.opcode,
            "params" to event.notification.params?.let {
                android.util.Base64.encodeToString(it, android.util.Base64.NO_WRAP)
            }
        ))
    }

    private fun handleMeshEvent(event: MeshEvent) {
        when (event.type) {
            MeshEvent.EVENT_TYPE_DISCONNECTED -> {
                connectionEventSink?.success(mapOf(
                    "state" to "disconnected",
                    "desc" to event.desc
                ))
            }
            MeshEvent.EVENT_TYPE_CONNECT_SUCCESS -> {
                connectionEventSink?.success(mapOf(
                    "state" to "connected",
                    "desc" to event.desc
                ))
            }
            MeshEvent.EVENT_TYPE_CONNECT_FAIL -> {
                connectionEventSink?.success(mapOf(
                    "state" to "connectFail",
                    "desc" to event.desc
                ))
            }
        }
    }

    private fun handleConnectionEvent(event: GattConnectionEvent) {
        connectionEventSink?.success(mapOf(
            "state" to event.state.toString(),
            "desc" to event.desc
        ))
    }

    private fun handleOtaEvent(event: GattOtaEvent) {
        when (event.type) {
            GattOtaEvent.EVENT_TYPE_OTA_SUCCESS -> {
                otaEventSink?.success(mapOf(
                    "type" to "success",
                    "desc" to event.desc
                ))
            }
            GattOtaEvent.EVENT_TYPE_OTA_FAIL -> {
                otaEventSink?.success(mapOf(
                    "type" to "fail",
                    "desc" to event.desc
                ))
            }
            GattOtaEvent.EVENT_TYPE_OTA_PROGRESS -> {
                otaEventSink?.success(mapOf(
                    "type" to "progress",
                    "progress" to event.progress,
                    "desc" to event.desc
                ))
            }
        }
    }

    private fun handleFirmwareUpdatingEvent(event: FirmwareUpdatingEvent) {
        when (event.type) {
            FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_SUCCESS -> {
                otaEventSink?.success(mapOf(
                    "type" to "firmwareSuccess",
                    "desc" to event.desc
                ))
            }
            FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_FAIL -> {
                otaEventSink?.success(mapOf(
                    "type" to "firmwareFail",
                    "desc" to event.desc
                ))
            }
            FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_PROGRESS -> {
                otaEventSink?.success(mapOf(
                    "type" to "firmwareProgress",
                    "progress" to event.progress,
                    "desc" to event.desc
                ))
            }
            FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_STOPPED -> {
                otaEventSink?.success(mapOf(
                    "type" to "firmwareStopped",
                    "desc" to event.desc
                ))
            }
        }
    }
}
