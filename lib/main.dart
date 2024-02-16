import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpuiosbundle/store.dart';
import 'package:gpuiosbundle/message.dart';
import 'package:gpuiosbundle/read.dart';
import 'package:gpuiosbundle/lock.dart';
import 'package:gpuiosbundle/tuning.dart';
import 'package:gpuiosbundle/loadBuffer.dart';
import 'package:gpuiosbundle/storeBuffer.dart';
import 'package:gpuiosbundle/TwoPlusTwoWritePage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gpuiosbundle/tests.dart';
import 'package:gpuiosbundle/home.dart';

//import 'package:gpuiosbundle/utilities.dart';

//import 'package:platform/platform.dart';

void delete() async {
  Directory dir = await getTemporaryDirectory();
  dir.deleteSync(recursive: true);
  dir.create();
}

void main() {
  runApp(MyApp());

  // check method channel call
  // printy("assets/store/litmustest_store_default.spv");
  // mssg_init();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPU Memory Model Tests',
      home: MyHomePage(title: 'GPU Memory Model Tests'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    TestsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 253, 254),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFF1F3DD2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.code),
              label: 'Tests',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 31, 61, 210),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
