import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MqttServerClient client;
  bool isSafe = true;
  bool isSwitchOn = false;
  String deviceStatus = "OFF";
  double current = 0;
  double voltage = 230;
  double power = 0;
  double ratedPower = 250;

  @override
  void initState() {
    super.initState();
    connectMQTT();
  }

  Future<void> connectMQTT() async {
    client = MqttServerClient(
      'broker.hivemq.com',
      'Flutter_WattGuard_${DateTime.now().millisecondsSinceEpoch}',
    );

    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onConnected = () => debugPrint("MQTT Connected");

    await client.connect();

    client.subscribe('Wattguard/relay', MqttQos.atMostOnce);
    client.subscribe('WattGuard/current', MqttQos.atMostOnce);

    client.updates!.listen((events) {
      final recMess = events[0].payload as MqttPublishMessage;
      final topic = events[0].topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      if (topic == 'WattGuard/current') {
        setState(() {
          current = double.tryParse(payload) ?? 0.0;
        });
      }
    });
  }

  void publishCommand(String cmd) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(cmd);

    client.publishMessage(
      'Wattguard/relay',
      MqttQos.atMostOnce,
      builder.payload!,
    );

    setState(() {
      deviceStatus = cmd;
    });
  }

  void toggleSwitch(bool value) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(value ? "ON" : "OFF");

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.publishMessage(
        'WattGuard/relay',
        MqttQos.atMostOnce,
        builder.payload!,
      );

      setState(() {
        isSwitchOn = value;
        deviceStatus = value ? "ON" : "OFF";
      });
    } else {
      debugPrint("MQTT not connected yet");
    }

    setState(() {
      isSwitchOn = value;
      deviceStatus = value ? "ON" : "OFF";
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    power = voltage * current;
    isSafe = ratedPower >= power;
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF1F1F1),
              Color(0xFF265E88),
              Color(0xFF0B3C5D),
              Color(0xFF000000),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'WATT Guard',
                        style: TextStyle(
                          color: Color(0xFFFF8C00),
                          fontWeight: FontWeight.w500,
                          fontSize: 30,
                          height: 2,
                        ),
                      ),
                      Icon(
                        Icons.electric_bolt_rounded,
                        color: Colors.yellow,
                        size: 35,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            width: screenWidth / 2 - 15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white60,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${current.toStringAsFixed(2)} A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            padding: EdgeInsets.all(10),
                            width: screenWidth / 2 - 15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white60,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${power.toStringAsFixed(2)} W',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: screenWidth / 2 - 15,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            isSafe ? '😀' : '😱',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 80,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white60, width: 1),
                    ),
                    child: Container(
                      height: screenWidth / 2,
                      width: screenWidth - 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white38,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text('Graph'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Safety status and Power switch',
                    style: TextStyle(color: Colors.white, height: 2),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: screenWidth - 20,
                    decoration: BoxDecoration(
                      color: isSafe ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSafe ? 'Safe' : 'Danger',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 50,
                            height: 1,
                          ),
                        ),
                        Switch(
                          value: isSwitchOn,
                          onChanged: (value) {
                            setState(() {
                              toggleSwitch(value);
                            });
                          },
                          activeThumbColor: Colors.black,
                          inactiveThumbColor: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
