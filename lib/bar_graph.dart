import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gpuiosbundle/utilities.dart';

class Data {
  late int xaxis;
  late double yaxis;
  late Color color;

  Data(int s, double x, Color c) {
    this.xaxis = s;
    this.yaxis = x;
    this.color = c;
  }
}

// default, use values from init functino
double yaxis_length = 100;

// call the function here to initialize the list data
List<Data> list = [
  Data(0, 80, Colors.black),
  Data(1, 40, Colors.blue),
  Data(2, 40, Colors.red)
];

void initList() async {
  // read from the output json file

  // add the params to the list

  File file = File(outputFile);
  var jsonString = await file.readAsString();
  Map<String, dynamic> user = jsonDecode(jsonString);

  //total = iterations * testingWorkgroups * workgroupSize
  // this will be y axis

  // interleaved, seq and weak

  yaxis_length = user["params"]["iterations"].toDouble() *
      user["params"]["testingWorkgroups"].toDouble() *
      user["params"]["workgroupSize"].toDouble();

  list[0].yaxis = user["GPU Litmus Test"]["interleaved"].toDouble();
  list[1].yaxis = user["GPU Litmus Test"]["seq"].toDouble();
  list[2].yaxis = user["GPU Litmus Test"]["weak"].toDouble();
}

class myBarGraph extends StatefulWidget {
  myBarGraph({super.key});

  @override
  State<StatefulWidget> createState() => BarChartSample4State();
}

class BarChartSample4State extends State<myBarGraph> {
  Widget topTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Interleaved';
        break;
      case 1:
        text = 'Seq';
        break;
      case 2:
        text = 'Weak';
        break;
      default:
        text = '';
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = list[0].yaxis.toString();
        break;
      case 1:
        text = list[1].yaxis.toString();
        break;
      case 2:
        text = list[2].yaxis.toString();
        break;
      default:
        text = '';
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    initList();
    //print(yaxis_length);
    return BarChart(
      BarChartData(
        maxY: yaxis_length,
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: topTitles,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: bottomTitles,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: list
            .map(
              (data) => BarChartGroupData(
                x: data.xaxis,
                barRods: [
                  BarChartRodData(
                      toY: data.yaxis,
                      width: 25,
                      color: data.color,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
