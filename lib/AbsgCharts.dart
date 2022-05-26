import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import 'package:absg/AbsgRecorder.dart';
import 'package:absg/MyAbsgChart.dart';
import 'package:absg/MyAbsgChart2.dart';
import 'package:absg/MyAbsgChart3.dart';
import 'package:absg/MyAbsgChart_Circle_SVG.dart';
import 'package:absg/MyAbsgChart_Circle_SVG2.dart';

class SensorData {
  double _g = 9.8;

  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;
  double _absa = 0;
  double _absg = 0;

  SensorData() {
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
  }
}

class MyAbsgCharts extends StatefulWidget {
  const MyAbsgCharts({Key? key, required this.sensorData}) : super(key: key);

  final SensorData sensorData;

  @override
  State<MyAbsgCharts> createState() => _MyAbsgChartsState();
}

class _MyAbsgChartsState extends State<MyAbsgCharts> {
  int displayIndex = 0;

  final List<Widget> _charts = [
    const MyAbsgChart_Circle_SVG2(),
    const MyAbsgChart_Circle_SVG(),
    const MyAbsgChart3(),
    const MyAbsgChart(),
    const MyAbsgChart2(),
  ];

  void _onPageChanged(index) {
    setState(() {
      displayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 60,
        child: AbsgRecorder(
          storage: CounterStorage(),
        ),
      ),
      Expanded(
        child: PageView(
          controller: PageController(),
          children: _charts,
          onPageChanged: _onPageChanged,
        ),
      ),
    ]);
  }
}
