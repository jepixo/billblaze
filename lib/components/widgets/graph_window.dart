import 'dart:async';
import 'dart:math';

import 'package:billblaze/colors.dart';
import 'package:billblaze/home.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GraphWindow extends StatefulWidget {
  final double sWidth;
  final double sHeight;
  final int s;
  // final bool isHomeTab;
  // final Duration defaultDuration;
  // final Map<double, double> monthRevenueMap;
  // final Map<double, double> dayRevenueMap;
  // final int kDayCycle;
  // final double topPadPosDistance;
  // final double appinioMaxTabChanged;
  // final double appinioMinTabChanged;
  // final List monthNames;
  // final int selectedYear;
  // final int selectedMonth;
  // final NumberFormat currencyFormatter;
  // final Animation<int> graphLineSpeedTween;
  const GraphWindow({
    super.key,
    required this.sWidth,
    required this.sHeight,
    required this.s,
    // required this.isHomeTab,
    // required this.defaultDuration,
    // required this.monthRevenueMap,
    // required this.dayRevenueMap,
    // required this.kDayCycle,
    // required this.topPadPosDistance,
    // required this.appinioMaxTabChanged,
    // required this.appinioMinTabChanged,
    // required this.monthNames,
    // required this.selectedMonth,
    // required this.selectedYear,
    // required this.currencyFormatter,
    // required this.graphLineSpeedTween,
  });

  @override
  State<GraphWindow> createState() => _GraphWindowState();
}

class _GraphWindowState extends State<GraphWindow> {
  late List<List<FlSpot>> _dataPoints;
  late Timer _timer;
  int _xValue = 0;
  int _curDay = 0;
  int _curMonth = 0;
  double _globalMinY = double.infinity;
  double _globalMaxY = double.negativeInfinity;
  DateTime dateTimeNow = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dataPoints = List.generate(7, (_) => <FlSpot>[]);
    _startDataUpdate();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startDataUpdate() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 100), // tweak using your _graphLineSpeedTween
      (_) {
        _getCurrentTime();
        },
    );
  }
  void _getCurrentTime() {
    setState(() {
      dateTimeNow = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.s) {
      case 1:
        return LineChart(LineChartData(
          lineBarsData: [LineChartBarData()],
          titlesData: FlTitlesData(show: false),
          gridData: const FlGridData(
              show: true,
              horizontalInterval: 7.8,
              verticalInterval: 30),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 50,
          maxX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                  500 +
              250,
          minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
              500));
      case 2:
      return Opacity(
        opacity: 0.35,
        child: LineChart(LineChartData(
            lineBarsData: [LineChartBarData()],
            titlesData: const FlTitlesData(show: false),
            gridData: FlGridData(
              getDrawingVerticalLine: (value) => FlLine(
                  color:  defaultPalette.extras[0].withOpacity(0.6),
                  dashArray: [2, 8],
                  strokeWidth: 1),
              getDrawingHorizontalLine: (value) => FlLine(
                  color: defaultPalette.extras[0].withOpacity(0.6),
                  dashArray: [2, 8],
                  strokeWidth: 1),
              show: true,
              horizontalInterval: 10,
              verticalInterval: 30),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: 50,
            maxX:
                dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                        500 +
                    250,
            minX:
                dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                    500)),
          );
      default:
        return LineChart(LineChartData(
          lineBarsData: [LineChartBarData()],
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(
              show: true,
              horizontalInterval: 7.8,
              verticalInterval: 30),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 50,
          maxX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() / 500 + 250,
          minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() / 500));
    }
    
  
  }

}
