import 'dart:convert';
import 'dart:ffi';
//import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
//import 'package:gpuiosbundle/forms.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:gpuiosbundle/forms.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';

String shader_spv = "assets/litmustest_message_passing_default.spv";
String result_spv = "assets/litmustest_message_passing_results.spv";
String param_basic = "assets/parameters_basic.txt";
String param_stress = "assets/parameters_stress.txt";
const String title = "Tuning/Conformance";

const String page =
    "This page is used to evaluate the performance of a set tuned parameters on uncovering potential violations of Vulkan memory consistency model. There will be two methods of running weak memory tests: running with single memory location and running with barriers between instructions. There will also be two methods of running coherence tests: running with single memory location and running with RMW instruction. A weak behaviour on any test represents a violation of Vulkan memory consistency model.";
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
class TuningPage extends StatefulWidget {
  const TuningPage({Key? key}) : super(key: key);

  @override
  State<TuningPage> createState() => _TuningPageState();
}

// extend the class
class _TuningPageState extends State<TuningPage> {
  final String _title = title;
  final _formKey = GlobalKey<FormState>();
  TextEditingController userInput = TextEditingController();

  late String _iterationMssg;
  // bool something  = true;
  late bool _visible;
  late bool _isExplorerButtonDisabled;
  late bool _isStressButtonDisabled;
  late bool _isResultButtonDisabled;
  late bool _isEmailButtonDisabled;
  late int _counter;
  final subscription = controller.stream;
  bool default_param = true;
  //late bool _visibleTable;

  List<DataRow> _rowList = [];

  var pressExplorer = false;
  var pressTuning = false;
  var pressConformance = false;

  var _visibleExplorer = false;
  var _visibleTuning = false;
  var _visibleTable = false;
  //var _visibleConformance = false;

  // var isChecked = false;

  var messagePassingCoherency = false;
  var messagePassingBarrier = false;
  var loadBufferCoherency = false;
  var loadBufferBarrier = false;
  var storeBufferCoherency = false;
  var storeBufferBarrier = false;
  var readCoherency = false;
  var readRMWBarrier = false;
  var storeCoherency = false;
  var storeBarrier = false;
  var storeBufferRMWBarrier = false;
  var twoPlusTwoWriteCoherency = false;
  var twoPlusTwoWriteRMWBarrier = false;
  var rr = false;
  var rrRMW = false;
  var rw = false;
  var rwRMW = false;
  var wr = false;
  var wrRMW = false;
  var ww = false;
  var wwRMW = false;

  var messagePassing = false;
  var messagePassingBarrier1 = false;
  var messagePassingBarrier2 = false;
  var messagePassingCoherencyTuning = false;
  var loadBuffer = false;
  var loadBufferBarrier1 = false;
  var loadBufferBarrier2 = false;
  var loadBufferCoherencyTuning = false;
  var store = false;
  var storeBarrier1 = false;
  var storeBarrier2 = false;
  var storeCoherencyTuning = false;
  var readRMW = false;
  var readRMWBarrier1 = false;
  var readRMWBarrier2 = false;
  var readCoherencyTuning = false;
  var storeBufferRMW = false;
  var storeBufferRMWBarrier1 = false;
  var storeBufferRMWBarrier2 = false;
  var storeBufferCoherencyTuning = false;
  var twoPlusTwoWriteRMW = false;
  var twoPlusTwoWriteRMWBarrier1 = false;
  var twoPlusTwoWriteRMWBarrier2 = false;
  var twoPlusTwoWriteCoherencyTuning = false;
  var rrMutant = false;
  var rrRMWMutant = false;
  var rwMutant = false;
  var rwRMWMutant = false;
  var wrMutant = false;
  var wrRMWMutant = false;
  // var wwMutant = false;
  // var wwRMWMutant = false;

  var tuningListMap = {
    "assets/litmustest_message_passing_default.spv": [
      "messagePassing",
      "assets/litmustest_message_passing_results.spv"
    ],

    "assets/litmustest_message_passing_barrier.spv": [
      "messagePassingBarrier1",
      "assets/litmustest_message_passing_results.spv"
    ],

    "assets/litmustest_message_passing_workgroup_barrier.spv": [
      "messagePassingBarrier2",
      "assets/litmustest_message_passing_results.spv"
    ],

    "assets/litmustest_message_passing_coherency.spv": [
      "messagePassingCoherencyTuning",
      "assets/litmustest_message_passing_coherency_results.spv"
    ],

    "assets/litmustest_load_buffer_default.spv": [
      "loadBuffer",
      "assets/litmustest_load_buffer_results.spv"
    ],

    "assets/litmustest_load_buffer_storage_workgroup_barrier.spv": [
      "loadBufferBarrier1",
      "assets/litmustest_load_buffer_results.spv"
    ],

    "assets/litmustest_load_buffer_workgroup_barrier.spv": [
      "loadBufferBarrier2",
      "assets/litmustest_load_buffer_results.spv"
    ],

    "assets/litmustest_load_buffer_coherency.spv": [
      "loadBufferCoherencyTuning",
      "assets/litmustest_load_buffer_coherency_results.spv"
    ],

    "assets/litmustest_store_default.spv": [
      "store",
      "assets/litmustest_store_results.spv"
    ],

    "assets/litmustest_store_storage_workgroup_barrier.spv": [
      "storeBarrier1",
      "assets/litmustest_store_results.spv"
    ],

    "assets/itmustest_store_workgroup_barrier.spv": [
      "storeBarrier2",
      "assets/litmustest_store_results.spv"
    ],

    "assets/litmustest_store_coherency.spv": [
      "storeCoherencyTuning",
      "assets/litmustest_store_coherency_results.spv"
    ],

    "assets/litmustest_read_default.spv": [
      "readRMW",
      "assets/litmustest_read_results.spv"
    ],

    "assets/litmustest_read_storage_workgroup_rmw_barrier.spv": [
      "readRMWBarrier1",
      "assets/litmustest_read_results.spv"
    ],

    "assets/litmustest_read_workgroup_rmw_barrier.spv": [
      "readRMWBarrier2",
      "assets/litmustest_read_results.spv"
    ],

    "assets/litmustest_read_coherency.spv": [
      "readCoherencyTuning",
      "assets/litmustest_read_coherency_results.spv"
    ],

    "assets/litmustest_store_buffer_default.spv": [
      "storeBufferRMW",
      "assets/litmustest_store_buffer_results.spv"
    ],

    "assets/litmustest_store_buffer_storage_workgroup_rmw_barrier.spv": [
      "storeBufferRMWBarrier1",
      "assets/litmustest_store_buffer_results.spv"
    ],

    "assets/litmustest_store_buffer_workgroup_rmw_barrier.spv": [
      "storeBufferRMWBarrier2",
      "assets/litmustest_store_buffer_results.spv"
    ],

    "assets/litmustest_store_buffer_coherency.spv": [
      "storeBufferCoherencyTuning",
      "assets/litmustest_store_buffer_coherency_results.spv"
    ],

    "assets/litmustest_write_22_default.spv": [
      "twoPlusTwoWriteRMW",
      "assets/litmustest_write_22_results.spv"
    ],

    "assets/litmustest_write_22_storage_workgroup_rmw_barrier.spv": [
      "twoPlusTwoWriteRMWBarrier1",
      "assets/litmustest_write_22_results.spv"
    ],

    "assets/litmustest_write_22_workgroup_rmw_barrier.spv": [
      "twoPlusTwoWriteRMWBarrier2",
      "assets/litmustest_write_22_results.spv"
    ],

    "assets/itmustest_write_22_coherency.spv": [
      "twoPlusTwoWriteCoherencyTuning",
      "assets/litmustest_write_22_coherency_results.spv"
    ],

    "assets/litmustest_corr_mutation.spv": [
      "rrMutant",
      "assets/litmustest_corr_results.spv"
    ],

    "assets/litmustest_corr_rmw_mutation.spv": [
      "rrRMWMutant",
      "assets/litmustest_corr_results.spv"
    ],

    "assets/litmustest_corw2_mutation.spv": [
      "rwMutant",
      "assets/litmustest_corw2_results.spv"
    ],

    "assets/litmustest_corw2_rmw_mutation.spv": [
      "rwRMWMutant",
      "assets/litmustest_corw2_results.spv"
    ],

    "assets/litmustest_cowr_mutation.spv": [
      "wrMutant",
      "assets/litmustest_cowr_results.spv"
    ],

    "assets/litmustest_cowr_rmw1_mutation.spv": [
      "wrRMWMutant",
      "assets/llitmustest_cowr_results.spv"
    ],
    // "assets/litmustest_coww_rmw.spv": wwMutant,
    // "assets/litmustest_coww_rmw.spv": wwRMWMutant,
  };

  var tuningList = {};
  var conformanceList = {};

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
    _visible = false;
    _visibleTable = false;
    _iterationMssg = "Counter is 0";

    var conformanceList = {
      "assets/litmustest_message_passing_coherency.spv":
          messagePassingCoherency,
      "assets/litmustest_message_passing_barrier.spv": messagePassingBarrier,
      "assets/litmustest_store_coherency.spv": storeCoherency,
      "assets/litmustest_store_barrier.spv": storeBarrier,
      "assets/litmustest_read_coherency.spv": readCoherency,
      "assets/litmustest_read_barrier.spv": readRMWBarrier,
      "assets/litmustest_load_buffer_coherency.spv": loadBufferCoherency,
      "assets/litmustest_load_buffer_barrier.spv": loadBufferBarrier,
      "assets/litmustest_store_buffer_coherency.spv": storeBufferCoherency,
      "assets/litmustest_store_buffer_rmw_barrier.spv": storeBufferRMWBarrier,
      "assets/litmustest_write_22_coherency.spv": twoPlusTwoWriteCoherency,
      "assets/litmustest_write_22_rmw_barrier.spv": twoPlusTwoWriteRMWBarrier,
      "assets/litmustest_corr_default.spv": rr,
      "assets/litmustest_corr_rmw.spv": rrRMW,
      "assets/litmustest_corw2_default.spv": rw,
      "assets/litmustest_corw2_rmw.spv": rwRMW,
      "assets/litmustest_cowr_default.spv": wr,
      "assets/litmustest_cowr_rmw.spv": wrRMW,
      "assets/litmustest_coww_default.spv": ww,
      "assets/litmustest_coww_rmw.spv": wwRMW,
    };

    var tuningList = {
      "assets/litmustest_message_passing_default.spv": messagePassing,
      "assets/litmustest_message_passing_barrier.spv": messagePassingBarrier1,
      "assets/litmustest_message_passing_workgroup_barrier.spv":
          messagePassingBarrier2,
      "assets/litmustest_message_passing_coherency.spv":
          messagePassingCoherencyTuning,
      "assets/litmustest_load_buffer_default.spv": loadBuffer,
      "assets/litmustest_load_buffer_storage_workgroup_barrier.spv":
          loadBufferBarrier1,
      "assets/litmustest_load_buffer_workgroup_barrier.spv": loadBufferBarrier2,
      "assets/litmustest_load_buffer_coherency.spv": loadBufferCoherencyTuning,
      "assets/litmustest_store_default.spv": store,
      "assets/litmustest_store_storage_workgroup_barrier.spv": storeBarrier1,
      "assets/itmustest_store_workgroup_barrier.spv": storeBarrier2,
      "assets/litmustest_store_coherency.spv": storeCoherencyTuning,
      "assets/litmustest_read_default.spv": readRMW,
      "assets/litmustest_read_storage_workgroup_rmw_barrier.spv":
          readRMWBarrier1,
      "assets/litmustest_read_workgroup_rmw_barrier.spv": readRMWBarrier2,
      "assets/litmustest_read_coherency.spv": readCoherencyTuning,
      "assets/litmustest_store_buffer_default.spv": storeBufferRMW,
      "assets/litmustest_store_buffer_storage_workgroup_rmw_barrier.spv":
          storeBufferRMWBarrier1,
      "assets/litmustest_store_buffer_workgroup_rmw_barrier.spv":
          storeBufferRMWBarrier2,
      "assets/litmustest_store_buffer_coherency.spv":
          storeBufferCoherencyTuning,
      "assets/litmustest_write_22_default.spv": twoPlusTwoWriteRMW,
      "assets/litmustest_write_22_storage_workgroup_rmw_barrier.spv":
          twoPlusTwoWriteRMWBarrier1,
      "assets/litmustest_write_22_workgroup_rmw_barrier.spv":
          twoPlusTwoWriteRMWBarrier2,
      "assets/itmustest_write_22_coherency.spv": twoPlusTwoWriteCoherencyTuning,
      "assets/litmustest_corr_mutation.spv": rrMutant,
      "assets/litmustest_corr_rmw_mutation.spv": rrRMWMutant,
      "assets/litmustest_corw2_mutation.spv": rwMutant,
      "assets/litmustest_corw2_rmw_mutation.spv": rwRMWMutant,
      "assets/litmustest_cowr_mutation.spv": wrMutant,
      "assets/litmustest_cowr_rmw1_mutation.spv": wrRMWMutant,
      // "assets/litmustest_coww_rmw.spv": wwMutant,
      // "assets/litmustest_coww_rmw.spv": wwRMWMutant,
    };
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // void _addRow() {
  //   // Built in Flutter Method.
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below.
  //     _rowList.add(DataRow(cells: <DataCell>[
  //       DataCell(Text('BBBBBB')),
  //       DataCell(Text('2')),
  //       DataCell(Text('No')),
  //     ]));
  //   });
  // }

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

  void _computeTuning() async {
    setState(() {
      _counter = 0;
      _iterationMssg = "Computed $_counter from 100";
      _visible = true;
      _visibleTable = true;
    });

    subscription.listen((data) {
      _counter = data;
      // print(_counter);
      setState(() {
        _iterationMssg = "Computed $_counter from 100";
      });
    });

    //use the selected logic

    var active_shaders = [];

    tuningList.forEach((key, value) {
      if (value == true) {
        active_shaders.add(key);
      }
    });

    currTestIterations = int.parse(_tIter.text);
    tuningTestWorkgroups = int.parse(_tWorkgroup.text);
    tuningMaxWorkgroups = int.parse(_tMaxworkgroup.text);
    tuningWorkgroupSize = int.parse(_tSize.text);
    numConfig = int.parse(_tConfigNum.text);
    var seed = _tRandomSeed.text;

    var fileMap = {};

    var tmpRandom = Random();

    if (seed.isEmpty) {
      tmpRandom = Random(10);
    } else {
      tmpRandom = Random(prngGen(seed));
    }

    var tuningoutput = "$cache" + "/tuning.txt";

    for (int i = 0; i < numConfig; i++) {
      // var tuningRandom = Random(tmpRandom.nextInt(prngGen(seed)));

      // // create the parameters
      // await FFIBridge.writetuningParams("Tuning Test", false);

      // // open a outputFile
      // File file = await File(tuningoutput).create(recursive: true);

      // for (int i = 0; i < active_shaders.length; i++) {
      //   await call_bridge(
      //       param_tmp, active_shaders[i], tuningListMap[active_shaders[i]]![1]);
      //   var tmp_Str = File(outputFile).readAsStringSync();
      //   await file.writeAsString(tmp_Str, mode: FileMode.append);
      // }

      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below.

        _rowList.add(DataRow(cells: <DataCell>[
          DataCell(Text('$i')),
          DataCell(MaterialButton(
            onPressed: () {},
            child: Text("Statistics"),
            color: Colors.blue,
          )),
          DataCell(Text('No')),
          DataCell(Text('No')),
          DataCell(Text('No')),
          DataCell(Text('No')),
          DataCell(Text('No')),
          DataCell(Text('No')),
        ]));
      });
    }
  }

  void _compute() async {
    setState(() {
      _counter = 0;

      _isExplorerButtonDisabled = false;
      _isStressButtonDisabled = false;
      _isResultButtonDisabled = false;
      _isEmailButtonDisabled = false;

      _iterationMssg = "Computed $_counter from 100";
      _visible = true;
      _visibleTable = true;
    });

    subscription.listen((data) {
      _counter = data;
      // print(_counter);
      setState(() {
        _iterationMssg = "Computed $_counter from 100";
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

  void _chooseConformanceTests() {
    setState(() {
      messagePassingCoherency = true;
      messagePassingBarrier = true;
      loadBufferCoherency = true;
      loadBufferBarrier = true;
      storeCoherency = true;
      storeBarrier = true;
      readCoherency = true;
      readRMWBarrier = true;
      storeBufferCoherency = true;
      storeBufferRMWBarrier = true;
      twoPlusTwoWriteCoherency = true;
      twoPlusTwoWriteRMWBarrier = true;
      rr = true;
      rrRMW = true;
      rw = true;
      rwRMW = true;
      wr = true;
      wrRMW = true;
      ww = true;
      wwRMW = true;
    });
  }

  void _chooseTuning() {
    setState(() {
      messagePassing = true;
      messagePassingBarrier1 = true;
      messagePassingBarrier2 = true;
      messagePassingCoherencyTuning = true;
      loadBuffer = true;
      loadBufferBarrier1 = true;
      loadBufferBarrier2 = true;
      loadBufferCoherencyTuning = true;
      store = true;
      storeBarrier1 = true;
      storeBarrier2 = true;
      storeCoherencyTuning = true;
      readRMW = true;
      readRMWBarrier1 = true;
      readRMWBarrier2 = true;
      readCoherencyTuning = true;
      storeBufferRMW = true;
      storeBufferRMWBarrier1 = true;
      storeBufferRMWBarrier2 = true;
      storeBufferCoherencyTuning = true;
      twoPlusTwoWriteRMW = true;
      twoPlusTwoWriteRMWBarrier1 = true;
      twoPlusTwoWriteRMWBarrier2 = true;
      twoPlusTwoWriteCoherencyTuning = true;
      rrMutant = true;
      rrRMWMutant = true;
      rwMutant = true;
      rwRMWMutant = true;
      wrMutant = true;
      wrRMWMutant = true;
    });
  }

  void _chooseAllTests() {
    setState(() {
      messagePassingCoherency = true;
      messagePassingBarrier = true;
      loadBufferCoherency = true;
      loadBufferBarrier = true;
      storeCoherency = true;
      storeBarrier = true;
      readCoherency = true;
      readRMWBarrier = true;
      storeBufferCoherency = true;
      storeBufferRMWBarrier = true;
      twoPlusTwoWriteCoherency = true;
      twoPlusTwoWriteRMWBarrier = true;
      rr = true;
      rrRMW = true;
      rw = true;
      rwRMW = true;
      wr = true;
      wrRMW = true;
      ww = true;
      wwRMW = true;

      messagePassing = true;
      messagePassingBarrier1 = true;
      messagePassingBarrier2 = true;
      messagePassingCoherencyTuning = true;
      loadBuffer = true;
      loadBufferBarrier1 = true;
      loadBufferBarrier2 = true;
      loadBufferCoherencyTuning = true;
      store = true;
      storeBarrier1 = true;
      storeBarrier2 = true;
      storeCoherencyTuning = true;
      readRMW = true;
      readRMWBarrier1 = true;
      readRMWBarrier2 = true;
      readCoherencyTuning = true;
      storeBufferRMW = true;
      storeBufferRMWBarrier1 = true;
      storeBufferRMWBarrier2 = true;
      storeBufferCoherencyTuning = true;
      twoPlusTwoWriteRMW = true;
      twoPlusTwoWriteRMWBarrier1 = true;
      twoPlusTwoWriteRMWBarrier2 = true;
      twoPlusTwoWriteCoherencyTuning = true;
      rrMutant = true;
      rrRMWMutant = true;
      rwMutant = true;
      rwRMWMutant = true;
      wrMutant = true;
      wrRMWMutant = true;
    });
  }

  void _chooseClearSelection() {
    setState(() {
      messagePassingCoherency = false;
      messagePassingBarrier = false;
      loadBufferCoherency = false;
      loadBufferBarrier = false;
      storeCoherency = false;
      storeBarrier = false;
      readCoherency = false;
      readRMWBarrier = false;
      storeBufferCoherency = false;
      storeBufferRMWBarrier = false;
      twoPlusTwoWriteCoherency = false;
      twoPlusTwoWriteRMWBarrier = false;
      rr = false;
      rrRMW = false;
      rw = false;
      rwRMW = false;
      wr = false;
      wrRMW = false;
      ww = false;
      wwRMW = false;

      messagePassing = false;
      messagePassingBarrier1 = false;
      messagePassingBarrier2 = false;
      messagePassingCoherencyTuning = false;
      loadBuffer = false;
      loadBufferBarrier1 = false;
      loadBufferBarrier2 = false;
      loadBufferCoherencyTuning = false;
      store = false;
      storeBarrier1 = false;
      storeBarrier2 = false;
      storeCoherencyTuning = false;
      readRMW = false;
      readRMWBarrier1 = false;
      readRMWBarrier2 = false;
      readCoherencyTuning = false;
      storeBufferRMW = false;
      storeBufferRMWBarrier1 = false;
      storeBufferRMWBarrier2 = false;
      storeBufferCoherencyTuning = false;
      twoPlusTwoWriteRMW = false;
      twoPlusTwoWriteRMWBarrier1 = false;
      twoPlusTwoWriteRMWBarrier2 = false;
      twoPlusTwoWriteCoherencyTuning = false;
      rrMutant = false;
      rrRMWMutant = false;
      rwMutant = false;
      rwRMWMutant = false;
      wrMutant = false;
      wrRMWMutant = false;
    });
  }

  showExplorerDialog() {
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
      body: SingleChildScrollView(
        child: Container(
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
                const Text(
                  'Test List',
                  // style: TextStyle(fontSize: 18.0),
                  //  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Conformance Test',
                    style: TextStyle(
                      color: Colors.grey,

                      //   overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                //  Row(mainAxisSize: MainAxisSize.min,
                Wrap(children: <Widget>[
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: messagePassingCoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          messagePassing = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'messagePassingCoherency',
                        // textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: messagePassingBarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          messagePassingBarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'messagePassingBarrier',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadBufferCoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          loadBufferCoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: Text(
                        'loadBufferCoherency',
                        // textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                  //    ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadBufferBarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          loadBufferBarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'loadBufferBarrier',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeCoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          storeCoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'storeCoherency',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'storeBarrier',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readCoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          readCoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'readCoherency',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readRMWBarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          readRMWBarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'readRMWBarrier',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBufferCoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBufferCoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'storeBufferCoherency',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBufferRMWBarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBufferRMWBarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'storeBufferRMWBarrier',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoPlusTwoWriteCoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          twoPlusTwoWriteCoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'twoPlusTwoWriteCoherency',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoPlusTwoWriteRMWBarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          twoPlusTwoWriteRMWBarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'twoPlusTwoWriteRMWBarrier',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rr,
                      onChanged: (bool? value) {
                        setState(() {
                          rr = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'rr',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rrRMW,
                      onChanged: (bool? value) {
                        setState(() {
                          rrRMW = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'rrRMW',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rw,
                      onChanged: (bool? value) {
                        setState(() {
                          rw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'rw',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rwRMW,
                      onChanged: (bool? value) {
                        setState(() {
                          rwRMW = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'rwRMW',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wr,
                      onChanged: (bool? value) {
                        setState(() {
                          wr = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'wr',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wrRMW,
                      onChanged: (bool? value) {
                        setState(() {
                          wrRMW = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'wrRMW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: ww,
                      onChanged: (bool? value) {
                        setState(() {
                          ww = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'ww',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wwRMW,
                      onChanged: (bool? value) {
                        setState(() {
                          wwRMW = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'wwRMW',
                      ),
                    ),
                  ]),
                ]),

                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Tuning Tests',
                    style: TextStyle(
                      color: Colors.grey,

                      //   overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                Wrap(children: [
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: messagePassing,
                      onChanged: (bool? value) {
                        setState(() {
                          messagePassing = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'messagePassing',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: messagePassingBarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          messagePassingBarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'messagePassingBarrier1',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: messagePassingBarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          messagePassingBarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'messagePassingBarrier2',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: messagePassingCoherencyTuning,
                      onChanged: (bool? value) {
                        setState(() {
                          messagePassingCoherencyTuning = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'messagePassingCoherencyTuning',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadBuffer,
                      onChanged: (bool? value) {
                        setState(() {
                          loadBuffer = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'loadBuffer',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadBufferBarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          loadBufferBarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'loadBufferBarrier1',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadBufferBarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          loadBufferBarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'loadBufferBarrier2',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadBufferCoherencyTuning,
                      onChanged: (bool? value) {
                        setState(() {
                          loadBufferCoherencyTuning = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'loadBufferCoherencyTuning',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: store,
                      onChanged: (bool? value) {
                        setState(() {
                          store = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'store',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'storeBarrier1',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'storeBarrier2',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeCoherencyTuning,
                      onChanged: (bool? value) {
                        setState(() {
                          storeCoherencyTuning = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'storeCoherencyTuning',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readRMW,
                      onChanged: (bool? value) {
                        setState(() {
                          readRMW = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'readRMW',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readRMWBarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          readRMWBarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'readRMWBarrier1',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readRMWBarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          readRMWBarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'readRMWBarrier2',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readCoherencyTuning,
                      onChanged: (bool? value) {
                        setState(() {
                          readCoherencyTuning = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'readCoherencyTuning',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBufferRMW,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBufferRMW = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'storeBufferRMW',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBufferRMWBarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBufferRMWBarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'storeBufferRMWBarrier1',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBufferRMWBarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBufferRMWBarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'storeBufferRMWBarrier2',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storeBufferCoherencyTuning,
                      onChanged: (bool? value) {
                        setState(() {
                          storeBufferCoherencyTuning = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'storeBufferCoherencyTuning',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoPlusTwoWriteRMW,
                      onChanged: (bool? value) {
                        setState(() {
                          twoPlusTwoWriteRMW = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'twoPlusTwoWriteRMW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoPlusTwoWriteRMWBarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          twoPlusTwoWriteRMWBarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'twoPlusTwoWriteRMWBarrier1',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoPlusTwoWriteRMWBarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          twoPlusTwoWriteRMWBarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'twoPlusTwoWriteRMWBarrier2',
                      ),
                    ),
                  ]),

                  //more8
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoPlusTwoWriteCoherencyTuning,
                      onChanged: (bool? value) {
                        setState(() {
                          twoPlusTwoWriteCoherencyTuning = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'twoPlusTwoWriteCoherencyTuning',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rrMutant,
                      onChanged: (bool? value) {
                        setState(() {
                          rrMutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'rrMutant',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rrRMWMutant,
                      onChanged: (bool? value) {
                        setState(() {
                          rrRMWMutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'rrRMWMutant',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rwMutant,
                      onChanged: (bool? value) {
                        setState(() {
                          rwMutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'rwMutant',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rwRMWMutant,
                      onChanged: (bool? value) {
                        setState(() {
                          rwRMWMutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'rwRMWMutant',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wrMutant,
                      onChanged: (bool? value) {
                        setState(() {
                          wrMutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'wrMutant',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wrRMWMutant,
                      onChanged: (bool? value) {
                        setState(() {
                          wrRMWMutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'wrRMWMutant',
                      ),
                    ),
                  ]),
                  // Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  //   Checkbox(
                  //     // title: Text('Message Passing'),
                  //     activeColor: Colors.white,
                  //     checkColor: Colors.blue,
                  //     value: wwMutant,
                  //     onChanged: (bool? value) {
                  //       setState(() {
                  //         wwMutant = value!;
                  //       });
                  //     },
                  //   ),
                  //   Container(
                  //     // width: double.infinity,
                  //     width: 75,
                  //     child: const Text(
                  //       'wwMutant',
                  //     ),
                  //   ),
                  // ]),
                  // Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  //   Checkbox(
                  //     // title: Text('Message Passing'),
                  //     activeColor: Colors.white,
                  //     checkColor: Colors.blue,
                  //     value: wwRMWMutant,
                  //     onChanged: (bool? value) {
                  //       setState(() {
                  //         wwRMWMutant = value!;
                  //       });
                  //     },
                  //   ),
                  //   Container(
                  //     // width: double.infinity,
                  //     width: 75,
                  //     child: const Text(
                  //       'wwRMWMutant',
                  //     ),
                  //   ),
                  // ]),
                ]),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Presets',
                    style: TextStyle(
                      color: Colors.grey,

                      //   overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 180, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseConformanceTests,
                          child: const Text('Conformance Tests'),
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
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseTuning,
                          child: const Text('Tuning Tests'),
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
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseAllTests,
                          child: Text('All Tests'),
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
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseClearSelection,
                          child: const Text('Clear Selection'),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Test Type',
                    style: TextStyle(fontSize: 18.0),
                    //   overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 140, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: pressExplorer
                                ? MaterialStatePropertyAll<Color>(Colors.green)
                                : MaterialStatePropertyAll<Color>(Colors.grey),
                          ),
                          onPressed: () {
                            setState(() {
                              pressExplorer = true;
                              pressTuning = false;
                              pressConformance = false;
                              _visibleExplorer = true;
                              _visibleTuning = false;
                            });
                          },
                          child: const Text('Explorer'),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 30),

                    SizedBox(
                      width: 140, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: pressTuning
                                ? MaterialStatePropertyAll<Color>(Colors.green)
                                : MaterialStatePropertyAll<Color>(Colors.grey),
                          ),
                          onPressed: () {
                            setState(() {
                              pressTuning = true;
                              pressExplorer = false;
                              pressConformance = false;
                              _visibleExplorer = false;
                              _visibleTuning = true;
                              _visibleTable = true;

                              _computeTuning();
                            });
                          },
                          child: const Text('Tuning'),
                        ),
                      ),
                    ),
                    //  const SizedBox(height: 30),

                    SizedBox(
                      width: 140, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: pressConformance
                                ? MaterialStatePropertyAll<Color>(Colors.green)
                                : MaterialStatePropertyAll<Color>(Colors.grey),
                          ),
                          onPressed: () {
                            setState(() {
                              pressTuning = false;
                              pressExplorer = false;
                              pressConformance = true;
                              _visibleExplorer = false;
                              _visibleTuning = true;
                            });
                          },
                          child: Text('Tune/Conform'),
                        ),
                      ),
                    ),
                  ],
                ),

                Visibility(
                  visible: _visibleExplorer,
                  child: Container(
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
                                              controller:
                                                  _memStressStoreFirstPct,
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
                                              controller:
                                                  _memStressStoreSecondPct,
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
                                              controller:
                                                  _preStressStoreFirstPct,
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
                                              controller:
                                                  _preStressStoreSecondPct,
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
                                              controller:
                                                  _stressAssignmentStrategy,
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
                ),

                Visibility(
                  visible: _visibleTuning,
                  child: Container(
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
                ),
                Visibility(
                  child: Text(_iterationMssg),
                  visible: _visible,
                ),
                Visibility(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(columns: [
                      DataColumn(label: Text('Run Number')),
                      DataColumn(label: Text('Run Statistics')),
                      DataColumn(label: Text('Test Completed')),
                      DataColumn(label: Text('Overall Progress')),
                      DataColumn(label: Text('Time (seconds)')),
                      DataColumn(label: Text('Sequential')),
                      DataColumn(label: Text('Interleaved')),
                      DataColumn(label: Text('Weak')),
                    ], rows: _rowList),
                  ),
                  visible: _visibleTable,
                ),
              ]),
        ),
      ),
    );
  }
}
