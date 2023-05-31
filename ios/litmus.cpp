//
//  litmus.cpp
//  Runner
//
//  Created by Abhijeet Nikam on 19/03/23.
//

//#include <CoreFoundation/CoreFoundation.h>

#include <stdio.h>

#include <map>
#include <set>
#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <chrono>
#include <unistd.h>
//#include <jni.h>
//#include <android/log.h>
#include "easyvk.hpp"

#include "json.hpp"

#include "dart_api_dl.h"
#include "dart_native_api.h"
//#include "dart_api_dl.h"

using namespace std;
using namespace nlohmann;


//Receives NativePort ID from Flutter code
static Dart_Port dart_port = 0;

int iter = 0;
//int total_iter = 0;

json j;

string jsonString;

DART_EXPORT intptr_t initDartApiDL(void* data) {
   return Dart_InitializeApiDL(data);
}

// Ensure that the function is not-mangled; exported as a pure C function
//static Dart_Port_DL dart_port = 0;

extern "C" /* <= C++ only */ __attribute__((visibility("default"))) __attribute__((used))

void startWork( Dart_Port sendPort)
{
   // here receive the port and assign it once
   dart_port = sendPort;
}

extern "C" /* <= C++ only */ __attribute__((visibility("default"))) __attribute__((used))

void work( Dart_Port sendPort)
{
//
    sendPort = dart_port;
    Dart_CObject msg;
    msg.type = Dart_CObject_kInt64;
//
//   // cout<< "c++ :" << message << "\n";
//    msg.value.as_string = ;
   // The function is thread-safe; you can call it anywhere on your C++ code
   msg.value.as_int64 =  iter;

   // this is the place where we keep sending the data back
   Dart_PostCObject_DL(sendPort, &msg);
}



using namespace std;
using namespace easyvk;

//#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__))

using namespace std;
using namespace easyvk;

const int size = 4;
//constexpr char *TAG = "Main";

constexpr char *TAG = "Main";

bool tuningMode = false;
bool conformanceMode = false;



/** Returns the GPU to use for this test run. */
Device getDevice(Instance &instance, map<string, int> params, ofstream &outputFile) {
    int idx = 0;
    if (params.find("gpuDeviceId") != params.end()) {
        int j = 0;
        for (Device _device : instance.devices()) {
            if (_device.properties().deviceID == params["gpuDeviceId"]) {
                idx = j;
                _device.teardown();
                break;
            }
            j++;
            _device.teardown();
        }
    }
    Device device = instance.devices().at(idx);
    if(!tuningMode) {
       // outputFile << "Device: " << device.properties().deviceName << "\n";
      //  outputFile << "\n";
    }
    return device;
}


/** Zeroes out the specified buffer. */
void clearMemory(Buffer &gpuMem, int size) {
    for (int i = 0; i < size; i++) {
        gpuMem.store(i, 0);
    }
}

/** Checks whether a random value is less than a given percentage. Used for parameters like memory stress that should only
 *  apply some percentage of iterations.
 */
bool percentageCheck(int percentage) {
    return rand() % 100 < percentage;
}

/** Assigns shuffled workgroup ids, using the shufflePct to determine whether the ids should be shuffled this iteration. */
void setShuffledWorkgroups(Buffer &shuffledWorkgroups, int numWorkgroups, int shufflePct) {
    for (int i = 0; i < numWorkgroups; i++) {
        shuffledWorkgroups.store(i, i);
    }
    if (percentageCheck(shufflePct)) {
        for (int i = numWorkgroups - 1; i > 0; i--) {
            int swap = rand() % (i + 1);
            int temp = shuffledWorkgroups.load(i);
            shuffledWorkgroups.store(i, shuffledWorkgroups.load(swap));
            shuffledWorkgroups.store(swap, temp);
        }
    }
}

/** Sets the stress regions and the location in each region to be stressed. Uses the stress assignment strategy to assign
  * workgroups to specific stress locations. Assignment strategy 0 corresponds to a "round-robin" assignment where consecutive
  * threads access separate scratch locations, while assignment strategy 1 corresponds to a "chunking" assignment where a group
  * of consecutive threads access the same location.
  */
void setScratchLocations(Buffer &locations, int numWorkgroups, map<string, int> params) {
    set <int> usedRegions;
    int numRegions = params["scratchMemorySize"] / params["stressLineSize"];
    bool roundRobinAssignStrategy = percentageCheck(params["stressStrategyBalancePct"]);
    for (int i = 0; i < params["stressTargetLines"]; i++) {
        int region = rand() % numRegions;
        while(usedRegions.count(region))
            region = rand() % numRegions;
        int locInRegion = rand() % (params["stressLineSize"]);
        if (roundRobinAssignStrategy) {
            for (int j = i; j < numWorkgroups; j += params["stressTargetLines"]) {
                locations.store(j, (region * params["stressLineSize"]) + locInRegion);
            }
        } else {
            int workgroupsPerLocation = numWorkgroups/params["stressTargetLines"];
            for (int j = 0; j < workgroupsPerLocation; j++) {
                locations.store(i*workgroupsPerLocation + j, (region * params["stressLineSize"]) + locInRegion);
            }
            if (i == params["stressTargetLines"] - 1 && numWorkgroups % params["stressTargetLines"] != 0) {
                for (int j = 0; j < numWorkgroups % params["stressTargetLines"]; j++) {
                    locations.store(numWorkgroups - j - 1, (region * params["stressLineSize"]) + locInRegion);
                }
            }
        }
    }
}

/** These parameters vary per iteration, based on a given percentage. */
void setDynamicStressParams(Buffer &stressParams, map<string, int> params) {
    if (percentageCheck(params["barrierPct"])) {
        stressParams.store(0, 1);
    } else {
        stressParams.store(0, 0);
    }
    if (percentageCheck(params["memStressPct"])) {
        stressParams.store(1, 1);
    } else {
        stressParams.store(1, 0);
    }
    bool memStressStoreFirst = percentageCheck(params["memStressStoreFirstPct"]);
    bool memStressStoreSecond = percentageCheck(params["memStressStoreSecondPct"]);
    int memStressPattern;
    if (memStressStoreFirst && memStressStoreSecond) {
        memStressPattern = 0;
    } else if (memStressStoreFirst) {
        memStressPattern = 1;
    } else if (memStressStoreSecond) {
        memStressPattern = 2;
    } else {
        memStressPattern = 3;
    }
    stressParams.store(3, memStressPattern);
    if (percentageCheck(params["preStressPct"])) {
        stressParams.store(4, 1);
    } else {
        stressParams.store(4, 0);
    }
    bool preStressStoreFirst = percentageCheck(params["preStressStoreFirstPct"]);
    bool preStressStoreSecond = percentageCheck(params["preStressStoreSecondPct"]);
    int preStressPattern;
    if (preStressStoreFirst && preStressStoreSecond) {
        preStressPattern = 0;
    } else if (preStressStoreFirst) {
        preStressPattern = 1;
    } else if (preStressStoreSecond) {
        preStressPattern = 2;
    } else {
        preStressPattern = 3;
    }
    stressParams.store(6, preStressPattern);
}

/** These parameters are static for all iterations of the test. Aliased memory is used for coherence tests. */
void setStaticStressParams(Buffer &stressParams, map<string, int> params) {
    stressParams.store(2, params["memStressIterations"]);
    stressParams.store(5, params["preStressIterations"]);
    stressParams.store(7, params["permuteFirst"]);
    stressParams.store(8, params["permuteSecond"]);
    stressParams.store(9, params["testingWorkgroups"]);
    stressParams.store(10, params["memStride"]);
    if (params["aliasedMemory"] == 1) {
        stressParams.store(11, 0);
    } else {
        stressParams.store(11, params["memStride"]);
    }
}

/** Returns a value between the min and max. */
int setBetween(int min, int max) {
    if (min == max) {
        return min;
    } else {
        int size = rand() % (max - min);
        return min + size;
    }
}

/** A test consists of N iterations of a shader and its corresponding result shader. */


void run(string &test, string &shader_file, string &result_shader_file, map<string, int> params, ofstream &outputFile)
{
    // initialize settings

    //error validation - is this an issue? -> IOS 

    auto instance = Instance(false);
    auto device = getDevice(instance, params, outputFile);
    int testingThreads = params["workgroupSize"] * params["testingWorkgroups"];

    
    int testLocSize = testingThreads * params["numMemLocations"] * params["memStride"];
    
    cout << "working:" << params["workgroupSize"] << "\n";
    cout << "testing:" << params["testingWorkgroups"] << "\n";
    

    int numSeq = 0;
    int numInter = 0;
    int numWeak = 0;
    
    //testLocSize = 65536;

    // set up buffers
    cout << testLocSize << "\n";
    auto testLocations = Buffer(device, testLocSize);
    auto readResults = Buffer(device, params["numOutputs"] * testingThreads);
    auto testResults = Buffer(device, 4);
    auto shuffledWorkgroups = Buffer(device, params["maxWorkgroups"]);
    auto barrier = Buffer(device, 1);
    auto scratchpad = Buffer(device, params["scratchMemorySize"]);
    auto scratchLocations = Buffer(device, params["maxWorkgroups"]);
    auto stressParams = Buffer(device, 12);
    setStaticStressParams(stressParams, params);
    vector<Buffer> buffers = {testLocations, readResults, shuffledWorkgroups, barrier, scratchpad, scratchLocations, stressParams};
    vector<Buffer> resultBuffers = {testLocations, readResults, testResults, stressParams};

//    jclass clazz = env->GetObjectClass(obj);
//    jmethodID iterationMethod = env->GetMethodID(clazz, "iterationProgress", "(Ljava/lang/String;)V");
//    jmethodID deviceMethod = env->GetMethodID(clazz, "setGPUName", "(Ljava/lang/String;)V");
//    jmethodID vendorMethod = env->GetMethodID(clazz, "setGPUVendorId", "(Ljava/lang/String;)V");

      string gpuStr = device.properties().deviceName;
      cout << gpuStr << "\n";
    
//    const char* gpuChar =  gpuStr.c_str();
//    jstring gpuName = env->NewStringUTF(gpuChar);
//    env->CallVoidMethod(obj, deviceMethod, gpuName);
//
      uint32_t gpuVendorInt = device.properties().vendorID;
      string gpuVendorStr = to_string(gpuVendorInt);
      cout << gpuVendorStr << "\n";
    
//    jstring gpuVendor = env->NewStringUTF(gpuVendorStr.c_str());
//    env->CallVoidMethod(obj, vendorMethod, gpuVendor);

    // run iterations
    chrono::time_point<std::chrono::system_clock> start, end, itStart, itEnd;
    start = chrono::system_clock::now();
    for (int i = 0; i < params["iterations"]; i++) {
        // Update iteration number if explorer mode
        string iterationStr = to_string(i+1);
        const char* iterationChar = iterationStr.c_str();
//        jstring iterationNum = env->NewStringUTF(iterationChar);
//        env->CallVoidMethod(obj, iterationMethod, iterationNum);
        
        // we run test from 1
        iter = i+1;


      //  cout<< "This is original:" << iter << "\n";
        
        // here we send data back to c++
        work(dart_port);
        

        auto program = Program(device, shader_file.c_str(), buffers);
        auto resultProgram = Program(device, result_shader_file.c_str(), resultBuffers);
        int numWorkgroups = setBetween(params["testingWorkgroups"], params["maxWorkgroups"]);
        clearMemory(testLocations, testLocSize);
        clearMemory(testResults, 4);
        clearMemory(barrier, 1);
        clearMemory(scratchpad, params["scratchMemorySize"]);
        setShuffledWorkgroups(shuffledWorkgroups, numWorkgroups, params["shufflePct"]);
        setScratchLocations(scratchLocations, numWorkgroups, params);
        setDynamicStressParams(stressParams, params);
        program.setWorkgroups(numWorkgroups);
        resultProgram.setWorkgroups(params["testingWorkgroups"]);
        program.setWorkgroupSize(params["workgroupSize"]);
        resultProgram.setWorkgroupSize(params["workgroupSize"]);
        program.prepare();

        itStart = chrono::system_clock::now();
        program.run();
        itEnd = chrono::system_clock::now();

        resultProgram.prepare();
        resultProgram.run();

        numSeq += testResults.load(0) + testResults.load(1);
        numInter += testResults.load(2);
        numWeak += testResults.load(3);

        program.teardown();
        resultProgram.teardown();
    }

//    outputFile << "Total Result:\n";
//    outputFile << "seq  =  " << numSeq << "\n";
//    outputFile << "interleaved = " << numInter << "\n";
//    outputFile << "weak = " << numWeak << "\n";
    j[test] = { {"seq", numSeq}, {"interleaved", numInter}, {"weak", numWeak}};
    j["device"] = gpuStr;
    j["vendor"] = gpuVendorStr;
    
//    cout << "Total Result:\n";
//    cout << "seq: " << numSeq << "\n";
//    cout << "interleaved: " << numInter << "\n";
//    cout << "weak: " << numWeak << "\n";


    end = std::chrono::system_clock::now();
    std::chrono::duration<double> elapsed_seconds = end - start;
//    outputFile << "Total elapsed time: " << std::fixed << std::setprecision(3) << elapsed_seconds.count() << "s\n";
    
    j["Time Elapsed"] = elapsed_seconds.count();
    
    cout << "Total elapsed time: " << std::fixed << std::setprecision(3) << elapsed_seconds.count() << "s\n";

    for (Buffer buffer : buffers) {
        buffer.teardown();
    }
    testResults.teardown();
    device.teardown();
    instance.teardown();
}


/* Reads a specified config file and stores the parameters in a map. Parameters should be of the form "key=value", one per line.*/

map<string, int> read_config(string &config_file)
{
    map<string, int> m;
    ifstream in_file(config_file);
    string line;
    while (getline(in_file, line))
    {
        istringstream is_line(line);
        string key;
        if (getline(is_line, key, '='))
        {
            string value;
            if (getline(is_line, value))
            {
                m[key] = stoi(value);
            }
        }
    }
    return m;
}

std::string readOutput(std::string filePath) {
    std::ifstream ifs(filePath);
    std::stringstream ss;

    ss << ifs.rdbuf();

    return ss.str();
}


//extern "C" /* <= C++ only */ __attribute__((visibility("default"))) __attribute__((used))
//
//int runTest(string testName, string shaderFile, string resultShaderFile,string configFile, string filePath)
//{
//    std::ofstream outputFile;
//    string outputFilePath = filePath +  "/" + "output.txt";
//    outputFile.open(outputFilePath);
//
//    outputFile << "Test Name: " << testName << "\n";
//    outputFile << "Shader Name: " << shaderFile << "\n";
//    outputFile << "Result Name: " << resultShaderFile << "\n";
//    outputFile << "\n";
//
//    std::string configFileFullPath = filePath + "/" + configFile;
//    shaderFile = filePath + "/" + shaderFile + ".spv";
//    resultShaderFile = filePath + "/" + resultShaderFile + ".spv";
//
//    printf("%s", configFileFullPath.c_str());
//    printf("%s", shaderFile.c_str());
//    printf("%s", resultShaderFile.c_str());
//
//    srand(time(NULL));
//    map<string, int> params = read_config(configFileFullPath);
//
//    outputFile << "Parameter:\n";
//
//    for (const auto& [key, value] : params) {
//        outputFile << key << " = " << value << ";\n";
//    }
//    outputFile << "\n";
//
//    try{
//        run(shaderFile, resultShaderFile, params, outputFile);
//    }
//    catch (const std::runtime_error& e) {
//        outputFile << e.what() << "\n";
//        outputFile.close();
//        return 1;
//    }
//    outputFile.close();
//
//    printf(
//            "%s/%s:\n%s",
//            filePath.c_str(),
//            testName.c_str(),
//            readOutput(outputFilePath).c_str());
//
//    return 0;
//}


extern "C" /* <= C++ only */ __attribute__((visibility("default"))) __attribute__((used))

int runTest(char* test, char* shader, char* result, char* config, char* path)
{
    
    // let's create a json here for our output file
    
    string testName = test;
    string shaderFile = shader;
    string resultShaderFile = result;
    string configFileFullPath = config;
    string outputFilePath = path;
    outputFilePath  += "/output.txt";
    

    // cout << "Test Name: " << testName << "\n";
    // cout << "Shader Name: " << shaderFile << "\n";
    // cout << "Result Name: " << resultShaderFile << "\n";
    // cout << "config file path Name: " << configFileFullPath << "\n";
    // cout << "\n";
    
    ofstream outputFile;

    
    cout<< outputFilePath << "\n";

    outputFile.open(outputFilePath, ios::out);
    
    if (outputFile.is_open() ) {
        
        cout<< "success in creating the file" <<"\n";
    }
        
    else {
        cout << "error in opening the file" << "\n";
    }
    
//    char wd[256];
//    std::cout << getcwd(wd, sizeof(wd)) << std::endl;

//    outputFile << "Test Name: " << testName << "\n";
//    outputFile << "Shader Name: " << shaderFile << "\n";
//    outputFile << "Result Shader Name: " << resultShaderFile << "\n";
//    outputFile << "\n";
    
//    jsonString = "{";
//    jsonString += "\"" + testName + "\":";
    
//    outputFile << "Shader Name: " << shaderFile << "\n";
//    outputFile << "Result Shader Name: " << resultShaderFile << "\n";
//    outputFile << "\n";

 //   std::string configFileFullPath =  filePath + configFile;
    
   // std::string configFileFullPath = "";
 //   shaderFile = filePath + shaderFile + ".spv";
 //   resultShaderFile =  filePath + resultShaderFile + ".spv";

    cout<< configFileFullPath.c_str() << "\n";
    cout<<  shaderFile.c_str() << "\n" ;
    cout<< resultShaderFile.c_str() << "\n";

    srand(time(NULL));
    map<string, int> params = read_config(configFileFullPath);

//    outputFile << "Parameter:\n";

    
  //  outputFile << "\n";

    try{
        run(testName, shaderFile, resultShaderFile, params, outputFile);
    }
    catch (const std::runtime_error& e) {
        outputFile << e.what() << "\n";
        outputFile.close();
        return 1;
    }
    
//    jsonString+= "\"params\": {" ;
//
//    for (const auto& [key, value] : params) {
//        //outputFile << key << " = " << value << ";\n";
//        jsonString+= "\"" + key + "\": " + value + "\,";
//    }
    
    j["params"] = params;
    
//    jsonString += "}";
//    jsonString += "}";
    
   // j = json::parse(jsonString);
    
    cout<< j.dump(4);
    outputFile <<std::setw(4) << j;
    
    outputFile.close();

    cout<<
            //filePath.c_str() <<
            outputFilePath.c_str() << "\n" <<
            testName.c_str() << "\n" <<
            readOutput(outputFilePath).c_str();
    
//    cout<<
//            testName.c_str() <<
//            readOutput(outputFilePath).c_str();
    
    cout <<"returning from main";

    return 0;
}

