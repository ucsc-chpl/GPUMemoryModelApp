import 'package:flutter/material.dart';
import 'package:gpuiosbundle/store.dart';
import 'package:gpuiosbundle/message.dart';
import 'package:gpuiosbundle/read.dart';
import 'package:gpuiosbundle/lock.dart';
import 'package:gpuiosbundle/tuning.dart';
//import 'package:gpuiosbundle/utilities.dart';

//import 'package:platform/platform.dart';

void main() {
  runApp(const MyApp());

  // check method channel call
  // printy("assets/store/litmustest_store_default.spv");
  // mssg_init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'GPU Memory Model Tests';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const SizedBox(
        //   //child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'This app uses litmus test to showcase the allowed behavious of GPU memory model. This app is required to be run with Android 8.0+ and IOS 8.0+, and GPU that supports Vulkan 1.1',
            // textAlign: TextAlign.center,
            //  overflow: TextOverflow.clip,
          ),
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              // <-- SEE HERE
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text(
                "Team GPU Harbor",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                "InsertgpuHarbor@email.com",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: FlutterLogo(),
            ),
            ListTile(
              title: const Text('Introduction'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Tuning/Conformance'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return TuningPage();
                    // return MessagePage();
                  }),
                );
              },
            ),
            ListTile(
              title: const Text('Lock Tests'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return Lock();
                    // return MessagePage();
                  }),
                );
              },
            ),
            const Divider(), //here is a divider

            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Weak Memory Test",
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            ListTile(
              title: const Text('Message Passing'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return MessagePage();
                    // return MessagePage();
                  }),
                );
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Read'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ReadPage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
