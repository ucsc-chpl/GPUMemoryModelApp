import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gpuiosbundle/bar_graph.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TestPageTemplateWidget extends StatelessWidget {
    final String title;
    final String page;
    final String init_state;
    final String final_state;
    final String workgroup0_thread0_text1;
    final String workgroup0_thread0_text2;
    final String workgroup1_thread0_text1;
    final String workgroup1_thread0_text2;

    final bool isExplorerButtonDisabled;
    final void Function() showExplorerDialog;
    final bool isStressButtonDisabled;
    final void Function() showTuningDialog;
    final bool isResultButtonDisabled;
    final void Function() results;
    final bool isEmailButtonDisabled;
    final void Function() email;
    final double percentageValue;
    final String iterationMssg;
    final bool visibleIndicator;
    final bool visibleBarChart;

    TestPageTemplateWidget({
        required this.title,
        required this.page,
        required this.init_state,
        required this.final_state,
        required this.workgroup0_thread0_text1,
        required this.workgroup0_thread0_text2,
        required this.workgroup1_thread0_text1,
        required this.workgroup1_thread0_text2,
        required this.isExplorerButtonDisabled,
        required this.showExplorerDialog,
        required this.isStressButtonDisabled,
        required this.showTuningDialog,
        required this.isResultButtonDisabled,
        required this.results,
        required this.isEmailButtonDisabled,
        required this.email,
        required this.percentageValue,
        required this.iterationMssg,
        required this.visibleIndicator,
        required this.visibleBarChart,
    });

   

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        body: Container(
            //child: Center(
            //  height: 800,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.all(24),
            child: Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                Text(
                                page,
                                // textAlign: TextAlign.center,
                                //overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    //  crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                    Text(
                                        'Initial State:',
                                        //  textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                        init_state,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: Color.fromARGB(
                                                255, 203, 198, 198)),
                                        // textAlign: TextAlign.center,
                                        //  overflow: TextOverflow.ellipsis,
                                        ),
                                    )
                                    ]),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                    Text(
                                        'Final State:',
                                        textAlign: TextAlign.center,
                                        // overflow: TextOverflow.ellipsis,
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                        final_state,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: Color.fromARGB(
                                                255, 203, 198, 198)),
                                        textAlign: TextAlign.center,
                                        //   overflow: TextOverflow.ellipsis,
                                        ),
                                    ),
                                    ]),
                                SizedBox(height: 15),
                                Column(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                    const Text(
                                        'Workgroup 0 Thread 0:',
                                        //  textAlign: TextAlign.center,
                                        //  overflow: TextOverflow.ellipsis,
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                     SizedBox(height: 5),
                                    Container(
                                        color: Colors.grey,
                                        child:  Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                            Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                workgroup0_thread0_text1,
                                                //  textAlign: TextAlign.center,
                                                //  overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                workgroup0_thread0_text2,
                                                // textAlign: TextAlign.center,
                                                //   overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
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
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                        color: Colors.grey,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                            Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                workgroup1_thread0_text1,
                                                // textAlign: TextAlign.center,
                                                //  overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                workgroup1_thread0_text2,
                                                // textAlign: TextAlign.center,
                                                //   overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
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
                                                MaterialStatePropertyAll<Color>(
                                                    Colors.green),
                                        ),
                                        onPressed: isExplorerButtonDisabled
                                            ? showExplorerDialog
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
                                                MaterialStatePropertyAll<Color>(
                                                    Colors.green),
                                        ),
                                        onPressed: isStressButtonDisabled
                                            ? showTuningDialog
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
                                                MaterialStatePropertyAll<Color>(
                                                    Colors.red),
                                        ),
                                        onPressed: isResultButtonDisabled
                                            ? results
                                            : null,
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
                                                MaterialStatePropertyAll<Color>(
                                                    Colors.blue),
                                        ),
                                        onPressed:
                                            isEmailButtonDisabled ? email : null,
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
                                        percent: percentageValue,
                                        progressColor: Colors.deepPurple,
                                        backgroundColor:
                                            Colors.deepPurple.shade100,
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(iterationMssg))
                                    ],
                                    ),
                                    visible: visibleIndicator,
                                ),
                                ),

                                // Padding(
                                //     padding: const EdgeInsets.all(10.0),
                                //     child: Visibility(child: Text(_iterationMssg))),

                                // here lies the bar graph code

                                Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Visibility(
                                    child:
                                        SizedBox(height: 200, child: myBarGraph()),
                                    visible: visibleBarChart,
                                ),
                                )
                            ])))
                ]),
        ),
        );
    }
    
}