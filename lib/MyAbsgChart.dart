import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import 'package:absg/AbsgRecorder.dart';

class MyAbsgChart extends StatefulWidget {
  const MyAbsgChart({Key? key}) : super(key: key);

  @override
  State<MyAbsgChart> createState() => _MyAbsgChartState();
}

class _MyAbsgChartState extends State<MyAbsgChart> {
  double _g = 9.8;

  int _clock = 0;

  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;
  double _absa = 0;
  double _absg = 0;

  @override
  void initState() {
    print("1 initState is called!!");
    print(this.mounted.toString());
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (this.mounted) {
        setState(() {
          _clock++;
        });
      }
    });
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      _ax = event.x;
      _ay = event.y;
      _az = event.z;
      _gx = _ax / _g;
      _gy = _ay / _g;
      _gz = _az / _g;
      _absa = sqrt(pow(_ax, 2) + pow(_ay, 2));
      _absg = sqrt(pow(_gx, 2) + pow(_gy, 2));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
          maxY: 2,
          minY: -2,
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          groupsSpace: 10,
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: _absa, width: 15, colors: [Colors.red]),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: _ax, width: 15),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: _ay, width: 15),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: _az, width: 15),
            ]),
          ]),
    );
  }
}
