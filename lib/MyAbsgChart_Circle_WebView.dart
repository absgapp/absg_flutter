import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:async";
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyAbsgChart_Circle_WebView extends StatefulWidget {
  const MyAbsgChart_Circle_WebView({Key? key}) : super(key: key);

  @override
  State<MyAbsgChart_Circle_WebView> createState() =>
      MyAbsgChart_Circle_WebViewState();
}

class MyAbsgChart_Circle_WebViewState
    extends State<MyAbsgChart_Circle_WebView> {
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
  List<double> _svg_matrix = [1, 0, 0, 1, 1, 0];
  String _svg_matrix_str = "";
  List<ScatterSpot> _spots = [];

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool _isLoading = false;
  String _title = '';

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
    _dimension = 203.0;
    _absg_namashi = 0;
    _circle_r = 0;
    WebView.platform = SurfaceAndroidWebView();
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

      _svg_rotate_rad = atan2(_ax, _ay);
      _svg_rotate = _svg_rotate_rad / pi * 180;
      // _svg_rotate = 30;
      // _svg_rotate_rad = 30 / 180 * pi;
      _svg_matrix[0] = cos(_svg_rotate_rad);
      _svg_matrix[1] = sin(_svg_rotate_rad);
      _svg_matrix[2] = -sin(_svg_rotate_rad);
      _svg_matrix[3] = cos(_svg_rotate_rad);
      _svg_matrix[4] = 150;
      _svg_matrix[5] = 150;
      _svg_matrix_str =
          "matrix(${_svg_matrix[0]},${_svg_matrix[1]},${_svg_matrix[2]},${_svg_matrix[3]},${_svg_matrix[4]},${_svg_matrix[5]})";
      //"matrix3d(${_svg_matrix3d[0]},${_svg_matrix3d[1]},${_svg_matrix3d[2]},${_svg_matrix3d[3]},${_svg_matrix3d[4]},${_svg_matrix3d[5]},${_svg_matrix3d[6]},${_svg_matrix3d[7]},${_svg_matrix3d[8]})";
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const WebView(
      initialUrl: 'https://dev-yakuza.posstree.com/en/',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
