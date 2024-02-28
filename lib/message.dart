import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gpuiosbundle/bar_graph.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'explorerDialogTemplate.dart';
import 'testPageTemplate.dart';
import 'tuningDialogTemplate.dart';



String shader_spv = "assets/message-passing.spv";
String result_spv = "assets/message-passing-results.spv";
String param_basic = "assets/parameters_basic.txt";
String param_stress = "assets/parameters_stress.txt";
const String title = "GPU Message Passing Test";



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

  void _tuningClick() async {
    await FFIBridge.tuning(
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
      _visibleIndicator = false;
      _visibleBarChart = true;
    });

    //myBarGraph();

    await initList(_tConfigNum.text);
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

  void _email() {

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
    }

        //

        );

    // print("I am here");

    writeDefault();

    setState(() {
      _isExplorerButtonDisabled = true;
      _isStressButtonDisabled = true;
      _isResultButtonDisabled = true;
      _isEmailButtonDisabled = true;
    });

    // print("when done");

    await initList();
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
    tuningParam["permuteFirst"] = 419;
    tuningParam["permuteSecond"] = 1031;
    tuningParam["aliasedMemory"] = 0;

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
    showDialog(
      context: context,
      builder: (context) => ExplorerDialogTemplate(
        iter: _iter,
        workgroup: _workgroup,
        maxworkgroup: _maxworkgroup,
        size: _size,
        shufflepct: _shufflepct,
        barrierpct: _barrierpct,
        scratchMemSize: _scratchMemSize,
        memStressPct: _memStressPct,
        memStride: _memStride,
        memStressIter: _memStressIter,
        preStressIter: _preStressIter,
        memStressStoreFirstPct: _memStressStoreFirstPct,
        memStressStoreSecondPct: _memStressStoreSecondPct,
        preStressStoreFirstPct: _preStressStoreFirstPct,
        preStressStoreSecondPct: _preStressStoreSecondPct,
        stressLineSize: _stressLineSize,
        stressTargetLines: _stressTargetLines,
        stressAssignmentStrategy: _stressAssignmentStrategy,
        changeStress: _changeStress,
        changeDefault: _changeDefault,
        compute: _compute,
        title_: "Message Passing",
        preStressPct: _preStressPct,
      ),
    );
  }

  showTuningDialog() {
    showDialog(
        context: context,
        builder: (context) => TuningDialogTemplate(
          tIter: _tIter,
          tConfigNum: _tConfigNum, 
          tRandomSeed: _tRandomSeed, 
          tWorkgroup: _tWorkgroup, 
          tMaxworkgroup: _tMaxworkgroup, 
          tSize: _tSize,
          tuningClick: _tuningClick,
        ),
    );
  }

  // print("controller is active");

  @override
  Widget build(BuildContext context) {
    final String page =
    "The message passing litmus test checks to see if two stores in one thread can be re-ordered according to loads on a second thread";
    final String init_state = "*x = 0, *y = 0";
    final String final_state = "r0 == 1 && r1 == 0";
    final String workgroup0_thread0_text1 =
        "0.1: atomic_store_explicit (x,1,memory_order_relaxed)";
    final String workgroup0_thread0_text2 =
        "0.2: atomic_store_explicit (y,1,memory_order_relaxed)";
    final String workgroup1_thread0_text1 =
        "1.1: r0 = atomic_load_explicit (y,memory_order_relaxed)";
    final String workgroup1_thread0_text2 =
        "1.2: r1 = atomic_load_explicit (x,memory_order_relaxed)";
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Container(color: Color(0xFF1F3DD2), height: 1.0),
        ),
      ),
      body: TestPageTemplateWidget(
        title: title,
        page: page,
        init_state: init_state,
        final_state: final_state,
        workgroup0_thread0_text1: workgroup0_thread0_text1,
        workgroup0_thread0_text2: workgroup0_thread0_text2,
        workgroup1_thread0_text1: workgroup1_thread0_text1,
        workgroup1_thread0_text2: workgroup1_thread0_text2,
        isExplorerButtonDisabled: _isExplorerButtonDisabled,
        showExplorerDialog: showExplorerDialog,
        isStressButtonDisabled: _isStressButtonDisabled,
        showTuningDialog: showTuningDialog,
        isResultButtonDisabled: _isResultButtonDisabled,
        results: _results,
        isEmailButtonDisabled: _isEmailButtonDisabled,
        email: _email,
        percentageValue: _percentageValue,
        iterationMssg: _iterationMssg,
        visibleIndicator: _visibleIndicator,
        visibleBarChart: _visibleBarChart,
      ),
    );
  }
}
