
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gpuiosbundle/bar_graph.dart';
import 'package:percent_indicator/percent_indicator.dart';


class TuningDialogTemplate extends StatelessWidget {
    final TextEditingController tIter;
    final TextEditingController tConfigNum;
    final TextEditingController tRandomSeed;
    final TextEditingController tWorkgroup;
    final TextEditingController tMaxworkgroup;
    final TextEditingController tSize;
    final void Function() tuningClick;

    TuningDialogTemplate({
        required this.tIter,
        required this.tConfigNum, 
        required this.tRandomSeed, 
        required this.tWorkgroup, 
        required this.tMaxworkgroup, 
        required this.tSize,
        required this.tuningClick,
    });

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
              "Store Buffer",
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
                                controller: tConfigNum,
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
                                controller: tIter,
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
                                controller: tRandomSeed,
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
                                controller: tWorkgroup,
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
                                controller: tMaxworkgroup,
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
                                controller: tSize,
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
                                Navigator.of(context).pop();
                                this.tuningClick();
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
    }


}