import 'package:flutter/material.dart';
import 'package:gpuiosbundle/utilities.dart';

String lock_correct = "assets/locktest_correct.spv";
String lock_correct_relaxed = "assets/locktest_correctrelaxed.spv";
String lock_speed = "assets/locktest_speed.spv";
String lock_speedrelaxed = "assets/locktest_speedrelaxed.spv";
const String title = "Lock Tests";

const String page =
    "This page contains testing with mutex, a synchronization object to protect against data conflicts. When a thread tries to access the shared memory, it will call lock() function which prevents any other thread to access the shared memory at the same time. Once the thread has finished, it will call unlock() function to let another thread to call lock() function to access the shared memory. The speed tests checks for duration for all the mutexes to go through lock() and unlock(). The correctness test checks to see if only one thread is accessing the shared memory, to avoid any data conflict.";

// create statefull widget class
class Lock extends StatefulWidget {
  const Lock({Key? key}) : super(key: key);

  @override
  State<Lock> createState() => _LockState();
}

// extend the class
class _LockState extends State<Lock> {
  final String _title = title;
  final _formKey = GlobalKey<FormState>();
  TextEditingController userInput = TextEditingController();

  //late String _iterationMssg;
  // late bool _visible;
  bool _isStartButtonDisabled = true;
  //late bool _isStressButtonDisabled;
  bool _isResultButtonDisabled = true;
  //late bool _isEmailButtonDisabled;
  // late int _counter;
  // final subscription = controller.stream;

  TextEditingController _itercontroller = TextEditingController(text: '1000');
  TextEditingController _groupNumcontroller = TextEditingController(text: '16');
  TextEditingController _sizecontroller = TextEditingController(text: '16');

  @override
  void initState() {
    super.initState();

    //_counter = 0;
    _isStartButtonDisabled = true;
    // _isStressButtonDisabled = true;
    _isResultButtonDisabled = true;
    // _isEmailButtonDisabled = true;
    // _visible = false;
    //  _iterationMssg = "Counter is 0";

    //_itercontroller = TextEditingController(text: '1000');
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _compute(var spv) async {
    setState(() {
      _isStartButtonDisabled = false;
      _isResultButtonDisabled = false;
    });

    await FFIBridge.run_isolate_lock(spv, _itercontroller.text,
        _groupNumcontroller.text, _sizecontroller.text);

    setState(() {
      _isStartButtonDisabled = true;
      _isResultButtonDisabled = true;
    });
  }

  void _results() {
    String outputPath = FFIBridge.getFile();

    final contents = readCounter(outputPath);

    dynamic output;

    contents.then((value) {
      output = value;

      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Message Test Results'),
                content: SingleChildScrollView(
                  // won't be scrollable
                  child: Text(output),
                ),
              ));
    });
  }

  // print("controller is active");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Container(
        //child: Center(

        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
              // mainAxisAlignment: MainAxisAlignment.left,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  page,
                  // textAlign: TextAlign.center,
                  //overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Column(
                    //  crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Test Parameter',
                        // textAlign: TextAlign.left,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Test Iteration:',
                            ),
                          ),
                          //SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _itercontroller,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Work Group Number:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _groupNumcontroller,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Workgroup Size:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _sizecontroller,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ]),
                const SizedBox(height: 20),
                const SizedBox(
                    width: 150, // <-- Your width
                    height: 30, // <-- Your height
                    child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text("Speed Test (acl_rel)"))),
                Row(
                  children: [
                    SizedBox(
                      width: 160, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.blue),
                          ),
                          onPressed: _isStartButtonDisabled
                              ? () => _compute(lock_speed)
                              : null,
                          child: const Text('Start'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.red),
                          ),
                          onPressed: _isResultButtonDisabled ? _results : null,
                          child: Text('Result'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const SizedBox(
                    width: 150, // <-- Your width
                    height: 30, // <-- Your height
                    child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text("Speed Test (relaxed)"))),
                Row(
                  children: [
                    SizedBox(
                      width: 160, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.blue),
                          ),
                          onPressed: _isStartButtonDisabled
                              ? () => _compute(lock_speedrelaxed)
                              : null,
                          child: const Text('Start'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.red),
                          ),
                          onPressed: _isResultButtonDisabled ? _results : null,
                          child: Text('Result'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const SizedBox(
                    width: 200, // <-- Your width
                    height: 30, // <-- Your height
                    child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text("Correctness Test (acl_rel)"))),
                Row(
                  children: [
                    SizedBox(
                      width: 160, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.blue),
                          ),
                          onPressed: _isStartButtonDisabled
                              ? () => _compute(lock_correct)
                              : null,
                          child: const Text('Start'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.red),
                          ),
                          onPressed: _isResultButtonDisabled ? _results : null,
                          child: Text('Result'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const SizedBox(
                    width: 200, // <-- Your width
                    height: 30, // <-- Your height
                    child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text("Correctness Test (relaxed)"))),
                Row(
                  children: [
                    SizedBox(
                      width: 160, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.blue),
                          ),
                          onPressed: _isStartButtonDisabled
                              ? () => _compute(lock_correct_relaxed)
                              : null,
                          child: const Text('Start'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.red),
                          ),
                          onPressed: _isResultButtonDisabled ? _results : null,
                          child: Text('Result'),
                        ),
                      ),
                    ),
                  ],
                )
              ]),
        ),
      ),
    );
  }
}
