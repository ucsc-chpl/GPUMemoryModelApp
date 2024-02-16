
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gpuiosbundle/bar_graph.dart';
import 'package:percent_indicator/percent_indicator.dart';


class ExplorerDialogTemplate extends StatelessWidget {
    final TextEditingController iter;
    final TextEditingController workgroup;
    final TextEditingController maxworkgroup;
    final TextEditingController size;
    final TextEditingController shufflepct;
    final TextEditingController barrierpct;
    final TextEditingController scratchMemSize;
    final TextEditingController memStride;
    final TextEditingController memStressPct;
    final TextEditingController memStressIter;
    final TextEditingController memStressStoreFirstPct;
    final TextEditingController memStressStoreSecondPct;
    final TextEditingController preStressIter;
    final TextEditingController preStressStoreFirstPct;
    final TextEditingController preStressStoreSecondPct;
    final TextEditingController stressLineSize;
    final TextEditingController stressTargetLines;
    final TextEditingController stressAssignmentStrategy;
    final TextEditingController preStressPct;
    final void Function() changeStress;
    final void Function() changeDefault;
    final void Function() compute;
    final String title_; 

    ExplorerDialogTemplate({
        required this.iter,
        required this.workgroup, 
        required this.maxworkgroup, 
        required this.size, 
        required this.shufflepct, 
        required this.barrierpct, 
        required this.scratchMemSize, 
        required this.memStressPct,
        required this.memStride,
        required this.memStressIter,
        required this.preStressIter,
        required this.memStressStoreFirstPct,
        required this.memStressStoreSecondPct,
        required this.preStressStoreFirstPct,
        required this.preStressStoreSecondPct,
        required this.stressLineSize,
        required this.stressTargetLines,
        required this.stressAssignmentStrategy,
        required this.changeStress,
        required this.changeDefault,
        required this.compute,
        required this.title_,
        required this.preStressPct,
    });
    TextEditingController get iterController => iter;
    TextEditingController get workgroupController => workgroup;
    TextEditingController get maxworkgroupController => maxworkgroup;
    TextEditingController get sizeController => size;
    TextEditingController get shufflepctController => shufflepct;
    TextEditingController get barrierpctController => barrierpct;
    TextEditingController get scratchMemSizeController => scratchMemSize;
    TextEditingController get memStrideController => memStride;
    TextEditingController get memStressPctController => memStressPct;
    TextEditingController get memStressIterController => memStressIter;
    TextEditingController get memStressStoreFirstPctController => memStressStoreFirstPct;
    TextEditingController get memStressStoreSecondPctController => memStressStoreSecondPct;
    TextEditingController get preStressIterController => preStressIter;
    TextEditingController get preStressStoreFirstPctController => preStressStoreFirstPct;
    TextEditingController get preStressStoreSecondPctController => preStressStoreSecondPct;
    TextEditingController get stressLineSizeController => stressLineSize;
    TextEditingController get stressTargetLinesController => stressTargetLines;
    TextEditingController get stressAssignmentStrategyController => stressAssignmentStrategy;
    TextEditingController get preStressPctController => preStressPct;


    @override
    Widget build(BuildContext context) {
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
              title_,
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
                                        controller: iterController,
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
                                        controller: workgroupController,
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
                                        controller: maxworkgroupController,
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
                                        controller: this.size,
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
                                        controller: shufflepctController,
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
                                        controller: barrierpctController,
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
                                        controller: scratchMemSizeController,
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
                                        controller: memStrideController,
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
                                        controller: memStressPctController,
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
                                        controller: memStressIterController,
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
                                        controller: memStressStoreFirstPctController,
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
                                        controller: memStressStoreSecondPctController,
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
                                        controller: preStressPctController,
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
                                        controller: preStressIterController,
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
                                        controller: preStressStoreFirstPctController,
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
                                        controller: preStressStoreSecondPctController,
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
                                        controller: stressLineSizeController,
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
                                        controller: stressTargetLinesController,
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
                                        controller: stressAssignmentStrategyController,
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
                                        this.changeStress();
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
                                        this.changeDefault();
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
                              Navigator.of(context).pop();
                              this.compute();
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
    }
}
