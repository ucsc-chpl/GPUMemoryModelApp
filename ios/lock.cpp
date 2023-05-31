//
//  lock.cpp
//  Runner
//
//  Created by Abhijeet Nikam on 01/05/23.
//

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

//#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__))

using namespace std;
using namespace easyvk;
using namespace nlohmann;

json j2;

constexpr char *TAG = "LockTest";

bool checkCorrect = false;

static Device getDevice(Instance &instance, ofstream &outputFile) {
    int idx = 0;
    Device device = instance.devices().at(idx);
//    outputFile << "Using device " << device.properties().deviceName << "\n";
//    outputFile << "\n";
    
    j2["Device"] = device.properties().deviceName;
    return device;
}

static void clearMemory(Buffer &gpuMem, int size) {
    for (int i = 0; i < size; i++) {
        gpuMem.store(i, 0);
    }
}

static void run(string &testName, string &shader_file, string &testIterationStr, string &workgroupNumStr, string &workgroupSizeStr, ofstream &outputFile) {
    bool allTestsCorrect = true;

    // initialize settings
    auto instance = Instance(false);
    auto device = getDevice(instance, outputFile);

    int testIteration = atoi(testIterationStr.c_str());
    int workgroupNum = atoi(workgroupNumStr.c_str());
    int workgroupSize = atoi(workgroupSizeStr.c_str());
    
    j2[testName] = { {"Test Iteration", testIteration}, {"Workgroup Number", workgroupNum}, {"Workgroup Size:", workgroupSize}};
    
//    outputFile << "Test Iteration: " << testIteration << "\n";
//    outputFile << "Workgroup Number: " << workgroupNum << "\n";
//    outputFile << "Workgroup Size: " << workgroupSize << "\n";
//    outputFile << "\n";

    // set up buffers
    auto testLocations = Buffer(device, workgroupNum * workgroupSize);
    auto readResults = Buffer(device, 1);
    auto testIterations = Buffer(device, 1);
    vector<Buffer> buffers = {testLocations, readResults, testIterations};

//    jclass clazz = env->GetObjectClass(obj);
//    jmethodID iterationMethod = env->GetMethodID(clazz, "iterationProgress", "(Ljava/lang/String;)V");
//    jmethodID deviceMethod = env->GetMethodID(clazz, "setGPUName", "(Ljava/lang/String;)V");

    string gpuStr = device.properties().deviceName;
    const char* gpuChar =  gpuStr.c_str();
//    jstring gpuName = env->NewStringUTF(gpuChar);
//    env->CallVoidMethod(obj, deviceMethod, gpuName);

    // run iterations
    chrono::time_point<std::chrono::system_clock> start, end;

    // Update iteration number
    /*string iterationStr = to_string(i+1);
    const char* iterationChar = iterationStr.c_str();
    jstring iterationNum = env->NewStringUTF(iterationChar);
    env->CallVoidMethod(obj, iterationMethod, iterationNum);*/

    auto program = Program(device, shader_file.c_str(), buffers);
    clearMemory(testLocations, workgroupNum * workgroupSize);
    clearMemory(readResults, 1);
    testIterations.store(0, testIteration);
    program.setWorkgroups(workgroupNum);
    program.setWorkgroupSize(workgroupSize);
    program.prepare();

    start = chrono::system_clock::now();
    program.run();
    end = chrono::system_clock::now();
    program.teardown();

    std::chrono::duration<double> testDuration = end - start;
   // outputFile << "Total elapsed time: " << testDuration.count() << "s\n";
    j2["Total elapsed time"] = testDuration.count();

    if(checkCorrect) {
        if(readResults.load(0) != (workgroupNum * testIteration)) {
            if(readResults.load(0) == 0) {
//                outputFile << "Untouched output = " << readResults.load(0) << "\n";
                j2["Untouched Output"] = readResults.load(0);
            }
            else {
//                outputFile << "Wrong output = " << readResults.load(0) << "\n";
                j2["Wrong Output"] = readResults.load(0);

            }
            
            j2["Correct Output"] = workgroupNum * testIteration;
            //outputFile << "Correct output = " << workgroupNum * testIteration << "\n";
            allTestsCorrect = false;
        }
        else {
            
            j2["Output"] = readResults.load(0);
            j2["Result"] =  "Test was successful";
            
//            outputFile << "Output = " << readResults.load(0) << "\n";
//            outputFile << "Test was successful \n";
        }
    }

    for (Buffer buffer : buffers) {
        buffer.teardown();
    }
    device.teardown();
    instance.teardown();
}

static std::string readOutput(std::string filePath) {
    std::ifstream ifs(filePath);
    std::stringstream ss;

    ss << ifs.rdbuf();

    return ss.str();
}


extern "C" /* <= C++ only */ __attribute__((visibility("default"))) __attribute__((used))

int runLockTest(char* test, char*  shader, char*  testIter, char * workgroupNum_para, char* workgroupSize_para, char* fPath)
{
    
    string testName = test;
    string shaderFile = shader;
    string testIteration = testIter;
    string workgroupNum = workgroupNum_para;
    string workgroupSize = workgroupSize_para;
    string filePath = fPath ;
    
    std::ofstream outputFile;
    string outputFilePath = "";
    outputFilePath = filePath;
    //+ "/" + shaderFile + "_output.txt";
    outputFile.open(outputFilePath);

//    outputFile << "Test Name: " << testName << "\n";
//    outputFile << "Shader Name: " << shaderFile << "\n";
//    outputFile << "\n";
    
    checkCorrect = true;

   // shaderFile = filePath + "/" + shaderFile + ".spv";

    //LOGD("%s", shaderFile.c_str());
    
//    cout<<"we reached the c++ code"<<"\n";
//    cout<<testName<<"\n";
//    cout<<shaderFile<<"\n";
//    cout<<testIteration<<"\n";
//    cout<<workgroupNum<<"\n";
//    cout<<workgroupSize<<"\n";
//    cout<<filePath<<"\n";

    srand(time(NULL));

    try{
        run(testName, shaderFile, testIteration, workgroupNum, workgroupSize, outputFile);
    }
    catch (const std::runtime_error& e) {
        outputFile << e.what() << "\n";
        outputFile.close();
        return 1;
    }
    
    outputFile << j2.dump(4);
    
    outputFile.close();

//    LOGD(
//            "%s/%s:\n%s",
//            filePath.c_str(),
//            testName.c_str(),
//            readOutput(outputFilePath).c_str());

    return 0;
}

//std::string getFileDirFromJava(JNIEnv *env, jobject obj) {
//    jclass clazz = env->GetObjectClass(obj);
//    jmethodID method = env->GetMethodID(clazz, "getFileDir", "()Ljava/lang/String;");
//    jobject ret = env->CallObjectMethod(obj, method);
//
//    jstring jFilePath = (jstring) ret;
//
//    return std::string(env->GetStringUTFChars(jFilePath, nullptr));
//}

//extern "C" JNIEXPORT jint
//Java_com_example_litmustestandroid_LockTestThread_main(
//        JNIEnv* env,
//        jobject obj,
//        jobject mainObj,
//        jobjectArray testArray,
//        jboolean checkingModeEnabled) {
//
//    // Convert string array to individual string
//    jstring jTestName = (jstring) (env)->GetObjectArrayElement(testArray, 0);
//    jstring jShaderFile = (jstring) (env)->GetObjectArrayElement(testArray, 1);
//    jstring jTestIteration = (jstring) (env)->GetObjectArrayElement(testArray, 2);
//    jstring jWorkgroupNum = (jstring) (env)->GetObjectArrayElement(testArray, 3);
//    jstring jWorkgroupSize = (jstring) (env)->GetObjectArrayElement(testArray, 4);
//
//    const char* testConvertedValue = (env)->GetStringUTFChars(jTestName, 0);
//    std::string testName = testConvertedValue;
//
//    const char* shaderConvertedValue = (env)->GetStringUTFChars(jShaderFile, 0);
//    std::string shaderFile = shaderConvertedValue;
//
//    const char* testIterationConvertedValue = (env)->GetStringUTFChars(jTestIteration, 0);
//    std::string testIteration = testIterationConvertedValue;
//
//    const char* workgroupNumConvertedValue = (env)->GetStringUTFChars(jWorkgroupNum, 0);
//    std::string workgroupNum = workgroupNumConvertedValue;
//
//    const char* workgroupSizeConvertedValue = (env)->GetStringUTFChars(jWorkgroupSize, 0);
//    std::string workgroupSize = workgroupSizeConvertedValue;
//
//   // LOGD("Get file path via JNI");
//    std::string filePath = getFileDirFromJava(env, mainObj);
//
//    checkCorrect = checkingModeEnabled;
//
//    runTest(env, mainObj, testName, shaderFile, testIteration, workgroupNum, workgroupSize, filePath);
//
//    jclass clazz = env->GetObjectClass(mainObj);
//    jmethodID completeMethod = env->GetMethodID(clazz, "testComplete", "()V");
//    env->CallVoidMethod(mainObj, completeMethod);
//
//    return 0;
//}
