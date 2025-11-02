import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_telink_ble/flutter_telink_ble.dart';
import 'package:flutter_telink_ble/models/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telink BLE Mesh Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _plugin = FlutterTelinkBle();
  String _platformVersion = 'Unknown';
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isConnected = false;
  final List<UnprovisionedDevice> _scannedDevices = [];
  StreamSubscription<UnprovisionedDevice>? _scanSubscription;
  StreamSubscription<MeshConnectionStateEvent>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _initPlatform();
    _listenToConnectionState();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _plugin.dispose();
    super.dispose();
  }

  Future<void> _initPlatform() async {
    try {
      final version = await _plugin.getPlatformVersion() ?? 'Unknown';
      setState(() => _platformVersion = version);
    } on PlatformException {
      setState(() => _platformVersion = 'Failed to get platform version');
    }
  }

  Future<void> _initializeMesh() async {
    try {
      final config = TelinkMeshConfig(
        networkKey: '7dd7364cd842ad18c17c2b820c84c3d6',
        netKeyIndex: 0,
        appKeys: {0: '63964771734fbd76e3b40519d1d94a48'},
        ivIndex: 0,
        sequenceNumber: 0,
        localAddress: 1,
      );

      await _plugin.initialize(config);
      setState(() => _isInitialized = true);
      _showSnackBar('Mesh initialized successfully');
    } catch (e) {
      _showSnackBar('Failed to initialize: $e');
    }
  }

  void _listenToConnectionState() {
    _connectionSubscription = _plugin.connectionStateStream.listen((event) {
      setState(() {
        _isConnected = event.state == MeshConnectionState.connected;
      });
      _showSnackBar('Connection: ${event.state.name}');
    });
  }

  Future<void> _startScan() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize mesh first');
      return;
    }

    setState(() {
      _isScanning = true;
      _scannedDevices.clear();
    });

    _scanSubscription = _plugin.scanForDevices().listen(
      (device) {
        setState(() {
          _scannedDevices.add(device);
        });
      },
      onError: (error) {
        _showSnackBar('Scan error: $error');
      },
    );

    // Auto-stop after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_isScanning) _stopScan();
    });
  }

  Future<void> _stopScan() async {
    await _scanSubscription?.cancel();
    await _plugin.stopScan();
    setState(() => _isScanning = false);
  }

  Future<void> _connectToMesh() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize mesh first');
      return;
    }

    try {
      await _plugin.connectToMesh();
      _showSnackBar('Connecting to mesh...');
    } catch (e) {
      _showSnackBar('Failed to connect: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telink BLE Mesh Demo'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth),
            onPressed: _isConnected ? null : _connectToMesh,
            tooltip: _isConnected ? 'Connected' : 'Connect to Mesh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform: $_platformVersion'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Mesh Initialized: '),
                      Icon(
                        _isInitialized ? Icons.check_circle : Icons.cancel,
                        color: _isInitialized ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Mesh Connected: '),
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.cancel,
                        color: _isConnected ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized ? null : _initializeMesh,
                    icon: const Icon(Icons.settings),
                    label: const Text('Initialize'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized && !_isScanning ? _startScan : _stopScan,
                    icon: Icon(_isScanning ? Icons.stop : Icons.search),
                    label: Text(_isScanning ? 'Stop Scan' : 'Scan'),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Tabs
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.devices), text: 'Devices'),
                      Tab(icon: Icon(Icons.lightbulb), text: 'Control'),
                      Tab(icon: Icon(Icons.group), text: 'Groups'),
                      Tab(icon: Icon(Icons.system_update), text: 'OTA'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildDeviceList(),
                        _buildDeviceControl(),
                        _buildGroupManagement(),
                        _buildOTAUpdate(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_scannedDevices.isEmpty) {
      return const Center(
        child: Text('No devices found. Tap "Scan" to search for devices.'),
      );
    }

    return ListView.builder(
      itemCount: _scannedDevices.length,
      itemBuilder: (context, index) {
        final device = _scannedDevices[index];
        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.name),
          subtitle: Text('UUID: ${device.uuid}\nRSSI: ${device.rssi}'),
          trailing: ElevatedButton(
            onPressed: () => _provisionDevice(device),
            child: const Text('Provision'),
          ),
        );
      },
    );
  }

  Widget _buildDeviceControl() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Device Control', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Device Address (e.g., 10)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isConnected ? () => _sendOnOffCommand(10, true) : null,
            icon: const Icon(Icons.power_settings_new),
            label: const Text('Turn ON'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _isConnected ? () => _sendOnOffCommand(10, false) : null,
            icon: const Icon(Icons.power_off),
            label: const Text('Turn OFF'),
          ),
          const SizedBox(height: 16),
          const Text('Brightness'),
          Slider(
            value: 50,
            min: 0,
            max: 100,
            onChanged: _isConnected ? (value) => _sendLevelCommand(10, value.toInt()) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupManagement() {
    return const Center(
      child: Text('Group Management - Coming Soon'),
    );
  }

  Widget _buildOTAUpdate() {
    return const Center(
      child: Text('OTA Update - Coming Soon'),
    );
  }

  Future<void> _provisionDevice(UnprovisionedDevice device) async {
    try {
      _showSnackBar('Provisioning ${device.name}...');
      // Provision logic would go here
    } catch (e) {
      _showSnackBar('Provisioning failed: $e');
    }
  }

  Future<void> _sendOnOffCommand(int address, bool isOn) async {
    try {
      await _plugin.sendOnOffCommand(address, isOn);
      _showSnackBar('Sent ${isOn ? "ON" : "OFF"} command to device $address');
    } catch (e) {
      _showSnackBar('Command failed: $e');
    }
  }

  Future<void> _sendLevelCommand(int address, int level) async {
    try {
      await _plugin.sendLevelCommand(address, level);
      _showSnackBar('Set brightness to $level% for device $address');
    } catch (e) {
      _showSnackBar('Command failed: $e');
    }
  }
}
