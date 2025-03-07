import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/components/animated_stack.dart';
import 'package:billblaze/components/elevated_button.dart';
import 'package:billblaze/components/flutter_balloon_slider.dart';
import 'package:billblaze/components/navbar/curved_navigation_bar.dart';
import 'package:billblaze/main.dart';
import 'package:billblaze/providers/box_provider.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:appinio_swiper/appinio_swiper.dart';

final cCardIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final appinioLoopProvider = StateProvider<bool>((ref) {
  return true;
});

final layProvider = StateProvider<bool>((ref) {
  return false;
});

final pgPropsEnableProvider = StateProvider<bool>((ref) {
  return true;
});

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  List<List<FlSpot>> _dataPoints = [
    [FlSpot(0, 0)],
    [FlSpot(0, 0)],
    [FlSpot(0, 0)],
    [FlSpot(0, 0)],
    [FlSpot(0, 0)],
    [FlSpot(0, 0)],
    [FlSpot(0, 0)],
  ];
  Timer? _timer;
  double _xValue = 0.0;
  double _xxValue = 0.0;
  late Animation<int> _graphLineSpeedTween;
  List<int> _graphSpeed = [60, 80];
  double appinioMinTabChanged = 0;
  double appinioMaxTabChanged = 10;
  bool even = true;
  DateTime dateTimeNow = DateTime.now();
  // bool lay = false;
  // int _currentCardIndex = 0;

  double _cardPosition = 0;
  late AppinioSwiperController recentsCardController;
  late AnimationController squiggleFadeAnimationController;
  late AnimationController sliderFadeAnimationController;
  late AnimationController sliderController;
  late AnimationController titleFontFadeController;
  Orientation? _lastOrientation;
  // bool appinioLoop = true;
  Key titleMainKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // _initializeDataPoints();
    recentsCardController = AppinioSwiperController();
    sliderController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 80),
    );
    _graphLineSpeedTween = IntTween(begin: _graphSpeed[0], end: _graphSpeed[1])
        .animate(sliderController)
      ..addListener(() {
        setState(() {
          _graphSpeed[0] = _graphSpeed[1];
        }); // Update the UI with the new animation values.
      });
    // sliderController.forward();
    _startDataUpdate();
    squiggleFadeAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    sliderFadeAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    titleFontFadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    if (ref.read(layProvider)) {
      _homeTabSwitched(1, ref);
      squiggleFadeAnimationController.forward();
      sliderFadeAnimationController.forward();
    }
    // titleFontFadeController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    squiggleFadeAnimationController.dispose();
    sliderFadeAnimationController.dispose();
    sliderController.dispose();
    // recentsCardController.dispose();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant Home oldWidget) {
  //   // TODO: implement didUpdateWidget
  //   super.didUpdateWidget(oldWidget);
  //   if (ref.read(layProvider)) {
  //     _homeTabSwitched(1, ref);
  //   }
  // }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final currentOrientation = MediaQuery.of(context).orientation;
    if (_lastOrientation != currentOrientation) {
      _lastOrientation = currentOrientation;
      // Your specific code to run when orientation
      if (ref.read(layProvider)) {
        _homeTabSwitched(1, ref);
        Future.delayed(Durations.short3).then((u) {
           _homeTabSwitched(1, ref);
        });
      }
    }
    if (ref.read(layProvider)) {
      _homeTabSwitched(1, ref);
    }
  }

  //
  //
  //
  void _startDataUpdate() {
    _timer = Timer.periodic(Duration(milliseconds: _graphLineSpeedTween.value),
        (timer) {
      setState(() {
        // Generate an oscillating y value using a sine wave
        double yValue =
            20 * sin(_xValue * 0.8); // Adjust amplitude and frequency as needed
        _xValue += 0.5;
        _dataPoints[0].add(FlSpot(_xValue, yValue));
        if (_dataPoints[0].length >
            (_dataPoints[0].last.x <= _graphLineSpeedTween.value
                ? _dataPoints[0].last.x + 10
                : _graphLineSpeedTween.value)) {
          _dataPoints[0].removeAt(0);
        }

        if (even) {
          _xxValue = _xxValue + 1;
        }
        even = !even;
        // Alternates between 10 and -10
        // double yyValue = 20 * double.parse(sin(_xxValue).round().toString());
        double yyValue = _xxValue % 2 == 0 ? -10 : -20;
        _dataPoints[1].add(FlSpot(_xValue + 1, yyValue));
        if (_dataPoints[1].length > 20) {
          _dataPoints[1].removeAt(0);
        }

        double yyyValue = _xxValue % 2 == 0 ? -10 : -20;
        _dataPoints[2].add(FlSpot(
            _graphLineSpeedTween.value <= 50 ? _xValue - 20 : _xValue - 25,
            yyyValue));
        if (_dataPoints[2].length > 25) {
          _dataPoints[2].removeAt(0);
        }

        double y4Value = _xxValue % 2 == 0 ? -10 : -20;
        _dataPoints[3].add(FlSpot(_xValue - 1.7, y4Value));
        if (_dataPoints[3].length > 20) {
          _dataPoints[3].removeAt(0);
        }

        double y5Value = _xxValue % 2 == 0 ? 10 : 20;
        _dataPoints[4].add(FlSpot(
            _graphLineSpeedTween.value <= 50
                ? _xValue - 18.21
                : _xValue - 20.21,
            y5Value));
        if (_dataPoints[4].length > 20) {
          _dataPoints[4].removeAt(0);
        }

        double y6Value = _xxValue % 2 == 0 ? 10 : 20;
        _dataPoints[5].add(FlSpot(_xValue + 3, y6Value));
        if (_dataPoints[5].length > 25) {
          _dataPoints[5].removeAt(0);
        }

        double y7Value = _xxValue % 2 == 0 ? 10 : 20;
        _dataPoints[6].add(FlSpot(
            _graphLineSpeedTween.value <= 50 ? _xValue - 19 : _xValue - 21,
            y7Value));
        if (_dataPoints[6].length > 25) {
          _dataPoints[6].removeAt(0);
        }
      });
      _getCurrentTime();
    });
  }

  //
  //
  //
  void _updateGraphLineSpeed(int newSpeed) {
    setState(() {
      _graphSpeed[1] = newSpeed;
      _updateSliderAnimation(_graphSpeed[0], _graphSpeed[1]);
      _timer?.cancel(); // Cancel the existing timer
      _startDataUpdate(); // Start a new timer with the updated speed
    });
  }

  //
  //
  //
  void _getCurrentTime() {
    setState(() {
      dateTimeNow = DateTime.now();
    });
  }

  //
  //
  //
  void _homeTabSwitched(int index, WidgetRef ref) {
    bool left = index != 0;
    ref.read(layProvider.notifier).state = index == 1;
    if (left && recentsCardController.cardIndex! <= 9) {
      //Handling Card Exit Animation
      setState(() {
        _updateSliderAnimation(
          _graphSpeed[0],
          10,
        );
        Future.delayed(Duration(milliseconds: 100)).then((n) {
          // _updateGraphLineSpeed(10);
          _updateGraphLineSpeed(10);
          // _updateGraphLineSpeed(10);
        });
        ref.read(appinioLoopProvider.notifier).update(
              (state) => state = false,
            );
        appinioMinTabChanged = _dataPoints[0].first.x;
        appinioMaxTabChanged = _dataPoints[0].last.x;
      });
      for (int i = 0; i < 2; i++) {
        recentsCardController
            .swipeDefault()
            .then((n) => recentsCardController.swipeLeft().then((n) {
                  if (recentsCardController.cardIndex! <= 9) {
                    // print(recentsCardController.cardIndex);
                    recentsCardController.setCardIndex(9);
                  }
                  setState(() {
                    _cardPosition = 0;
                  });
                  recentsCardController.swipeDefault().then((n) => setState(() {
                        _cardPosition = 0;
                        ref
                            .read(cCardIndexProvider.notifier)
                            .update((s) => s = 0);
                      }));
                  print(recentsCardController.cardIndex);
                }));
      }
      //Handling Squiggle

      // _updateGraphLineSpeed(20);
      setState(() {
        Future.delayed(Duration(milliseconds: 100)).then((n) {
          sliderController.forward().then((n) {
            // _timer?.cancel();
            // _startDataUpdate();
            squiggleFadeAnimationController.forward();
            sliderFadeAnimationController.forward();
          });
        });
      });
    } else if (!left) {
      if (ref.read(appinioLoopProvider) == false) {
        setState(() {
          ref.read(appinioLoopProvider.notifier).update(
                (state) => state = true,
              );
          squiggleFadeAnimationController.reverse();
          squiggleFadeAnimationController.reset();
          squiggleFadeAnimationController.reverse();

          squiggleFadeAnimationController.reverse();
          sliderFadeAnimationController.reverse().then((n) {
            _updateGraphLineSpeed(50);
            Future.delayed(Duration(milliseconds: 100)).then((n) {
              _updateGraphLineSpeed(60);
              _updateGraphLineSpeed(60);
              _updateGraphLineSpeed(60);
            });
          });
        });
        recentsCardController.unswipe().then((n) {
          recentsCardController.unswipe().then((n) {
            recentsCardController.setCardIndex(0);
            ref
                .read(cCardIndexProvider.notifier)
                .update((s) => s = recentsCardController.cardIndex!);
            _cardPosition = 0;
          });
        });
        recentsCardController.setCardIndex(0);
        setState(() {
          ref
              .read(cCardIndexProvider.notifier)
              .update((s) => s = recentsCardController.cardIndex!);
          _cardPosition = 0;
        });
      }
    }
    if (ref.read(layProvider)) {
      setState(() {
        ref.read(layProvider.notifier).state = true;
      });
    } else if (!ref.read(layProvider)) {
      setState(() {
        ref.read(layProvider.notifier).state = false;
      });
    }
    print('e ${recentsCardController.cardIndex}');
  }

  //
  //
  //
  //
  void _updateSliderAnimation(int newBegin, int newEnd, {Function? func}) {
    setState(() {
      _graphSpeed[0] = newBegin;
      _graphSpeed[1] = newEnd;

      // Dispose the previous controller and create a new one with the new tween values.
      _graphLineSpeedTween =
          IntTween(begin: _graphSpeed[0], end: _graphSpeed[1])
              .animate(sliderController);

      sliderController.reset();
      // _timer?.cancel();
      // _startDataUpdate();
      sliderController.forward().then((n) => func);
    });
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;
    Duration sideBarPosDuration = Duration(milliseconds: 300);
    Duration defaultDuration = Duration(milliseconds: 300);
    double topPadPosDistance = sHeight / 25;
    double leftPadPosDistance = sWidth / 10;
    double DTsectHeight = sHeight / 2;
    double DTsectWidth = sWidth;
    double topPadGraphDistance = sHeight / 4.2;
    double titleFontSize = sHeight / 10;
    double topPadCardsDistance = sHeight / 6;
    bool appinioLoop = ref.watch(appinioLoopProvider);
    if (sWidth > sHeight) {
      return Scaffold(
          // resizeToAvoidBottomInset: true,
          body: AnimatedStack(
        scaleHeight: 80,
        scaleWidth: 80,
        slideAnimationDuration: Duration(milliseconds: 600),
        fabBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        fabIconColor: Colors.green,
        buttonIcon: IconsaxPlusBold.add,
        columnWidget: Column(),
        bottomWidget: Row(),
        foregroundWidget: Container(
          height: sHeight,
          width: sWidth,
          child: SafeArea(
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: !appinioLoop,
                  child: Container(
                    width: sWidth,
                    height: sHeight,
                    color: Colors.transparent,
                  ),
                ),
                _getLayoutAndTemplatesWin(context, ref, topPadPosDistance),
                //
                //BILLBLAZE MAIN TITLE
                AnimatedPositioned(
                  duration: defaultDuration,
                  top: topPadPosDistance -
                      (appinioLoop ? 0 : topPadPosDistance / 1.5),
                  left: appinioLoop ? leftPadPosDistance : sWidth / 18,
                  child: AnimatedTextKit(
                    key: ValueKey(appinioLoop),
                    animatedTexts: [
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.abrilFatface(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.zcoolKuaiLe(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.splash(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze",
                          textStyle: GoogleFonts.libreBarcode39ExtendedText(
                              fontSize: appinioLoop
                                  ? titleFontSize / 1.1
                                  : titleFontSize / 3,
                              letterSpacing:
                                  appinioLoop ? -titleFontSize / 4 : 0,
                              height: 1),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.redactedScript(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.fascinateInline(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      // TypewriterAnimatedText("Bill\nBlaze.",
                      //     textStyle: GoogleFonts.nabla(
                      //         fontSize: appinioLoop
                      //             ? titleFontSize
                      //             : titleFontSize / 3,
                      //         color: appinioLoop
                      //             ? Colors.black
                      //             : Color(0xFF000000).withOpacity(0.8),
                      //         height: 0.9),
                      //     speed: Duration(milliseconds: 100)),
                    ],
                    // totalRepeatCount: 1,
                    repeatForever: true,
                    pause: const Duration(milliseconds: 30000),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ),
                //
                //SIDE BAR BUTTON
                // AnimatedPositioned(
                //   duration: sideBarPosDuration,
                //   top: (sHeight / 20) - (appinioLoop ? 0 : sHeight / 28),
                //   left: (sWidth / 40) - (appinioLoop ? 0 : sWidth / 12),
                //   child: ElevatedLayerButton(
                //     onClick: () {},
                //     buttonHeight: 70,
                //     buttonWidth: 70,
                //     borderRadius: BorderRadius.circular(100),
                //     animationDuration: const Duration(milliseconds: 200),
                //     animationCurve: Curves.ease,
                //     topDecoration: BoxDecoration(
                //       color: Colors.white,
                //       border: Border.all(),
                //     ),
                //     topLayerChild: Icon(
                //       IconsaxPlusLinear.element_3,
                //       size: 25,
                //     ),
                //     baseDecoration: BoxDecoration(
                //       color: Colors.green,
                //       border: Border.all(),
                //     ),
                //   ),
                // ),

                //
                //Graph
                AnimatedPositioned(
                  duration: defaultDuration,
                  top: topPadPosDistance + topPadGraphDistance,
                  left: sWidth / 15,
                  height: sHeight / 4,
                  width: sWidth / 1.5,
                  child: IgnorePointer(
                    ignoring: !appinioLoop,
                    child: AnimatedOpacity(
                      // manualTrigger: true,
                      // animate: true,
                      // controller: (p0) {
                      //   squiggleFadeAnimationController = p0;
                      // },
                      opacity: appinioLoop ? 1 : 0,
                      duration: Durations.medium2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _dataPoints[0],
                                isCurved: true,
                                curveSmoothness: 0.5,
                                barWidth: 2,
                                color: Colors.black,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                              ),
                              LineChartBarData(
                                spots: _dataPoints[1],
                                isCurved: false,
                                curveSmoothness: 0,
                                barWidth: 1,
                                color: Colors.green,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                                // isStepLineChart: true,
                              ),
                              LineChartBarData(
                                  spots: _dataPoints[2],
                                  isCurved: false,
                                  curveSmoothness: 0,
                                  barWidth: 1,
                                  color: Colors.redAccent,
                                  belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(show: false),
                                  isStepLineChart: true),
                              LineChartBarData(
                                spots: _dataPoints[3],
                                isCurved: false,
                                curveSmoothness: 0,
                                barWidth: 1,
                                color: Colors.black,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                              ),
                              LineChartBarData(
                                spots: _dataPoints[4],
                                isCurved: false,
                                curveSmoothness: 0,
                                barWidth: 1,
                                color: Colors.black,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                              ),
                              LineChartBarData(
                                  spots: _dataPoints[5],
                                  isCurved: false,
                                  curveSmoothness: 0,
                                  barWidth: 1,
                                  color: Colors.purple,
                                  belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(show: false),
                                  isStepLineChart: true),
                              LineChartBarData(
                                spots: _dataPoints[6],
                                isCurved: false,
                                curveSmoothness: 0,
                                barWidth: 1,
                                color: Colors.indigo,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                              ),
                            ],
                            backgroundColor: Colors.black.withOpacity(0.02),
                            titlesData: FlTitlesData(
                              show: false,
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                interval: _dataPoints[0].last.x <= 50
                                    ? 50
                                    : _dataPoints[0].last.x,
                                reservedSize: 30,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 10,
                                    child: Text(
                                      value.round().toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              )),
                              bottomTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                      reservedSize: 20, showTitles: false)),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                      reservedSize: 10, showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                      reservedSize: 10, showTitles: true)),
                            ),
                            gridData: FlGridData(
                                show: true,
                                horizontalInterval: 20,
                                verticalInterval: 10),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              //
                              //
                              //
                              //
                              //
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((spotIndex) {
                                  final spot = barData.spots[spotIndex];
                                  if (spot.x == 0 || spot.x == 6) {
                                    return null;
                                  }
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: Colors.green,
                                      strokeWidth: 1,
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        if (index.isEven) {
                                          return FlDotCirclePainter(
                                            radius: 5,
                                            color: Colors.black,
                                            strokeWidth: 0,
                                            // strokeColor: widget
                                            //     .indicatorTouchedSpotStrokeColor,
                                          );
                                        } else {
                                          return FlDotSquarePainter(
                                            size: 5,
                                            color: Colors.black,
                                            strokeWidth: 0,
                                            // strokeColor: widget
                                            //     .indicatorTouchedSpotStrokeColor,
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                // getTooltipColor: (touchedSpot) =>
                                //     widget.tooltipBgColor,
                                getTooltipItems:
                                    (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    final flSpot = barSpot;
                                    if (flSpot.x == 0 || flSpot.x == 6) {
                                      return null;
                                    }

                                    TextAlign textAlign;
                                    switch (flSpot.x.toInt()) {
                                      case 1:
                                        textAlign = TextAlign.left;
                                        break;
                                      case 5:
                                        textAlign = TextAlign.right;
                                        break;
                                      default:
                                        textAlign = TextAlign.center;
                                    }

                                    return LineTooltipItem(
                                      'som \n',
                                      TextStyle(
                                        // color: widget.tooltipTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: flSpot.y.toString(),
                                          style: TextStyle(
                                            // color: widget.tooltipTextColor,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' k ',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: 'calories',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                      textAlign: textAlign,
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            minX: appinioLoop
                                ? _dataPoints[0].first.x
                                : appinioMinTabChanged,
                            maxX: appinioLoop
                                ? _dataPoints[0].last.x <= 50
                                    ? 50
                                    : (_dataPoints[0].last.x +
                                            ((_dataPoints[0].last.x -
                                                    _dataPoints[0].first.x) *
                                                0.2)) -
                                        _dataPoints[0].last.y * 0.02
                                : appinioMaxTabChanged,
                            minY: -30,
                            maxY: 30,
                          ),
                          duration: Duration(milliseconds: 150),
                          curve: Curves.linear,
                        ),
                      ),
                    ),
                  ),
                ),
                //
                //dateTime
                AnimatedPositioned(
                    duration: defaultDuration,
                    top: appinioLoop
                        ? topPadPosDistance + topPadGraphDistance + sHeight / 4
                        : sHeight,
                    // left: -50,
                    height: DTsectHeight,
                    width: DTsectWidth,
                    child: AnimatedContainer(
                      duration: defaultDuration,
                      height: DTsectHeight,
                      width: DTsectWidth,
                      color: Color(0xFFFBF5FF).withOpacity(0.7),
                    )),
                //
                //slider
                AnimatedPositioned(
                    duration: defaultDuration,
                    top:
                        topPadPosDistance + topPadGraphDistance + sHeight / 4.2,
                    left: sWidth / 15,
                    height: 20,
                    width: sWidth / 1.5,
                    child: AnimatedOpacity(
                      // animate: true,
                      // manualTrigger: true,
                      // controller: (p0) {
                      //   sliderFadeAnimationController = p0;
                      // },
                      opacity: appinioLoop ? 1 : 0,
                      duration: Durations.medium2,
                      child: IgnorePointer(
                        ignoring: !appinioLoop,
                        child: BalloonSlider(
                            thumbRadius: 3,
                            trackHeight: 3,
                            value: (_graphLineSpeedTween.value / 100),
                            ropeLength: sHeight / 6,
                            showRope: true,
                            onChangeStart: (val) {
                              setState(() {
                                _updateGraphLineSpeed(
                                    (val.clamp(0.1, 0.9) * 100).round());
                                // _updateGraphLineSpeed(_graphLineSpeed);
                              });
                            },
                            onChanged: (val) {
                              setState(() {
                                _updateGraphLineSpeed(
                                    (val.clamp(0.1, 0.9) * 100).round());
                              });
                            },
                            onChangeEnd: (val) {
                              setState(() {
                                _updateGraphLineSpeed(
                                    (val.clamp(0.1, 0.9) * 100).round());
                                // _updateGraphLineSpeed(_graphLineSpeed);
                              });
                            },
                            color: Colors.black),
                      ),
                    )),
                //
                //appinio cards
                AnimatedPositioned(
                  duration: defaultDuration,
                  top: Platform.isWindows ? topPadPosDistance + 10 : 5
                  // +
                  //     topPadGraphDistance +
                  //     topPadCardsDistance
                  ,
                  right: 6,
                  height: sHeight / 1.1,
                  width: sWidth / 3.6,
                  child: AppinioSwiper(
                    backgroundCardCount: 1,
                    // initialIndex: ref.read(cCardIndexProvider),
                    backgroundCardOffset: Offset(6, 6),
                    duration: Duration(milliseconds: 150),
                    backgroundCardScale: 1,
                    loop: appinioLoop,
                    cardCount: 10,
                    allowUnSwipe: true,
                    controller: recentsCardController,
                    onCardPositionChanged: (position) {
                      setState(() {
                        _cardPosition =
                            position.offset.dx.abs() + position.offset.dy.abs();
                      });
                    },
                    onSwipeEnd: (a, b, direction) {
                      // print(direction.toString());
                      setState(() {
                        ref
                            .read(cCardIndexProvider.notifier)
                            .update((s) => s = b);
                        // _currentCardIndex = b;
                        _cardPosition = 0;
                      });
                    },
                    cardBuilder: (BuildContext context, int index) {
                      int currentCardIndex = ref.watch(cCardIndexProvider);
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: defaultDuration,
                              margin: EdgeInsets.all(15),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(index.toString()),
                            ),
                          ),
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: currentCardIndex == index
                                  ? 0
                                  : index >= (currentCardIndex + 2) % 10
                                      ? 1
                                      : (1 -
                                          (_cardPosition / 200)
                                              .clamp(0.0, 1.0)),
                              duration: Duration(milliseconds: 300),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: index == (currentCardIndex + 1) % 10
                                      ? Colors.green
                                      : index == (currentCardIndex + 2) % 10
                                          ? Colors.green
                                          : Colors.green,
                                  border: Border.all(width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(index.toString()),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                //
                //SideNavbar
                Positioned(
                  // duration: defaultDuration,
                  top: 0,
                  left: sWidth / 10.5,
                  height: sWidth / 10.5,
                  width: sHeight,
                  child: Consumer(builder: (context, ref, c) {
                    return Transform.rotate(
                      angle: pi / 2,
                      alignment: Alignment.topLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: CurvedNavigationBar(
                          disp: Platform.isWindows
                              ? 60 / (sWidth / 800)
                              : 40 / (sWidth / 1100),
                          bgHeight: sWidth / 1.8,
                          index: appinioLoop ? 0 : 1,
                          radius: 0,
                          width: sHeight,
                          s: 0.18,
                          bottom: 0.7,
                          height: Platform.isWindows
                              ? 40 * ((sWidth + sHeight) / 1200)
                              : 50,
                          animationDuration: Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          color: Colors.green,
                          items: [
                            Transform.rotate(
                              angle: 3 * pi / 2,
                              child: Icon(
                                IconsaxPlusLinear.home_2,
                                size: sHeight / 28,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            Transform.rotate(
                              angle: 3 * pi / 2,
                              child: Icon(
                                IconsaxPlusLinear.document_text_1,
                                size: sHeight / 28,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            Transform.rotate(
                              angle: 3 * pi / 2,
                              child: Icon(
                                IconsaxPlusLinear.direct,
                                size: sHeight / 28,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            Transform.rotate(
                              angle: 3 * pi / 2,
                              child: Icon(
                                IconsaxPlusLinear.graph,
                                size: sHeight / 28,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                          onTap: (index) {
                            // Handle button tap
                            ref
                                .read(currentTabIndexProvider.notifier)
                                .update((state) => state = index);

                            // print(ref.read(currentTabIndexProvider));
                            _homeTabSwitched(index, ref);
                          },
                        ),
                      ),
                    );
                  }),
                )

                // Windows top bar
                ,
                if (Platform.isWindows)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {
                      appWindow.startDragging();
                    },
                    onDoubleTap: () {
                      appWindow.maximizeOrRestore();
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: 40,
                      child: Row(
                        children: [
                          Text(
                            '',
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          //minimize button
                          ElevatedLayerButton(
                            // isTapped: false,
                            // toggleOnTap: true,
                            onClick: () {
                              Future.delayed(Durations.medium1).then((y) {
                                appWindow.minimize();
                              });
                            },
                            buttonHeight: 30,
                            buttonWidth: 30,
                            borderRadius: BorderRadius.circular(5),
                            animationDuration:
                                const Duration(milliseconds: 100),
                            animationCurve: Curves.ease,
                            topDecoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(),
                            ),
                            topLayerChild: Icon(
                              TablerIcons.rectangle,
                              size: 15,
                              // color: Colors.blue,
                            ),
                            baseDecoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(),
                            ),
                          ),
                          //maximize button
                          ElevatedLayerButton(
                            // isTapped: false,
                            // toggleOnTap: true,
                            onClick: () {
                              Future.delayed(Durations.medium1).then((y) {
                                appWindow.maximizeOrRestore();
                              });
                            },
                            buttonHeight: 30,
                            buttonWidth: 30,
                            borderRadius: BorderRadius.circular(5),
                            animationDuration:
                                const Duration(milliseconds: 100),
                            animationCurve: Curves.ease,
                            topDecoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(),
                            ),
                            topLayerChild: Icon(
                              TablerIcons.triangle,
                              size: 14,
                              // color: Colors.amber,
                            ),
                            baseDecoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(),
                            ),
                          ),
                          //close button
                          ElevatedLayerButton(
                            // isTapped: false,
                            // toggleOnTap: true,
                            onClick: () {
                              Future.delayed(Durations.medium1).then((y) {
                                appWindow.close();
                              });
                            },
                            buttonHeight: 30,
                            buttonWidth: 30,
                            borderRadius: BorderRadius.circular(5),
                            animationDuration:
                                const Duration(milliseconds: 100),
                            animationCurve: Curves.ease,
                            topDecoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(),
                            ),
                            topLayerChild: Icon(
                              TablerIcons.circle,
                              size: 15,
                              // color: Colors.red,
                            ),
                            baseDecoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(),
                            ),
                          ),
                          //space
                          SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ));
    } else {
      //MOBILE
      return Scaffold(
          // resizeToAvoidBottomInset: true,
          body: AnimatedStack(
        slideAnimationDuration: Duration(milliseconds: 600),
        fabBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        fabIconColor: Colors.green,
        buttonIcon: IconsaxPlusBold.add,
        columnWidget: Column(),
        bottomWidget: Row(),
        foregroundWidget: Container(
          height: sHeight,
          width: sWidth,
          child: SafeArea(
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: !appinioLoop,
                  child: Container(
                    width: sWidth,
                    height: sHeight,
                    color: Colors.transparent,
                  ),
                ),
                _getLayoutAndTemplates(context, ref, topPadPosDistance),
                //
                //BILLBLAZE MAIN TITLE
                AnimatedPositioned(
                  duration: defaultDuration,
                  top: topPadPosDistance -
                      (appinioLoop ? 0 : topPadPosDistance / 1.5),
                  left: leftPadPosDistance + (appinioLoop ? 0 : sWidth / 50),
                  child: AnimatedTextKit(
                    key: ValueKey(appinioLoop),
                    animatedTexts: [
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.abrilFatface(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.zcoolKuaiLe(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.splash(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze",
                          textStyle: GoogleFonts.libreBarcode39ExtendedText(
                              fontSize: appinioLoop
                                  ? titleFontSize / 1.1
                                  : titleFontSize / 3,
                              letterSpacing:
                                  appinioLoop ? -titleFontSize / 4 : 0,
                              height: 1),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.redactedScript(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.fascinateInline(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                      TypewriterAnimatedText("Bill\nBlaze.",
                          textStyle: GoogleFonts.nabla(
                              fontSize: appinioLoop
                                  ? titleFontSize
                                  : titleFontSize / 3,
                              color: appinioLoop
                                  ? Colors.black
                                  : Color(0xFF000000).withOpacity(0.8),
                              height: 0.9),
                          speed: Duration(milliseconds: 100)),
                    ],
                    // totalRepeatCount: 1,
                    repeatForever: true,
                    pause: const Duration(milliseconds: 30000),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ),
                //
                //SIDE BAR BUTTON
                AnimatedPositioned(
                  duration: sideBarPosDuration,
                  top: (sHeight / 20) - (appinioLoop ? 0 : sHeight / 28),
                  left: (sWidth / 40) - (appinioLoop ? 0 : sWidth / 12),
                  child: ElevatedLayerButton(
                    onClick: () {},
                    buttonHeight: 70,
                    buttonWidth: 70,
                    borderRadius: BorderRadius.circular(100),
                    animationDuration: const Duration(milliseconds: 200),
                    animationCurve: Curves.ease,
                    topDecoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                    ),
                    topLayerChild: Icon(
                      IconsaxPlusLinear.element_3,
                      size: 25,
                    ),
                    baseDecoration: BoxDecoration(
                      color: Colors.green,
                      border: Border.all(),
                    ),
                  ),
                ),

                //
                //Graph
                AnimatedPositioned(
                  duration: defaultDuration,
                  top: topPadPosDistance + topPadGraphDistance,
                  height: sHeight / 6,
                  width: sWidth,
                  child: IgnorePointer(
                    ignoring: !appinioLoop,
                    child: FadeOut(
                      manualTrigger: true,
                      animate: true,
                      controller: (p0) {
                        squiggleFadeAnimationController = p0;
                      },
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _dataPoints[0],
                              isCurved: true,
                              curveSmoothness: 0.5,
                              barWidth: 2,
                              color: Colors.black,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: _dataPoints[1],
                              isCurved: false,
                              curveSmoothness: 0,
                              barWidth: 1,
                              color: Colors.green,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: false),
                              // isStepLineChart: true,
                            ),
                            LineChartBarData(
                                spots: _dataPoints[2],
                                isCurved: false,
                                curveSmoothness: 0,
                                barWidth: 1,
                                color: Colors.redAccent,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                                isStepLineChart: true),
                            LineChartBarData(
                              spots: _dataPoints[3],
                              isCurved: false,
                              curveSmoothness: 0,
                              barWidth: 1,
                              color: Colors.black,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: _dataPoints[4],
                              isCurved: false,
                              curveSmoothness: 0,
                              barWidth: 1,
                              color: Colors.black,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                                spots: _dataPoints[5],
                                isCurved: false,
                                curveSmoothness: 0,
                                barWidth: 1,
                                color: Colors.purple,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                                isStepLineChart: true),
                            LineChartBarData(
                              spots: _dataPoints[6],
                              isCurved: false,
                              curveSmoothness: 0,
                              barWidth: 1,
                              color: Colors.indigo,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          backgroundColor: Colors.black.withOpacity(0.02),
                          titlesData: FlTitlesData(
                            show: false,
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(
                              interval: _dataPoints[0].last.x <= 50
                                  ? 50
                                  : _dataPoints[0].last.x,
                              reservedSize: 30,
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 10,
                                  child: Text(
                                    value.round().toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            )),
                            bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    reservedSize: 20, showTitles: false)),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    reservedSize: 10, showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    reservedSize: 10, showTitles: true)),
                          ),
                          gridData: FlGridData(
                              show: true,
                              horizontalInterval: 20,
                              verticalInterval: 10),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            //
                            //
                            //
                            //
                            //
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> spotIndexes) {
                              return spotIndexes.map((spotIndex) {
                                final spot = barData.spots[spotIndex];
                                if (spot.x == 0 || spot.x == 6) {
                                  return null;
                                }
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: Colors.green,
                                    strokeWidth: 1,
                                  ),
                                  FlDotData(
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      if (index.isEven) {
                                        return FlDotCirclePainter(
                                          radius: 5,
                                          color: Colors.black,
                                          strokeWidth: 0,
                                          // strokeColor: widget
                                          //     .indicatorTouchedSpotStrokeColor,
                                        );
                                      } else {
                                        return FlDotSquarePainter(
                                          size: 5,
                                          color: Colors.black,
                                          strokeWidth: 0,
                                          // strokeColor: widget
                                          //     .indicatorTouchedSpotStrokeColor,
                                        );
                                      }
                                    },
                                  ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              // getTooltipColor: (touchedSpot) =>
                              //     widget.tooltipBgColor,
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final flSpot = barSpot;
                                  if (flSpot.x == 0 || flSpot.x == 6) {
                                    return null;
                                  }

                                  TextAlign textAlign;
                                  switch (flSpot.x.toInt()) {
                                    case 1:
                                      textAlign = TextAlign.left;
                                      break;
                                    case 5:
                                      textAlign = TextAlign.right;
                                      break;
                                    default:
                                      textAlign = TextAlign.center;
                                  }

                                  return LineTooltipItem(
                                    'som \n',
                                    TextStyle(
                                      // color: widget.tooltipTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: flSpot.y.toString(),
                                        style: TextStyle(
                                          // color: widget.tooltipTextColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' k ',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'calories',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                    textAlign: textAlign,
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          minX: appinioLoop
                              ? _dataPoints[0].first.x
                              : appinioMinTabChanged,
                          maxX: appinioLoop
                              ? _dataPoints[0].last.x <= 50
                                  ? 50
                                  : (_dataPoints[0].last.x +
                                          ((_dataPoints[0].last.x -
                                                  _dataPoints[0].first.x) *
                                              0.2)) -
                                      _dataPoints[0].last.y * 0.02
                              : appinioMaxTabChanged,
                          minY: -30,
                          maxY: 30,
                        ),
                        duration: Duration(milliseconds: 150),
                        curve: Curves.linear,
                      ),
                    ),
                  ),
                ),
                //
                //dateTime
                AnimatedPositioned(
                    duration: defaultDuration,
                    top: appinioLoop
                        ? topPadPosDistance +
                            topPadGraphDistance +
                            sHeight / 5.9
                        : sHeight,
                    // left: -50,
                    height: DTsectHeight,
                    width: DTsectWidth,
                    child: AnimatedContainer(
                      duration: defaultDuration,
                      height: DTsectHeight,
                      width: DTsectWidth,
                      color: Color(0xFFFBF5FF).withOpacity(0.7),
                    )),
                //
                //slider
                AnimatedPositioned(
                    duration: defaultDuration,
                    top:
                        topPadPosDistance + topPadGraphDistance + sHeight / 6.3,
                    left: -50,
                    height: 20,
                    width: sWidth + 100,
                    child: FadeOut(
                      animate: true,
                      manualTrigger: true,
                      controller: (p0) {
                        sliderFadeAnimationController = p0;
                      },
                      child: IgnorePointer(
                        ignoring: !appinioLoop,
                        child: BalloonSlider(
                            value: (_graphLineSpeedTween.value / 100),
                            ropeLength: sHeight / 6,
                            showRope: true,
                            onChangeStart: (val) {
                              setState(() {
                                _updateGraphLineSpeed(
                                    (val.clamp(0.1, 0.9) * 100).round());
                                // _updateGraphLineSpeed(_graphLineSpeed);
                              });
                            },
                            onChanged: (val) {
                              setState(() {
                                _updateGraphLineSpeed(
                                    (val.clamp(0.1, 0.9) * 100).round());
                              });
                            },
                            onChangeEnd: (val) {
                              setState(() {
                                _updateGraphLineSpeed(
                                    (val.clamp(0.1, 0.9) * 100).round());
                                // _updateGraphLineSpeed(_graphLineSpeed);
                              });
                            },
                            color: Colors.black),
                      ),
                    )),
                //
                //appinio cards
                AnimatedPositioned(
                  duration: defaultDuration,
                  top: topPadPosDistance +
                      topPadGraphDistance +
                      topPadCardsDistance,
                  right: 6,
                  height: sHeight / 3,
                  width: sWidth / 2,
                  child: AppinioSwiper(
                    backgroundCardCount: 1,
                    // initialIndex: ref.read(cCardIndexProvider),
                    backgroundCardOffset: Offset(6, 6),
                    duration: Duration(milliseconds: 150),
                    backgroundCardScale: 1,
                    loop: appinioLoop,
                    cardCount: 10,
                    allowUnSwipe: true,
                    controller: recentsCardController,
                    onCardPositionChanged: (position) {
                      setState(() {
                        _cardPosition =
                            position.offset.dx.abs() + position.offset.dy.abs();
                      });
                    },
                    onSwipeEnd: (a, b, direction) {
                      // print(direction.toString());
                      setState(() {
                        ref
                            .read(cCardIndexProvider.notifier)
                            .update((s) => s = b);
                        // _currentCardIndex = b;
                        _cardPosition = 0;
                      });
                    },
                    cardBuilder: (BuildContext context, int index) {
                      int currentCardIndex = ref.watch(cCardIndexProvider);
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: defaultDuration,
                              margin: EdgeInsets.all(15),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(index.toString()),
                            ),
                          ),
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: currentCardIndex == index
                                  ? 0
                                  : index >= (currentCardIndex + 2) % 10
                                      ? 1
                                      : (1 -
                                          (_cardPosition / 200)
                                              .clamp(0.0, 1.0)),
                              duration: Duration(milliseconds: 300),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: index == (currentCardIndex + 1) % 10
                                      ? Colors.green
                                      : index == (currentCardIndex + 2) % 10
                                          ? Colors.green
                                          : Colors.green,
                                  border: Border.all(width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(index.toString()),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                //
                //BottomNavbar
                AnimatedPositioned(
                  duration: defaultDuration,
                  bottom: 20,
                  left: 15,
                  height: sHeight / 7,
                  width: sWidth * 0.72,
                  child: Consumer(builder: (context, ref, c) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: CurvedNavigationBar(
                        bgHeight: sHeight,
                        index: appinioLoop ? 0 : 1,
                        radius: 35,
                        width: sWidth * 0.72,
                        s: 0.3,
                        bottom: 0.55,
                        height: sHeight / 12,
                        animationDuration: Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        color: Colors.green,
                        items: [
                          Icon(
                            IconsaxPlusLinear.home_2,
                            size: sHeight / 28,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          Icon(
                            IconsaxPlusLinear.document_text_1,
                            size: sHeight / 28,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          Icon(
                            IconsaxPlusLinear.direct,
                            size: sHeight / 28,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          Icon(
                            IconsaxPlusLinear.graph,
                            size: sHeight / 28,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                        onTap: (index) {
                          // Handle button tap
                          ref
                              .read(currentTabIndexProvider.notifier)
                              .update((state) => state = index);

                          // print(ref.read(currentTabIndexProvider));
                          _homeTabSwitched(index, ref);
                        },
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ));
      //
    }
  }

  //mobile
  Widget _getLayoutAndTemplates(
      BuildContext context, WidgetRef ref, double topPadPosDistance) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    bool appinioLoop = ref.watch(appinioLoopProvider);
    bool lay = ref.watch(layProvider);

    return AnimatedPositioned(
      duration: Durations.short2,
      // top: (topPadPosDistance * 1.08),
      height: sHeight,
      child: AnimatedOpacity(
        opacity: lay ? 1 : 0,
        duration: Duration(milliseconds: 100),
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: !lay,
              child: Container(
                height: sHeight,
                width: sWidth,
                alignment: Alignment.centerRight,
                color: appinioLoop
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.06),
                padding: EdgeInsets.only(
                  top: (topPadPosDistance * 1.08),
                ),
                //layGraph
                child: LineChart(LineChartData(
                    lineBarsData: [LineChartBarData()],
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(
                        show: true,
                        horizontalInterval: 10,
                        verticalInterval: 30),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 50,
                    maxX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                            500 +
                        250,
                    minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                        500)),
              ),
            ),
            //
            //lay&
            AnimatedPositioned(
              duration: Durations.medium2,
              width: sWidth,
              height: sHeight / 4,
              top: ((sHeight / 4) / 4),
              right: lay ? sWidth / 2.2 : (sWidth / 1.8),
              child: Text('&',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.dongle(
                      color: Color(0xFF000000).withOpacity(0.1),
                      fontSize: sHeight / 1.8,
                      letterSpacing: -5,
                      height: 0.6)),
            ),
            //layTEXTTITLE
            AnimatedPositioned(
              duration: Durations.medium2,
              right: 30,
              top: lay ? (topPadPosDistance * 1.2) : 0,
              child: Text('LAYOUT\nTEMPLATES',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.dongle(
                      color: Color(0xFF000000).withOpacity(0.7),
                      fontSize: sHeight / 8,
                      letterSpacing: -5,
                      height: 0.6)),
            ),
            //add buttons
            AnimatedPositioned(
              duration: Duration.zero,
              height: (sHeight - (sHeight / 2.95)) * 0.2,
              width: sWidth,
              top: lay ? sHeight / 2.95 : sHeight / 1.5,
              right: lay ? 2 : 2,
              child: IgnorePointer(
                ignoring: !lay,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedLayerButton(
                      onClick: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => Material(
                                        child: PopScope(
                                      child: LayoutDesigner3(),
                                      canPop: false,
                                    ))));
                      },
                      buttonHeight: sHeight / 8,
                      buttonWidth: sWidth / 2.2,
                      borderRadius: BorderRadius.circular(20),
                      animationDuration: const Duration(milliseconds: 200),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      topLayerChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              IconsaxPlusLinear.grid_3,
                              size: 40,
                            ),
                            Text(
                              'Create New \nLayout.',
                              style: GoogleFonts.outfit(
                                  // fontSize: 20,
                                  ),
                            )
                          ]),
                      baseDecoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(),
                      ),
                    ),
                    ElevatedLayerButton(
                      onClick: () {},
                      buttonHeight: sHeight / 8,
                      buttonWidth: sWidth / 2.2,
                      borderRadius: BorderRadius.circular(20),
                      animationDuration: const Duration(milliseconds: 200),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      topLayerChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              IconsaxPlusLinear.pen_add,
                              size: 40,
                            ),
                            Text(
                              'Create New \nTemplate.',
                              style: GoogleFonts.outfit(
                                  // fontSize: 20,
                                  ),
                            )
                          ]),
                      baseDecoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //LayoutList
            AnimatedPositioned(
              duration: Durations.extralong2,
              top: lay
                  ? (sHeight - (sHeight / 2.95)) * 0.19 + sHeight / 2.95
                  : sHeight,
              right: 2,
              height: sHeight / 2.75,
              width: sWidth,
              child: IgnorePointer(
                ignoring: !lay,
                child: AnimatedOpacity(
                  duration: Durations.extralong4 * 2,
                  opacity: lay ? 1 : 0,
                  curve: Curves.bounceInOut,
                  child: Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: defaultPalette.primary),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ListView.builder(
                        itemCount: Boxes.getLayouts().length,
                        itemBuilder: (BuildContext context, int i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return PopScope(
                                    canPop: false,
                                    child: LayoutDesigner3(
                                      id: Boxes.getLayouts().keyAt(i),
                                      index: i,
                                    ),
                                  );
                                },
                              ));
                            },
                            child: Container(
                              height: 50,
                              color: defaultPalette.secondary,
                              width: 30,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(right: 10, left: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(Boxes.getLayouts()
                                        .values
                                        .toList()[i]
                                        .name),
                                  ),
                                  //Delete a Layout button
                                  Expanded(
                                    flex: 3,
                                    child: ElevatedLayerButton(
                                      onClick: () async {
                                        final layoutsBox = Boxes.getLayouts();

                                        // Get the current key of the item to be deleted
                                        final int currentIndex = i;

                                        // Delete the item
                                        await layoutsBox
                                            .get(layoutsBox.keyAt(i))
                                            ?.delete();
                                        // Adjust keys for the remaining items
                                        // for (int index = currentIndex;
                                        //     index < layoutsBox.length;
                                        //     index++) {
                                        //   // Get the layout item
                                        //   final layout = layoutsBox.get(index);

                                        //   if (layout != null) {
                                        //     // Remove from the current key
                                        //     await layout.delete();
                                        //     // Add to the new key
                                        //     await layoutsBox.put(
                                        //         index - 1, layout);
                                        //   }
                                        // }

                                        // If you have a setState function or similar to refresh the UI, call it here
                                        setState(() {});
                                      },
                                      buttonHeight: 40,
                                      buttonWidth: 60,
                                      borderRadius: BorderRadius.circular(100),
                                      animationDuration:
                                          const Duration(milliseconds: 200),
                                      animationCurve: Curves.ease,
                                      topDecoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                      ),
                                      topLayerChild: Icon(
                                        TablerIcons.trash,
                                        size: 20,
                                      ),
                                      baseDecoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border.all(),
                                      ),
                                    ),
                                  ),
                                  //Options a Layout button
                                  Expanded(
                                    child: ElevatedLayerButton(
                                      onClick: () {},
                                      buttonHeight: 40,
                                      buttonWidth: 30,
                                      borderRadius: BorderRadius.circular(100),
                                      animationDuration:
                                          const Duration(milliseconds: 200),
                                      animationCurve: Curves.ease,
                                      topDecoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                      ),
                                      topLayerChild: Icon(
                                        TablerIcons.dots_vertical,
                                        size: 15,
                                      ),
                                      baseDecoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border.all(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // child: AppinioSwiper(
                  //   backgroundCardCount: 1,
                  //   backgroundCardOffset: Offset(6, 6),
                  //   duration: Duration(milliseconds: 150),
                  //   backgroundCardScale: 1,
                  //   loop: true,
                  //   cardCount: 2,
                  //   allowUnSwipe: true,
                  //   onCardPositionChanged: (position) {
                  //     setState(() {
                  //       _cardPosition =
                  //           position.offset.dx.abs() + position.offset.dy.abs();
                  //     });
                  //   },
                  //   onSwipeEnd: (a, b, direction) {
                  //     setState(() {
                  //       ref
                  //           .read(cCardIndexProvider.notifier)
                  //           .update((s) => s = b);
                  //       _cardPosition = 0;
                  //     });
                  //   },
                  //   cardBuilder: (BuildContext context, int index) {
                  //     int currentCardIndex = ref.watch(cCardIndexProvider);
                  //     return Stack(
                  //       children: [
                  //         Positioned.fill(
                  //           child: AnimatedContainer(
                  //             duration: Durations.medium2,
                  //             margin: EdgeInsets.all(15),
                  //             alignment: Alignment.center,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               border: Border.all(width: 2),
                  //               borderRadius: BorderRadius.circular(30),
                  //             ),
                  //             child:
                  //           ),
                  //         ),
                  //         Positioned.fill(
                  //           child: AnimatedOpacity(
                  //             opacity: currentCardIndex == index
                  //                 ? 0
                  //                 : index >= (currentCardIndex + 2) % 10
                  //                     ? 1
                  //                     : (1 -
                  //                         (_cardPosition / 200)
                  //                             .clamp(0.0, 1.0)),
                  //             duration: Duration(milliseconds: 300),
                  //             child: AnimatedContainer(
                  //               duration: Duration(milliseconds: 300),
                  //               margin: EdgeInsets.all(15),
                  //               alignment: Alignment.center,
                  //               decoration: BoxDecoration(
                  //                 color: index == (currentCardIndex + 1) % 10
                  //                     ? Colors.green
                  //                     : index == (currentCardIndex + 2) % 10
                  //                         ? Colors.green
                  //                         : Colors.green,
                  //                 border: Border.all(width: 2),
                  //                 borderRadius: BorderRadius.circular(30),
                  //               ),
                  //               child: ListView.builder(
                  //                 itemCount: Boxes.getLayouts().length,
                  //                 itemBuilder: (BuildContext context, int i) {
                  //                   return GestureDetector(
                  //                     onTap: () {
                  //                       Navigator.push(context,
                  //                           MaterialPageRoute(
                  //                         builder: (context) {
                  //                           return LayoutDesigner3(
                  //                             id: i,
                  //                           );
                  //                         },
                  //                       ));
                  //                     },
                  //                     child: Container(
                  //                       height: 50,
                  //                       color: Colors.amber,
                  //                       width: 30,
                  //                       alignment: Alignment.center,
                  //                       child: Text(Boxes.getLayouts()
                  //                           .get(i)
                  //                           .toString()),
                  //                     ),
                  //                   );
                  //                 },
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // ),
                ),
              ),
            ),
            // AnimatedPositioned(
            //     duration: Durations.extralong1,
            //     top: 5,
            //     right: 0,
            //     height: sHeight,
            //     width: sWidth,
            //     child: const MultiBoardListExample())
          ],
        ),
      ),
    );
  }

  //Windows/web
  Widget _getLayoutAndTemplatesWin(
      BuildContext context, WidgetRef ref, double topPadPosDistance) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    bool appinioLoop = ref.watch(appinioLoopProvider);
    bool lay = ref.watch(layProvider);

    return AnimatedPositioned(
      duration: Durations.short2,
      // top: (topPadPosDistance * 1.08),
      height: sHeight,
      child: AnimatedOpacity(
        opacity: lay ? 1 : 0,
        duration: Duration(milliseconds: 100),
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: !lay,
              child: Container(
                // duration: Durations.extralong1,
                height: sHeight,
                width: sWidth,
                alignment: Alignment.centerRight,
                color: appinioLoop
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.06),
                padding: EdgeInsets.only(
                  top: (topPadPosDistance * 1.08),
                ),
                //layGraph
                child: LineChart(LineChartData(
                    lineBarsData: [LineChartBarData()],
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(
                        show: true,
                        horizontalInterval: 10,
                        verticalInterval: 30),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 50,
                    maxX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                            500 +
                        250,
                    minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                        500)),
              ),
            ),
            //
            //lay&
            AnimatedPositioned(
              duration: Durations.medium2,
              width: sWidth,
              height: sHeight / 4,
              top: topPadPosDistance + sHeight / 4,
              right: lay ? sWidth / 2 : (sWidth / 1.8),
              child: Text('&',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.dongle(
                      color: Color(0xFF000000).withOpacity(0.1),
                      fontSize: sHeight / 1.8,
                      letterSpacing: -5,
                      height: 0.6)),
            ),
            //layTEXTTITLE
            AnimatedPositioned(
              duration: Durations.medium2,
              left: sWidth / 10,
              top: lay ? topPadPosDistance + sHeight / 4.2 : 0,
              child: Text('LAYOUT\nTEMPLATES',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.dongle(
                      color: Color(0xFF000000).withOpacity(0.7),
                      fontSize: sHeight / 5,
                      letterSpacing: -5,
                      height: 0.6)),
            ),
            //add buttons
            AnimatedPositioned(
              duration: Durations.extralong1,
              // height: (sHeight - (sHeight / 2.95)) * 0.2,
              width: sWidth,
              top: lay ? sHeight / 1.7 : sHeight / 1.5,
              // right: lay ? null : 2,
              left: sWidth / 18,
              child: IgnorePointer(
                ignoring: !lay,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedLayerButton(
                      onClick: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const Material(
                                        child: PopScope(
                                      child: LayoutDesigner3(),
                                      canPop: false,
                                    ))));
                      },
                      buttonHeight: sHeight / 6.5,
                      buttonWidth: sWidth / 2.2,
                      borderRadius: BorderRadius.circular(20),
                      animationDuration: const Duration(milliseconds: 200),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      topLayerChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              IconsaxPlusLinear.grid_3,
                              size: 40,
                            ),
                            Text(
                              'Create New \nLayout.',
                              style: GoogleFonts.outfit(
                                  // fontSize: 20,
                                  ),
                            )
                          ]),
                      baseDecoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(),
                      ),
                    ),
                    ElevatedLayerButton(
                      onClick: () {},
                      buttonHeight: sHeight / 6.5,
                      buttonWidth: sWidth / 2.2,
                      borderRadius: BorderRadius.circular(20),
                      animationDuration: const Duration(milliseconds: 200),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      topLayerChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              IconsaxPlusLinear.pen_add,
                              size: 40,
                            ),
                            Text(
                              'Create New \nTemplate.',
                              style: GoogleFonts.outfit(
                                  // fontSize: 20,
                                  ),
                            )
                          ]),
                      baseDecoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //LayoutList
            AnimatedPositioned(
              duration: Durations.extralong2,
              top: lay
                  ? Platform.isWindows
                      ? topPadPosDistance + 10
                      : 5
                  : sHeight,
              right: 2,
              height: sHeight / 1.1,
              width: sWidth / 2.05,
              child: IgnorePointer(
                ignoring: !lay,
                child: AnimatedOpacity(
                  duration: Durations.extralong4 * 2,
                  opacity: lay ? 1 : 0,
                  curve: Curves.bounceInOut,
                  child: Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: defaultPalette.primary),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ListView.builder(
                        itemCount: Boxes.getLayouts().length,
                        itemBuilder: (BuildContext context, int i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return PopScope(
                                    canPop: false,
                                    child: LayoutDesigner3(
                                      id: Boxes.getLayouts().keyAt(i),
                                      index: i,
                                    ),
                                  );
                                },
                              ));
                            },
                            child: Container(
                              height: 50,
                              color: defaultPalette.secondary,
                              width: 30,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(right: 10, left: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(Boxes.getLayouts()
                                        .values
                                        .toList()[i]
                                        .name),
                                  ),
                                  //Delete a Layout button
                                  Expanded(
                                    flex: 3,
                                    child: ElevatedLayerButton(
                                      onClick: () async {
                                        final layoutsBox = Boxes.getLayouts();

                                        // Get the current key of the item to be deleted
                                        final int currentIndex = i;

                                        // Delete the item
                                        await layoutsBox
                                            .get(layoutsBox.keyAt(i))
                                            ?.delete();
                                        // Adjust keys for the remaining items
                                        // for (int index = currentIndex;
                                        //     index < layoutsBox.length;
                                        //     index++) {
                                        //   // Get the layout item
                                        //   final layout = layoutsBox.get(index);

                                        //   if (layout != null) {
                                        //     // Remove from the current key
                                        //     await layout.delete();
                                        //     // Add to the new key
                                        //     await layoutsBox.put(
                                        //         index - 1, layout);
                                        //   }
                                        // }

                                        // If you have a setState function or similar to refresh the UI, call it here
                                        setState(() {});
                                      },
                                      buttonHeight: 40,
                                      buttonWidth: 60,
                                      borderRadius: BorderRadius.circular(100),
                                      animationDuration:
                                          const Duration(milliseconds: 200),
                                      animationCurve: Curves.ease,
                                      topDecoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                      ),
                                      topLayerChild: Icon(
                                        TablerIcons.trash,
                                        size: 20,
                                      ),
                                      baseDecoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border.all(),
                                      ),
                                    ),
                                  ),
                                  //Options a Layout button
                                  Expanded(
                                    child: ElevatedLayerButton(
                                      onClick: () {},
                                      buttonHeight: 40,
                                      buttonWidth: 30,
                                      borderRadius: BorderRadius.circular(100),
                                      animationDuration:
                                          const Duration(milliseconds: 200),
                                      animationCurve: Curves.ease,
                                      topDecoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                      ),
                                      topLayerChild: Icon(
                                        TablerIcons.dots_vertical,
                                        size: 15,
                                      ),
                                      baseDecoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border.all(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // child: AppinioSwiper(
                  //   backgroundCardCount: 1,
                  //   backgroundCardOffset: Offset(6, 6),
                  //   duration: Duration(milliseconds: 150),
                  //   backgroundCardScale: 1,
                  //   loop: true,
                  //   cardCount: 2,
                  //   allowUnSwipe: true,
                  //   onCardPositionChanged: (position) {
                  //     setState(() {
                  //       _cardPosition =
                  //           position.offset.dx.abs() + position.offset.dy.abs();
                  //     });
                  //   },
                  //   onSwipeEnd: (a, b, direction) {
                  //     setState(() {
                  //       ref
                  //           .read(cCardIndexProvider.notifier)
                  //           .update((s) => s = b);
                  //       _cardPosition = 0;
                  //     });
                  //   },
                  //   cardBuilder: (BuildContext context, int index) {
                  //     int currentCardIndex = ref.watch(cCardIndexProvider);
                  //     return Stack(
                  //       children: [
                  //         Positioned.fill(
                  //           child: AnimatedContainer(
                  //             duration: Durations.medium2,
                  //             margin: EdgeInsets.all(15),
                  //             alignment: Alignment.center,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               border: Border.all(width: 2),
                  //               borderRadius: BorderRadius.circular(30),
                  //             ),
                  //             child:
                  //           ),
                  //         ),
                  //         Positioned.fill(
                  //           child: AnimatedOpacity(
                  //             opacity: currentCardIndex == index
                  //                 ? 0
                  //                 : index >= (currentCardIndex + 2) % 10
                  //                     ? 1
                  //                     : (1 -
                  //                         (_cardPosition / 200)
                  //                             .clamp(0.0, 1.0)),
                  //             duration: Duration(milliseconds: 300),
                  //             child: AnimatedContainer(
                  //               duration: Duration(milliseconds: 300),
                  //               margin: EdgeInsets.all(15),
                  //               alignment: Alignment.center,
                  //               decoration: BoxDecoration(
                  //                 color: index == (currentCardIndex + 1) % 10
                  //                     ? Colors.green
                  //                     : index == (currentCardIndex + 2) % 10
                  //                         ? Colors.green
                  //                         : Colors.green,
                  //                 border: Border.all(width: 2),
                  //                 borderRadius: BorderRadius.circular(30),
                  //               ),
                  //               child: ListView.builder(
                  //                 itemCount: Boxes.getLayouts().length,
                  //                 itemBuilder: (BuildContext context, int i) {
                  //                   return GestureDetector(
                  //                     onTap: () {
                  //                       Navigator.push(context,
                  //                           MaterialPageRoute(
                  //                         builder: (context) {
                  //                           return LayoutDesigner3(
                  //                             id: i,
                  //                           );
                  //                         },
                  //                       ));
                  //                     },
                  //                     child: Container(
                  //                       height: 50,
                  //                       color: Colors.amber,
                  //                       width: 30,
                  //                       alignment: Alignment.center,
                  //                       child: Text(Boxes.getLayouts()
                  //                           .get(i)
                  //                           .toString()),
                  //                     ),
                  //                   );
                  //                 },
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // ),
                ),
              ),
            ),
            // AnimatedPositioned(
            //     duration: Durations.extralong1,
            //     top: 5,
            //     right: 0,
            //     height: sHeight,
            //     width: sWidth,
            //     child: const MultiBoardListExample())
          ],
        ),
      ),
    );
  }
}
