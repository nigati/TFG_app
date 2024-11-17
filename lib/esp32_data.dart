import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_app/menu.dart';

class BLEHome extends StatefulWidget {
  const BLEHome({super.key, required this.title});
  final String title;

  @override
  State<BLEHome> createState() => _BLEHomeState();
}

class _BLEHomeState extends State<BLEHome> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  String accelerationData = '';
  SharedPreferences? prefs;
  Color screenColor = Colors.green;  // Default color

  @override
  void initState() {
    super.initState();
    initializePreferences();
  }

  void initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs?.getString('connectedDeviceId');
    if (deviceId != null) {
      autoReconnect(deviceId);
    } else {
      scanForDevices();
    }
  }

  void scanForDevices() {
    print('Scanning for devices...');
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
      for (ScanResult result in results) {
        print('Found device: ${result.device.platformName} (${result.device.remoteId})');
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    print('Connecting to device: ${device.platformName} (${device.remoteId})');
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    prefs?.setString('connectedDeviceId', device.id.toString());
    discoverServices();
  }

  void autoReconnect(String deviceId) async {
    print('Attempting to reconnect to device: $deviceId');
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    for (BluetoothDevice device in devices) {
      if (device.remoteId.toString() == deviceId) {
        setState(() {
          connectedDevice = device;
        });
        discoverServices();
        return;
      }
    }
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.remoteId.toString() == deviceId) {
          FlutterBluePlus.stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  void discoverServices() async {
    print('Discovering services...');
    var services = await connectedDevice?.discoverServices();
    for (var service in services!) {
      for (var char in service.characteristics) {
        print('Found characteristic: ${char.uuid}');
        if (char.uuid.toString() == '2a58') {
          setState(() {
            characteristic = char;
          });
          readCharacteristic();
        }
      }
    }
  }

  void readCharacteristic() async {
    print('Setting up notifications...');
    await characteristic?.setNotifyValue(true);
    characteristic?.lastValueStream.listen((value) {
      String receivedData = String.fromCharCodes(value);
      print('Received data: $receivedData');

      // Parse the received acceleration data
      List<String> parts = receivedData.split(',');
      if (parts.length == 6) {
        try {
          double z = double.parse(parts[2]);
          setState(() {
            accelerationData = receivedData;
            // Update the screen color based on the z-axis value
            screenColor = (z.abs() <= 5) ? Colors.red : Colors.green;
          });
        } catch (e) {
          print('Error parsing acceleration data: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Menu(
      title: widget.title,
      body: Container(
        color: screenColor,
        child: Center(
          child: connectedDevice == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: scanForDevices,
                      child: Text('Scan for devices'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: scanResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(scanResults[index].device.platformName),
                            subtitle: Text(scanResults[index].device.remoteId.toString()),
                            onTap: () => connectToDevice(scanResults[index].device),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Connected to ${connectedDevice!.platformName}'),
                    Text('Acceleration Data: $accelerationData'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          connectedDevice = null;
                        });
                        prefs?.remove('connectedDeviceId');
                        scanForDevices();
                      },
                      child: Text('Disconnect'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
