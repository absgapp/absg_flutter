import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import 'package:absg/AbsgRecorder.dart';

class MyAbsgChart3 extends StatefulWidget {
  const MyAbsgChart3({Key? key}) : super(key: key);

  @override
  State<MyAbsgChart3> createState() => _MyAbsgChartState3();
}

class _MyAbsgChartState3 extends State<MyAbsgChart3> {
  double _g = 9.8;

  var _timer;
  int _clock = 0;

  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;
  double _absa = 0;
  double _absg = 0;
  List<ScatterSpot> _spots = [];

  ScatterSpot retSpot(x, y, z) {
    return ScatterSpot(x, y,
        radius: 5, //z * 100 + 10 > 10 ? z * 100 + 10 : 3,
        color: Color.fromRGBO(
            (255 - 255 * x).toInt(), (19).toInt(), (255 * y).toInt(), 0.8));
  }

  void _onTimer(timer) {
    if (_spots.length > 10) {
      _spots.removeAt(0);
    }
    ScatterSpot spot = retSpot(_gx, _gy, _gz);
    _spots.add(spot);

    setState(() {
      _clock++;
    });
  }

  @override
  void initState() {
    print("3 initState is called!!");
    print(this.mounted.toString());
    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      _onTimer(timer);
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double roundAt(var value, int fixed_point) {
    return ((value * fixed_point.toDouble()).round()) / fixed_point.toDouble();
  }

  double _minY = 0;
  double _maxY = 2;
  double _maxYMax = 1;
  double _PanStartY = 0;
  double _PanUpdatingY = 0;

  void _touched(FlTouchEvent event, BarTouchResponse? res) {
    print("FlTouchEvnet");
    if (event is FlPanStartEvent) {
      //_PanStartSpot = event.details.globalPosition.dx;
      print("FlPanStartEvent");
      print(event.details.localPosition.dy.toString());
      _PanStartY = event.details.localPosition.dy;
    } else if (event is FlPanUpdateEvent) {
      print("FlPanUpdateEvent");
      print(event.details.localPosition.dy.toString());
      _PanUpdatingY = event.details.localPosition.dy;
      double _PannedYDistance = _PanUpdatingY - _PanStartY;
      //double _MaxYInc = _PannedYDistance > 0 ? 0.05 : -0.05;
      double _MaxYInc = (_maxY - _minY) / 50.0;
      _MaxYInc = _PannedYDistance > 0 ? _MaxYInc : -_MaxYInc;
      _MaxYInc = -_MaxYInc;

      setState(() {
        if (_maxY >= _maxYMax)
          _maxY += _MaxYInc;
        else
          _maxY = _maxYMax;
      });
    } else if (event is FlPanEndEvent) {
      print("FlPanEndEvent");
    } else if (event is FlPanCancelEvent) {
      print("FlPanCancelEvent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Align(
          alignment: Alignment.topLeft,
          child: Visibility(
            visible: false,
            child: SizedBox(
                child: Text(
                    "sqrt(gx^2 + gy^2) = " + roundAt(_absg, 100).toString())),
          ),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Expanded(
          child: BarChart(
        BarChartData(
            maxY: _maxY,
            minY: _minY,
            titlesData: FlTitlesData(
              show: true,
              topTitles: SideTitles(showTitles: false),
              rightTitles: SideTitles(showTitles: false),
              bottomTitles: SideTitles(showTitles: false),
              leftTitles: SideTitles(
                  showTitles: true, rotateAngle: 0, textAlign: TextAlign.right),
            ),
            borderData: FlBorderData(
                border: const Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide.none,
              bottom: BorderSide(width: 1),
            )),
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchCallback: _touched,
            ),
            groupsSpace: 10,
            barGroups: [
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: _absg,
                  //toY: 0,
                  width: MediaQuery.of(context).size.width * 0.8,
                  colors: [Colors.red],
                  borderRadius: BorderRadius.all(Radius.zero),
                  borderSide: BorderSide(width: 0),
                ),
              ]),
            ]),
      )),
      SizedBox(
        height: 10,
      ),
    ]);
  }
}
