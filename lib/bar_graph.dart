import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gpuiosbundle/utilities.dart';

class Data {
  late int xaxis;
  late double yaxis;
  late Color color;

  Data(this.xaxis, this.yaxis, this.color);
}

double yaxis_length = 100000;
List<Data> list = [
  Data(0, 80, Colors.black),
  Data(1, 40, Colors.blue),
  Data(2, 40, Colors.red),
];

Future<void> initList([var configNumber]) async {
  File file = File(outputFile);
  var jsonString = await file.readAsString();
  Map<String, dynamic> user = jsonDecode(jsonString);

  if (configNumber == null) {
    yaxis_length = user["params"]["iterations"].toDouble() *
        user["params"]["testingWorkgroups"].toDouble() *
        user["params"]["workgroupSize"].toDouble();

    list[0].yaxis = user["GPU Litmus Test"]["interleaved"].toDouble();
    list[1].yaxis = user["GPU Litmus Test"]["seq"].toDouble();
    list[2].yaxis = user["GPU Litmus Test"]["weak"].toDouble();
  } else {
    yaxis_length = 0;
    list[0].yaxis = 0;
    list[1].yaxis = 0;
    list[2].yaxis = 0;

    for (int i = 0; i < int.parse(configNumber); i++) {
      yaxis_length += user['$i']["params"]["iterations"].toDouble() *
          user['$i']["params"]["testingWorkgroups"].toDouble() *
          user['$i']["params"]["workgroupSize"].toDouble();
      list[0].yaxis += user['$i']["GPU Litmus Test"]["interleaved"].toDouble();
      list[1].yaxis += user['$i']["GPU Litmus Test"]["seq"].toDouble();
      list[2].yaxis += user['$i']["GPU Litmus Test"]["weak"].toDouble();
    }
  }
}

class myBarGraph extends StatefulWidget {
  myBarGraph({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarChartSample4State();
}

class _BarChartSample4State extends State<myBarGraph> {
  @override
  void initState() {
    super.initState();
    initList().then((_) {
      setState(() {
        // will rebuild graph when data is loaded
      });
    });
  }

  Widget topTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    switch (value.toInt()) {
      case 0:
        return SideTitleWidget(axisSide: meta.axisSide, child: Text('Interleaved', style: style));
      case 1:
        return SideTitleWidget(axisSide: meta.axisSide, child: Text('Seq', style: style));
      case 2:
        return SideTitleWidget(axisSide: meta.axisSide, child: Text('Weak', style: style));
      default:
        return Container();
    }
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    switch (value.toInt()) {
      case 0:
        return SideTitleWidget(axisSide: meta.axisSide, child: Text(list[0].yaxis.toString(), style: style));
      case 1:
        return SideTitleWidget(axisSide: meta.axisSide, child: Text(list[1].yaxis.toString(), style: style));
      case 2:
        return SideTitleWidget(axisSide: meta.axisSide, child: Text(list[2].yaxis.toString(), style: style));
      default:
        return Container();
    }
  }
  @override
  Widget build(BuildContext context) {
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
                    ),
                  ),
                ],
              ),
            )
            .toList(),
        barTouchData: BarTouchData(
          enabled: false,
        ),
      ),
    );
  }
}
