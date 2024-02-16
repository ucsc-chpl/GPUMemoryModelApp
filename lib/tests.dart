import 'package:flutter/material.dart';
import 'package:gpuiosbundle/store.dart';
import 'package:gpuiosbundle/message.dart';
import 'package:gpuiosbundle/read.dart';
import 'package:gpuiosbundle/lock.dart';
import 'package:gpuiosbundle/tuning.dart';
import 'package:gpuiosbundle/loadBuffer.dart';
import 'package:gpuiosbundle/storeBuffer.dart';
import 'package:gpuiosbundle/TwoPlusTwoWritePage.dart';

// Define a model for the test item
class TestItem {
  final String name;
  final String description;

  TestItem({required this.name, required this.description});
}

class TestsPage extends StatefulWidget {
  const TestsPage({Key? key}) : super(key: key);

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  // List of tests with names and descriptions
  final List<TestItem> testItems = [
    TestItem(name: 'Message Passing', description: 'The message passing litmus test checks to see if two stores in one thread can be re-ordered according to loads on a second thread.'),
    TestItem(name: 'Store', description: 'The store litmus test checks to see if two stores in one thread can be re-ordered according to a store and a load on a second thread.'),
    TestItem(name: 'Read', description: 'The read litmus test checks to see if two stores in one thread can be re-ordered according to a store and a load on a second thread.'),
    TestItem(name: 'Load Buffer', description: 'The load buffer litmus test checks to see if loads can be buffered and re-ordered on different threads.'),
    TestItem(name: 'Store Buffer', description: 'The store buffer litmus test checks to see if stores can be buffered and re-ordered on different threads.'),
    TestItem(name: '2+2 Write', description: 'The 2+2 write litmus test checks to see if two stores in two threads can both be re-ordered.'),
  ];

  void navigateToTestPage(BuildContext context, String testName) {
    // Implement navigation logic here
    Widget page = MessagePage();
    switch (testName) {
        case 'Message Passing':
              page = MessagePage();
              break;
        case 'Store':
              page = StorePage();
              break;
        case 'Read':
              page = ReadPage();
              break;
        case 'Load Buffer':
              page = LoadBufferPage();
              break;
        case 'Store Buffer':
              page = StoreBufferPage();
              break;
        case '2+2 Write':
              page = TwoPlusTwoWritePage();
              break;
    }
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
    );
    print('Navigating to $testName page'); // Placeholder print statement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPU Litmus Tests'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Please choose which test you would like to run.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: testItems.length, // Make sure 'testItems' is defined and has data
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => navigateToTestPage(context, testItems[index].name),
                  child: Container(
                    margin: EdgeInsets.all(8.0), // Adds space around each tile
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF1F3DD2), // Set the border color
                        width: 2.0, // Set the border width
                      ),
                      borderRadius: BorderRadius.circular(5.0), // Rounds the corners
                    ),
                    child: ListTile(
                      title: Text(testItems[index].name),
                      subtitle: Text(testItems[index].description),
                      // You can add trailing, leading, etc., here
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
