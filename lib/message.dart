import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:gpuiosbundle/forms.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gpuiosbundle/bar_graph.dart';
import 'package:percent_indicator/percent_indicator.dart';

String shader_spv = "assets/litmustest_message_passing_default.spv";
String result_spv = "assets/litmustest_message_passing_results.spv";
String param_basic = "assets/parameters_basic.txt";
String param_stress = "assets/parameters_stress.txt";
const String title = "GPU Message Passing Test";

const String page =
    "The message passing litmus test checks to see if two stores in one thread can be re-ordered according to loads on a second thread";
const String init_state = "*x = 0, *y = 0";
const String final_state = "r0 == 1 && r1 == 0";
const String workgroup0_thread0_text1 =
    "0.1: atomic_store_explicit (x,1,memory_order_relaxed)";
const String workgroup0_thread0_text2 =
    "0.2: atomic_store_explicit (y,1,memory_order_relaxed)";
const String workgroup1_thread0_text1 =
    "1.1: r0 = atomic_load_explicit (y,memory_order_relaxed)";
const String workgroup1_thread0_text2 =
    "1.2: r1 = atomic_load_explicit (x,memory_order_relaxed)";

// create statefull widget class
class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

// extend the class
class _MessagePageState extends State<MessagePage> {
  final String _title = title;
  final _formKey = GlobalKey<FormState>();
  TextEditingController userInput = TextEditingController();

  late String _iterationMssg;
  late bool _visibleIndicator;
  late bool _visibleBarChart;
  late bool _isExplorerButtonDisabled;
  late bool _isStressButtonDisabled;
  late bool _isResultButtonDisabled;
  late bool _isEmailButtonDisabled;
  late int _counter;
  late double _percentageValue;
  final subscription = controller.stream;
  bool default_param = true;

// explorer controllers
  TextEditingController _iter = TextEditingController(text: '100');
  TextEditingController _workgroup = TextEditingController(text: '2');
  TextEditingController _maxworkgroup = TextEditingController(text: '4');
  TextEditingController _size = TextEditingController(text: '256');
  TextEditingController _shufflepct = TextEditingController(text: '0');
  TextEditingController _barrierpct = TextEditingController(text: '0');
  TextEditingController _scratchMemSize = TextEditingController(text: '2048');
  TextEditingController _memStride = TextEditingController(text: '1');
  TextEditingController _memStressPct = TextEditingController(text: '0');
  TextEditingController _memStressIter = TextEditingController(text: '1024');
  TextEditingController _memStressStoreFirstPct =
      TextEditingController(text: '0');
  TextEditingController _memStressStoreSecondPct =
      TextEditingController(text: '100');
  TextEditingController _preStressPct = TextEditingController(text: '0');
  TextEditingController _preStressIter = TextEditingController(text: '128');
  TextEditingController _preStressStoreFirstPct =
      TextEditingController(text: '0');
  TextEditingController _preStressStoreSecondPct =
      TextEditingController(text: '0');
  TextEditingController _stressLineSize = TextEditingController(text: '64');
  TextEditingController _stressTargetLines = TextEditingController(text: '2');
  TextEditingController _stressAssignmentStrategy =
      TextEditingController(text: '100');
  TextEditingController _numMemLocations = TextEditingController(text: '2');
  TextEditingController _numOutputs = TextEditingController(text: '2');

  // tuning controllers
  TextEditingController _tIter = TextEditingController(text: '100');
  TextEditingController _tConfigNum = TextEditingController(text: '10');
  TextEditingController _tRandomSeed = TextEditingController(text: '');
  TextEditingController _tWorkgroup = TextEditingController(text: '2');
  TextEditingController _tMaxworkgroup = TextEditingController(text: '4');
  TextEditingController _tSize = TextEditingController(text: '256');

  @override
  void initState() {
    super.initState();

    _counter = 0;
    _isExplorerButtonDisabled = true;
    _isStressButtonDisabled = true;
    _isResultButtonDisabled = true;
    _isEmailButtonDisabled = true;
    _visibleIndicator = false;
    _visibleBarChart = false;
    _percentageValue = 0;

    var iterValue = _iter.text;
    _iterationMssg = "Computed is 0 from $iterValue";
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _tuningClick() {
    print("reached here");
    FFIBridge.tuning(
        "Tuning Test",
        shader_spv,
        result_spv,
        _tConfigNum.text,
        _tIter.text,
        _tRandomSeed.text,
        _tWorkgroup.text,
        _tMaxworkgroup.text,
        _tSize.text);

    setState(() {
      _visibleIndicator = true;
      _visibleBarChart = true;
    });
  }

  void _changeStress() {
    _iter.text = '100';
    _workgroup.text = '2';
    _maxworkgroup.text = '4';
    _size.text = '256';
    _shufflepct.text = '0';
    _barrierpct.text = '0';
    _scratchMemSize.text = '2048';
    _memStride.text = '1';
    _memStressPct.text = '0';
    _memStressIter.text = '1024';
    _memStressStoreFirstPct.text = '0';
    _memStressStoreSecondPct.text = '100';
    _preStressPct.text = '0';
    _preStressIter.text = '128';
    _preStressStoreFirstPct.text = '0';
    _preStressStoreSecondPct.text = '0';
    _stressLineSize.text = '64';
    _stressTargetLines.text = '2';
    _stressAssignmentStrategy.text = '100';
  }

  void _changeDefault() {
    _iter.text = '100';
    _workgroup.text = '512';
    _maxworkgroup.text = '1024';
    _size.text = '256';
    _shufflepct.text = '100';
    _barrierpct.text = '100';
    _scratchMemSize.text = '2048';
    _memStride.text = '4';
    _memStressPct.text = '100';
    _memStressIter.text = '1024';
    _memStressStoreFirstPct.text = '0';
    _memStressStoreSecondPct.text = '100';
    _preStressPct.text = '100';
    _preStressIter.text = '128';
    _preStressStoreFirstPct.text = '0';
    _preStressStoreSecondPct.text = '100';
    _stressLineSize.text = '64';
    _stressTargetLines.text = '2';
    _stressAssignmentStrategy.text = '100';
  }

  void _compute() async {
    setState(() {
      _counter = 0;

      _isExplorerButtonDisabled = false;
      _isStressButtonDisabled = false;
      _isResultButtonDisabled = false;
      _isEmailButtonDisabled = false;
      _visibleBarChart = false;

      // _iterationMssg = "Computed $_counter from $_iter.value";
      _visibleIndicator = true;
    });

    subscription.listen((data) {
      _counter = data;
      // print(_counter);
      setState(() {
        var iterValue = _iter.text;
        _iterationMssg = "Computed $_counter from $iterValue";

        _percentageValue = _counter / (int.parse(iterValue));

        if (_counter == int.parse(_iter.text)) {
          _visibleBarChart = true;
        }
      });
    });

    // print("I am here");

    writeDefault();

    setState(() {
      _isExplorerButtonDisabled = true;
      _isStressButtonDisabled = true;
      _isResultButtonDisabled = true;
      _isEmailButtonDisabled = true;
    });

    // print("when done");
  }

  void writeDefault() async {
    //print("we here");
    Map<String, dynamic> tuningParam = new Map();

    tuningParam["iterations"] = _iter.text;
    tuningParam["testingWorkgroups"] = _workgroup.text;
    tuningParam["maxWorkgroups"] = _maxworkgroup.text;
    tuningParam["workgroupSize"] = _size.text;
    tuningParam["shufflePct"] = _shufflepct.text;
    tuningParam["barrierPct"] = _barrierpct.text;
    tuningParam["scratchMemorySize"] = _scratchMemSize.text;
    tuningParam["memStride"] = _memStride.text;
    tuningParam["memStressPct"] = _memStressPct.text;
    tuningParam["preStressPct"] = _preStressPct.text;
    tuningParam["memStressIterations"] = _memStressIter.text;
    tuningParam["preStressIterations"] = _preStressIter.text;
    tuningParam["stressLineSize"] = _stressLineSize.text;
    tuningParam["stressTargetLines"] = _stressTargetLines.text;
    tuningParam["stressStrategyBalancePct"] = _stressAssignmentStrategy.text;
    tuningParam["memStressStoreFirstPct"] = _memStressStoreFirstPct.text;
    tuningParam["memStressStoreSecondPct"] = _memStressStoreSecondPct.text;
    tuningParam["preStressStoreFirstPct"] = _preStressStoreFirstPct.text;
    tuningParam["preStressStoreSecondPct"] = _preStressStoreSecondPct.text;
    tuningParam["numMemLocations"] = 2;
    tuningParam["numOutputs"] = 2;

    Directory tempDir = await getTemporaryDirectory();

    // assign the global path value
    cache = tempDir.path;

    param_tmp = "$cache/$param_tmp";

    //print(param_tmp);

    // now we write these parameters to our cache file

    // if the file exists delete it
    if (await File(param_tmp).exists()) {
      await File(param_tmp).delete();
    }

    File file = await File(param_tmp).create(recursive: true);

    tuningParam.forEach((key, value) async {
      file.writeAsStringSync("${key}=${value} \n", mode: FileMode.append);
      //print("${key} = ${value}");
    });

    print(param_tmp);

    File(param_tmp)
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((l) => print('line: $l'));

    call_bridge(param_tmp, shader_spv, result_spv);
  }

  void _results([outputType]) {
    String outputPath = FFIBridge.getFile();

    final contents = readCounter(outputPath);

    // if (outputType == "tuning") {
    //   final contents = readCounter(tuningOutputFile);
    // }

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

  showExplorerDialog() {
    // setState(() {
    //   _visibleBarChart = false;
    //   _visibleIndicator = false;
    // });
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: EdgeInsets.only(
              top: 10.0,
            ),
            title: Text(
              "Message Passing",
              style: TextStyle(fontSize: 24.0),
            ),
            content: Container(
              height: 400,
              //width: 400, //or whatever you want

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // child:
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Test Iteration:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _iter,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Testing Workgroups',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _workgroup,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Max Workgroup:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _maxworkgroup,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
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
                                        controller: _size,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Shuffle Percentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _shufflepct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Barrier Perecentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _barrierpct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Scratch Memory Size:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _scratchMemSize,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stride:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStride,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Percentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Iterations',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressIter,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Store First Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressStoreFirstPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Store Second Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressStoreSecondPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Percentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Iterations:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressIter,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Store First Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressStoreFirstPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Store Second Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressStoreSecondPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Stress Line Size:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _stressLineSize,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Stress Target Lines:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _stressTargetLines,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Stress Assignment Strategy:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _stressAssignmentStrategy,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Test Parameters Presets",
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Wrap(children: <Widget>[
                                  Container(
                                    //  width: double.infinity,
                                    height: 60,
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _changeStress();
                                        // Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.cyan,
                                        // fixedSize: Size(250, 50),
                                      ),
                                      child: const Text(
                                        "Default",
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // width: double.infinity,
                                    height: 60,
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _changeDefault();
                                        //Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey,
                                        // fixedSize: Size(250, 50),
                                      ),
                                      child: const Text(
                                        "Stress",
                                      ),
                                    ),
                                  ),
                                ]))
                          ]),
                    ),
                  ),

                  Align(
                      alignment: Alignment.center,
                      child: Wrap(children: <Widget>[
                        Container(
                          //  width: double.infinity,
                          height: 60,
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _compute();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              // fixedSize: Size(250, 50),
                            ),
                            child: Text(
                              "Start",
                            ),
                          ),
                        ),
                        Container(
                          // width: double.infinity,
                          height: 60,
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueGrey,
                              // fixedSize: Size(250, 50),
                            ),
                            child: Text(
                              "Close",
                            ),
                          ),
                        ),
                      ]))
                ],
              ),
            ),
          );

          //),
          //);
        });
  }

  showTuningDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: EdgeInsets.only(
              top: 10.0,
            ),
            title: Text(
              "Message Passing",
              style: TextStyle(fontSize: 24.0),
            ),
            content: Container(
              height: 400,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Test Config Number:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tConfigNum,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Test Iteration:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tIter,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Random Seed:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tRandomSeed,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Testing Workgroups:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tWorkgroup,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Max Workgroups:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tMaxworkgroup,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Work Group Size:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tSize,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Wrap(children: <Widget>[
                          Container(
                            //  width: double.infinity,
                            height: 60,
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                _tuningClick();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                // fixedSize: Size(250, 50),
                              ),
                              child: Text(
                                "Start",
                              ),
                            ),
                          ),
                          Container(
                            // width: double.infinity,
                            height: 60,
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                // fixedSize: Size(250, 50),
                              ),
                              child: Text(
                                "Close",
                              ),
                            ),
                          ),
                        ]))
                  ],
                ),
              ),
            ),
          );
        });
  }

  // print("controller is active");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Container(
        //child: Center(
        //  height: 800,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(24),
        child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                page,
                // textAlign: TextAlign.center,
                //overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Row(
                  mainAxisSize: MainAxisSize.min,
                  //  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Initial State:',
                      //  textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        init_state,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            backgroundColor:
                                Color.fromARGB(255, 203, 198, 198)),
                        // textAlign: TextAlign.center,
                        //  overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]),
              const SizedBox(height: 10),
              const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text(
                  'Final State:',
                  textAlign: TextAlign.center,
                  // overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    final_state,
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Color.fromARGB(255, 203, 198, 198)),
                    textAlign: TextAlign.center,
                    //   overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const SizedBox(height: 15),
              Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Workgroup 0 Thread 0:',
                      //  textAlign: TextAlign.center,
                      //  overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      color: Colors.grey,
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                workgroup0_thread0_text1,
                                //  textAlign: TextAlign.center,
                                //  overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                workgroup0_thread0_text2,
                                // textAlign: TextAlign.center,
                                //   overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                    ),
                  ]),
              const SizedBox(height: 15),
              Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Workgroup 1 Thread 0',
                      //  textAlign: TextAlign.center,
                      //   overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      color: Colors.grey,
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                workgroup1_thread0_text1,
                                // textAlign: TextAlign.center,
                                //  overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                workgroup1_thread0_text2,
                                // textAlign: TextAlign.center,
                                //   overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                    ),
                  ]),
              const SizedBox(height: 15),
              Wrap(
                // mainAxisSize: MainAxisSize.min,

                children: <Widget>[
                  SizedBox(
                    width: 160, // <-- Your width
                    height: 50, // <-- Your height
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.green),
                        ),
                        onPressed: _isExplorerButtonDisabled
                            ? () => showExplorerDialog()
                            : null,
                        child: const Text('Default Explorer'),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 30),

                  SizedBox(
                    width: 160, // <-- Your width
                    height: 50, // <-- Your height
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.green),
                        ),
                        onPressed: _isStressButtonDisabled
                            ? () => showTuningDialog()
                            : null,
                        child: const Text('Tuning'),
                      ),
                    ),
                  ),
                  //  const SizedBox(height: 30),

                  SizedBox(
                    width: 160, // <-- Your width
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

                  SizedBox(
                    width: 160, // <-- Your width
                    height: 50, // <-- Your height
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.blue),
                        ),
                        onPressed: _isEmailButtonDisabled ? email : null,
                        child: const Text('Email'),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Visibility(
                  child: Column(
                    children: [
                      LinearPercentIndicator(
                        lineHeight: 10,
                        percent: _percentageValue,
                        progressColor: Colors.deepPurple,
                        backgroundColor: Colors.deepPurple.shade100,
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(_iterationMssg))
                    ],
                  ),
                  visible: _visibleIndicator,
                ),
              ),

              // Padding(
              //     padding: const EdgeInsets.all(10.0),
              //     child: Visibility(child: Text(_iterationMssg))),

              // here lies the bar graph code

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Visibility(
                  child: SizedBox(height: 200, child: myBarGraph()),
                  visible: _visibleBarChart,
                ),
              )
            ]),
      ),
    );
  }
}
