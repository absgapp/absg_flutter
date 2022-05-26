import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_svg/flutter_svg.dart';

class MyAbsgChart_Circle_SVG2 extends StatefulWidget {
  const MyAbsgChart_Circle_SVG2({Key? key}) : super(key: key);

  @override
  State<MyAbsgChart_Circle_SVG2> createState() =>
      MyAbsgChart_Circle_SVG2State();
}

class MyAbsgChart_Circle_SVG2State extends State<MyAbsgChart_Circle_SVG2> {
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
  double _absg_namashi = 0;
  double _circle_r = 0;
  double _svg_rotate = 0;
  double _svg_rotate_rad = 0;
  // Color _svg_color = HSVColor.fromAHSV(0, 183, 60, 100).toColor();
  Color _svg_color = Color.fromARGB(255, 150, 86, 255);
  List<double> _svg_matrix = [1, 0, 0, 1, 0, 0];
  String _svg_matrix_str = "";
  bool _svg_rotate_bool = true;

  final double _svg_arrow_center_x = 150;
  final double _svg_arrow_center_y = 150;
  final double _svg_arrow_head_length = 40;
  final double _svg_arrow_head_width = 20;
  final double _svg_arrow_origin_width = 60;
  final double _svg_arrow_origin_length = 50;

  String _get_svg_arrow_str() {
    String str = '''
      M ${_svg_arrow_center_x} ${_svg_arrow_center_y} 
      h ${-_svg_arrow_origin_width / 2.0}
      v ${-_svg_arrow_origin_length} 
      h ${-_svg_arrow_head_width} 
      l ${_svg_arrow_origin_width / 2.0 + _svg_arrow_head_width} ${-_svg_arrow_head_length} 
      l ${_svg_arrow_origin_width / 2.0 + _svg_arrow_head_width} ${_svg_arrow_head_length} 
      h ${-_svg_arrow_head_width} 
      v ${_svg_arrow_origin_length} 
      h ${-_svg_arrow_origin_width / 2.0}
      Z
    ''';

    return str;
  }

  List<ScatterSpot> _spots = [];

  ScatterSpot retSpot(x, y, z) {
    return ScatterSpot(x, y,
        radius: 5, //z * 100 + 10 > 10 ? z * 100 + 10 : 3,
        color: Color.fromRGBO(
            (255 - 255 * x).toInt(), (19).toInt(), (255 * y).toInt(), 0.8));
  }

  late double _dimension;

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
    print("MyAbsgChart_Circle initState is called!!");
    _dimension = 0.6;
    _absg_namashi = 0;
    _circle_r = 0;
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
      _absa = sqrt(pow(_ax, 2) + pow(_ay, 2) + pow(_az, 2));
      _absg = _absa / _g;
      _absg_namashi += (_absg - _absg_namashi) * 0.1;
      _circle_r = _absg_namashi * 100 / 0.4;
      if (_circle_r > 100) _circle_r = 100;

      _svg_rotate_rad = atan2(_ax, -_az);
      _svg_rotate = _svg_rotate_rad / pi * 180;
      // _svg_rotate = 30;
      // _svg_rotate_rad = 30 / 180 * pi;
      _svg_matrix[0] = cos(_svg_rotate_rad);
      _svg_matrix[1] = sin(_svg_rotate_rad);
      _svg_matrix[2] = -sin(_svg_rotate_rad);
      _svg_matrix[3] = cos(_svg_rotate_rad);
      _svg_matrix[4] = 0;
      _svg_matrix[5] = 0;
      _svg_matrix_str =
          "matrix(${_svg_matrix[0]},${_svg_matrix[1]},${_svg_matrix[2]},${_svg_matrix[3]},${_svg_matrix[4]},${_svg_matrix[5]})";
      if (!_svg_rotate_bool) {
        _svg_matrix_str = "matrix(1,0, 0,1, 0,0)";
      }
      //"matrix3d(${_svg_matrix3d[0]},${_svg_matrix3d[1]},${_svg_matrix3d[2]},${_svg_matrix3d[3]},${_svg_matrix3d[4]},${_svg_matrix3d[5]},${_svg_matrix3d[6]},${_svg_matrix3d[7]},${_svg_matrix3d[8]})";

      _svg_color =
          Color.fromARGB(255, 0 + (_circle_r / 100 * 255).toInt(), 86, 255);
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handleCheckbox(bool? val) {
    setState(() {
      if (val != null) {
        _svg_rotate_bool = val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        children: [
          Slider(
              min: 0.1,
              //max: MediaQuery.of(context).size.width - 10.0,
              max: 3,
              value: _dimension,
              onChanged: (double val) {
                setState(() => _dimension = val);
              }),
          new Checkbox(value: _svg_rotate_bool, onChanged: _handleCheckbox),
        ],
      ),
      Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(_absg.toString()),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(_absg_namashi.toString()),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(_svg_rotate.toString()),
          ),
          SvgPicture.string('''
<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" fill="none">
  <g transform=" translate(150, 150) ${_svg_matrix_str} scale(${_dimension}) scale(${_circle_r / 50}) translate(-150, -150)">
    <path d="${_get_svg_arrow_str()}" fill="red" fill-rule="evenodd" />
   <circle cx="150" cy="150" r="50" fill="blue"/>

  </g>

  
</svg>
              ''',
              width: 300,
              height: 300,
              color: _svg_color,
              allowDrawingOutsideViewBox: true),
        ],
      ),
    ]);
  }
}
