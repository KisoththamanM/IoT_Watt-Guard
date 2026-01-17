import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSafe = true;
  bool isSwitchOn = false;
  double current = 0;
  double voltage = 0;
  double power = 0;
  double ratedPower = 0;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    power = voltage * current;
    isSafe = ratedPower <= power;
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
                                '$current A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
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
                                '$power W',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
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
                            'Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
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
                              isSwitchOn = value;
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
