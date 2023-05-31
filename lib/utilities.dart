import 'dart:async';
import 'dart:convert';
import 'dart:io';
//import 'dart:js_interop';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/services.dart';
import 'dart:isolate';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
//import 'package:flutter_isolate/flutter_isolate.dart';

typedef Native_Dart_InitializeApiDL = Int32 Function(Pointer<Void> data);
typedef FFI_Dart_InitializeApiDL = int Function(Pointer<Void> data);
typedef StartWorkType = Void Function(Int64 port);
typedef StartWorkFunc = void Function(int port);

String param_tmp = "assets/parameters.txt";

//const platformMethodChannel = MethodChannel('com.flutter.gpuiosbundle/getPath');

final controller = StreamController.broadcast();

String cache = "";

var iter = 0;
String outputFile = "";
String tuningOutputFile = "";
String conformanceOutputFile = "";

var tuningRandom = Random();
int tuningrandomSeed = 10;
int currTestIterations = 1;
int tuningTestWorkgroups = 0;
int tuningMaxWorkgroups = 0;
int tuningWorkgroupSize = 0;
int numConfig = 0;

Future<String> getPathCacheAssets(String arg) async {
  //load the file from assets
  ByteData byteData = await rootBundle.load(arg);

  // this creates the file image

  File file = await File('$cache/$arg').create(recursive: true);

  // copies data byte by byte
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return "$cache/$arg";
}

/////// message passer c++ to dart//////////
void mssg_init(SendPort port) {
  DynamicLibrary nativeApi = Platform.isAndroid
      ? DynamicLibrary.open('libnative_litmus.so')
      : DynamicLibrary.process();

//  Dart_InitializeApiDL defined in Dart SDK (implemented in dart_api_dl.c)
  FFI_Dart_InitializeApiDL initializeFunc = nativeApi.lookupFunction<
      Native_Dart_InitializeApiDL, FFI_Dart_InitializeApiDL>("initDartApiDL");

  if (initializeFunc(NativeApi.initializeApiDLData) != 0) {
    throw "Failed to initialize Dart API";
  }

  final StartWorkFunc startWork =
      nativeApi.lookup<NativeFunction<StartWorkType>>("startWork").asFunction();

  final interactiveCppRequests = ReceivePort();

  interactiveCppRequests.listen((data) {
    iter = data;
    // print('Received: $iter from C++');
    port.send(data);
    // interactiveCppRequests.close();
  });

  final int nativePort = interactiveCppRequests.sendPort.nativePort;

// first we establish the port details
  startWork(nativePort);
}

// I am platform channel code
// Future<String> printy(String arg) async {
//   dynamic tmp;

//   print(arg);

//   try {
//     tmp = await platformMethodChannel.invokeMethod<String>('printy', arg);

//     print(tmp);
//   } catch (e) {
//     print(e);
//   }

//   return tmp;
// }

int hashCode(String s) {
  var h = 0, l = s.length, i = 0;
  if (l > 0) {
    while (i < l) {
      // print(s[i]);
      h = (h << 5) - h + s.codeUnitAt(i);
      i += 1;
    }
  }
  return h;
}

class PRNGInternal {
  var seed;
  PRNGInternal(var seed) {
    this.seed = hashCode(seed);
    if (this.seed <= 0) this.seed += 2147483646;
  }
}

int prngGen(var seed) {
  var prng = PRNGInternal(seed);

  var x = prng.seed;
  var y = 16807;

  prng.seed = (x.toUnsigned(32) * y.toUnsigned(32)).toSigned(32) % 2147483646;
  if (prng.seed < 0) prng.seed += 2147483646;

  return prng.seed;
}

/// I am isolate code/////
class FFIBridge {
  //static var tuningShader

  static int randomGenerator(int min, int max) {
    return tuningRandom.nextInt(10) % (max - min + 1) + min;
  }

  static int getPercentage(bool smoothedParameters) {
    if (smoothedParameters) {
      return roundedPercentage();
    } else {
      return randomGenerator(0, 100);
    }
  }

  static int roundedPercentage() {
    return (((randomGenerator(0, 100) / 5)) * 5).toInt();
  }

  static Future<void> writetuningParams(var type, bool reset) async {
    bool smoothedParameters = false;
    int workgroupLimiter = tuningMaxWorkgroups;

    //print("lets write");

    Map<String, dynamic> tuningParam = new Map();

    int testingWorkgroups =
        randomGenerator(tuningTestWorkgroups, workgroupLimiter);
    int workgroupSize = randomGenerator(1, tuningWorkgroupSize);
    int maxWorkgroups = randomGenerator(testingWorkgroups, workgroupLimiter);
    num stressLineSize = pow(2, randomGenerator(2, 10).toInt());
    int stressTargetLines = randomGenerator(1, 16);
    int memStride = randomGenerator(1, 7);
    tuningParam["iterations"] = currTestIterations;
    tuningParam["testingWorkgroups"] = testingWorkgroups;
    tuningParam["maxWorkgroups"] = (maxWorkgroups);
    tuningParam["workgroupSize"] = (workgroupSize);
    tuningParam["shufflePct"] = getPercentage(smoothedParameters);
    tuningParam["barrierPct"] = getPercentage(smoothedParameters);
    tuningParam["scratchMemorySize"] =
        (32 * stressLineSize * stressTargetLines);
    tuningParam["memStride"] = memStride;
    tuningParam["memStressPct"] = getPercentage(smoothedParameters);
    tuningParam["preStressPct"] = getPercentage(smoothedParameters);
    tuningParam["memStressIterations"] = randomGenerator(0, 1024);
    tuningParam["preStressIterations"] = randomGenerator(0, 128);
    tuningParam["stressLineSize"] = stressLineSize;
    tuningParam["stressTargetLines"] = stressTargetLines;
    tuningParam["stressStrategyBalancePct"] = getPercentage(smoothedParameters);
    tuningParam["memStressStoreFirstPct"] = getPercentage(smoothedParameters);
    tuningParam["memStressStoreSecondPct"] = getPercentage(smoothedParameters);
    tuningParam["preStressStoreFirstPct"] = getPercentage(smoothedParameters);
    tuningParam["preStressStoreSecondPct"] = getPercentage(smoothedParameters);
    tuningParam["numMemLocations"] = 2;
    tuningParam["numOutputs"] = 2;

    Directory tempDir = await getTemporaryDirectory();

    // assign the global path value
    cache = tempDir.path;

    param_tmp = "$cache" + "/assets/parameters.txt";

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

    // File(param_tmp)
    //     .openRead()
    //     .transform(utf8.decoder)
    //     .transform(LineSplitter())
    //     .forEach((l) => print('line: $l'));
  }

  static void tuning(var testName, var spv, var res_spv, var configNum,
      var iter, String seed, var tgroup, var mgroup, var size) async {
    //print("reached here");

    //  tuningrandomSeed = int.parse(seed);

    //if ()
    //tuningrandomSeed = 10;
    currTestIterations = int.parse(iter);
    ;
    tuningTestWorkgroups = int.parse(tgroup);
    tuningMaxWorkgroups = int.parse(mgroup);
    tuningWorkgroupSize = int.parse(size);
    numConfig = int.parse(configNum);

    // this si where we use the configNum

    var fileMap = {};

    var tmpRandom = Random();

    if (seed.isEmpty) {
      tmpRandom = Random(10);
    } else {
      tmpRandom = Random(prngGen(seed));
    }

    for (int i = 0; i < numConfig; i++) {
      tuningRandom = Random(tmpRandom.nextInt(prngGen(seed)));

      await writetuningParams("Tuning Test", false);

      //print(param_tmp);

      await call_bridge(param_tmp, spv, res_spv);

      // print(outputFile);
      var tmp_Str = jsonDecode(File(outputFile).readAsStringSync());

      // fileMap["$i"] = File(outputFile).readAsStringSync();
      fileMap["$i"] = tmp_Str;

      if (await File(outputFile).exists()) {
        await File(outputFile).delete();
      }
    }

    String jsonstringmap = JsonEncoder.withIndent(' ' * 4).convert(fileMap);

    File file = await File(outputFile).create(recursive: true);

    await file.writeAsString(jsonstringmap);
  }

  static Future<void> run_isolate_lock(
      var spv, var iter, var workgroupNum, var workgroupSize) async {
    //print(rootBundle.

    Directory tempDir = await getTemporaryDirectory();

    cache = tempDir.path;

    outputFile = "$cache/output.txt";

    var shaderComp = await getPathCacheAssets(spv);

    // path to be forwared
    String path = outputFile;
    String test = "";

    print(shaderComp);
    print(iter);
    print(workgroupNum);
    print(workgroupSize);
    print(cache);

    List<String> list = [
      test,
      shaderComp,
      iter,
      workgroupNum,
      workgroupSize,
      path
    ];

    // var rPort1 = new ReceivePort();

    // rPort1.listen((data) {
    //   iter = data;
    //   controller.sink.add(data);
    //   // print('Received: $data from Isolate');
    //   // interactiveCppRequests.close();
    // });

    Map<int, dynamic> map = new Map();

    // map[1] = rPort1.sendPort;

    map[2] = list;

    //  try {
    // await Isolate.spawn(native_call, map);
    lock_native_call(map);
  }

  static void lock_native_call(Map<int, dynamic> map) {
    List<String> arg = map[2];
    // SendPort sport = map[1];

    //print("reacher here");
    // mssg_init(sport);

    DynamicLibrary nativeApiLib = Platform.isAndroid
        ? DynamicLibrary.open('libnative_litmus.so')
        : DynamicLibrary.process();

    final int Function(Pointer<Utf8> a, Pointer<Utf8> b, Pointer<Utf8> c,
            Pointer<Utf8> d, Pointer<Utf8> e, Pointer<Utf8> f) run =
        nativeApiLib
            .lookup<
                NativeFunction<
                    Int32 Function(
                        Pointer<Utf8>,
                        Pointer<Utf8>,
                        Pointer<Utf8>,
                        Pointer<Utf8>,
                        Pointer<Utf8>,
                        Pointer<Utf8>)>>('runLockTest')
            .asFunction();

    String test = "GPU Lock Test";

    //int litmus_test =

    print("starting native call");
    run(test.toNativeUtf8(), arg[1].toNativeUtf8(), arg[2].toNativeUtf8(),
        arg[3].toNativeUtf8(), arg[4].toNativeUtf8(), arg[5].toNativeUtf8());
  }

  static Future<void> run_isolate_litmus(
      var shaderComp, var shaderRes, var para, var path) async {
    // print(shaderComp);
    // print(shaderRes);
    // print(para);
    // print(path);

    //print(rootBundle.
    List<String> list = [shaderComp, shaderRes, para, path];

    var rPort1 = new ReceivePort();

    rPort1.listen((data) {
      iter = data;
      controller.sink.add(data);
      // print('Received: $data from Isolate');
      // interactiveCppRequests.close();
    });

    Map<int, dynamic> map = new Map();

    map[1] = rPort1.sendPort;
    map[2] = list;

    //  try {
    // await Isolate.spawn(native_call, map);
    limtus_native_call(map);
  }

  //@pragma('vm:entry-point')
  static void limtus_native_call(Map<int, dynamic> map) {
    List<String> arg = map[2];
    SendPort sport = map[1];

    //print("reacher here");
    mssg_init(sport);

    DynamicLibrary nativeApiLib = Platform.isAndroid
        ? DynamicLibrary.open('libnative_litmus.so')
        : DynamicLibrary.process();

    final int Function(Pointer<Utf8> a, Pointer<Utf8> b, Pointer<Utf8> c,
            Pointer<Utf8> d, Pointer<Utf8> e) run =
        nativeApiLib
            .lookup<
                NativeFunction<
                    Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
                        Pointer<Utf8>, Pointer<Utf8>)>>('runTest')
            .asFunction();

    String test = "GPU Litmus Test";

    //int litmus_test =

    print("starting native call");
    run(test.toNativeUtf8(), arg[0].toNativeUtf8(), arg[1].toNativeUtf8(),
        arg[2].toNativeUtf8(), arg[3].toNativeUtf8());
  }

  static Future<void> call(String spv, String res, String param) async {
    Directory tempDir = await getTemporaryDirectory();

    // assign the global path value
    cache = tempDir.path;

    outputFile = "$cache/output.txt";

    var shaderComp = await getPathCacheAssets(spv);
    var shaderRes = await getPathCacheAssets(res);
    // var para = await getPathCacheAssets(param);
    var para = param;

    //print(shaderComp);

    await run_isolate_litmus(shaderComp, shaderRes, para, cache);

    //  print("after isolate kill: " + outputFile);
  }

  static String getFile() {
    return outputFile;
  }
}

Future<void> call_bridge(String param, String shader, String result) async {
  await FFIBridge.call(shader, result, param);
}

void email() async {
  print(" I am in email");

  String outputPath = FFIBridge.getFile();

  final Email email = Email(
    body: 'Email body',
    subject: 'Test',
    recipients: ['anikam@ucsc.edu'],
    // cc: ['cc@example.com'],
    // bcc: ['bcc@example.com'],
    attachmentPaths: [outputPath],
    // isHTML: false,
  );

  await FlutterEmailSender.send(email);
}

Future<String> readCounter(String path) async {
  try {
    // Read the file
    File file = await get(path);
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "";
  }
}

Future<File> get(String path) async {
  //print(path);
  return File(path);
}
