import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:math' as math;
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:billblaze/auth/user_auth.dart';
import 'package:billblaze/components/balloon_slider/widget.dart';
import 'package:billblaze/components/widgets/search_bar.dart';
import 'package:billblaze/models/bill/bill_type.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/providers/llama_provider.dart';
import 'package:billblaze/repo/google_cloud_storage_repository.dart';
import 'package:billblaze/repo/llama_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart' as gap;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/components/animated_stack.dart';
import 'package:billblaze/components/elevated_button.dart';
import 'package:billblaze/components/navbar/curved_navigation_bar.dart';
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
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:scrollbar_ultima/scrollbar_ultima.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:uuid/uuid.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;

final cCardIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final homeScreenTabIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final processMessageProvider = StateProvider<String>((ref) {
  return  'Initializing...';
});

final aiTokenProvider = StateProvider<String>((ref) {
  return  'Initializing...';
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
  bool isLayoutTileView = false;
  bool isTemplateView = false;
  TextEditingController layoutSearchController = TextEditingController();
  FocusNode layoutSearchFocusNode = FocusNode();
  late List<LayoutModel> filteredLayoutBox;
  double _cardPosition = 0;
  double totalRevenue = 0;
  late AppinioSwiperController recentsCardController;
  late AnimationController squiggleFadeAnimationController;
  late AnimationController sliderFadeAnimationController;
  late AnimationController sliderController;
  late AnimationController titleFontFadeController;
  Orientation? _lastOrientation;
  Map<double, double> monthRevenueMap = {};
  Map<double, double> dayRevenueMap = {};
  String result ='Loading AI';
  // bool isHomeTab = true;

  Key titleMainKey = GlobalKey();
  var monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  Map<SheetType, Map<String, double>> typeStats = {};
  int touchedIndex = -1;
  bool isDragging = false;
  List<TextEditingController> dateTextControllers = [
  ];
  List<FocusNode>  dateFocusNodes= List.generate(2, (index) => FocusNode(),);

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
    if (ref.read(homeScreenTabIndexProvider) ==1) {
      _homeTabSwitched(1, ref);
      squiggleFadeAnimationController.forward();
      sliderFadeAnimationController.forward();
    }
    filteredLayoutBox = Boxes.getLayouts().values.toList();
    // titleFontFadeController.forward();
    dateTextControllers = [
    TextEditingController()..text = monthNames[selectedMonth-1], TextEditingController()..text = selectedYear.toString()
  ];
  // Future.delayed(Duration.zero, () async {
  //     final String output = await Future.delayed(
  //       Duration.zero,
  //       () {
  //         String modelPath = Directory.current.path + r"\assets\models\phi-2.Q8_0.gguf";
  //         // String modelPath = "D:/Jepixo/CurrYaar/App/billblaze/assets/models/phi-2.Q8_0.gguf";
  //         return runAI(
  //         modelPath,
  //         "Summarize this month's transactions",
  //         ref
  //         );
  //       },
  //     );

  //     setState(() {
  //       result = output;
  //     });
  //   });
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await LlamaRepository.init(ref);
  //   });
  
  
  }

  @override
  void dispose() {
    _timer?.cancel();
    squiggleFadeAnimationController.dispose();
    sliderFadeAnimationController.dispose();
    sliderController.dispose();
    // recentsCardController.dispose();
    // ref.read(llamaProvider).dispose();
    // LlamaRepository.dispose();
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final currentOrientation = MediaQuery.of(context).orientation;
    if (_lastOrientation != currentOrientation) {
      _lastOrientation = currentOrientation;
      // Your specific code to run when orientation
      if (ref.read(homeScreenTabIndexProvider) ==1) {
        _homeTabSwitched(1, ref);
        Future.delayed(Durations.short3).then((u) {
           _homeTabSwitched(1, ref);
        });
      }
    }
    if (ref.read(homeScreenTabIndexProvider) ==1) {
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
    // ref.read(isLayoutTabProvider.notifier).state = index == 1;
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
        // ref.read(isHomeTabProvider.notifier).update(
        //       (state) => state = false,
        //     );
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
                  // print(recentsCardController.cardIndex);
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
      if (ref.read(homeScreenTabIndexProvider) !=0) {
        setState(() {
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
            ref.read(cCardIndexProvider.notifier).update((s) => s = recentsCardController.cardIndex!);
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
    // print('e ${recentsCardController.cardIndex}');
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
    Duration defaultDuration = Duration(milliseconds: 300);
    double topPadPosDistance = sHeight / 25;
    double leftPadPosDistance = sWidth / 10;
    double topPadGraphDistance = sHeight / 4.2;
    double titleFontSize = sHeight / 10;
    int homeScreenTabIndex = ref.watch(homeScreenTabIndexProvider);
    String processMessage = ref.watch(processMessageProvider);
    bool isHomeTab = homeScreenTabIndex ==0;
    bool isLayoutTab = homeScreenTabIndex ==1;
    bool isBillTab = homeScreenTabIndex ==2;
    // print(mapValue(value: sHeight, inMin: 480, inMax: 1186, outMin: 0.18, outMax: 0.1));
    // print(sHeight);
      return Scaffold(
          // resizeToAvoidBottomInset: true,
          backgroundColor: defaultPalette.extras[0],
          body: Stack(
            children: [
              AnimatedStack(
              scaleHeight: 40,
              scaleWidth: 40,
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
                      ignoring: homeScreenTabIndex !=0,
                      child: Container(
                        width: sWidth,
                        height: sHeight,
                        color: defaultPalette.primary,
                      ),
                    ),
                    _getBillsAndCharts(context, ref, topPadPosDistance),
                    _getLayoutAndTemplates(context, ref, topPadPosDistance),
                    AnimatedContainer(
                    duration: defaultDuration,
                    // color: isHomeTab?defaultPalette.white: defaultPalette.secondary,
                    height: 35,),
                    //
                    //BILLBLAZE MAIN TITLE
                    AnimatedPositioned(
                      duration: defaultDuration,
                      top: isHomeTab ? topPadPosDistance :10,
                      left: isHomeTab ? 110 : 60,
                      child: AnimatedTextKit(
                        key: ValueKey(isHomeTab ?sHeight*sWidth:isHomeTab),
                        animatedTexts: [
                          TypewriterAnimatedText("Bill\nBlaze.",
                              textStyle: GoogleFonts.abrilFatface(
                                  fontSize: isHomeTab
                                      ? titleFontSize
                                      : 20,
                                  color: defaultPalette.extras[0],
                                  height: 0.9),
                              speed: Duration(milliseconds: 100)),
                          TypewriterAnimatedText("Bill\nBlaze.",
                              textStyle: GoogleFonts.zcoolKuaiLe(
                                  fontSize: isHomeTab
                                      ? titleFontSize
                                      : 20,
                                  color: isHomeTab
                                      ? Colors.black
                                      : Color(0xFF000000).withOpacity(0.8),
                                  height: 0.9),
                              speed: Duration(milliseconds: 100)),
                          TypewriterAnimatedText("Bill\nBlaze.",
                              textStyle: GoogleFonts.splash(
                                  fontSize: isHomeTab
                                      ? titleFontSize
                                      : 20,
                                  color: isHomeTab
                                      ? Colors.black
                                      : Color(0xFF000000).withOpacity(0.8),
                                  height: 0.9),
                              speed: Duration(milliseconds: 100)),
                          TypewriterAnimatedText("Bill\nBlaze",
                              textStyle: GoogleFonts.libreBarcode39ExtendedText(
                                  fontSize: isHomeTab
                                      ? titleFontSize / 1.1
                                      : 20,
                                  letterSpacing:
                                      isHomeTab ? -titleFontSize / 4 : 0,
                                  height: 1),
                              speed: Duration(milliseconds: 100)),
                          TypewriterAnimatedText("Bill\nBlaze.",
                              textStyle: GoogleFonts.redactedScript(
                                  fontSize: isHomeTab
                                      ? titleFontSize
                                      : 20,
                                  color: isHomeTab
                                      ? Colors.black
                                      : Color(0xFF000000).withOpacity(0.8),
                                  height: 0.9),
                              speed: Duration(milliseconds: 100)),
                          TypewriterAnimatedText("Bill\nBlaze.",
                              textStyle: GoogleFonts.fascinateInline(
                                  fontSize: isHomeTab
                                      ? titleFontSize
                                      : 20,
                                  color: isHomeTab
                                      ? Colors.black
                                      : Color(0xFF000000).withOpacity(0.8),
                                  height: 0.9),
                              speed: Duration(milliseconds: 100)),
                          // TypewriterAnimatedText("Bill\nBlaze.",
                          //     textStyle: GoogleFonts.nabla(
                          //         fontSize: isHomeTab
                          //             ? titleFontSize
                          //             : titleFontSize / 3,
                          //         color: isHomeTab
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
                    //
                    //Graph window
                    AnimatedPositioned(
                      duration: defaultDuration,
                      top: topPadPosDistance + topPadGraphDistance,
                      left: sWidth / 15,
                      height: sHeight / 4,
                      width: sWidth / 1.5,
                      child: IgnorePointer(
                        ignoring: !isHomeTab,
                        child: AnimatedOpacity(
                          // manualTrigger: true,
                          // animate: true,
                          // controller: (p0) {
                          //   squiggleFadeAnimationController = p0;
                          // },
                          opacity: isHomeTab ? 1 : 0,
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
                                backgroundColor: defaultPalette.black.withOpacity(0.02),
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
                                      if (true) {
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
                                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) => List.filled(touchedBarSpots.length, null),
                                  ),
                                ),
                                minX: isHomeTab
                                    ? _dataPoints[0].first.x
                                    : appinioMinTabChanged,
                                maxX: isHomeTab
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
                    //
                    //balloon slider
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
                          opacity: isHomeTab ? 1 : 0,
                          duration: Durations.medium2,
                          child: IgnorePointer(
                            ignoring: !isHomeTab,
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
                    //appinio recents cards
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
                        loop: isHomeTab,
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
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                left: 25, right:25, top:25, bottom:25,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(10),
                                    child: Text( ref.watch(aiTokenProvider))),
                                )),
                              Positioned.fill(
                              left: 25, right:25, top:25, bottom:25,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Column(
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final receivePort = ReceivePort();

                                          final prompt = ChatHistory()
                                            ..addMessage(
                                              role: Role.system,
                                              content: """"" You are a concise, analytical assistant.
                                            Always focus directly on asnwering the user's prompt, 
                                            keep responses short and precise, and never include unnecessary elaboration. 
                                            Only generate the answer and stop. Never answer with information about geography, history, or unrelated trivia.
                                            Only provide brief, direct answers to user queries strictly related to statistical data from BillBlaze. 
                                            Do not generate questions or mention unrelated topics. """)
                                            ..addMessage(role: Role.user, content: "what time is it?")
                                            ..addMessage(role: Role.assistant, content: "");

                                          final modelPath = "C:/Users/ANTEC/Downloads/Compressed/LFM2-1.2B-Q4_K_M.gguf";

                                          // ✅ Pass only data, not Flutter state
                                          await Isolate.spawn(runLlamaModel, {
                                            'sendPort': receivePort.sendPort,
                                            'prompt': prompt.exportFormat(ChatFormat.chatml, leaveLastAssistantOpen: true),
                                            'modelPath': modelPath,
                                          });

                                          final buffer = StringBuffer();
                                          await for (final token in receivePort) {
                                            if (token == null) break;
                                            buffer.write(token);
                                            ref.read(aiTokenProvider.notifier).state += token;
                                          }

                                          print("✅ Final Response: ${buffer.toString()}");
                                        },
                                        // onTap: () async => await LlamaRepository.llamaRun(ref, 'What time is it?'),
                                        child: Container(
                                          width: 100,
                                          height:100,
                                          alignment: Alignment(0,0),
                                          decoration: BoxDecoration(color:defaultPalette.tertiary.withOpacity(0.4)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          );
                        },
                      ),
                    ),
                    
                  ],
                ),
              ),
                ),
              ),
              
              
              //SideNavbar
              Positioned(
                // duration: defaultDuration,
                top: 0,
                left:100,
                height: 100,
                width: sHeight,
                child: Consumer(builder: (context, ref, c) {
                  return Transform.rotate(
                    angle: pi / 2,
                    alignment: Alignment.topLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: CurvedNavigationBar(
                        disp: 50,
                        bgHeight: 50,
                        index: homeScreenTabIndex,
                        radius: 0,
                        width: sHeight,
                        s: mapValue(value: sHeight, inMin: 480, inMax: 1190, outMin: 0.2, outMax: 0.1),
                        bottom: 0.7,
                        height:  70,
                        animationDuration: Duration(milliseconds: 300),
                        buttonBackgroundColor:  defaultPalette.primary,
                        buttonIconColor: defaultPalette.extras[0],
                        backgroundColor: Colors.transparent,
                        color: defaultPalette.tertiary,
                        items: [
                          Icon(
                            IconsaxPlusLinear.home_2,
                            size: 25,
                            color: defaultPalette.extras[0],
                          ),
                          Icon(
                            IconsaxPlusLinear.document_text_1,
                            size: 25,
                            color:  defaultPalette.extras[0],
                          ),
                          Icon(
                            IconsaxPlusLinear.direct,
                            size: 25,
                            color:  defaultPalette.extras[0],
                          ),
                          Icon(
                            IconsaxPlusLinear.graph,
                            size: 25,
                            color:  defaultPalette.extras[0],
                          ),
                        ],
                        onTap: (index) {
                          // Handle button tap
                          ref
                              .read(homeScreenTabIndexProvider.notifier)
                              .update((state) => state = index);

                          // print(ref.read(currentTabIndexProvider));
                          _homeTabSwitched(index, ref);
                        },
                      ),
                    ),
                  );
                }),
              ),
              // Windows top bar
              if (Platform.isWindows)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (details) {
                  appWindow.startDragging();
                },
                onDoubleTap: () {
                  appWindow.maximizeOrRestore();
                },
                child: SizedBox(
                  height: 30,
                  child: Consumer(builder: (context, ref, c) {
                    return Stack(
                      children: [
                        AnimatedPositioned(
                          right: 0,
                          top: 0,
                          duration: Durations.short4,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: AnimatedContainer(
                              duration: Durations.short4,
                              padding: const EdgeInsets.only(
                                  right: 6, bottom: 0),
                              margin: const EdgeInsets.only(top: 5),
                              decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  )),
                              child: Row(
                                children: [
                                  //minimize button
                                  ElevatedLayerButton(
                                    // isTapped: false,
                                    // toggleOnTap: true,
                                    depth: 2.5, subfac: 2.5,
                                    onClick: () {
                                      Future.delayed(Duration.zero)
                                          .then((y) {
                                        appWindow.minimize();
                                      });
                                    },
                                    buttonHeight: 22,
                                    buttonWidth: 22,
                                    borderRadius:
                                        BorderRadius.circular(5),
                                    animationDuration:
                                        const Duration(milliseconds: 10),
                                    animationCurve: Curves.ease,
                                    topDecoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                    ),
                                    topLayerChild: const Icon(
                                      TablerIcons.rectangle,
                                      size: 15,
                                      // color: Colors.blue,
                                    ),
                                    baseDecoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(),
                                    ),
                                  ),
                                  SizedBox(width: 7,),
                                  //
                                  //maximize button
                                  ElevatedLayerButton(
                                    // isTapped: false,
                                    // toggleOnTap: true,
                                    depth: 2.5, subfac:2.5,
                                    onClick: () {
                                      Future.delayed(Durations.short1)
                                          .then((y) {
                                        appWindow.maximizeOrRestore();
                                      });
                                    },
                                    buttonHeight: 22,
                                    buttonWidth: 22,
                                    borderRadius:
                                        BorderRadius.circular(5),
                                    animationDuration:
                                        const Duration(milliseconds: 1),
                                    animationCurve: Curves.ease,
                                    topDecoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                    ),
                                    topLayerChild: const Icon(
                                      TablerIcons.triangle,
                                      size: 14,
                                      // color: Colors.amber,
                                    ),
                                    baseDecoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(),
                                    ),
                                  ),
                                  SizedBox(width: 7,),
                                  //close button
                                  ElevatedLayerButton(
                                    // isTapped: false,
                                    // toggleOnTap: true,
                                    depth: 2.5, subfac:2.5,
                                    onClick: () {
                                      Future.delayed(Duration.zero)
                                          .then((y) {
                                        appWindow.close();
                                      });
                                    },
                                    buttonHeight: 22,
                                    buttonWidth: 22,
                                    borderRadius:
                                        BorderRadius.circular(5),
                                    animationDuration:
                                        const Duration(milliseconds: 1),
                                    animationCurve: Curves.ease,
                                    topDecoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                    ),
                                    topLayerChild: const Icon(
                                      TablerIcons.circle,
                                      size: 15,
                                      // color: Colors.red,
                                    ),
                                    baseDecoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(),
                                    ),
                                  ),
                                ],
                              ),
                              //
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              
            ],
          ));
     
  }

  //Windows/web
  Widget _getLayoutAndTemplates(
      BuildContext context, WidgetRef ref, double topPadPosDistance) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    int homeScreenTabIndex = ref.watch(homeScreenTabIndexProvider);
    String processMessage = ref.watch(processMessageProvider);
    bool isHomeTab = homeScreenTabIndex ==0;
    bool isLayoutTab = homeScreenTabIndex ==1;
    double dotSize = sHeight/50;
    // print(sWidth);
    return AnimatedPositioned(
      duration: Durations.short2,
      // top: (topPadPosDistance * 1.08),
      height: sHeight,
      child: AnimatedOpacity(
        opacity: isLayoutTab ? 1 : 0,
        duration: Duration(milliseconds: 100),
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: !isLayoutTab,
              child: Container(
                // duration: Durations.extra,
                height: sHeight,
                width: sWidth,
                alignment: Alignment.centerRight,
                color: isHomeTab
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.06),
                padding: EdgeInsets.only(
                  top: 0,
                ),
                //layGraph
                child: LineChart(LineChartData(
                    lineBarsData: [LineChartBarData()],
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(
                        show: true,
                        horizontalInterval: 7.8,
                        verticalInterval: 30),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 50,
                    maxX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                            500 + 250,
                    minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                        500)),
              ),
            ),
            // AnimatedPositioned(
            //   duration: Durations.medium2,
            //   top: mapValueDimensionBased( 70, 90, sWidth,sHeight),
            //   left: isLayoutTab ? 120 : (sWidth / 1.8),
            //   child: IgnorePointer(
            //     ignoring:!isLayoutTab,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.end,
            //       children: [
            //         Container(
            //         decoration: BoxDecoration(
            //           color: defaultPalette.tertiary,
            //           shape: BoxShape.circle,
            //         ),
            //         child: SizedBox(height: dotSize,width:dotSize),
            //         ),
            //         SizedBox(width:4),
            //         Container(
            //         decoration: BoxDecoration(
            //           color: defaultPalette.extras[0],
            //           shape: BoxShape.circle,
            //         ),
            //         child: SizedBox(height: dotSize,width:dotSize),
            //         ),
            //         SizedBox(width:4),
            //         Container(
            //         decoration: BoxDecoration(
            //           color: defaultPalette.primary,
            //           shape: BoxShape.circle,
            //         ),
            //         child: SizedBox(height: dotSize, width:dotSize),
            //         ),
            //       ]
                  
            //     ),
            //   ),
            // ),
            // // //
            //Layout&
            AnimatedPositioned(
              duration: Durations.medium2,
              width: sWidth,
              height: (sHeight / 2.5),
              top: topPadPosDistance + sHeight / 3-(sHeight / 8).clamp(0, 85),
              right: isLayoutTab ? sWidth - math.min( (sHeight / 8), (sWidth/12)) - 350: (sWidth / 1.8),
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: Text('&',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.greatVibes(
                    color: Color(0xFF000000).withOpacity(0.2),
                    fontSize: (sHeight / 2.5).clamp(0, 300),
                    letterSpacing: -5,
                    fontWeight: FontWeight.w100,
                    height: 0.6
                  )
                ),
              ),
            ),
            //layTEXT TITLE
            AnimatedPositioned(
              duration: Durations.medium2,
              left:sWidth / (sWidth / 120),
              top: isLayoutTab ?  (sHeight / 4) : 0,
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: Text('Layouts\nTemplates',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.outfit(
                        color: defaultPalette.extras[0],
                        fontSize: math.min( (sHeight / 8).clamp(0, 85), (sWidth/12).clamp(0, 85)),
                        letterSpacing: -2,
                        fontWeight: FontWeight.w600,
                        height: 0.9)),
              ),
            ),
            
            //  gradient
            AnimatedPositioned(
              duration: Durations.extralong1,
              height: (sHeight/2.5),
              width: (sWidth/2.05)-70,
              bottom: sHeight / 18 ,
              left:(sWidth / 20).clamp( 90, double.infinity),
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0.1, 1.0], // Control where the fade starts/ends
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn, // Important for masking
                    child: Container(
                      decoration: BoxDecoration(color: 
                      Color(0xffc0c0c0),
                      borderRadius: BorderRadius.circular(20)
                      )
                    ),
                  ),
                )
              ),
            ),
            // addLayoutbutton
            AnimatedPositioned(
              duration: Durations.medium3,
              bottom: 1.6*(sHeight / 18),
              left: (sWidth / 20).clamp( 90, double.infinity)+(sWidth / 20)/2,
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: Stack(  
                  children: [
                    SizedBox(
                      height:isLayoutTab? (sHeight/2.5)-50:0,
                      width: (sWidth/10),
                    ),
                    Positioned(
                      left: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                      bottom: 0,
                       child: AnimatedContainer(
                        duration: Durations.medium3,
                        curve: Curves.easeIn,
                        height:isLayoutTab? ((sHeight/2.5)-46)/2:0,
                        width: (sWidth/10)-mapValueDimensionBased( 5, 10, sWidth,sHeight),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                          top: 5,
                          left: mapValueDimensionBased( 7, 15, sWidth,sHeight,useWidth: true),
                          right: mapValueDimensionBased( 7, 15, sWidth,sHeight,useWidth: true),
                        ),
                        transform: Matrix4.identity()
                        ..translate(isLayoutTab
                              ? 0.0
                              : (-((sHeight) - 250) /10).clamp(double.negativeInfinity, 50))
                          ..rotateZ( isLayoutTab? 0: -math.pi / 2),
                        decoration: BoxDecoration(
                          color: defaultPalette.transparent,
                          // border: Border.all(),
                          borderRadius: BorderRadius.circular(
                            isLayoutTab
                                ? mapValueDimensionBased( 12, 40, sWidth,sHeight)
                                : 900 
                            )
                          ),
                        
                      ),
                     ),
                    Positioned(
                      bottom: 0,
                      child: AnimatedContainer(
                        duration: Durations.medium3,
                         transform: Matrix4.identity()
                          ..translate(isLayoutTab
                            ? 0.0
                            : (-((sHeight) - 250) /10).clamp(double.negativeInfinity, 50))
                          ..rotateZ( isLayoutTab? 0: math.pi / 2),
                        child: ElevatedLayerButton(
                            onClick: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (c) =>  Material(
                                        child: PopScope(
                                      child: LayoutDesigner(
                                        onPop: (pdf) {
                                        },
                                      ),
                                      canPop: false,
                                    )
                                  )
                                )
                              );
                            },
                            buttonHeight: ((sHeight/2.5)-40)/2,
                            buttonWidth: (sWidth/10),
                            borderRadius: BorderRadius.circular(mapValueDimensionBased( 12, 40, sWidth,sHeight)),
                            animationDuration: const Duration(milliseconds: 200),
                            animationCurve: Curves.ease,
                            subfac: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                            depth: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                            topDecoration: BoxDecoration(
                              color: defaultPalette.primary,
                              border: Border.all(),
                            ),
                            topLayerChild: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Icon(
                                  //   IconsaxPlusLinear.grid_3,
                                  //   size: 40,
                                  // ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment(-1, -1),
                                      padding: EdgeInsets.only(
                                        top: mapValueDimensionBasedLockOnDesync( 5, 20, sWidth,sHeight),
                                        left:mapValueDimensionBasedLockOnDesync( 8, 20, sWidth,sHeight),
                                        right: mapValueDimensionBasedLockOnDesync( 7, 15, sWidth,sHeight,),
                                      ),
                                      child: Text(
                                        'Layout \nNew',
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.lexend(
                                          fontSize: mapValueDimensionBasedLockOnDesync( 15.5, 30, sWidth,sHeight,),
                                          color: defaultPalette.extras[0],
                                          letterSpacing: -1,
                                      
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                            baseDecoration: BoxDecoration(
                              color: defaultPalette.extras[0],
                              border: Border.all(),
                            ),
                          ),
                      ),
                    ),
                      
                  ],
                )
              ),
            ),
            // addBillbutton
            Positioned(
              // duration: Durations.medium3,
              bottom: 1.6*(sHeight / 18),
              left: ((sWidth / 20).clamp(90, double.infinity)+(sWidth / 20)/2)+(sWidth/10) + mapValue(value: sWidth, inMin: 800, inMax: 2194, outMin: 5, outMax: 30),
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: Stack(  
                  children: [
                    SizedBox(
                      height:isLayoutTab? (sHeight/2.5)-50:0,
                      width: (sWidth/10),
                    ),
                    Positioned(
                      left: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                      bottom: 0,
                       child: AnimatedContainer(
                        duration: Durations.medium3,
                        curve: Curves.easeIn,
                        height:isLayoutTab? ((sHeight/2.5)-40)/2:0,
                        width: (sWidth/10)-mapValueDimensionBased( 5, 10, sWidth,sHeight),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                          top: 5,
                          left:mapValueDimensionBased( 8, 15, sWidth,sHeight)
                        ),
                        transform: Matrix4.identity()
                        ..translate(isLayoutTab
                              ? 0.0
                              : (-((sHeight) - 250) /10).clamp(double.negativeInfinity, 50))
                          ..rotateZ( isLayoutTab? 0: -math.pi / 2),
                        decoration: BoxDecoration(
                          color: defaultPalette.transparent,
                          // border: Border.all(),
                          borderRadius:
                              BorderRadius.circular(
                                isLayoutTab
                                    ? mapValueDimensionBased( 12, 40, sWidth,sHeight)
                                    : 900)),
                        
                        
                      ),
                     ),
                    Positioned(
                      bottom: 0,
                      child: AnimatedContainer(
                        duration: Durations.medium3,
                         transform: Matrix4.identity()
                          ..translate(isLayoutTab
                            ? 0.0
                            : (-((sHeight) - 250) /10).clamp(double.negativeInfinity, 50))
                          ..rotateZ( isLayoutTab? 0: math.pi / 2),
                        child: ElevatedLayerButton(
                            onClick: () {
                             final box = Boxes.getLayouts();

                              for (var key in box.keys) {
                                final value = box.get(key);
                                print('Key: $key, Value: $value');
                              }
                              final name = Boxes.getBillName();
                              var key = 'BI-${const Uuid().v4()}';
                              // keyIndex = box.length;
                              var lm = LayoutModel(
                                createdAt: DateTime.now(),
                                modifiedAt: DateTime.now(),
                                name: name,
                                docPropsList: [],
                                spreadSheetList: [],
                                id: key,
                                type: SheetType.taxInvoice.index,

                              );
                              
                              box.put(key, lm);
                              lm.save();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (c) =>  Material(
                                        child: PopScope(
                                      child: LayoutDesigner(
                                        id: key,
                                        onPop: (pdf) {
                                        },
                                        
                                      ),
                                      canPop: false,
                                    )
                                  )
                                )
                              );
                            },
                            buttonHeight: ((sHeight/2.5)-40)/2,
                            buttonWidth: (sWidth/10),
                            borderRadius: BorderRadius.circular(mapValueDimensionBased( 12, 40, sWidth,sHeight)),
                            animationDuration: const Duration(milliseconds: 200),
                            animationCurve: Curves.ease,
                            subfac: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                            depth: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                            topDecoration: BoxDecoration(
                              color: defaultPalette.primary,
                              border: Border.all(),
                            ),
                            topLayerChild: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment(-1, -1),
                                      padding: EdgeInsets.only(
                                        top: mapValueDimensionBasedLockOnDesync( 5, 20, sWidth,sHeight),
                                        left:mapValueDimensionBasedLockOnDesync( 8, 20, sWidth,sHeight)
                                      ),
                                      child: Text(
                                        'Bill \nNew',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.lexend(
                                          fontSize: mapValueDimensionBasedLockOnDesync( 15.5, 30, sWidth,sHeight),
                                          color: defaultPalette.extras[0],
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                            baseDecoration: BoxDecoration(
                              color: defaultPalette.extras[0],
                              border: Border.all(),
                            ),
                          ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            // BG templatelbutton
            Positioned(
            left:mapValueDimensionBased( 5, 10, sWidth,sHeight)+ ((sWidth / 20).clamp( 90, double.infinity)+(sWidth / 20)/2)+2*((sWidth/10) + mapValue(value: sWidth, inMin: 800, inMax: 2194, outMin: 5, outMax: 30)),
    
            bottom: 1.6*(sHeight / 18),
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: AnimatedContainer(
                duration: Durations.medium3,
                curve: Curves.easeIn,
                height:isLayoutTab?((sHeight/2.5)-50-mapValueDimensionBased( 0, 10, sWidth,sHeight))/2:0,
                width: (sWidth/10)-mapValueDimensionBased( 5, 10, sWidth,sHeight),
                padding: EdgeInsets.only(
                          top: 5,
                          left:mapValueDimensionBased( 8, 15, sWidth,sHeight)
                        ),
                alignment: Alignment.topLeft,
                transform: Matrix4.identity()
                        ..translate(isLayoutTab
                              ? 0.0
                              : (-((sHeight) - 250) /10).clamp(double.negativeInfinity, 50))
                          ..rotateZ( isLayoutTab? 0: -math.pi / 2),
                decoration: BoxDecoration(
                  color: defaultPalette.extras[0],
                  border: Border.all(),
                  borderRadius: BorderRadius.circular( mapValueDimensionBased( 12, 40, sWidth,sHeight))),
                
                ),
                
              ),
            ),
            //
            // Cloud buttons
            Positioned(
              // duration: Durations.medium3,
              bottom: 1.6*(sHeight / 18),
              left: ((sWidth / 20).clamp(90, double.infinity)+(sWidth / 20)/2)+2*((sWidth/10) + mapValue(value: sWidth, inMin: 800, inMax: 2194, outMin: 5, outMax: 30)),
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: Stack(  
                  children: [
                    SizedBox(
                      height:isLayoutTab? (sHeight/2.5)-50:0,
                      width: (sWidth/10),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: Durations.medium3,
                             transform: Matrix4.identity()
                              ..translate(isLayoutTab
                                ? 0.0
                                : (-((sHeight) - 250) /10).clamp(double.negativeInfinity, 50))
                              ..rotateZ( isLayoutTab? 0: math.pi / 2),
                            child: ElevatedLayerButton(
                                onClick: () async {
                                  OverlayEntry? overlay;
                                    overlay =  OverlayEntry(builder: (context) => Scaffold(
                                    backgroundColor: defaultPalette.tertiary,
                                    body: Stack(
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            height: 150,
                                            child: LoadingIndicator(
                                                indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                                                colors: [defaultPalette.extras[0],defaultPalette.extras[0],defaultPalette.extras[0]],       /// Optional, The color collections
                                                strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                                backgroundColor: defaultPalette.transparent,      /// Optional, Background of the widget
                                                pathBackgroundColor: defaultPalette.tertiary  /// Optional, the stroke backgroundColor
                                            ),
                                          )
                                        ),
                                         Positioned(
                                          bottom: 10,
                                          left: 0,
                                          right: 0,
                                          child: Text(
                                            ref.watch(processMessageProvider),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lexend(
                                              fontSize: mapValueDimensionBased( 15, 30, sWidth,sHeight),
                                              color: defaultPalette.extras[0],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (Platform.isWindows)
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onPanStart: (details) {
                                              appWindow.startDragging();
                                            },
                                            onDoubleTap: () {
                                              appWindow.maximizeOrRestore();
                                            },
                                            child: SizedBox(
                                              height: 30,
                                              child: Consumer(builder: (context, ref, c) {
                                                return Stack(
                                                  children: [
                                                    AnimatedPositioned(
                                                      right: 0,
                                                      top: 0,
                                                      duration: Durations.short4,
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: AnimatedContainer(
                                                          duration: Durations.short4,
                                                          padding: const EdgeInsets.only(
                                                              right: 6, bottom: 0),
                                                          margin: const EdgeInsets.only(top: 5),
                                                          decoration: const BoxDecoration(
                                                              color: Colors.transparent,
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(12),
                                                                bottomLeft: Radius.circular(12),
                                                              )),
                                                          child: Row(
                                                            children: [
                                                              //minimize button
                                                              ElevatedLayerButton(
                                                                // isTapped: false,
                                                                // toggleOnTap: true,
                                                                depth: 2.5, subfac: 2.5,
                                                                onClick: () {
                                                                  Future.delayed(Duration.zero)
                                                                      .then((y) {
                                                                    appWindow.minimize();
                                                                  });
                                                                },
                                                                buttonHeight: 22,
                                                                buttonWidth: 22,
                                                                borderRadius:
                                                                    BorderRadius.circular(5),
                                                                animationDuration:
                                                                    const Duration(milliseconds: 10),
                                                                animationCurve: Curves.ease,
                                                                topDecoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  border: Border.all(),
                                                                ),
                                                                topLayerChild: const Icon(
                                                                  TablerIcons.rectangle,
                                                                  size: 15,
                                                                  // color: Colors.blue,
                                                                ),
                                                                baseDecoration: BoxDecoration(
                                                                  color: Colors.green,
                                                                  border: Border.all(),
                                                                ),
                                                              ),
                                                              SizedBox(width: 7,),
                                                              //
                                                              //maximize button
                                                              ElevatedLayerButton(
                                                                // isTapped: false,
                                                                // toggleOnTap: true,
                                                                depth: 2.5, subfac:2.5,
                                                                onClick: () {
                                                                  Future.delayed(Durations.short1)
                                                                      .then((y) {
                                                                    appWindow.maximizeOrRestore();
                                                                  });
                                                                },
                                                                buttonHeight: 22,
                                                                buttonWidth: 22,
                                                                borderRadius:
                                                                    BorderRadius.circular(5),
                                                                animationDuration:
                                                                    const Duration(milliseconds: 1),
                                                                animationCurve: Curves.ease,
                                                                topDecoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  border: Border.all(),
                                                                ),
                                                                topLayerChild: const Icon(
                                                                  TablerIcons.triangle,
                                                                  size: 14,
                                                                  // color: Colors.amber,
                                                                ),
                                                                baseDecoration: BoxDecoration(
                                                                  color: Colors.green,
                                                                  border: Border.all(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          //
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                          ),
              
                                      ],
                                    ),),);
                                    Overlay.of(context).insert(
                                      overlay
                                    );
                                  var box =Boxes.getLayouts();
                                  final gmap = await fetchAndReconstructLayoutModels(ref, overlay);
                                  overlay.remove();

                                  for (var lmEntry in gmap.entries) {
                                    final id = lmEntry.key;
                                    final incoming = lmEntry.value as LayoutModel;
                                    final existing = box.get(id);
                                    

                                    if (existing != null && incoming.modifiedAt.isBefore(existing.modifiedAt)) {
                                      if (!mounted) return;

                                      final shouldOverwrite = await showDialog<int>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: defaultPalette.primary,
                                          title: Text("Older ${incoming.id.startsWith('LY-')? 'Layout': incoming.type == 0? 'Bill': SheetType.values[incoming.type].name} In The Cloud!",
                                          style: GoogleFonts.lexend(
                                              fontSize: 25,
                                              color: defaultPalette.extras[0],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Do you want to overwrite it?",
                                                style: GoogleFonts.lexend(
                                                  fontSize: 14,
                                                  color: defaultPalette.extras[0],
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                ),
                                                SizedBox(height: 4,),
                                              Column(
                                                 mainAxisSize: MainAxisSize.min,
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  //incoming lm
                                                  Row(
                                                    children: [
                                                      Icon(TablerIcons.cloud),
                                                      SizedBox(width: 2,),
                                                      Text(
                                                      " ${incoming.name}",
                                                        style: GoogleFonts.lexend(
                                                          fontSize: 14, 
                                                          color: defaultPalette.extras[0],
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  RichText(
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  // overflow: TextOverflow.ellipsis,
                                                  text: TextSpan(
                                                    style: GoogleFonts.lexend(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w300,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Created: ',
                                                        style: GoogleFonts.lexend(color: defaultPalette.extras[0]),
                                                      ),
                                                      TextSpan(
                                                        text: DateFormat("EEE MMM d, y 'at' h:mm a").format(incoming.createdAt),
                                                        style: TextStyle(color: defaultPalette.extras[0]),
                                                      ),
                                                    ],
                                                  ),
                                                  ),
                                                  RichText(
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    // overflow: TextOverflow.ellipsis,
                                                    text: TextSpan(
                                                      style: GoogleFonts.lexend(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w300,
                                                        letterSpacing: -0.2,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: 'Modified: ',
                                                          style: GoogleFonts.lexend(color: defaultPalette.extras[0]),
                                                        ),
                                                        TextSpan(
                                                          text: DateFormat("EEE MMM d, y 'at' h:mm a").format(incoming.modifiedAt),
                                                          style: TextStyle(color: defaultPalette.extras[4]),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4,),
                                                  //existing lm
                                                  Row(
                                                    children: [
                                                      Icon(TablerIcons.server),
                                                      SizedBox(width: 2,),
                                                      Text(
                                                      " ${existing.name}",
                                                        style: GoogleFonts.lexend(
                                                          fontSize: 14, 
                                                          color: defaultPalette.extras[0],
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  RichText(
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  // overflow: TextOverflow.ellipsis,
                                                  text: TextSpan(
                                                    style: GoogleFonts.lexend(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w300,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Created: ',
                                                        style: GoogleFonts.lexend(color: defaultPalette.extras[0]),
                                                      ),
                                                      TextSpan(
                                                        text: DateFormat("EEE MMM d, y 'at' h:mm a").format(existing.createdAt),
                                                        style: TextStyle(color: defaultPalette.extras[0]),
                                                      ),
                                                    ],
                                                  ),
                                                  ),
                                                  RichText(
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    // overflow: TextOverflow.ellipsis,
                                                    text: TextSpan(
                                                      style: GoogleFonts.lexend(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w300,
                                                        letterSpacing: -0.2,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: 'Modified: ',
                                                          style: GoogleFonts.lexend(color: defaultPalette.extras[0]),
                                                        ),
                                                        TextSpan(
                                                          text: DateFormat("EEE MMM d, y 'at' h:mm a").format(existing.modifiedAt),
                                                          style: TextStyle(color: defaultPalette.tertiary),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                
                                                ],
                                              )
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, 0),
                                              child: Text("Nah",
                                              style: GoogleFonts.lexend(
                                              fontSize: 14,
                                              color: defaultPalette.extras[0],
                                              fontWeight: FontWeight.w500,
                                            ),
                                              ),
                                            ),
                                            TextButton(
                                              
                                              onPressed: () => Navigator.pop(ctx, 1),
                                              child: Text("Overwrite",
                                              style: GoogleFonts.lexend(
                                              fontSize: 14,
                                              color: defaultPalette.extras[4],
                                              fontWeight: FontWeight.w500,
                                              ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, 2),
                                              child: Text("Keep Both",
                                              style: GoogleFonts.lexend(
                                              fontSize: 14,
                                              color: defaultPalette.tertiary,
                                              fontWeight: FontWeight.w500,
                                              ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldOverwrite == 0) continue;
                                      if (shouldOverwrite == 1) {
                                        box.put(id, incoming.copyWith(pdf: existing.pdf));
                                      } else if (shouldOverwrite ==2) {
                                        var newId = '${existing.id.substring(0,4)}${Uuid().v4()}';
                                        var newlm = LayoutModel(
                                          docPropsList: incoming.docPropsList, 
                                          spreadSheetList: incoming.spreadSheetList, 
                                          id: newId, name: incoming.name+'-old', 
                                          createdAt: incoming.createdAt, 
                                          modifiedAt: incoming.modifiedAt,
                                          labelList:incoming.labelList,
                                          pdf: existing.pdf,
                                          type: incoming.type,

                                          );
                                        box.put(newId, newlm);
                                      }
                                    }

                                  }

                                  setState(() {
                                    filteredLayoutBox = box.values.toList();
                                  });
                                 
                                },
                                buttonHeight: ((sHeight/2.5)-40)/2,
                                buttonWidth: (sWidth/20),
                                borderRadius: BorderRadius.circular(mapValueDimensionBased( 12, 40, sWidth,sHeight)),
                                animationDuration: const Duration(milliseconds: 200),
                                animationCurve: Curves.ease,
                                subfac: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                                depth: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                                topDecoration: BoxDecoration(
                                  color: defaultPalette.primary,
                                  border: Border.all(),
                                ),
                                topLayerChild: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: mapValueDimensionBasedLockOnDesync( 5, 20, sWidth,sHeight),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(TablerIcons.cloud,size: mapValueDimensionBased( 16, 40, sWidth,sHeight),),
                                              Icon(TablerIcons.download,size: mapValueDimensionBased( 16, 40, sWidth,sHeight),),
                                            ],
                                          )
                                        ),
                                      ),
                                    ]),
                                baseDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                  // border: Border.all(),
                                ),
                              ),
                          ),
                          AnimatedContainer(
                            duration: Durations.medium3,
                             transform: Matrix4.identity()
                              ..translate(isLayoutTab
                                ? 0.0
                                : (-((sHeight) - 250) /10).clamp(double.negativeInfinity, 50))
                              ..rotateZ( isLayoutTab? 0: math.pi / 2),
                            child: ElevatedLayerButton(
                                onClick: () async {
                                   OverlayEntry? overlay;
                                    overlay =  OverlayEntry(builder: (context) => Scaffold(
                                    backgroundColor: defaultPalette.tertiary,
                                    body: Stack(
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            height: 150,
                                            child: LoadingIndicator(
                                                indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                                                colors: [defaultPalette.primary,defaultPalette.primary,],       /// Optional, The color collections
                                                strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                                backgroundColor: defaultPalette.transparent,      /// Optional, Background of the widget
                                                pathBackgroundColor: defaultPalette.tertiary  /// Optional, the stroke backgroundColor
                                            ),
                                          )
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          left: 0,
                                          right: 0,
                                          child: Text(
                                            ref.watch(processMessageProvider),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lexend(
                                              fontSize: mapValueDimensionBased( 15, 30, sWidth,sHeight),
                                              color: defaultPalette.extras[0],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (Platform.isWindows)
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onPanStart: (details) {
                                              appWindow.startDragging();
                                            },
                                            onDoubleTap: () {
                                              appWindow.maximizeOrRestore();
                                            },
                                            child: SizedBox(
                                              height: 30,
                                              child: Consumer(builder: (context, ref, c) {
                                                return Stack(
                                                  children: [
                                                    AnimatedPositioned(
                                                      right: 0,
                                                      top: 0,
                                                      duration: Durations.short4,
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: AnimatedContainer(
                                                          duration: Durations.short4,
                                                          padding: const EdgeInsets.only(
                                                              right: 6, bottom: 0),
                                                          margin: const EdgeInsets.only(top: 5),
                                                          decoration: const BoxDecoration(
                                                              color: Colors.transparent,
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(12),
                                                                bottomLeft: Radius.circular(12),
                                                              )),
                                                          child: Row(
                                                            children: [
                                                              //minimize button
                                                              ElevatedLayerButton(
                                                                // isTapped: false,
                                                                // toggleOnTap: true,
                                                                depth: 2.5, subfac: 2.5,
                                                                onClick: () {
                                                                  Future.delayed(Duration.zero)
                                                                      .then((y) {
                                                                    appWindow.minimize();
                                                                  });
                                                                },
                                                                buttonHeight: 22,
                                                                buttonWidth: 22,
                                                                borderRadius:
                                                                    BorderRadius.circular(5),
                                                                animationDuration:
                                                                    const Duration(milliseconds: 10),
                                                                animationCurve: Curves.ease,
                                                                topDecoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  border: Border.all(),
                                                                ),
                                                                topLayerChild: const Icon(
                                                                  TablerIcons.rectangle,
                                                                  size: 15,
                                                                  // color: Colors.blue,
                                                                ),
                                                                baseDecoration: BoxDecoration(
                                                                  color: Colors.green,
                                                                  border: Border.all(),
                                                                ),
                                                              ),
                                                              SizedBox(width: 7,),
                                                              //
                                                              //maximize button
                                                              ElevatedLayerButton(
                                                                // isTapped: false,
                                                                // toggleOnTap: true,
                                                                depth: 2.5, subfac:2.5,
                                                                onClick: () {
                                                                  Future.delayed(Durations.short1)
                                                                      .then((y) {
                                                                    appWindow.maximizeOrRestore();
                                                                  });
                                                                },
                                                                buttonHeight: 22,
                                                                buttonWidth: 22,
                                                                borderRadius:
                                                                    BorderRadius.circular(5),
                                                                animationDuration:
                                                                    const Duration(milliseconds: 1),
                                                                animationCurve: Curves.ease,
                                                                topDecoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  border: Border.all(),
                                                                ),
                                                                topLayerChild: const Icon(
                                                                  TablerIcons.triangle,
                                                                  size: 14,
                                                                  // color: Colors.amber,
                                                                ),
                                                                baseDecoration: BoxDecoration(
                                                                  color: Colors.green,
                                                                  border: Border.all(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          //
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                          ),
              
                                      ],
                                    ),),);
                                    Overlay.of(context).insert(
                                      overlay
                                    );
                                 await authenticateAndSyncLayoutModels(Boxes.getLayouts(), ref, overlay).then((value) {
                                   overlay?.remove();
                                 },);
                                },
                                buttonHeight: ((sHeight/2.5)-40)/2,
                                buttonWidth: (sWidth/20),
                                borderRadius: BorderRadius.circular(mapValueDimensionBased(12, 40, sWidth,sHeight)),
                                animationDuration: const Duration(milliseconds: 200),
                                animationCurve: Curves.ease,
                                subfac: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                                depth: mapValueDimensionBased( 5, 10, sWidth,sHeight),
                                topDecoration: BoxDecoration(
                                  color: defaultPalette.primary,
                                  border: Border.all(),
                                ),
                                topLayerChild: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: mapValueDimensionBasedLockOnDesync( 5, 20, sWidth,sHeight),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(TablerIcons.cloud, size: mapValueDimensionBasedLockOnDesync( 16, 40, sWidth,sHeight),),
                                              Icon(TablerIcons.upload, size: mapValueDimensionBasedLockOnDesync( 16, 40, sWidth,sHeight),),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                baseDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                  // border: Border.all(),
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),
            ),
            //toggle bwteen layouts and templates
            AnimatedPositioned(
              duration: Durations.medium3,
              bottom: 1.6*(sHeight / 18) -sWidth/30,
              left: isLayoutTab?((sWidth / 20).clamp( 90, double.infinity)+(sWidth / 20)/2)+3*((sWidth/10) + mapValue(value: sWidth, inMin: 800, inMax: 2194, outMin: 5, outMax: 30)):sWidth/2,
              child: Transform.rotate(
                alignment: Alignment(-1, -1),
                angle: -pi/2,
                child: IgnorePointer(
                  ignoring: !isLayoutTab,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync( 10, 36, sWidth,sHeight),),
                    ),
                    child: AnimatedToggleSwitch<bool>.dual(
                      current: isTemplateView,
                      first: true,
                      second: false,
                      onChanged: (value) {
                        setState(() {
                          isTemplateView = value;
                        });
                      },
                      animationCurve:
                          Curves.easeInOutExpo,
                      animationDuration:
                          Durations.medium4,
                      borderWidth:
                          2, // backgroundColor is set independently of the current selection
                      styleBuilder: (value) =>
                          ToggleStyle(
                              borderRadius:
                                  BorderRadius
                                      .circular(mapValueDimensionBasedLockOnDesync( 9, 35, sWidth,sHeight),),
                              indicatorBorderRadius:
                                  BorderRadius.only(
                                    topLeft:  Radius.circular(!value?8:34) ,
                                    topRight: Radius.circular(value?8:34) ,
                                    bottomLeft:Radius.circular(!value?8:34) ,
                                    bottomRight:  Radius.circular(value?8:34) ,
                                    ),
                              indicatorBorder: Border.all(),
                              borderColor:
                                  defaultPalette
                                      .extras[0],
                              backgroundColor:
                                  defaultPalette
                                      .extras[0],
                              indicatorColor:
                                  defaultPalette
                                          .primary), // indicatorColor changes and animates its value with the selection
                      iconBuilder: (value) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Transform.rotate(
                            angle: pi/2,
                            child: Icon(
                                !value? TablerIcons
                                        .layout
                                    : TablerIcons
                                        .template,
                                size: mapValueDimensionBased( 12,30, sWidth,sHeight),
                                color: defaultPalette
                                    .extras[0]),
                          ),
                        );
                      },
                      textBuilder: (value) {
                        return Text(
                          value ? 'template'
                              : 'layout',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              GoogleFonts.lexend(
                                  fontSize: mapValueDimensionBased( 10, 20, sWidth,sHeight),
                                  fontWeight: FontWeight.w500,
                                  color: 
                                  defaultPalette
                                      .primary ,
                                  ),
                        );
                      },
                      height:sWidth/30,
                      spacing:(sHeight/2.5)-150,
                    ),
                  ),
                ),
              ),
            ),
            //quote
            AnimatedPositioned(
              duration: Durations.medium2,
              left:((sWidth / 20).clamp(90, double.infinity)+(sWidth / 20)/1.5),
              bottom: isLayoutTab ? 1.6*(sHeight / 18)+(sHeight/2.6)-mapValueDimensionBased( 85, 115, sWidth,sHeight): 0,
              child: Text(
                  ' Pay up, \n buttercup!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // textAlign: TextAlign.end,
                  style: GoogleFonts.lexend(
                    fontSize: mapValueDimensionBased( 15, 30, sWidth,sHeight),
                    color: defaultPalette.extras[0].withOpacity(0.4),
                    letterSpacing: -0.2,
                    height: 1
                  ),
                ),
              ),
            
            //LayoutList
            AnimatedPositioned(
              duration: Durations.extralong2,
              top: isLayoutTab
                  ? Platform.isWindows
                      ? topPadPosDistance + 10
                      : 5
                  : sHeight,
              right: 2,
              height: sHeight / 1.1,
              width: sWidth / 2.05,
              child: IgnorePointer(
                ignoring: !isLayoutTab,
                child: AnimatedOpacity(
                  duration: Durations.extralong3 * 2,
                  opacity: isLayoutTab ? 1 : 0,
                  curve: Curves.bounceInOut,
                  child: Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(mapValueDimensionBased( 5, 10, sWidth,sHeight)).copyWith(top: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: defaultPalette.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //my layouts title search bar list page toggle
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '   Layouts',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.lexend(
                                  fontSize: mapValueDimensionBased( 20, 30, sWidth,sHeight),
                                  color: defaultPalette.extras[0],
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            
                              ExpandableSearchBar(
                                onTap: () {
                                  
                                },
                                onChange: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      filteredLayoutBox = Boxes.getLayouts()
                                          .values
                                          .where((i) => i.name.toLowerCase().contains(value.toLowerCase()))
                                          .toList();
                                    } else {
                                      filteredLayoutBox = Boxes.getLayouts()
                                          .values.toList();
                                    }
                                  });
                                },
                                hintText: "search layout...",
                                editTextController: layoutSearchController,
                                focusNode: layoutSearchFocusNode,
                                boxShadow: [],
                                iconBackgroundColor: defaultPalette.primary,
                                iconColor: defaultPalette.extras[0],
                                iconSize: mapValueDimensionBased( 20, 30, sWidth,sHeight),
                                backgroundColor: defaultPalette.secondary,

                              ),
                              SizedBox(width: 3,), 
                              AnimatedToggleSwitch<bool>.dual(
                              current: isLayoutTileView,
                              first: true,
                              second: false,
                              onChanged: (value) {
                                setState(() {
                                  isLayoutTileView = value;
                                });
                              },
                              animationCurve:
                                  Curves.easeInOutExpo,
                              animationDuration:
                                  Durations.medium4,
                              borderWidth:
                                  2, // backgroundColor is set independently of the current selection
                              styleBuilder: (value) =>
                                  ToggleStyle(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  50),
                                      indicatorBorderRadius:
                                          BorderRadius
                                              .circular(
                                                  5),
                                      borderColor:
                                          defaultPalette
                                              .secondary,
                                      backgroundColor:
                                          defaultPalette
                                              .secondary,
                                      indicatorColor:
                                          defaultPalette
                                                  .extras[0]), // indicatorColor changes and animates its value with the selection
                              iconBuilder: (value) {
                                return Icon(
                                    value? TablerIcons
                                            .grip_horizontal
                                        : TablerIcons
                                            .grip_vertical,
                                    size: 12,
                                    color: defaultPalette
                                        .primary);
                              },
                              textBuilder: (value) {
                                return Text(
                                  value ? 'list'
                                      : 'page',
                                  style:
                                      GoogleFonts.bungee(
                                          fontSize: 12),
                                );
                              },
                              height:mapValueDimensionBased( 22, 32, sWidth,sHeight),
                              spacing:mapValueDimensionBased( 10, 30, sWidth,sHeight),
                            ),
                            SizedBox(width: 5,),                    
                          ],
                        ),
                        SizedBox(height: 10,),
                        //the layout tiles
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color:  Color(0xffc0c0c0).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.all(5),
                            child:  ScrollConfiguration(
                              behavior: ScrollBehavior().copyWith(scrollbars: false),
                              child: DynMouseScroll(
                                durationMS: 500,
                                scrollSpeed: 1,
                                builder: (context, controller, physics) {
                                  return ScrollbarUltima(
                                    alwaysShowThumb: true,
                                    controller: controller,
                                    scrollbarPosition:
                                        ScrollbarPosition.right,
                                    backgroundColor: defaultPalette.primary,
                                    isDraggable: true,
                                    maxDynamicThumbLength: 90,
                                    minDynamicThumbLength: 50,
                                    thumbBuilder:
                                        (context, animation, widgetStates) {
                                      return Container(
                                        margin: EdgeInsets.only(right: 3, top: 8,bottom: 8),
                                        decoration: BoxDecoration(
                                            color: defaultPalette.primary,
                                            border: Border.all(),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        width: 6,
                                      );
                                    },
                                  child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(right:0),
                                  controller: controller,
                                  physics: physics,
                                  itemCount:layoutSearchController.text ==''?Boxes.getLayouts().values.toList().length+1: filteredLayoutBox.length+1,
                                  itemBuilder: (BuildContext context, int i) {
                                    
                                    if (i ==(layoutSearchController.text ==''?Boxes.getLayouts().values.toList().length:filteredLayoutBox.length)) {
                                      return SizedBox(height: 5,);
                                    }
                                    final layoutModel = layoutSearchController.text ==''?Boxes.getLayouts().values.toList()[i]: filteredLayoutBox[i];
                                    if (layoutModel.id.startsWith('BI-')) {
                                      return SizedBox.shrink();
                                    }
                                    if(!isLayoutTileView) {
                                      return Material(
                                        color: defaultPalette.transparent,
                                        child: InkWell(
                                          hoverColor: defaultPalette.extras[0].withOpacity(0.4),
                                          highlightColor: defaultPalette.extras[0].withOpacity(0.4),
                                          splashColor: defaultPalette.extras[0].withOpacity(0.4),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) {
                                                return PopScope(
                                                  canPop: false,
                                                  child: LayoutDesigner(
                                                    id: Boxes.getLayouts().keyAt(i),
                                                    onPop: (pdf) {
                                                      setState(() {
                                                      filteredLayoutBox = Boxes.getLayouts().values.toList();
                                                    });
                                                    },
                                                  ),
                                                );
                                              },
                                            ));
                                            filteredLayoutBox = Boxes.getLayouts()
                                          .values.toList();
                                          },
                                        child: Container(
                                          height: 200,
                                          width: 30,
                                          margin: EdgeInsets.only(bottom: 10,right: 8),
                                          color: defaultPalette.transparent,
                                          child: Row(
                                            children: [
                                              //mini layout pdf pages swiper
                                              SizedBox(
                                                height: 200,
                                                width: 150,
                                                child: AppinioSwiper(
                                                  cardCount: (layoutModel.spreadSheetList.length.isNaN ||layoutModel.docPropsList.length ==0 )?1:layoutModel.docPropsList.length,
                                                  backgroundCardCount: 5,
                                                  backgroundCardOffset: Offset(0.8, 0.8),
                                                  duration: Duration(milliseconds: 220),
                                                  backgroundCardScale: 1,
                                                  loop: true,
                                                  allowUnSwipe: true,
                                                  allowUnlimitedUnSwipe: true,
                                                  initialIndex: 0,  
                                                  cardBuilder: (context, indx) {
                                                    // print(layoutModel.pdf?.length);
                                                    return Stack(
                                                          children: [
                                                            //The main bgCOLOR OF THE CARD
                                                            Positioned.fill(
                                                              child: AnimatedContainer(
                                                                duration: Durations.short3,
                                                                alignment: Alignment.center,
                                                                margin: EdgeInsets.only(left:8,top:8,bottom: 2),
                                                                decoration: BoxDecoration(
                                                                  color:defaultPalette.primary,
                                                                  border: Border.all(width: 1.2, color:defaultPalette.extras[0], strokeAlign: BorderSide.strokeAlignOutside),
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  image:layoutModel.pdf==null?null: DecorationImage(image:MemoryImage(layoutModel.pdf![indx],),fit: BoxFit.fitWidth),
                                                                ),
                                                                // foregroundDecoration: BoxDecoration(
                                                                //   border: Border.all(width: 2, color:defaultPalette.extras[0]),
                                                                //   borderRadius: BorderRadius.circular(10),
                                                                // ),
                                                              ),
                                                            ),    
                                                          ],
                                                    );
                                                  },),
                                              ),
                                              SizedBox(width: 10,),
                                              //layoutname and created modified
                                              _getCreatedAndModified(layoutModel, sWidth, sHeight, !isLayoutTileView),
                                              SizedBox(width:5),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  //Make a bill out of the Layout button
                                                  Tooltip(
                                                    message: '  Create a Bill based on ${layoutModel.name} layout.  ',
                                                    textStyle: GoogleFonts.lexend(
                                                      fontSize: mapValueDimensionBased( 15, 20, sWidth,sHeight),
                                                      color: defaultPalette.primary,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: defaultPalette.extras[0].withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(50)
                                                    ),
                                                    child: ElevatedLayerButton(
                                                      onClick: () {
                                                        final box = Boxes.getLayouts();
                                                        final name = Boxes.getBillName();
                                                        var key = 'BI-${const Uuid().v4()}';
                                                        var prevLm =box.getAt(i);
                                                        // keyIndex = box.length;
                                                        var lm = LayoutModel(
                                                          createdAt: DateTime.now(),
                                                          modifiedAt: DateTime.now(),
                                                          name: name,
                                                          docPropsList: prevLm?.docPropsList??[],
                                                          spreadSheetList:prevLm?.spreadSheetList?? [],
                                                          id: key,
                                                          type: SheetType.taxInvoice.index,
                                                          labelList: prevLm?.labelList ??[],
                                                        );
                                                        
                                                        box.put(key, lm);
                                                        lm.save();
                                                        ref.read(homeScreenTabIndexProvider.notifier).update((state) => 2,);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                          builder: (c) =>  Material(
                                                                  child: PopScope(
                                                                child: LayoutDesigner(
                                                                  id: key,
                                                                  onPop: (pdf) {
                                                                  },
                                                                  
                                                                ),
                                                                canPop: false,
                                                              )
                                                            )
                                                          )
                                                        );
                                                      },
                                                      buttonHeight: 30,
                                                      buttonWidth: 30,
                                                      borderRadius: BorderRadius.circular(50)
                                                      // .copyWith(
                                                      //     topLeft: Radius.circular(80),
                                                      //     bottomRight: Radius.circular(100)
                                                      //   )
                                                        ,
                                                      animationDuration:
                                                          const Duration(milliseconds: 200),
                                                      animationCurve: Curves.ease,
                                                      topDecoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(),
                                                      ),
                                                      subfac: 3,depth: 3,
                                                      topLayerChild: Icon(
                                                        TablerIcons.receipt,
                                                        size: 15,
                                                      ),
                                                      baseDecoration: BoxDecoration(
                                                        color: defaultPalette.extras[0],
                                                        border: Border.all(),
                                                      ),
                                                    ),
                                                  ),
                                                
                                                  //Delete a Layout button
                                                  SizedBox(height:5),
                                                  ElevatedLayerButton(
                                                    onClick: () async {
                                                      print(filteredLayoutBox);
                                                      final layoutsBox = Boxes.getLayouts();
                                                      // Delete the item
                                                       print(layoutsBox);
                                                      await layoutsBox
                                                          .get(layoutsBox.keyAt(i))
                                                          ?.delete();
                                                      print('delete');
                                                      setState(() {
                                                        filteredLayoutBox = Boxes.getLayouts().values.toList();
                                                      });
                                                    },
                                                    buttonHeight: 45,
                                                    buttonWidth: 45,
                                                    borderRadius: BorderRadius.circular(10),
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
                                                    subfac: 3,depth: 3,
                                                    baseDecoration: BoxDecoration(
                                                      color: defaultPalette.extras[0],
                                                      border: Border.all(),
                                                    ),
                                                  ),
                                                  
                                                ],
                                              ),
                                              SizedBox(width:5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                    } else {
                                      return Material(
                                        color: defaultPalette.transparent,
                                        child: InkWell(
                                          hoverColor: defaultPalette.extras[0].withOpacity(0.4),
                                          highlightColor: defaultPalette.extras[0].withOpacity(0.4),
                                          splashColor: defaultPalette.extras[0].withOpacity(0.4),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) {
                                                return PopScope(
                                                  canPop: false,
                                                  child: LayoutDesigner(
                                                    id: Boxes.getLayouts().keyAt(i),
                                                    onPop: (pdf) {
                                                      
                                                    },
                                                  ),
                                                );
                                              },
                                            ));
                                          },
                                        child: Container(
                                          height: 70,
                                          width: 30,
                                          margin: EdgeInsets.only(bottom: 10,right: 8),
                                          color: defaultPalette.transparent,
                                          child: Row(
                                            children: [
                                              //layoutname
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left:12,top: 0),
                                                  child: Text(
                                                    layoutModel.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.start,
                                                    style: GoogleFonts.lexend(
                                                      fontSize: mapValueDimensionBased( 20, 30, sWidth,sHeight),
                                                      color: defaultPalette.extras[0],
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              //layoutname and created modified
                                              _getCreatedAndModified(layoutModel, sWidth, sHeight, !isLayoutTileView),
                                              SizedBox(width:5),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(height:5),
                                                  //make bill out of a Layout button
                                                  Tooltip(
                                                    message: '  Create a Bill based on ${layoutModel.name} layout.  ',
                                                    textStyle: GoogleFonts.lexend(
                                                      fontSize: mapValueDimensionBased( 15, 20, sWidth,sHeight),
                                                      color: defaultPalette.primary,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: defaultPalette.extras[0].withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(50)
                                                    ),
                                                    child: ElevatedLayerButton(
                                                      onClick: () {
                                                        final box = Boxes.getLayouts();
                                                        final name = Boxes.getBillName();
                                                        var key = 'BI-${const Uuid().v4()}';
                                                        var prevLm =box.getAt(i);
                                                        // keyIndex = box.length;
                                                        var lm = LayoutModel(
                                                          createdAt: DateTime.now(),
                                                          modifiedAt: DateTime.now(),
                                                          name: name,
                                                          docPropsList: prevLm?.docPropsList??[],
                                                          spreadSheetList:prevLm?.spreadSheetList?? [],
                                                          id: key,
                                                          type: SheetType.taxInvoice.index,
                                                          labelList: prevLm?.labelList ??[],
                                                        );
                                                        
                                                        box.put(key, lm);
                                                        lm.save();
                                                        ref.read(homeScreenTabIndexProvider.notifier).update((state) => 2,);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                          builder: (c) =>  Material(
                                                                  child: PopScope(
                                                                child: LayoutDesigner(
                                                                  id: key,
                                                                  onPop: (pdf) {
                                                                  },
                                                                  
                                                                ),
                                                                canPop: false,
                                                              )
                                                            )
                                                          )
                                                        );
                                                      },
                                                      buttonHeight: 30,
                                                      buttonWidth: 30,
                                                      borderRadius: BorderRadius.circular(100),
                                                      animationDuration:
                                                          const Duration(milliseconds: 200),
                                                      animationCurve: Curves.ease,
                                                      topDecoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(),
                                                      ),
                                                      subfac: 3,depth: 3,
                                                      topLayerChild: Icon(
                                                        TablerIcons.receipt,
                                                        size: 15,
                                                      ),
                                                      baseDecoration: BoxDecoration(
                                                        color: defaultPalette.extras[0],
                                                        border: Border.all(),
                                                      ),
                                                    ),
                                                  ),
                                                
                                                  //Delete a Layout button
                                                  SizedBox(height:5),
                                                  ElevatedLayerButton(
                                                    onClick: () async {
                                                      final layoutsBox = Boxes.getLayouts();
                                                      // Delete the item
                                                      await layoutsBox
                                                          .get(layoutsBox.keyAt(i))
                                                          ?.delete();
                                                      
                                                      setState(() {});
                                                    },
                                                    buttonHeight: 30,
                                                    buttonWidth: 30,
                                                    borderRadius: BorderRadius.circular(10),
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
                                                    subfac: 3,depth: 3,
                                                    baseDecoration: BoxDecoration(
                                                      color: defaultPalette.extras[0],
                                                      border: Border.all(),
                                                    ),
                                                  ),
                                                  
                                                ],
                                              ),
                                              SizedBox(width:5),
                                            ],
                                          ),
                                        ),
                                      ),
                                      );
                                    
                                    }
                                },
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                        
                      ),
                    ),
                  ],
                ),
                ),
                   
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
  
  Widget _getBillsAndCharts(
      BuildContext context, WidgetRef ref, double topPadPosDistance) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    int homeScreenTabIndex = ref.watch(homeScreenTabIndexProvider);
    bool isHomeTab = homeScreenTabIndex ==0;
    bool isBillTab = homeScreenTabIndex ==2;
    double dotSize = sHeight/35;
    // print(sWidth);
    return AnimatedPositioned(
      duration: Durations.short2,
      // top: (topPadPosDistance * 1.08),
      height: sHeight,
      child: AnimatedOpacity(
        opacity: isBillTab ? 1 : 0,
        duration: Duration(milliseconds: 100),
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: !isBillTab,
              child: Container(
                // duration: Durations.extra,
                height: sHeight,
                width: sWidth,
                alignment: Alignment.centerRight,
                color: isHomeTab
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.06),
                padding: EdgeInsets.only(
                  top: 0,
                ),
                //BillGraph
                child: LineChart(LineChartData(
                    lineBarsData: [LineChartBarData()],
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(
                        // getDrawingVerticalLine: (value) => FlLine(
                        //                         color: defaultPalette.tertiary,
                        //                         dashArray: [5, 5],
                        //                         strokeWidth: 1),
                        // getDrawingHorizontalLine: (value) =>
                        //     FlLine(
                        //         color: defaultPalette.tertiary,
                        //         dashArray: [5, 5,],
                        //         strokeWidth: 1),
                        show: true,
                        horizontalInterval: 7.8,
                        verticalInterval: 30),
                    borderData: FlBorderData(show: false),
                    minY: 0 ,
                    maxY:  50,
                    maxX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                            500 + 250,
                    minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() /
                        500)),
              ),
            ),
              
            //   ),
            // ),
            // //
            //
            //Bill$€₹
            AnimatedPositioned(
              duration: Durations.medium2,
              width: sWidth,
              height: (sHeight / 2.5),
              top: topPadPosDistance + sHeight / 3-(sHeight / 8).clamp(0, 85),
              right: isBillTab ? sWidth - math.min( (sHeight / 8), (sWidth/12)) - 350: (sWidth / 1.8),
              child: Text('\$€',
                textAlign: TextAlign.right,
                style: GoogleFonts.caesarDressing(
                  color: Color(0xFF000000).withOpacity(0.2),
                  fontSize: (sHeight / 2.5).clamp(0, 300),
                  letterSpacing: -5,
                  fontWeight: FontWeight.w100,
                  height: 0.6
                )
              ),
            ),
            
            // //BillsList
            AnimatedPositioned(
              duration: Durations.extralong2,
              top: isBillTab ? 60 : sHeight / 4,
              // top: isBillTab
              //     ?  topPadPosDistance + 10
              //     : sHeight,
              // left: 90,
              right: 15,
              height: (sHeight)-60-20,//60 from the top padding difference and 20 for bottom padding
              width: sWidth / 2.5,
              child: IgnorePointer(
                ignoring: !isBillTab,
                child: AnimatedOpacity(
                  duration: Durations.extralong3 * 2,
                  opacity: isBillTab ? 1 : 0,
                  curve: Curves.bounceInOut,
                  child: Container(
                    padding: EdgeInsets.all(mapValueDimensionBased( 5, 8, sWidth,sHeight)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: defaultPalette.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //my bills title search bar list page toggle
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15,),
                            Expanded(
                              child:Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Bills',
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  color: defaultPalette.extras[0],
                                  fontSize: math.min( (sHeight / 8).clamp(0, 55), (sWidth/12).clamp(0, 55)),
                                  letterSpacing: -2,
                                  fontWeight: FontWeight.w600,
                                  height: 0.9
                                )
                                ),
                              ),
                            ),
                            
                              ExpandableSearchBar(
                                onTap: () {
                                  
                                },
                                onChange: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      filteredLayoutBox = Boxes.getLayouts()
                                          .values
                                          .where((i) => i.name.toLowerCase().contains(value.toLowerCase()))
                                          .toList();
                                    } else {
                                      filteredLayoutBox = Boxes.getLayouts()
                                          .values.toList();
                                    }
                                  });
                                },
                                width:  (sWidth / 2.5)/3,
                                hintText: "search bill...",
                                editTextController: layoutSearchController,
                                focusNode: layoutSearchFocusNode,
                                boxShadow: [],
                                iconBackgroundColor: defaultPalette.primary,
                                iconColor: defaultPalette.extras[0],
                                iconSize: mapValueDimensionBased( 20, 30, sWidth,sHeight),
                                backgroundColor: defaultPalette.secondary,

                              ),
                              SizedBox(width: 3,), 
                              AnimatedToggleSwitch<bool>.dual(
                              current: isLayoutTileView,
                              first: true,
                              second: false,
                              onChanged: (value) {
                                setState(() {
                                  isLayoutTileView = value;
                                });
                              },
                              animationCurve:
                                  Curves.easeInOutExpo,
                              animationDuration:
                                  Durations.medium4,
                              borderWidth:
                                  2, // backgroundColor is set independently of the current selection
                              styleBuilder: (value) =>
                                  ToggleStyle(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  mapValueDimensionBased( 50, 999, sWidth,sHeight)),
                                      indicatorBorderRadius:
                                          BorderRadius
                                              .circular(
                                                  mapValueDimensionBased( 5, 32, sWidth,sHeight)),
                                      borderColor:
                                          defaultPalette
                                              .secondary,
                                      backgroundColor:
                                          defaultPalette
                                              .secondary,
                                      indicatorColor:
                                          defaultPalette
                                                  .extras[0]), // indicatorColor changes and animates its value with the selection
                              iconBuilder: (value) {
                                return Icon(
                                    value? TablerIcons
                                            .grip_horizontal
                                        : TablerIcons
                                            .grip_vertical,
                                    size: 12,
                                    color: defaultPalette
                                        .primary);
                              },
                              textBuilder: (value) {
                                return Text(
                                  value ? 'list'
                                      : 'page',
                                  style:
                                      GoogleFonts.bungee(
                                          fontSize: 12),
                                );
                              },
                              height:mapValueDimensionBased( 22, 32, sWidth,sHeight),
                              spacing:mapValueDimensionBased( 10, 30, sWidth,sHeight),
                            ),
                            SizedBox(width: 5,),                    
                          ],
                        ),
                  
                        //the bills tiles
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color:  defaultPalette.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.all(5),
                            child:  ScrollConfiguration(
                              behavior: ScrollBehavior().copyWith(scrollbars: false),
                              child: DynMouseScroll(
                                durationMS: 500,
                                scrollSpeed: 1,
                                builder: (context, controller, physics) {
                                  return ScrollbarUltima(
                                    alwaysShowThumb: true,
                                    controller: controller,
                                    scrollbarPosition:
                                        ScrollbarPosition.right,
                                    backgroundColor: defaultPalette.primary,
                                    isDraggable: true,
                                    maxDynamicThumbLength: 90,
                                    minDynamicThumbLength: 50,
                                    thumbBuilder:
                                        (context, animation, widgetStates) {
                                      return Container(
                                        margin: EdgeInsets.only(right: 3, top: 8,bottom: 8),
                                        decoration: BoxDecoration(
                                            color: defaultPalette.primary,
                                            border: Border.all(),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        width: isLayoutTileView? 4: 6,
                                      );
                                    },
                                  child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(right:isLayoutTileView?6:3),
                                  controller: controller,
                                  physics: physics,
                                  itemCount:layoutSearchController.text ==''?Boxes.getLayouts().values.toList().length+1: filteredLayoutBox.length+1,
                                  itemBuilder: (BuildContext context, int i) {
                                    
                                    if (i ==(layoutSearchController.text ==''?Boxes.getLayouts().values.toList().length:filteredLayoutBox.length)) {
                                      return SizedBox(height: 5,);
                                    }
                                    final layoutModel = layoutSearchController.text ==''?Boxes.getLayouts().values.toList()[i]: filteredLayoutBox[i];
                                    if (layoutModel.id.startsWith('LY-')) {
                                      return SizedBox.shrink();
                                    }
                                    if(!isLayoutTileView) {
                                      return Material(
                                        color: defaultPalette.transparent,
                                        child: InkWell(
                                          hoverColor: defaultPalette.extras[0].withOpacity(0.4),
                                          highlightColor: defaultPalette.extras[0].withOpacity(0.4),
                                          splashColor: defaultPalette.extras[0].withOpacity(0.4),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) {
                                                return PopScope(
                                                  canPop: false,
                                                  child: LayoutDesigner(
                                                    id: Boxes.getLayouts().keyAt(i),
                                                    onPop: (pdf) {
                                                      setState(() {
                                                      filteredLayoutBox = Boxes.getLayouts().values.toList();
                                                    });
                                                    },
                                                  ),
                                                );
                                              },
                                            ));
                                            filteredLayoutBox = Boxes.getLayouts()
                                          .values.toList();
                                          },
                                        child: Container(
                                          height: 110,
                                          width: 30,
                                          margin: EdgeInsets.only(bottom: 0,right: 8),
                                          color: defaultPalette.transparent,
                                          child: Row(
                                            children: [
                                              //mini layout pdf pages swiper
                                              SizedBox(
                                                height: 100,
                                                width: 80,
                                                child: AppinioSwiper(
                                                  cardCount: (layoutModel.spreadSheetList.length.isNaN ||layoutModel.docPropsList.length ==0 )?1:layoutModel.docPropsList.length,
                                                  backgroundCardCount: 5,
                                                  backgroundCardOffset: Offset(0.8, 0.8),
                                                  duration: Duration(milliseconds: 220),
                                                  backgroundCardScale: 1,
                                                  loop: true,
                                                  allowUnSwipe: true,
                                                  allowUnlimitedUnSwipe: true,
                                                  initialIndex: 0,  
                                                  cardBuilder: (context, indx) {
                                                    // print(layoutModel.pdf?.length);
                                                    return Stack(
                                                          children: [
                                                            //The main bgCOLOR OF THE CARD
                                                            Positioned.fill(
                                                              child: AnimatedContainer(
                                                                duration: Durations.short3,
                                                                alignment: Alignment.center,
                                                                margin: EdgeInsets.only(left:8,top:0,bottom: 4),
                                                                decoration: BoxDecoration(
                                                                  color:defaultPalette.primary,
                                                                  border: Border.all(width: 1.2, color:defaultPalette.extras[0]),
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  image:layoutModel.pdf==null?null: DecorationImage(image:MemoryImage(layoutModel.pdf![indx],),fit: BoxFit.fitWidth),
                                                                ),
                                                              ),
                                                            ),    
                                                          ],
                                                    );
                                                  },),
                                              ),
                                              SizedBox(width: 10,),
                                              //billname and created modified
                                              _getCreatedAndModified(layoutModel, sWidth, sHeight, !isLayoutTileView, isBill:true),
                                              
                                              SizedBox(width:5),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  //Export as pdf of the bill button
                                                  Tooltip(
                                                    message: '  Export ${layoutModel.name} as pdf.  ',
                                                    textStyle: GoogleFonts.lexend(
                                                      fontSize: mapValueDimensionBased( 15, 20, sWidth,sHeight),
                                                      color: defaultPalette.primary,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: defaultPalette.extras[0].withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(50)
                                                    ),
                                                    child: ElevatedLayerButton(
                                                      onClick: () {
                                                        Navigator.push(context, MaterialPageRoute(
                                                          builder: (context) {
                                                            return PopScope(
                                                              canPop: false,
                                                              child: LayoutDesigner(
                                                                id: Boxes.getLayouts().keyAt(i),
                                                                onPop: (pdf) {
                                                                  setState(() {
                                                                  filteredLayoutBox = Boxes.getLayouts().values.toList();
                                                                });
                                                                },
                                                                exportPdf: true,
                                                              ),
                                                            );
                                                          },
                                                        ));
                                                      },
                                                      buttonHeight: 30,
                                                      buttonWidth: 30,
                                                      borderRadius: BorderRadius.circular(50)
                                                      // .copyWith(
                                                      //     topLeft: Radius.circular(80),
                                                      //     bottomRight: Radius.circular(100)
                                                      //   )
                                                        ,
                                                      animationDuration:
                                                          const Duration(milliseconds: 200),
                                                      animationCurve: Curves.ease,
                                                      topDecoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(),
                                                      ),
                                                      subfac: 3,depth: 2,
                                                      topLayerChild: Icon(
                                                        TablerIcons.upload,
                                                        size: 15,
                                                      ),
                                                      baseDecoration: BoxDecoration(
                                                        color: defaultPalette.extras[0],
                                                        border: Border.all(),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height:5),
                                                  //Make a revised bill out of the bill button
                                                  Tooltip(
                                                    message: '  Create a revised ${(SheetType.values[layoutModel.type].name=='none'? 'document':SheetType.values[layoutModel.type].name)} of ${layoutModel.name}.  ',
                                                    textStyle: GoogleFonts.lexend(
                                                      fontSize: mapValueDimensionBased( 15, 20, sWidth,sHeight),
                                                      color: defaultPalette.primary,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: defaultPalette.extras[0].withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(50)
                                                    ),
                                                    child: ElevatedLayerButton(
                                                      onClick: () {
                                                        final box = Boxes.getLayouts();
                                                        final name = Boxes.getBillName();
                                                        var key = 'BI-${const Uuid().v4()}';
                                                        var prevLm =box.getAt(i);
                                                        // keyIndex = box.length;
                                                        var lm = LayoutModel(
                                                          createdAt: DateTime.now(),
                                                          modifiedAt: DateTime.now(),
                                                          name: '${prevLm?.name??''}-revised',
                                                          docPropsList: prevLm?.docPropsList??[],
                                                          spreadSheetList:prevLm?.spreadSheetList?? [],
                                                          id: key,
                                                          type: SheetType.taxInvoice.index,
                                                          labelList: prevLm?.labelList ??[],
                                                        );
                                                        
                                                        box.put(key, lm);
                                                        lm.save();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                          builder: (c) =>  Material(
                                                                  child: PopScope(
                                                                child: LayoutDesigner(
                                                                  id: key,
                                                                  onPop: (pdf) {
                                                                  },
                                                                  
                                                                ),
                                                                canPop: false,
                                                              )
                                                            )
                                                          )
                                                        );
                                                      },
                                                      buttonHeight: 30,
                                                      buttonWidth: 30,
                                                      borderRadius: BorderRadius.circular(50)
                                                      // .copyWith(
                                                      //     topLeft: Radius.circular(80),
                                                      //     bottomRight: Radius.circular(100)
                                                      //   )
                                                        ,
                                                      animationDuration:
                                                          const Duration(milliseconds: 200),
                                                      animationCurve: Curves.ease,
                                                      topDecoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(),
                                                      ),
                                                      subfac: 3,depth: 2,
                                                      topLayerChild: Icon(
                                                        TablerIcons.edit,
                                                        size: 15,
                                                      ),
                                                      baseDecoration: BoxDecoration(
                                                        color: defaultPalette.extras[0],
                                                        border: Border.all(),
                                                      ),
                                                    ),
                                                  ),
                                                
                                                  //Delete a Layout button
                                                  SizedBox(height:5),
                                                  ElevatedLayerButton(
                                                    onClick: () async {
                                                      print(filteredLayoutBox);
                                                      final layoutsBox = Boxes.getLayouts();
                                                      // Delete the item
                                                       print(layoutsBox);
                                                      await layoutsBox
                                                          .get(layoutsBox.keyAt(i))
                                                          ?.delete();
                                                      print('delete');
                                                      setState(() {
                                                        filteredLayoutBox = Boxes.getLayouts().values.toList();
                                                      });
                                                    },
                                                    buttonHeight: 30,
                                                    buttonWidth: 30,
                                                    borderRadius: BorderRadius.circular(10),
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
                                                    subfac: 3,depth: 3,
                                                    baseDecoration: BoxDecoration(
                                                      color: defaultPalette.extras[0],
                                                      border: Border.all(),
                                                    ),
                                                  ),
                                                   SizedBox(height:5),
                                                ],
                                              ),
                                              SizedBox(width:5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                    } else {
                                      return Material(
                                        color: defaultPalette.transparent,
                                        child: InkWell(
                                          hoverColor: defaultPalette.extras[0].withOpacity(0.4),
                                          highlightColor: defaultPalette.extras[0].withOpacity(0.4),
                                          splashColor: defaultPalette.extras[0].withOpacity(0.4),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) {
                                                return PopScope(
                                                  canPop: false,
                                                  child: LayoutDesigner(
                                                    id: Boxes.getLayouts().keyAt(i),
                                                    onPop: (pdf) {
                                                      
                                                    },
                                                  ),
                                                );
                                              },
                                            ));
                                          },
                                        child: Container(
                                          height: 54,
                                          width: 30,
                                          // margin: EdgeInsets.only(bottom: 10,right: 8),
                                          color: defaultPalette.transparent,
                                          child: Row(
                                            children: [
                                              //billname
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left:12,top: 0),
                                                  child: Text(
                                                    layoutModel.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.start,
                                                    style: GoogleFonts.lexend(
                                                      fontSize: mapValueDimensionBased( 20, 30, sWidth,sHeight),
                                                      color: defaultPalette.extras[0],
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              //billname and created modified
                                              _getCreatedAndModified(layoutModel, sWidth, sHeight, !isLayoutTileView,isBill: true),
                                              SizedBox(width:5),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  //make a revised bill out of a bill button
                                                  Tooltip(
                                                    message: '  Create a revised ${(SheetType.values[layoutModel.type].name=='none'? 'document':SheetType.values[layoutModel.type].name)} of ${layoutModel.name}.  ',
                                                    textStyle: GoogleFonts.lexend(
                                                      fontSize: mapValueDimensionBased( 15, 20, sWidth,sHeight),
                                                      color: defaultPalette.primary,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: defaultPalette.extras[0].withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(50)
                                                    ),
                                                    child: ElevatedLayerButton(
                                                      onClick: () {
                                                        final box = Boxes.getLayouts();
                                                        final name = Boxes.getBillName();
                                                        var key = 'BI-${const Uuid().v4()}';
                                                        var prevLm =box.getAt(i);
                                                        // keyIndex = box.length;
                                                        var lm = LayoutModel(
                                                          createdAt: DateTime.now(),
                                                          modifiedAt: DateTime.now(),
                                                          name: '${prevLm?.name??''}-revised',
                                                          docPropsList: prevLm?.docPropsList??[],
                                                          spreadSheetList:prevLm?.spreadSheetList?? [],
                                                          id: key,
                                                          type: SheetType.taxInvoice.index,
                                                          labelList: prevLm?.labelList ??[],
                                                        );
                                                        
                                                        box.put(key, lm);
                                                        lm.save();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                          builder: (c) =>  Material(
                                                                  child: PopScope(
                                                                child: LayoutDesigner(
                                                                  id: key,
                                                                  onPop: (pdf) {
                                                                  },
                                                                  
                                                                ),
                                                                canPop: false,
                                                              )
                                                            )
                                                          )
                                                        );
                                                      },
                                                      buttonHeight: 20,
                                                      buttonWidth: 20,
                                                      borderRadius: BorderRadius.circular(100),
                                                      animationDuration:
                                                          const Duration(milliseconds: 200),
                                                      animationCurve: Curves.ease,
                                                      topDecoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(),
                                                      ),
                                                      subfac: 1,depth: 1,
                                                      topLayerChild: Icon(
                                                        TablerIcons.edit,
                                                        size: 12,
                                                      ),
                                                      baseDecoration: BoxDecoration(
                                                        color: defaultPalette.extras[0],
                                                        border: Border.all(),
                                                      ),
                                                    ),
                                                  ),
                                                
                                                  //Delete a bill button
                                                  SizedBox(height:5),
                                                  ElevatedLayerButton(
                                                    onClick: () async {
                                                      final layoutsBox = Boxes.getLayouts();
                                                      // Delete the item
                                                      await layoutsBox
                                                          .get(layoutsBox.keyAt(i))
                                                          ?.delete();
                                                      
                                                      setState(() {});
                                                    },
                                                    buttonHeight: 20,
                                                    buttonWidth: 20,
                                                    borderRadius: BorderRadius.circular(10),
                                                    animationDuration:
                                                        const Duration(milliseconds: 200),
                                                    animationCurve: Curves.ease,
                                                    topDecoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(),
                                                    ),
                                                    topLayerChild: Icon(
                                                      TablerIcons.trash,
                                                      size: 12,
                                                    ),
                                                    subfac: 1,depth: 1,
                                                    baseDecoration: BoxDecoration(
                                                      color: defaultPalette.extras[0],
                                                      border: Border.all(),
                                                    ),
                                                  ),
                                                  
                                                ],
                                              ),
                                              SizedBox(width:5),
                                            ],
                                          ),
                                        ),
                                         ),
                                      );
                                    
                                    }
                                },
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                        
                      ),
                    ),
                        
                  ],
                ),
                ),
                   
                ),
              ),
            ),
            //  charts revenue analytical
           AnimatedPositioned(
              duration: Durations.medium2,
              // right: 15,
              left: 90,
              top: isBillTab ? 60 : sHeight / 4,
              child: ValueListenableBuilder(
              valueListenable: Hive.box<LayoutModel>('layouts').listenable(),
              builder: (context, Box<LayoutModel> box, _) {
                monthRevenueMap ={};
                dayRevenueMap = {};
                if (isDragging) {
                  dateTextControllers = [
                  TextEditingController()..text = monthNames[selectedMonth-1], 
                  TextEditingController()..text = selectedYear.toString(),
                  ];
                }
                final allLayouts = box.values.toList();

                // Collect all revised layout base names
                final revisedNames = allLayouts
                    .where((l) => l.name.endsWith('-revised'))
                    .map((l) => l.name.replaceAll('-revised', ''))
                    .toSet();

                // Now filter the layouts
                final layouts = allLayouts.where((layout) {
                  final name = layout.name;
                  if (name.endsWith('-old')) return false;
                  if (revisedNames.contains(name)) return false; // exclude if revised version exists
                  return true;
                }).toList();


                final invoiceCount = layouts.where((l) => l.type == SheetType.taxInvoice.index).length;
                final creditNoteCount = layouts.where((l) => l.type == SheetType.creditNote.index).length;

                totalRevenue = 0;

                // 👇 Month-wise totalPayable collector with 'YYYY-MM' as key

                for (final layout in layouts) {
                  try {
                    final totalPayableLabel = layout.labelList.firstWhere(
                      (lbl) => lbl.name == 'totalPayable',
                    );

                    if (totalPayableLabel != null && totalPayableLabel.indexPath.index != -951) {
                      final item = getItemAtPath(totalPayableLabel.indexPath, layout.spreadSheetList);
                      if (item is SheetTextBox) {
                        final List<Map<String, dynamic>> rawDelta = List<Map<String, dynamic>>.from(item.textEditorController);
                        final delta = Delta.fromJson(rawDelta);
                        final doc = Document.fromDelta(delta);
                        final rawText = doc.toPlainText();
                        double value = double.tryParse(rawText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

                        // If it's a credit note, negate the value
                        if (layout.type == SheetType.creditNote.index) {
                          value *= -1;
                        }
                        if (layout.type == SheetType.proformaInvoice.index) {
                          value *= 0;
                        }

                        totalRevenue += value;

                        if (layout.createdAt.year == selectedYear) {
                          final month = layout.createdAt.month.ceilToDouble(); // 1 to 12
                          monthRevenueMap.update(month, (existing) => existing + value, ifAbsent: () => value);
                        }
                        final date = layout.createdAt;
                        if (date.year == selectedYear && date.month == selectedMonth) {
                          final day = date.day.toDouble(); // 1 to 31
                          dayRevenueMap.update(day, (existing) => existing + value, ifAbsent: () => value);
                        }
                      }
                    }
                  } catch (_) {
                    // Skip this layout
                  }
                }

                // Ensure all months and days are initialized
                monthRevenueMap = Map.fromEntries(
                  List.generate(12, (i) => i + 1)
                      .map((month) => MapEntry(month.ceilToDouble(), monthRevenueMap[month.toDouble()] ?? 0)),
                );

                final daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
                dayRevenueMap = Map.fromEntries(
                  List.generate(daysInMonth, (i) => i + 1)
                      .map((day) => MapEntry(day.toDouble(), dayRevenueMap[day.toDouble()] ?? 0)),
                );

                // print(monthRevenueMap);
                return Container(
                  width: sWidth / 1.73 - 100,
                  height: sHeight / 1.8,
                  padding: EdgeInsets.all(5).copyWith(right: 10),
                  decoration: BoxDecoration(
                    color: defaultPalette.primary,
                    borderRadius: BorderRadius.circular(20)
                    ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title Revenue
                      SizedBox(
                        height: 25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 5,),
                            Icon(TablerIcons.chart_dots_3, size: mapValueDimensionBased(25, 30, sWidth, sHeight),),
                            SizedBox(width: 5,),
                            Expanded(
                              child: Text('Revenue',style: GoogleFonts.lexend(
                                fontSize: mapValueDimensionBased(20, 23, sWidth, sHeight),
                                color: defaultPalette.extras[0],
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1),),
                            ),
                            ...datePropertyTile(1),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      //yearly revenue
                      Expanded(child: 
                      LineChart(
                          LineChartData(
                          backgroundColor: defaultPalette.secondary,
                          lineTouchData: LineTouchData(
                            touchSpotThreshold: 25,
                            getTouchedSpotIndicator:
                                (LineChartBarData barData, List<int> spotIndexes) {
                                  final isMainChart = barData.barWidth == 5;
                              return spotIndexes.map((spotIndex) {
                                final spot = barData.spots[spotIndex];
                                if (!isMainChart) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(strokeWidth: 0, color: Colors.transparent),
                                    FlDotData(show: false),
                                  );
                                }
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: defaultPalette.tertiary,
                                    strokeWidth: 4,
                                  ),
                                  FlDotData(
                                    getDotPainter: (spot, percent, barData, index) {
                                      
                                      return FlDotCirclePainter(
                                        radius: 8,
                                        color: defaultPalette.primary,
                                        strokeWidth: 5,
                                        strokeColor: defaultPalette.tertiary,
                                      );
                                    },
                                  ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => defaultPalette.extras[0],
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final flSpot = barSpot;
                                 if (barSpot.x ==0 || barSpot.x ==13 || barSpot.barIndex ==1) {
                                   return null;
                                 }   
                                 
                                return LineTooltipItem(
                                  '${monthNames[(barSpot.x-1).clamp(0, 12).round()]}',
                                 GoogleFonts.lexend(
                                    color: defaultPalette.tertiary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' Revenue: \n',
                                      style:GoogleFonts.lexend(
                                        color: defaultPalette.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: NumberFormat.decimalPattern('en_IN').format(monthRevenueMap[(barSpot.x).clamp(1, 12).round()]),
                                      style:GoogleFonts.lexend(
                                        color: defaultPalette.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                     TextSpan(
                                      text: '₹ ',
                                      style:GoogleFonts.lexend(
                                        fontWeight: FontWeight.w900,
                                        color: defaultPalette.primary,
                                      ),
                                    ),
                                  ],
                                  textAlign: TextAlign.left
                                );
                              }).toList();
                            },
                          ),
                          touchCallback:
                              (FlTouchEvent event, LineTouchResponse? lineTouch) {
                            if (!event.isInterestedForInteractions ||
                                lineTouch == null ||
                                lineTouch.lineBarSpots == null) {
                              setState(() {
                                // touchedValue = -1;
                              });
                              return;
                            }
                          },
                          ),
                          lineBarsData: [
                          LineChartBarData(
                            isStepLineChart: true,
                            spots: [
                              const FlSpot(0, 0),
                              for( var entry in monthRevenueMap.entries)
                                FlSpot(entry.key, entry.value),
                              const FlSpot(13, 0),
                            ],
                            isCurved: false,
                            barWidth: 5,
                            color: defaultPalette.secondary,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(colors: [
                                defaultPalette.extras[0],defaultPalette.extras[0],
                              ],
                              stops: [0.5, 1],
                              begin: Alignment(0, -1),
                              end: Alignment(0, 1),
                              ),
                              applyCutOffY: true,
                              cutOffY: 0,
                              spotsLine: BarAreaSpotsLine(
                                show: true,
                                flLineStyle: FlLine(
                                  color: defaultPalette.extras[0],
                                  strokeWidth: 1,
                                ),
                                
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                
                                  return FlDotSquarePainter(
                                    size: 8.5,
                                    color: defaultPalette.primary,
                                    strokeWidth: 3,
                                    strokeColor: defaultPalette.extras[0],
                                  );
                                
                              },
                              checkToShowDot: (spot, barData) {
                                return( spot.y >1 && spot.x!=0);
                              },
                            ),
                          ),
                          LineChartBarData(
                            isStepLineChart: true,
                            spots: [
                              const FlSpot(0, 0),
                              for( var entry in monthRevenueMap.entries)
                               entry.value<0? FlSpot(entry.key, (entry.value)):FlSpot(entry.key, 0),
                              const FlSpot(13, 0),
                            ],
                            isCurved: false,
                            barWidth: 2,
                            color: defaultPalette.secondary,
                
                            belowBarData: BarAreaData(
                              show: true,
                              applyCutOffY: true,
                              cutOffY: 0,
                              gradient: LinearGradient(colors: [
                                defaultPalette.extras[0],defaultPalette.extras[0],
                              ],
                              stops: [0.5, 1],
                              begin: Alignment(0, 0),
                              end: Alignment(0, 3),
                              ),
                
                              spotsLine: BarAreaSpotsLine(
                                show: true,
                                flLineStyle: FlLine(
                                  color: defaultPalette.extras[0],
                                  strokeWidth: mapValueDimensionBased(25, 80, sWidth, sHeight, useWidth: true),
                                ),
                                
                              ),
                            ),
                            dotData: FlDotData(
                              show:monthRevenueMap.values.reduce(min)<-1,
                              getDotPainter: (spot, percent, barData, index) {
                                
                                  return FlDotSquarePainter(
                                    size: 8.5,
                                    color: defaultPalette.primary,
                                    strokeWidth: 3,
                                    strokeColor: defaultPalette.extras[0],
                                  );
                                
                              },
                              checkToShowDot: (spot, barData) {
                                return( spot.y.round() !=0 && spot.x!=0 && (spot.y <0));
                              },
                            ),
                          ),
                          ],
                          minY: monthRevenueMap.values.fold(0.0, (min, val) => val < (min??0) ? val : min),
                          maxY: max(monthRevenueMap.values.isNotEmpty ? monthRevenueMap.values.reduce(max): 0, 1),
                          borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(
                              color: defaultPalette.secondary,
                            width: 0),
                            right: BorderSide(
                              color: defaultPalette.secondary,
                            width: 0),
                            bottom: BorderSide(
                              color: defaultPalette.secondary,
                            width: 5),
                            top: BorderSide(
                              color: defaultPalette.secondary,
                            width: 12),
                            
                          ),
                          ),
                          gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: false,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            if (value == 0) {
                              return  FlLine(
                                color: defaultPalette.tertiary,
                                strokeWidth: 2,
                              );
                            } else {
                              return  FlLine(
                                color: defaultPalette.tertiary,
                                strokeWidth: 0.5,
                              );
                            }
                          },
                          getDrawingVerticalLine: (value) {
                            if (value == 0) {
                              return const FlLine(
                                color: Colors.redAccent,
                                strokeWidth: 10,
                              );
                            } else {
                              return  FlLine(
                                color: defaultPalette.tertiary,
                                strokeWidth: 0.5,
                              );
                            }
                          },
                          ),
                          titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: mapValueDimensionBased(25, 38, sWidth, sHeight),
                              interval: getSmartInterval( max(monthRevenueMap.values.isNotEmpty ? monthRevenueMap.values.reduce(max): 0, 1),),
                              getTitlesWidget:(value, meta) {
                                if (meta.min == value || meta.max == value||value == 0) {
                                  return const SizedBox.shrink(); // Hide first and last labels
                                }
                                return Text(meta.formattedValue.toLowerCase()+'\₹',
                                  style: GoogleFonts.lexend(
                                    fontSize:mapValueDimensionBased(10, 15, sWidth, sHeight),
                                    letterSpacing: -1,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              // reservedSize: 40,
                              interval: 1,
                              getTitlesWidget:(value, meta) {
                                if (value ==0 || value ==13) {
                                  return SizedBox.shrink();
                                }
                                return Text(monthNames[(value-1).clamp(0, double.infinity).round()],
                                  style: GoogleFonts.lexend(
                                    fontSize:mapValueDimensionBased(10, 15, sWidth, sHeight),
                                    letterSpacing: -1,
                                  ),
                                );
                              },
                            ),
                          ),
                          ),
                        ),
                      )
                      
                      ),
                      //the month display and editor
                      SizedBox(
                        height: 25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...datePropertyTile(0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      //day revenue
                      Expanded(child: 
                      LineChart(
                          LineChartData(
                          backgroundColor: defaultPalette.secondary,
                          lineTouchData: LineTouchData(
                            touchSpotThreshold: 25,
                            getTouchedSpotIndicator:
                                (LineChartBarData barData, List<int> spotIndexes) {
                                  
                                final isMainChart = barData.barWidth == 5;
 

                              return spotIndexes.map((spotIndex) {
                                final spot = barData.spots[spotIndex];
                                if (!isMainChart) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(strokeWidth: 0, color: Colors.transparent),
                                    FlDotData(show: false),
                                  );
                                }

                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: defaultPalette.tertiary,
                                    strokeWidth: 4,
                                  ),
                                  FlDotData(
                                    getDotPainter: (spot, percent, barData, index) {
                                      
                                      return FlDotCirclePainter(
                                        radius: 8,
                                        color: defaultPalette.primary,
                                        strokeWidth: 5,
                                        strokeColor: defaultPalette.tertiary,
                                      );
                                    },
                                  ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            maxContentWidth: 220,
                            getTooltipColor: (touchedSpot) => defaultPalette.tertiary,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final flSpot = barSpot;

                                 if (barSpot.x ==0 || barSpot.x ==32 ||  DateTime(selectedYear, selectedMonth, barSpot.x.toInt()).month != selectedMonth || barSpot.barIndex ==1) {
                                   return null;
                                 }   
                                
                                    
                                return LineTooltipItem(
                                  '${DateFormat.MMMMEEEEd().format(DateTime(selectedYear, selectedMonth, barSpot.x.toInt()))}${getOrdinal(barSpot.x.toInt())}\n',
                                 GoogleFonts.lexend(
                                    color: defaultPalette.extras[0],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Revenue: \n',
                                      style:GoogleFonts.lexend(
                                        color: defaultPalette.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    TextSpan(
                                      text: NumberFormat.decimalPattern('en_IN').format(dayRevenueMap[(barSpot.x).clamp(1, 31).round()]),
                                      style:GoogleFonts.lexend(
                                        color: defaultPalette.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                     TextSpan(
                                      text: '₹ ',
                                      style:GoogleFonts.lexend(
                                        fontWeight: FontWeight.w900,
                                        color: defaultPalette.primary,
                                      ),
                                    ),
                                  ],
                                  textAlign: TextAlign.left
                                );
                              }).toList();
                            },
                          ),
                          touchCallback:
                              (FlTouchEvent event, LineTouchResponse? lineTouch) {
                            if (!event.isInterestedForInteractions ||
                                lineTouch == null ||
                                lineTouch.lineBarSpots == null) {
                              setState(() {
                                // touchedValue = -1;
                              });
                              return;
                            }
                          },
                          ),
                          extraLinesData: ExtraLinesData(
                          ),
                          lineBarsData: [
                          LineChartBarData(
                            isStepLineChart: true,
                            spots: [
                              const FlSpot(0, 0),
                              for( var entry in dayRevenueMap.entries)
                                FlSpot(entry.key, (entry.value)),
                              const FlSpot(32, 0),
                            ],
                            isCurved: false,
                            barWidth: 5,
                            color: defaultPalette.secondary,
                
                            belowBarData: BarAreaData(
                              show: true,
                              applyCutOffY: true,
                              cutOffY: 0,
                              gradient: LinearGradient(colors: [
                                defaultPalette.extras[0],defaultPalette.extras[0],
                              ],
                              stops: [0.5, 1],
                              begin: Alignment(0, -5),
                              end: Alignment(0, 1),
                              ),
                
                              spotsLine: BarAreaSpotsLine(
                                show: true,
                                flLineStyle: FlLine(
                                  color: defaultPalette.extras[0],
                                  strokeWidth: 1,
                                ),
                                
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                
                                  return FlDotSquarePainter(
                                    size: 8.5,
                                    color: defaultPalette.primary,
                                    strokeWidth: 3,
                                    strokeColor: defaultPalette.extras[0],
                                  );
                                
                              },
                              checkToShowDot: (spot, barData) {
                                return( spot.y >1 && spot.x!=0);
                              },
                            ),
                          ),
                          
                          LineChartBarData(
                            isStepLineChart: true,
                            spots: [
                              const FlSpot(0, 0),
                              for( var entry in dayRevenueMap.entries)
                               entry.value<0? FlSpot(entry.key, (entry.value)):FlSpot(entry.key, 0),
                              const FlSpot(32, 0),
                            ],
                            isCurved: false,
                            barWidth: 2,
                            color: defaultPalette.secondary,
                
                            belowBarData: BarAreaData(
                              show: true,
                              applyCutOffY: true,
                              cutOffY: 0,
                              gradient: LinearGradient(colors: [
                                defaultPalette.extras[0],defaultPalette.extras[0],
                              ],
                              stops: [0.5, 1],
                              begin: Alignment(0, 0),
                              end: Alignment(0, 3),
                              ),
                
                              spotsLine: BarAreaSpotsLine(
                                show: true,
                                flLineStyle: FlLine(
                                  color: defaultPalette.extras[0],
                                  strokeWidth: mapValueDimensionBased(6, 30, sWidth, sHeight, useWidth: true),
                                ),
                                
                              ),
                            ),
                            dotData: FlDotData(
                              show:dayRevenueMap.values.fold(0.0, (min, val) => val < (min ?? 0)? val : min)<0,
                              getDotPainter: (spot, percent, barData, index) {
                                
                                  return FlDotSquarePainter(
                                    size: 8.5,
                                    color: defaultPalette.primary,
                                    strokeWidth: 3,
                                    strokeColor: defaultPalette.extras[0],
                                  );
                                
                              },
                              checkToShowDot: (spot, barData) {
                                return( spot.y.round() !=0 && spot.x!=0);
                              },
                            ),
                          ),
                          
                          ],
                          
                          minY: dayRevenueMap.values.fold(0.0, (min, val) => val < (min ?? 0)? val : min),
                          maxY: max(dayRevenueMap.values.isNotEmpty ? dayRevenueMap.values.reduce(max): 0, 1),
                          borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(
                              color: defaultPalette.secondary,
                            width: 0),
                            right: BorderSide(
                              color: defaultPalette.secondary,
                            width: 0),
                            bottom: BorderSide(
                              color: defaultPalette.secondary,
                            width: dayRevenueMap.values.reduce(min)<0?12:5),
                            top: BorderSide(
                              color: defaultPalette.secondary,
                            width: 12),
                            
                          ),
                          ),
                          gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: false,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            if (value == 0) {
                              return  FlLine(
                                color: defaultPalette.tertiary,
                                strokeWidth: 2,
                              );
                            } else {
                              return  FlLine(
                                color: defaultPalette.tertiary,
                                strokeWidth: 0.5,
                              );
                            }
                          },
                          getDrawingVerticalLine: (value) {
                            if (value == 0) {
                              return const FlLine(
                                color: Colors.redAccent,
                                strokeWidth: 10,
                              );
                            } else {
                              return  FlLine(
                                color: defaultPalette.tertiary,
                                strokeWidth: 0.5,
                              );
                            }
                          },
                          ),
                          titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: mapValueDimensionBased(25, 38, sWidth, sHeight),
                              interval: getSmartInterval(max(dayRevenueMap.values.isNotEmpty ? dayRevenueMap.values.reduce(max): 0, 1),minValue:dayRevenueMap.values.reduce(min) ),
                              getTitlesWidget:(value, meta) {
                                if (meta.min == value || (!isCleanRoundedNumber(meta.max) && meta.max == value ||value == 0)) {
                                  return const SizedBox.shrink();
                                }
                                return Text(meta.formattedValue.toLowerCase()+'\₹',
                                  style: GoogleFonts.lexend(
                                    fontSize:mapValueDimensionBased(10, 15, sWidth, sHeight),
                                    letterSpacing: -1,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              // reservedSize: 40,
                              interval: 1,
                              getTitlesWidget:(value, meta) {
                                if (value ==0 || value ==32) {
                                  return SizedBox.shrink();
                                }
                                return Text((value).clamp(0, double.infinity).round().toString(),
                                  style: GoogleFonts.lexend(
                                    fontSize:mapValueDimensionBased(10, 15, sWidth, sHeight),
                                    letterSpacing: -1,
                                  ),
                                );
                              },
                            ),
                          ),
                          ),
                        ),
                      )
                      
                      )
                    ],
                  ),
                                  
                );
                }
              ),
            ),
            //  summary analytical
           AnimatedPositioned(
              duration: Durations.medium2,
              // right: 15,
              left: 90,
              top: isBillTab ? 70 + sHeight / 1.8: sHeight / 4,
              child: ValueListenableBuilder(
              valueListenable: Hive.box<LayoutModel>('layouts').listenable(),
              builder: (context, Box<LayoutModel> box, _) {
                final allLayouts = box.values.toList();

                // Collect all revised layout base names
                final revisedNames = allLayouts
                    .where((l) => l.name.endsWith('-revised'))
                    .map((l) => l.name.replaceAll('-revised', ''))
                    .toSet();

                // Now filter the layouts
                final layouts = allLayouts.where((layout) {
                  final name = layout.name;
                  if (name.endsWith('-old')) return false;
                  if (revisedNames.contains(name)) return false; // exclude if revised version exists
                  return true;
                }).toList();
                typeStats ={};
                for (final layout in layouts) {
                  final type = SheetType.values[layout.type];
                  double totalPayable = 0;

                  try {
                    final label = layout.labelList.firstWhere((l) => l.name == 'totalPayable');
                    if (label.indexPath.index != -951) {
                      final item = getItemAtPath(label.indexPath, layout.spreadSheetList);
                      if (item is SheetTextBox) {
                        final delta = Delta.fromJson(List<Map<String, dynamic>>.from(item.textEditorController));
                        final doc = Document.fromDelta(delta);
                        final rawText = doc.toPlainText();
                        totalPayable = double.tryParse(rawText.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;

                        if (type == SheetType.creditNote) {
                          totalPayable = -totalPayable;
                        }
                      }
                    }
                  } catch (_) {
                    // silently skip errors
                  }

                  typeStats[type] = {
                    'count': (typeStats[type]?['count'] ?? 0) + 1,
                    'payable': (typeStats[type]?['payable'] ?? 0.0) + totalPayable,
                  };
                }


                return Container(
                  width: (sWidth / 1.73 - 100) / 2,
                  height: sHeight - (sHeight / 1.8) -90,// 90 is 70+10+10, 70 for the top bar, 10 for the bottom padding, and 10 for the padding in between the chart above
                  padding: EdgeInsets.all(5).copyWith(right: 8, bottom: 8,left: mapValueDimensionBased(8, 10, sWidth, sHeight)),
                  decoration: BoxDecoration(
                    color: defaultPalette.primary,
                    borderRadius: BorderRadius.circular(20)
                    ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title Revenue
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 5,),
                          Icon(TablerIcons.chart_arcs, size: mapValueDimensionBased(16, 30, sWidth, sHeight),),
                          SizedBox(width: 5,),
                          Expanded(
                            child: Text('Summary',style: GoogleFonts.lexend(
                              fontSize: mapValueDimensionBased(15, 25, sWidth, sHeight),
                              color: defaultPalette.extras[0],
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1),),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Expanded(
                        child: ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(scrollbars: false),
                        child: DynMouseScroll(
                          durationMS: 500,
                          scrollSpeed: 1,
                          builder: (context, controller, physics) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SingleChildScrollView(
                                controller: controller,
                                physics: physics,
                                // padding: EdgeInsets.only(
                                //   right: 10,
                                // ),
                                child: Column(
                                  children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 2,),
                                      ...[Icon(TablerIcons.moneybag, size: mapValueDimensionBased(15, 30, sWidth, sHeight),),
                                      SizedBox(width: 5,),],
                                      Expanded(
                                        child: Text('Total Revenue',
                                        style: GoogleFonts.lexend(
                                          fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                                          color: defaultPalette.extras[0],
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -1),),
                                      ),
                                      Expanded(
                                      child: Text(NumberFormat.decimalPattern('en_IN').format(totalRevenue),
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.lexend(
                                        fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                                        color: defaultPalette.extras[0],
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -1),),
                                        
                                    ),
                                    SizedBox(width:6,),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 2,),
                                      ...[Icon(TablerIcons.file_stack, size: mapValueDimensionBased(15, 30, sWidth, sHeight),),
                                      SizedBox(width: 5,),],
                                      Expanded(
                                        child: Text('Total Bills',
                                        style: GoogleFonts.lexend(
                                          fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                                          color: defaultPalette.extras[0],
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -1),),
                                      ),
                                      Expanded(
                                      child: Text(layouts.where((l) => SheetType.values[l.type] != SheetType.none).length.toString(),
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.lexend(
                                        fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                                        color: defaultPalette.extras[0],
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -1),),
                                        
                                    ),
                                      SizedBox(width: 6,),
                                    ],
                                    ),
                                    SizedBox(height: 10,),
                                    summaryTile('Tax Invoices',
                                      typeStats[SheetType.taxInvoice]!,
                                      TablerIcons.file_invoice,
                                      sWidth,
                                      sHeight,
                                    ), 
                                    summaryTile('Credit Notes',
                                      typeStats[SheetType.creditNote]!,
                                      TablerIcons.credit_card_pay,
                                      sWidth,
                                      sHeight,
                                    ),
                                    summaryTile('Debit Notes',
                                      typeStats[SheetType.debitNote]!,
                                      TablerIcons.credit_card_refund,
                                      sWidth,
                                      sHeight,
                                    ),
                                    summaryTile('Bills of Supply',
                                      typeStats[SheetType.billOfSupply]!,
                                      TablerIcons.receipt_2,
                                      sWidth,
                                      sHeight,
                                    ),
                                    summaryTile('Proforma Invoices',
                                      typeStats[SheetType.proformaInvoice]!,
                                      TablerIcons.receipt_filled,
                                      sWidth,
                                      sHeight,
                                    ),
                                    
                                    SizedBox(height: 5,),
                              
                                  ],
                                ),
                              ),
                            );
                            }
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                                  
                );
                }
              ),
            ),
            //  charts quantity analytical
           AnimatedPositioned(
              duration: Durations.medium2,
              // right: 15,
              left: 90 +(sWidth / 1.73 - 100)/2 + 10,
              top: isBillTab ? 70 + sHeight / 1.8: sHeight / 4,
              child: ValueListenableBuilder(
              valueListenable: Hive.box<LayoutModel>('layouts').listenable(),
              builder: (context, Box<LayoutModel> box, _) {
                final allLayouts = box.values.toList();

                // Collect all revised layout base names
                final revisedNames = allLayouts
                    .where((l) => l.name.endsWith('-revised'))
                    .map((l) => l.name.replaceAll('-revised', ''))
                    .toSet();

                // Now filter the layouts
                final layouts = allLayouts.where((layout) {
                  final name = layout.name;
                  if (name.endsWith('-old')) return false;
                  if (revisedNames.contains(name)) return false; // exclude if revised version exists
                  return true;
                }).toList();


                final Map<SheetType, int> yearlyCounts = {
                  SheetType.taxInvoice: 0,
                  SheetType.creditNote: 0,
                  SheetType.debitNote: 0,
                  SheetType.billOfSupply: 0,
                };

                Map<SheetType, int> monthlyCounts = {
                  SheetType.taxInvoice: 0,
                  SheetType.creditNote: 0,
                  SheetType.debitNote: 0,
                  SheetType.billOfSupply: 0,
                  SheetType.proformaInvoice: 0,
                };

                for (final layout in layouts) {
                  final type = SheetType.values[layout.type];

                  if (layout.createdAt.year == selectedYear) {
                    yearlyCounts[type] = (yearlyCounts[type] ?? 0) + 1;
                    
                    if (layout.createdAt.month == selectedMonth) {
                      monthlyCounts[type] = (monthlyCounts[type]?? 0) + 1;
                    }
                  }
                }
                // Sort the monthlyCounts by index
                monthlyCounts = Map.fromEntries(
                  monthlyCounts.entries.toList()
                    ..sort((a, b) => a.key.index.compareTo(b.key.index))
                );

                return Container(
                  width: (sWidth / 1.73 - 100) / 2 -10, // -10 because of the gap between the two charts
                  height: sHeight - (sHeight / 1.8) -90,// 90 is 70+10+10, 70 for the top bar, 10 for the bottom padding, and 10 for the padding in between the chart above
                  padding: EdgeInsets.all(5).copyWith(right: 5),
                  decoration: BoxDecoration(
                    color: defaultPalette.primary,
                    borderRadius: BorderRadius.circular(20)
                    ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 5,),
                          Icon(TablerIcons.tallymarks, size: mapValueDimensionBased(15, 30, sWidth, sHeight),),
                          SizedBox(width: 5,),
                          Expanded(
                            child: Text('Quantity',style: GoogleFonts.lexend(
                              fontSize: mapValueDimensionBased(14, 23, sWidth, sHeight),
                              color: defaultPalette.extras[0],
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1),),
                          ),
                          Expanded(child: Text(
                            '$selectedMonth/${selectedYear.toString().substring(2, 4)}',
                            textAlign: TextAlign.end,
                            style: GoogleFonts.lexend(
                              fontSize: mapValueDimensionBased(10, 15, sWidth, sHeight),
                              color: defaultPalette.extras[0],
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                          SizedBox(width: 5,),
                          // ...datePropertyTile(2),
                        ],
                      ),
                      //type revenue
                      Expanded(child: 
                      Row(
                        children: [
                          Expanded(
                            flex: 20,
                            child: Padding(
                            padding: const EdgeInsets.only(top: 6.0, bottom: 5, left: 5),
                            child: LineChart(
                            LineChartData(
                            backgroundColor: defaultPalette.secondary,
                            lineTouchData: LineTouchData(
                              touchSpotThreshold: 25,
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData, List<int> spotIndexes) {
                                return spotIndexes.map((spotIndex) {
                                  final spot = barData.spots[spotIndex];
                                  
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: defaultPalette.tertiary,
                                      strokeWidth: 4,
                                    ),
                                    FlDotData(
                                      getDotPainter: (spot, percent, barData, index) {
                                        
                                        return FlDotCirclePainter(
                                          radius: 8,
                                          color: defaultPalette.primary,
                                          strokeWidth: 5,
                                          strokeColor: defaultPalette.tertiary,
                                        );
                                      },
                                    ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              maxContentWidth: mapValueDimensionBased(120, 200, sWidth, sHeight),
                              getTooltipColor: (touchedSpot) => defaultPalette.tertiary,
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final flSpot = barSpot;
                                   if (barSpot.x ==0 || barSpot.x ==monthlyCounts.length+1 ) {
                                     return null;
                                   }   
                                  
                                      
                                  return LineTooltipItem(
                                    '${DateFormat.yMMMM().format(DateTime(selectedYear, selectedMonth))}\n',
                                   GoogleFonts.lexend(
                                      color: defaultPalette.extras[0],
                                      fontWeight: FontWeight.bold,
                                      fontSize:  mapValueDimensionBased(15, 20, sWidth, sHeight),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${monthlyCounts.keys.toList()[(barSpot.x-1).clamp(0, monthlyCounts.length).round()].name}: \n',
                                        style:GoogleFonts.lexend(
                                          color: defaultPalette.primary,
                                          fontSize:  mapValueDimensionBased(10, 20, sWidth, sHeight),
                                        ),
                                      ),
                                      TextSpan(
                                        text: NumberFormat.decimalPattern('en_IN').format(monthlyCounts.values.toList()[(barSpot.x-1).clamp(0, monthlyCounts.length).round()]),
                                        style:GoogleFonts.lexend(
                                          color: defaultPalette.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize:  mapValueDimensionBased(10, 20, sWidth, sHeight),
                                        ),
                                      ),
                                       
                                    ],
                                    textAlign: TextAlign.left
                                  );
                                }).toList();
                              },
                            ),
                            touchCallback:
                                (FlTouchEvent event, LineTouchResponse? lineTouch) {
                              if (!event.isInterestedForInteractions ||
                                  lineTouch == null ||
                                  lineTouch.lineBarSpots == null) {
                                setState(() {
                                  // touchedValue = -1;
                                });
                                return;
                              }
                            },
                            ),
                            extraLinesData: ExtraLinesData(
                            ),
                            lineBarsData: [
                            LineChartBarData(
                              isStepLineChart: true,
                              spots: [
                                const FlSpot(0, 0),
                                for (final entry in monthlyCounts.entries.toList()
                                    ..sort((a, b) => a.key.index.compareTo(b.key.index)))
                                  FlSpot(entry.key.index.toDouble(), entry.value.toDouble()),
                                FlSpot(monthlyCounts.length+1, 0),
                              ],
                              isCurved: false,
                              barWidth: 2,
                              color: defaultPalette.extras[0],
                                            
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(colors: [
                                  defaultPalette.secondary,defaultPalette.secondary,
                                ],
                                stops: [0.5, 1],
                                begin: Alignment(0, -1),
                                end: Alignment(0, 1),
                                ),
                                            
                                spotsLine: BarAreaSpotsLine(
                                  show: false,
                                  flLineStyle: FlLine(
                                    color: defaultPalette.extras[0],
                                    strokeWidth: 1,
                                  ),
                                  
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  
                                    return FlDotCirclePainter(
                                      radius: 4.5,
                                      color: defaultPalette.primary,
                                      strokeWidth: 2,
                                      strokeColor: defaultPalette.extras[0],
                                    );
                                  
                                },
                                checkToShowDot: (spot, barData) {
                                  return( spot.x!=0 && spot.x!=monthlyCounts.length+1 );
                                },
                              ),
                            ),
                            ],
                            minY: 0,
                            maxY: max(monthlyCounts.values.isNotEmpty ? monthlyCounts.values.reduce(max).toDouble(): 0, 1),
                            borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: BorderSide(
                                color: defaultPalette.secondary,
                              width: 0),
                              right: BorderSide(
                                color: defaultPalette.secondary,
                              width: 0),
                              bottom: BorderSide(
                                color: defaultPalette.secondary,
                              width: 5),
                              top: BorderSide(
                                color: defaultPalette.secondary,
                              width: 12),
                              
                            ),
                            ),
                            gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: false,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              if (value == 0) {
                                return  FlLine(
                                  color: defaultPalette.tertiary,
                                  strokeWidth: 2,
                                );
                              } else {
                                return  FlLine(
                                  color: defaultPalette.tertiary,
                                  strokeWidth: 0.5,
                                );
                              }
                            },
                            getDrawingVerticalLine: (value) {
                              if (value == 0) {
                                return const FlLine(
                                  color: Colors.redAccent,
                                  strokeWidth: 10,
                                );
                              } else {
                                return  FlLine(
                                  color: defaultPalette.tertiary,
                                  strokeWidth: 0.5,
                                );
                              }
                            },
                            ),
                            titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: mapValueDimensionBased(12, 38, sWidth, sHeight),
                                interval: getSmartInterval( max(monthlyCounts.values.isNotEmpty ? monthlyCounts.values.reduce(max).toDouble(): 0, 1),),
                                getTitlesWidget:(value, meta) {
                                  if (meta.min == value || meta.max == value) {
                                    return const SizedBox.shrink(); // Hide first and last labels
                                  }
                                  return Text(value.toString()+'  ',
                                    style: GoogleFonts.lexend(
                                      fontSize:mapValueDimensionBased(8, 15, sWidth, sHeight),
                                      letterSpacing: -1,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                                // reservedSize: 40,
                                interval: 1,
                                getTitlesWidget:(value, meta) {
                                  if (value ==0 || value ==monthlyCounts.length+1) {
                                    return SizedBox.shrink();
                                  }
                                  return Text(monthlyCounts.keys.toList()[(value-1).clamp(0, double.infinity).round()].name,
                                    style: GoogleFonts.lexend(
                                      fontSize:mapValueDimensionBased(10, 15, sWidth, sHeight),
                                      letterSpacing: -1,
                                    ),
                                  );
                                },
                              ),
                            ),
                            ),
                            ),
                          ),
                          )),
                          Expanded(
                            flex: 30,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                      // print('Touched index: $touchedIndex');
                                    });
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 1,
                                centerSpaceRadius: mapValueDimensionBasedLockOnDesync(10, 50, sWidth, sHeight,),
                                sections: showingSections(
                                  billCounts: yearlyCounts,
                                  touchedIndex: touchedIndex,
                                  sWidth: sWidth,
                                  sHeight: sHeight,
                                  ),
                              ),
                              swapAnimationDuration: Durations.short3,
                            ),
                          )
                        ],
                      ),
            
                      ),
                      
                    ],
                  ),
                                  
                );
                }
              ),
            ),
          
          ],
        ),
      ),
    );
  }

  Widget _getCreatedAndModified(LayoutModel layoutModel, double sWidth, double sHeight, bool isNotLayoutTileView, {bool isBill=false}){
    double fontSize =isBill? 10 : 12;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //layoutname
          if(isNotLayoutTileView)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left:8.0,top: 15),
              child: Text(
                layoutModel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: GoogleFonts.lexend(
                  fontSize: mapValueDimensionBased(isBill?18: 30, isBill?20:40, sWidth,sHeight),
                  color: defaultPalette.extras[0],
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          //created modified and pages
          Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  // color:  defaultPalette.primary,
                  borderRadius: BorderRadius.circular(12),
                  // border: Border.all()
                ),
                padding: EdgeInsets.all(isBill? isNotLayoutTileView?3:0:0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height:isBill?8: 15,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, 
                      child: RichText(
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: GoogleFonts.lexend(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.2,
                          ),
                          children: [
                            TextSpan(
                              text: 'Created: ',
                              style: GoogleFonts.lexend(color: defaultPalette.extras[0]),
                            ),
                            TextSpan(
                              text: DateFormat("EEE MMM d, y 'at' h:mm a").format(layoutModel.createdAt),
                              style: TextStyle(color: defaultPalette.extras[0]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: RichText(
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: GoogleFonts.lexend(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.2,
                          ),
                          children: [
                            TextSpan(
                              text: 'Modified: ',
                              style: GoogleFonts.lexend(color: defaultPalette.extras[0],fontWeight: FontWeight.w400,),
                            ),
                            TextSpan(
                              text: DateFormat("EEE MMM d, y 'at' h:mm a").format(layoutModel.modifiedAt),
                              style: TextStyle(color: defaultPalette.extras[0]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RichText(
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: GoogleFonts.lexend(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.2,
                          ),
                          children: [
                            TextSpan(
                              text: '${SheetType.values[layoutModel.type].name} · ',
                              style: GoogleFonts.lexend(
                                fontSize: fontSize,
                                color: defaultPalette.extras[0],
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            TextSpan(
                              text: 'Pages: ${layoutModel.spreadSheetList.isEmpty?'1':layoutModel.spreadSheetList.length.toString()}',
                              style: GoogleFonts.lexend(
                                fontSize: fontSize,
                                color: defaultPalette.extras[0],
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.2,
                              ),
                            ),
                            
                          ],
                        ),
                      ),   
                    SizedBox(height:isBill?7: 10,),    
                  ],
                ),
              ),
            ),
          ],
        ),
                                              
        ],
      ),
    );
                                              
  }
  
  List<Widget> datePropertyTile(int s) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
  return [
    SizedBox(
      width: 2,
    ),
          
    SizedBox(
      height: 15,
      child: IntrinsicWidth(
        child: TextFormField(
          onTapOutside: (event) => dateFocusNodes[s].unfocus(),
          focusNode: dateFocusNodes[s],
          controller: dateTextControllers[s],
          cursorColor: defaultPalette.tertiary,
          selectionControls: NoMenuTextSelectionControls(),
          enabled: s==1,
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0),
            labelStyle: GoogleFonts.lexend(color: defaultPalette.black),
            fillColor: defaultPalette.transparent,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
          style: GoogleFonts.mitr(
              fontSize: mapValueDimensionBased(18, 20, sWidth, sHeight),
              color: defaultPalette.extras[0],
              fontWeight: FontWeight.w400,
              letterSpacing: -1),
          onFieldSubmitted: (value) {
            setState(() {
              print(value);
              var newValue = (double.tryParse(value) ?? 0).clamp(
                  s==0
                  ? 1
                  : 1900
                  , s==0
                  ? 12
                  : DateTime.now().year.ceilToDouble()
                  ).round();
            print(newValue);
           switch (s) {
              case 0:
                selectedMonth =newValue;
                dateTextControllers = [
                  TextEditingController()..text = monthNames[selectedMonth-1], TextEditingController()..text = selectedYear.toString()
                ];
                break;
              case 1:
                selectedYear = newValue;
                dateTextControllers = [
          TextEditingController()..text = monthNames[selectedMonth-1], TextEditingController()..text = selectedYear.toString()
        ];
                break;
              
              default:
            }
              
            
            });
          },
        ),
      ),
    ),
    MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  print(selectedYear);
                  setState(() {
                  switch (s) {
                    case 0:
                      selectedMonth =(selectedMonth-1).clamp(
                        s==0
                        ? 1
                        : 1900
                        , s==0
                        ? 12
                        : DateTime.now().year.ceilToDouble()
                        ).round();
                      dateTextControllers = [
                        TextEditingController()..text = monthNames[selectedMonth-1], TextEditingController()..text = selectedYear.toString()
                      ];
                      break;
                    case 1:
                      selectedYear = (selectedYear-1).clamp(
                        s==0
                        ? 1
                        : 1900
                        , s==0
                        ? 12
                        : DateTime.now().year.ceilToDouble()
                        ).round();
                      dateTextControllers = [
                        TextEditingController()..text = monthNames[selectedMonth-1], TextEditingController()..text = selectedYear.toString()
                      ];
                      break;
                    
                    default:
                  }
                  print(selectedYear);
                });
                },
                child: Icon(TablerIcons.chevron_left, size: mapValueDimensionBased(15, 20, sWidth,sHeight),)
              ),
            ),
    
    MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  print(selectedYear);
                  setState(() {
                  switch (s) {
                    case 0:
                      selectedMonth =(selectedMonth+1).clamp(
                        s==0
                        ? 1
                        : 1900
                        , s==0
                        ? 12
                        : DateTime.now().year.ceilToDouble()
                        ).round();
                      dateTextControllers = [
                        TextEditingController()..text = monthNames[selectedMonth-1], TextEditingController()..text = selectedYear.toString()
                      ];
                      break;
                    case 1:
                      selectedYear = (selectedYear+1).clamp(
                        s==0
                        ? 1
                        : 1900
                        , s==0
                        ? 12
                        : DateTime.now().year.ceilToDouble()
                        ).round();
                      dateTextControllers = [
                        TextEditingController()..text = monthNames[selectedMonth-1], TextEditingController()..text = selectedYear.toString()
                      ];
                      break;
                    
                    default:
                  }
                  print(selectedYear);
                });
                },
                child: Icon(TablerIcons.chevron_right, size: mapValueDimensionBased(15, 20, sWidth,sHeight),)
              ),
            ),
    
    
  ];
  }

  String getOrdinal(int number) {
  if (number >= 11 && number <= 13) return 'th';
  switch (number % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}
  double getSmartInterval( double maxValue, {double minValue =0}) {
    final cleanSteps = [ 
      0.5, 1, 2, 5, 10, 20, 25, 50,
      100, 200, 250, 500,
      1000, 2000, 2500, 5000,
      10000, 20000, 25000, 50000,
      100000, 200000, 500000,
      1000000, 2000000,
    ];

    final range = (maxValue - minValue).abs();
    final safeRange = math.max(range, 1);

    for (final step in cleanSteps) {
      final count = (safeRange / step).ceil();
      if (count <= 4) return step.toDouble();
    }

    // If nothing fits, return a coarse default
    return (safeRange / 4).ceilToDouble();
  }
  bool isCleanRoundedNumber(num value) {
  if (value == 0) return false;
  String str = value.toInt().toString();
  return str.substring(1).split('').every((c) => c == '0');
}

  List<PieChartSectionData> showingSections({
  required Map<SheetType, int> billCounts,
  required int touchedIndex,
  double sWidth = 800,
  double sHeight = 600,
}) {
  final totalBills = billCounts.values.fold(0, (sum, count) => sum + count);
  if (totalBills == 0) return [];

  final visibleEntries = billCounts.entries
      .where((entry) => entry.value > 0)
      .toList();

  return List.generate(visibleEntries.length, (i) {
    final entry = visibleEntries[i];
    final type = entry.key;
    final count = entry.value;
    final isTouched = i == touchedIndex;
    final fontSize = isTouched ? mapValueDimensionBasedLockOnDesync(25, 40, sWidth, sHeight) : mapValueDimensionBasedLockOnDesync(13, 30, sWidth, sHeight);
    final radius = isTouched ? mapValueDimensionBasedLockOnDesync(40, 180, sWidth, sHeight) : mapValueDimensionBasedLockOnDesync(25, 90, sWidth, sHeight);
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    String badgeLabel = type.name.replaceFirstMapped(RegExp(r'[A-Z]'), (m) => '\n${m[0]}');// e.g. 'billOfSupply' -> 'bill\nof\nsupply'

    return PieChartSectionData(
      color: defaultPalette.extras[0], // You can assign different colors by type too
      value: count.toDouble() / totalBills * 100,
      title: count.toString(),
      radius: radius,
      titleStyle: GoogleFonts.lexend(
        fontSize: fontSize*mapValueDimensionBasedLockOnDesync(isTouched?0.5:0.8, isTouched?0.7:1, sWidth, sHeight),
        fontWeight: FontWeight.bold,
        color: defaultPalette.primary,
        shadows: shadows,
      ),
      badgeWidget: Container(
        decoration: BoxDecoration(
          color: defaultPalette.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: defaultPalette.extras[0], width: 0.2),
          boxShadow: [
            BoxShadow(
              color: defaultPalette.extras[0].withOpacity(0.5),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(3),
        child: Text(
          badgeLabel,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: fontSize *mapValueDimensionBasedLockOnDesync(0.4, 0.5, sWidth, sHeight),
            color: defaultPalette.extras[0],
          ),
        ),
      ),
      badgePositionPercentageOffset: mapValueDimensionBasedLockOnDesync(isTouched?1.2:1.2, isTouched?0.8: 1, sWidth, sHeight,),
      titlePositionPercentageOffset: 0.3,
    );
  });
}

  Widget summaryTile (String s, Map<String, double> stats, IconData icon, double sWidth, double sHeight, {textAlign = TextAlign.start}) {
    return Container(
      padding: EdgeInsets.all(mapValueDimensionBased(5, 10, sWidth, sHeight)),
      margin: EdgeInsets.only(bottom: mapValueDimensionBased(5, 10, sWidth, sHeight), right:2),
      decoration: BoxDecoration(
        color: defaultPalette.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: defaultPalette.extras[0], width: 0.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...[Icon(icon, size: mapValueDimensionBased(15, 30, sWidth, sHeight),),
              SizedBox(width: 5,),],
              Expanded(
                child: Text(s,
                textAlign: textAlign,
                style: GoogleFonts.lexend(
                  fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                  color: defaultPalette.extras[0],
                  fontWeight: FontWeight.w500,
                  letterSpacing: -1),),
              ),
             
            ],
          ),
          Row(
            children: [
              Expanded(
              child: Text('count  ',
              textAlign: textAlign,
              style: GoogleFonts.lexend(
                fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                color: defaultPalette.extras[0],
                fontWeight: FontWeight.w500,
                letterSpacing: -1),),
              ),
              Expanded(
              child: Text(NumberFormat.decimalPattern('en_IN').format(stats['count']),
              maxLines: 1,
              textAlign: TextAlign.end,
              style: GoogleFonts.lexend(
                fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                color: defaultPalette.extras[0],
                fontWeight: FontWeight.w500,
                letterSpacing: -1),),
                  
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
              child: Text('revenue  ',
              textAlign: textAlign,
              style: GoogleFonts.lexend(
                fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                color: defaultPalette.extras[0],
                fontWeight: FontWeight.w500,
                letterSpacing: -1),),
              ),
              Expanded(
              child: Text(NumberFormat.decimalPattern('en_IN').format(stats['payable']) + '₹',
              maxLines: 1,
              textAlign: TextAlign.end,
              style: GoogleFonts.lexend(
                fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                color: defaultPalette.extras[0],
                fontWeight: FontWeight.w500,
                letterSpacing: -1),),
                  
              ),
            ],
          )
        ],
      ),
    );
  }

}

  
  double mapValue({
    required double value,
    required double inMin,
    required double inMax,
    required double outMin,
    required double outMax,
  }) {
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin);
  }
  
  double mapValueDimensionBased(double outMin, double outMax, double w, double h,{bool b = true, bool useWidth= false}){
    return mapValue(
    value:b
    ? useWidth
      ? w
      : h*w
    :h, 
    inMin:b
    ? useWidth
      ? 800
      : 500*800
    :500, 
    inMax:b
    ? useWidth
      ? 2194
      :1187*2194
    :1187, 
    outMin: outMin, outMax: outMax);
  }

  double mapValueDimensionBasedLockOnDesync(
  double outMin,
  double outMax,
  double sWidth,
  double sHeight, {
  double baseWidth = 800,
  double baseHeight = 500,
  double maxWidth = 2194,
  double maxHeight = 1187,
}) {
  // Calculate individual progress
  final widthProgress = ((sWidth - baseWidth) / (maxWidth - baseWidth)).clamp(0.0, 1.0);
  final heightProgress = ((sHeight - baseHeight) / (maxHeight - baseHeight)).clamp(0.0, 1.0);

  final widthChanged = sWidth != baseWidth;
  final heightChanged = sHeight != baseHeight;

  final bothIncreased = sWidth > baseWidth && sHeight > baseHeight;
  final bothDecreased = sWidth < baseWidth && sHeight < baseHeight;

  if (bothIncreased || bothDecreased) {
    // Sync: interpolate based on the smaller of the two progress values
    final syncProgress = math.min(widthProgress, heightProgress);
    return outMin + (outMax - outMin) * syncProgress;
  }

  // Desync: freeze at the value where sync broke (based on last common progress)
  final frozenProgress = math.min(widthProgress, heightProgress);
  return outMin + (outMax - outMin) * frozenProgress;
}


