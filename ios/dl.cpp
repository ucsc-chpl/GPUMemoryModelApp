//
//  dl.cpp
//  Runner
//
//  Created by Abhijeet Nikam on 29/03/23.
//

#include <stdio.h>
#include <iostream>
using namespace std;

#include "dart_api_dl.h"
#include "dart_native_api.h"
#include "dart_api_dl.h"




// Receives NativePort ID from Flutter code
static Dart_Port_DL dart_port = 0;

DART_EXPORT intptr_t initDartApiDL(void* data) {
    return Dart_InitializeApiDL(data);
}

// Ensure that the function is not-mangled; exported as a pure C function
//static Dart_Port_DL dart_port = 0;

extern "C" /* <= C++ only */ __attribute__((visibility("default"))) __attribute__((used))

void startWork( Dart_Port sendPort, char *message)
{
//    if (!dart_port)
//        return;
    
    Dart_CObject msg;
    msg.type = Dart_CObject_kString;
    
   // cout<< "c++ :" << message << "\n";
    msg.value.as_string = (char *)message;
    // The function is thread-safe; you can call it anywhere on your C++ code
    
    
    Dart_PostCObject_DL(sendPort, &msg);
}
