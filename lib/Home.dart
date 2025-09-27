import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:math' as math;
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:billblaze/components/balloon_slider/widget.dart';
import 'package:billblaze/components/widgets/graph_window.dart';
import 'package:billblaze/components/widgets/search_bar.dart';
import 'package:billblaze/main.dart';
import 'package:billblaze/models/bill/bill_type.dart';
import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_functions.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:billblaze/providers/url_provider.dart';
import 'package:billblaze/repo/google_cloud_storage_repository.dart';
// import 'package:billblaze/repo/llama_repository.dart';
import 'package:billblaze/components/widgets/username.dart';
import 'package:billblaze/util/currency_conversion.dart';
import 'package:billblaze/util/numeric_input_formatter.dart';
import 'package:billblaze/util/static_noise.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart' as cm;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svgl/flutter_svgl.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/majesticons.dart';
import 'package:intl/intl.dart';
import 'package:billblaze/colors.dart';
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
// import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:loading_indicator/loading_indicator.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:scrollbar_ultima/scrollbar_ultima.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

final cCardIndexProvider = StateProvider<int>((ref) {
  return 0;
});
final revIndexProvider = StateProvider<int>((ref) {
  return 0;
});
final qtyIndexProvider = StateProvider<int>((ref) {
  return 0;
});
final profitsIndexProvider = StateProvider<int>((ref) {
  return 0;
});
final unpaidIndexProvider = StateProvider<int>((ref) {
  return 0;
});
final homeScreenTabIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final processMessageProvider = StateProvider<String>((ref) {
  return 'Initializing...';
});

final aiTokenProvider = StateProvider<String>((ref) {
  return 'Yeah, There\'s AI too...';
});
final aiPromptProvider = StateProvider<String>((ref) {
  return '';
});
// final folderPathProvider = StateProvider<String?>((ref) {
//   final box = Boxes.getFolderPaths();
//   return box.get(ref.read(authPr).currentUser?.uid??'default');
// });
final currencyCodeProvider = StateProvider<Currency>((ref) {
  return CurrencyService().findByCode('INR')!;
});
final fxRatesStreamProvider = StreamProvider<Map<String, double>>((ref) async* {
  while (true) {
    final response = await http.get(
      Uri.parse('https://api.frankfurter.app/latest?from=USD'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('YOOOO::'+data['rates'].toString());
      yield Map<String, double>.from(data['rates']);
    }
    await Future.delayed(Duration(seconds: 10)); // refresh every hour
  }
});

final fxRatesProvider = StateProvider<Map<String, double>>((ref) {
  return {};
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
  late Animation<int> _graphLineSpeedTween;
  List<int> _graphSpeed = [60, 80];
  double appinioMinTabChanged = 0;
  double appinioMaxTabChanged = 10;
  bool even = true;
  DateTime dateTimeNow = DateTime.now();
  bool isLayoutTileView = false;
  bool isTemplateView = false;
  int showUnpaid = 0;
  bool isLlmProcessing = false;
  TextEditingController layoutSearchController = TextEditingController();
  FocusNode layoutSearchFocusNode = FocusNode();
  late List<LayoutModel> filteredLayoutBox;
  double _cardPosition = 0;
  double _revCardPosition = 0;
  double _qtyCardPosition = 0;
  double _profitsCardPosition = 0;
  double _unpaidCardPosition = 0; 
  double totalRevenue = 0;
  double totalUnpaidRevenue = 0;
  double totalProfit = 0;
  int totalBills =0;
  int totalUnpaid = 0;
  late AppinioSwiperController recentsCardController;
  late AppinioSwiperController revCardController;
  late AppinioSwiperController unpaidCardController;
  late AppinioSwiperController qtyCardController;
  late AppinioSwiperController profitsCardController;
  late AnimationController squiggleFadeAnimationController;
  late AnimationController sliderFadeAnimationController;
  late AnimationController sliderController;
  late AnimationController titleFontFadeController;
  TextEditingController chatTextController = TextEditingController();
  TextEditingController folderPathController = TextEditingController();
  PieMenuController opsFormatPieController = PieMenuController();
  FocusNode chatFocusNode = FocusNode();
  FocusNode folderPathFocusNode = FocusNode();
  FocusNode keyboardFocusNode = FocusNode();
  Orientation? _lastOrientation;
  Map<double, double> monthRevenueMap = {};
  Map<double, double> dayRevenueMap = {};
  String result = 'Loading AI';
  InAppWebViewController? _controller;
  InAppWebViewController? _controller2;
  List<FocusNode> fontFocusNodes = List.generate( 4, (index) => FocusNode(),);
  Key titleMainKey = GlobalKey();
  var monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  Map<SheetType, Map<String, double>> typeStats = {};
  int touchedIndex = -1;
  bool isDragging = false;
  List<TextEditingController> dateTextControllers = [];
  List<FocusNode> dateFocusNodes = List.generate(
    2,
    (index) => FocusNode(),
  );
  OverlayEntry? sheetTypeBrowserEntry;
  OverlayEntry? infoOverlayEntry;
  TextEditingController textFieldSearchController = TextEditingController();
  LayoutModel tempLayoutModel = LayoutModel(
    name: 'New Layout',
    id: Uuid().v4(),
    type: SheetType.taxInvoice.index,
    docPropsList: [
      DocumentPropertiesBox(
        pageNumberController: '0', 
        marginAllController: '0',
        marginLeftController: '0', 
        marginRightController: '0', 
        marginBottomController: '0', 
        marginTopController: '0',
        orientationController: true, 
        pageFormatController: const {},)
    ], spreadSheetList: [], 
    createdAt: DateTime.now(), 
    modifiedAt: DateTime.now(),
  );
  double pageUnit = 1;
  int layoutPageCount = 1;
  List<TextEditingController> pageFormatControllers = [];
  double _globalMinY = double.infinity;
  double _globalMaxY = double.negativeInfinity;
  var _currencyFormatter = DynamicCurrencyFormatter(
    locale: 'hi_IN',
    currencyCode: 'INR',
  );
  bool isLoading = true;
  late Directory dir;
  late final Stream<List<LayoutModel>> _stream;
  StreamSubscription<List<LayoutModel>>? _subscription;
  late ProviderSubscription sub;


  @override
  void initState() {
    super.initState();
    isLoading = true;
    tempLayoutModel = LayoutModel(
      name: 'New Layout',
      id: Uuid().v4(),
      type: SheetType.taxInvoice.index,
      docPropsList: [
        DocumentPropertiesBox(
          pageNumberController: '0', 
          marginAllController: '0',
          marginLeftController: '0', 
          marginRightController: '0', 
          marginBottomController: '0', 
          marginTopController: '0',
          orientationController: true, 
          pageFormatController: getMapFromPageFormat(PdfPageFormat.a4),)
      ], spreadSheetList: [], 
      createdAt: DateTime.now(), 
      modifiedAt: DateTime.now(),
  );
    
    _currencyFormatter =DynamicCurrencyFormatter(
      locale: 'hi_IN',
      currencyCode:  ref.read(currencyCodeProvider).code,
    ); 
  
    pageFormatControllers = [
      TextEditingController()
        ..text = (getPageFormatFromMap(tempLayoutModel.docPropsList[0].pageFormatController).width * pageUnit)
            .toStringAsFixed(2),
      TextEditingController()
        ..text = (getPageFormatFromMap(tempLayoutModel.docPropsList[0].pageFormatController).height * pageUnit)
            .toStringAsFixed(2),
      TextEditingController()
        ..text = (layoutPageCount)
            .toString(),
    ];
    recentsCardController = AppinioSwiperController();
    revCardController = AppinioSwiperController();
    qtyCardController = AppinioSwiperController();
    profitsCardController = AppinioSwiperController();
    unpaidCardController = AppinioSwiperController();
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
    if (ref.read(homeScreenTabIndexProvider) == 1) {
      _homeTabSwitched(1, ref);
      squiggleFadeAnimationController.forward();
      sliderFadeAnimationController.forward();
    }
    // titleFontFadeController.forward();
    dateTextControllers = [
      TextEditingController()..text = monthNames[selectedMonth - 1],
      TextEditingController()..text = selectedYear.toString()
    ];
    
   
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      try {
        await Hive.openBox<LayoutModel>(ref.read(authPr).currentUser?.uid??'layouts');
        filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
        _updateGraphLineSpeed(100);
        // await syncLayoutsWithAssets();
      } on Exception catch (_) {
        print('Boxes: ${Hive.boxExists( ref.read(authPr).currentUser?.uid??'layouts')}');
      }finally{
      
      ref.read(fxRatesProvider.notifier).state = await fetchFxRates();
      setState(() {
        isLoading = false;
      });}
    },);
    
  }

  @override
  void dispose() {
    _timer?.cancel();
    squiggleFadeAnimationController.dispose();
    sliderFadeAnimationController.dispose();
    sliderController.dispose();
    recentsCardController.dispose();
    revCardController.dispose();
    qtyCardController.dispose();
    profitsCardController.dispose();
    titleFontFadeController.dispose();
    // recentsCardController.dispose();
    // ref.read(llamaProvider).dispose();
    // LlamaRepository.dispose();
    _subscription?.cancel();
    sub.close();
    // _controller?.dispose();
    chatFocusNode.dispose();
    keyboardFocusNode.dispose();
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
      if (ref.read(homeScreenTabIndexProvider) == 1) {
        _homeTabSwitched(1, ref);
        Future.delayed(Durations.short3).then((u) {
          _homeTabSwitched(1, ref);
        });
      }
    }
    if (ref.read(homeScreenTabIndexProvider) == 1) {
      _homeTabSwitched(1, ref);
    }
  }
  

  int _curDay = 0;    // 0..30
  int _curMonth = 0;  // 0..11
  int kDayCycle = 31;
  int kMonthCycle = 12;

  void _startDataUpdate() {
  _timer = Timer.periodic(
    Duration(milliseconds: _graphLineSpeedTween.value)*3,
    (_) {
      if(ref.read(homeScreenTabIndexProvider) ==0) {
        setState(() {
        _xValue += 1;

        // monthly line
        final mVal = monthRevenueMap[_curMonth] ?? 0;
        _dataPoints[0].add(FlSpot(_xValue, mVal));
        if (_dataPoints[0].length > kDayCycle) {
          _dataPoints[0].removeAt(0);
        }

        // daily line
        final dVal = dayRevenueMap[_curDay] ?? 0;
        _dataPoints[1].add(FlSpot(_xValue, dVal));
        if (_dataPoints[1].length > kDayCycle) {
          _dataPoints[1].removeAt(0);
        }

        _curDay = (_curDay + 1) % kDayCycle;
        _curMonth = (_curMonth + 1) % 12;

        // ✅ RECOMPUTE GLOBAL MAX/MIN BASED ON CURRENT DATA
        final allValues = [
          ..._dataPoints[0].map((e) => e.y),
          ..._dataPoints[1].map((e) => e.y),
        ];

        if (allValues.isNotEmpty) {
          _globalMaxY = allValues.reduce((a, b) => a > b ? a : b);
          _globalMinY = allValues.reduce((a, b) => a < b ? a : b);
        } else {
          _globalMaxY = 0;
          _globalMinY = 0;
        }

        // recompute helper lines with new max/min
        final double ampMin = _globalMaxY.abs() / 12;
        final double ampMax = _globalMaxY / 9;

        final y2Value = (_globalMaxY / 1.2) + sin(_xValue * 0.7) * ampMin;
        _dataPoints[2].add(FlSpot(_xValue - 18, y2Value));
        if (_dataPoints[2].length > 12) _dataPoints[2].removeAt(0);

        final y3Value = (_globalMaxY / 1.2) + ((_xValue % 4) - 5) / 5 * ampMax;
        _dataPoints[3].add(FlSpot(_xValue + 5, y3Value));
        if (_dataPoints[3].length > 12) _dataPoints[3].removeAt(0);

        final y4Value = (_globalMaxY / 1.2) + sin(_xValue * 0.6) * ampMax;
        _dataPoints[4].add(FlSpot(_xValue - 18, y4Value));
        if (_dataPoints[4].length > 12) _dataPoints[4].removeAt(0);

        final y5Value = (_globalMaxY / 1.2) + ((_xValue % 4) - 5) / 5 * ampMax;
        _dataPoints[5].add(FlSpot(_xValue + 3, y5Value));
        if (_dataPoints[5].length > 12) _dataPoints[5].removeAt(0);

        final y6Value = (_globalMaxY / 1.2) + cos(_xValue * 1.2) * (ampMax / 2);
        _dataPoints[6].add(FlSpot(_xValue - 19, y6Value));
        if (_dataPoints[6].length > 12) _dataPoints[6].removeAt(0);
      });

      }
      // _getCurrentTime();
    },
  
  );

}
  
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
  TypewriterAnimatedText typewriterText(bool isHomeTab, double sWidth, double sHeight, String text, [double fontSize =0]){
    if(fontSize==0){ fontSize = mapValueDimensionBasedLockOnDesync( 12, 30, sWidth, sHeight);}
    return TypewriterAnimatedText(text,
      textStyle: TextStyle(                                
        fontFamily: 'Lexend',
        fontSize: (isHomeTab) ? mapValueDimensionBasedLockOnDesync( 12, 30, sWidth, sHeight) : fontSize,
        color: defaultPalette.extras[0].withOpacity(0.4),
        height: 1.7),
      speed: Duration(milliseconds: 100));
  }
  
  void _homeTabSwitched(int index, WidgetRef ref) {
    bool left = index != 0;
    // ref.read(isLayoutTabProvider.notifier).state = index == 1;
    if (left && ((recentsCardController.cardIndex??10) <= 9)) {
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
      if (ref.read(homeScreenTabIndexProvider) != 0) {
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
        // recentsCardController.unswipe().then((n) {
        //   recentsCardController.unswipe().then((n) {
        //     recentsCardController.setCardIndex(0);
        //     ref
        //         .read(cCardIndexProvider.notifier)
        //         .update((s) => s = recentsCardController.cardIndex!);
        //     _cardPosition = 0;
        //   });
        // });
        // recentsCardController.setCardIndex(0);
        // setState(() {
        //   ref
        //       .read(cCardIndexProvider.notifier)
        //       .update((s) => s = recentsCardController.cardIndex!);
        //   _cardPosition = 0;
        // });
      }
    }
    // print('e ${recentsCardController.cardIndex}');
  }

  void tabSwitchOnTap(int index, WidgetRef ref){
    // setState(() {
    //               _updateGraphLineSpeed(
    //                   (300).round());
    //             });
    _homeTabSwitched(index, ref);
    sheetTypeBrowserEntry?.remove();
    sheetTypeBrowserEntry = null;
  }
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

  
  void openYouTubeChannel() async {
    html.window.open("https://www.youtube.com/@billblazex", "_blank");
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;
    Duration defaultDuration = Duration(milliseconds: 300);
    double topPadPosDistance = sHeight / 25;
    double titleFontSize = sHeight / 10;
    int homeScreenTabIndex = ref.watch(homeScreenTabIndexProvider);
    bool isHomeTab = homeScreenTabIndex == 0;
    bool isLayoutTab = homeScreenTabIndex == 1;
    bool isBillTab = homeScreenTabIndex == 2;
    // bool isProfileTab = homeScreenTabIndex == 3;
    final User? user = ref.watch(authPr).currentUser;
    ref.listen<Currency>(currencyCodeProvider, (previous, next) {
      setState(() {
        _currencyFormatter = DynamicCurrencyFormatter(
          locale: 'hi_IN', // you can also change this based on next if needed
          currencyCode: next.code,
        );
      });
    });
    

    // RefHolder.ref = ref;

    // print(mapValue(value: sHeight, inMin: 480, inMax: 1186, outMin: 0.18, outMax: 0.1));
    // print(sHeight);
    if(isLoading){
      return Scaffold(
          backgroundColor: defaultPalette.tertiary,
          body: SizedBox(
            width: sWidth,
            height: sHeight,
            child: Stack(
              children: [
                
                Positioned.fill(child: GestureDetector(
                  onTap: ()async{
                  // await Hive.deleteBoxFromDisk('decorations');
                  // await Hive.deleteBoxFromDisk('layouts');
                  // await Hive.openBox<SheetDecoration>('decorations');
                  // await Hive.openBox<LayoutModel>(globalContainer.read(authPr).currentUser?.email??'layouts');
                  // setState(() {
                  //   isLoading = false;
                  // });
                },
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/logos/billblazeLogoSplashTM.svg',
                      // allowDrawingOutsideViewBox: true,
                      // theme: SvgTheme(currentColor: defaultPalette.primary),
                      // width: sWidth/2,
                      height: sHeight/2,
                    )
                  ),
                )),
                if (!kIsWeb && Platform.isWindows)
                ...windowsTopBar(),   
              ]
            ),
          ),);
    }
    
    return Scaffold(
        // resizeToAvoidBottomInset: true,
        backgroundColor: defaultPalette.extras[0],
        body: 
        // StreamBuilder<List<LayoutModel>>(
        //   stream: _stream,
        //   builder:(context, snapshot)
        //   {return
           Stack(
            children: [

              SizedBox(
                  height: sHeight,
                  width: sWidth,
                  child: SafeArea(
                    child: Stack(
                      children: [
                        IgnorePointer(
                          ignoring: homeScreenTabIndex != 0,
                          child: Container(
                            width: sWidth,
                            height: sHeight,
                            color: defaultPalette.primary,
                          ),
                        ),
                        _getProfile(context, ref, topPadPosDistance, titleFontSize),
                        _getBillsAndCharts(context, ref, topPadPosDistance),
                        _getLayoutAndTemplates(context, ref, topPadPosDistance),
                        AnimatedContainer(
                          duration: defaultDuration,
                          // color: isHomeTab?defaultPalette.white: defaultPalette.secondary,
                          height: 35,
                        ),
                        if(!isHomeTab)
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: (isHomeTab) ? topPadPosDistance : 10,
                          left: (isHomeTab) ? 110 : 60,
                          child: SvgPicture.asset(
                            'assets/logos/Asset12.svg',
                            width: 35,
                            height: 25,
                          ),
                        ),
                        //
                        //BILLBLAZE MAIN TITLE
                        if(isHomeTab)
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: (isHomeTab) ? topPadPosDistance : 12,
                          left: (isHomeTab) ? 110 : 130,
                          child: AnimatedTextKit(
                            key: ValueKey(
                                (isHomeTab) ? sHeight * sWidth : (isHomeTab)),
                            animatedTexts: [
                              if(!isHomeTab)
                              TypewriterAnimatedText("Bill\nBlaze.".toUpperCase(),
                                  textStyle: TextStyle(                                fontFamily: 'PressStart2P',
                                      fontSize:
                                          (isHomeTab) ? titleFontSize/1.5 : 12,
                                      color: (isHomeTab)
                                          ? Colors.black
                                          : Color(0xFF000000).withOpacity(0.8),
                                      letterSpacing:(isHomeTab) ? -2:-1,
                                      height: (isHomeTab) ? 1.2:1.3),
                                  speed: Duration(milliseconds: 100)),
                              TypewriterAnimatedText("Bill\nBlaze.",
                                  textStyle: TextStyle(                                fontFamily: 'AbrilFatface',
                                      fontSize:
                                          (isHomeTab) ? titleFontSize : 20,
                                      color: defaultPalette.extras[0],
                                      height: 0.9),
                                  speed: Duration(milliseconds: 100)),
                              TypewriterAnimatedText("Bill\nBlaze.",
                                  textStyle: GoogleFonts.zcoolKuaiLe(
                                      fontSize:
                                          (isHomeTab) ? titleFontSize : 20,
                                      color: (isHomeTab)
                                          ? Colors.black
                                          : Color(0xFF000000).withOpacity(0.8),
                                      height: 0.9),
                                  speed: Duration(milliseconds: 100)),
                              TypewriterAnimatedText("Bill\nBlaze.",
                                  textStyle: GoogleFonts.moiraiOne(
                                      fontSize:
                                          (isHomeTab) ? titleFontSize : 20,
                                      color: (isHomeTab)
                                          ? Colors.black
                                          : Color(0xFF000000).withOpacity(0.8),
                                      height: 1),
                                  speed: Duration(milliseconds: 100)),
                              TypewriterAnimatedText("Bill\nBlaze.",
                                  textStyle: TextStyle(  
                                    fontFamily: 'Silkscreen',
                                      fontSize:
                                          (isHomeTab) ? titleFontSize*0.9 : 20,
                                      color: (isHomeTab)
                                          ? Colors.black
                                          : Color(0xFF000000).withOpacity(0.8),
                                      height: 0.9),
                                  speed: Duration(milliseconds: 100)),
                              TypewriterAnimatedText("Bill\nBlaze",
                                  textStyle:
                                      GoogleFonts.libreBarcode39ExtendedText(
                                          fontSize:
                                              (isHomeTab)
                                                  ? titleFontSize / 1.1
                                                  : 20,
                                          letterSpacing: (isHomeTab)
                                              ? -titleFontSize / 4
                                              : 0,
                                          height: 1),
                                  speed: Duration(milliseconds: 100)),
                              TypewriterAnimatedText("Bill\nBlaze.",
                                  textStyle: TextStyle(                                fontFamily: 'RedactedScript',
                                      fontSize:
                                          (isHomeTab) ? titleFontSize : 20,
                                      color: (isHomeTab)
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
                            pause: const Duration(milliseconds: 20000),
                            displayFullTextOnTap: true,
                            stopPauseOnTap: true,
                          ),
                        ),
                        //greetings and tips 
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: topPadPosDistance +  mapValueDimensionBased(115, 275, sWidth, sHeight, b:false),
                          // bottom: mapValueDimensionBasedLockOnDesync(18, 28, sWidth, sHeight)
                          // //height pf graph
                          // +sHeight / 4
                          // //height of balloon slider
                          // + mapValueDimensionBasedLockOnDesync(15, 30, sWidth, sHeight)
                          // //padding of statcards
                          // + mapValueDimensionBasedLockOnDesync(15, 30, sWidth, sHeight)
                          // //height of stat cards
                          // + mapValueDimensionBasedLockOnDesync(100, 180, sWidth, sHeight)
                          // //some padding
                          // + mapValueDimensionBasedLockOnDesync(15, 30, sWidth, sHeight),
                          left: mapValueDimensionBasedLockOnDesync(60, 75, sWidth, sHeight),
                          width: mapValueDimensionBased(453, 1325, sWidth, sHeight,useWidth: true),
                          child: IgnorePointer(
                            ignoring: !isHomeTab,
                            child: AnimatedOpacity(
                              opacity: isHomeTab ? 1 : 0,
                              duration: Durations.medium1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedLayerButton(
                                    onClick: () async {
                                      
                                    },
                                    buttonHeight: mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight),
                                    buttonWidth: mapValueDimensionBased(450, 1325, sWidth, sHeight,useWidth: true)-mapValueDimensionBasedLockOnDesync(55, 105, sWidth, sHeight),
                                    borderRadius: BorderRadius.circular(
                                      mapValueDimensionBasedLockOnDesync( 13, 20, sWidth, sHeight)),
                                    animationDuration:
                                      const Duration(milliseconds: 200),
                                    animationCurve: Curves.ease,
                                    subfac: mapValueDimensionBasedLockOnDesync( 3, 4, sWidth, sHeight),
                                    depth: mapValueDimensionBasedLockOnDesync( 3, 4, sWidth, sHeight),
                                    topDecoration: BoxDecoration(
                                    color: defaultPalette.primary,
                                    border: Border.all(),
                                    ),
                                    topLayerChild:Row(
                                      children: [
                                        Icon(TablerIcons.cursor_text,
                                        size: mapValueDimensionBasedLockOnDesync( 20, 35, sWidth, sHeight),
                                        ),
                                        Expanded(
                                          child: Container(
                                          alignment: Alignment(-1, 0),
                                          padding: EdgeInsets.all(4).copyWith(left:10),
                                          margin: EdgeInsets.symmetric(vertical:mapValueDimensionBasedLockOnDesync( 4,6, sWidth, sHeight)),
                                          decoration: BoxDecoration(
                                            color: defaultPalette.secondary,
                                            border: Border.all(width: 0.5),
                                            borderRadius: BorderRadius.circular(
                                            mapValueDimensionBasedLockOnDesync( 8, 20, sWidth, sHeight)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: AnimatedTextKit(
                                                  key: ValueKey(
                                                      (isHomeTab) ? sHeight * sWidth : (isHomeTab)),
                                                  animatedTexts: [
                                                    typewriterText(isHomeTab, sWidth, sHeight, 'Create Layouts.'),
                                                    typewriterText(isHomeTab, sWidth, sHeight, "From Layouts, Create Bills."),
                                                    typewriterText(isHomeTab, sWidth, sHeight, "Select A Bill Type."),
                                                    typewriterText(isHomeTab, sWidth, sHeight, "Assign Labels To Fields."),
                                                    typewriterText(isHomeTab, sWidth, sHeight, "Calculate Revenue, Profit, Taxes, etc."),
                                                    typewriterText(isHomeTab, sWidth, sHeight, "Decorate & Style Your Text, Lists and Tables."),
                                                    typewriterText(isHomeTab, sWidth, sHeight, "Track Your Revenue and Profits."),
                                                    
                                                  ],
                                                  // totalRepeatCount: 1,
                                                  repeatForever: true,
                                                  pause: const Duration(milliseconds: 1000),
                                                  displayFullTextOnTap: true,
                                                  stopPauseOnTap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ),
                                        SizedBox(width:mapValueDimensionBasedLockOnDesync( 5, 20, sWidth, sHeight)),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Text('Hola, Traveller!',
                                          textAlign: TextAlign.end,
                                          maxLines:1,
                                          overflow:TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            color: defaultPalette.extras[0],
                                            fontSize: mapValueDimensionBasedLockOnDesync(14, 35, sWidth, sHeight),
                                            letterSpacing: -1,
                                            fontWeight: FontWeight.w400,
                                            height: 0.5
                                          ),),
                                        ),
                                        SizedBox(width:mapValueDimensionBasedLockOnDesync( 5, 20, sWidth, sHeight)),
                                    ],
                                    ),
                                                                                    
                                    baseDecoration: BoxDecoration(
                                    color: defaultPalette.extras[0],
                                    // border: Border.all(),
                                      ),
                                    ),
                                ),
                                SizedBox(width:mapValueDimensionBasedLockOnDesync( 5, 20, sWidth, sHeight)),
                                ElevatedLayerButton(
                                    onClick: () async {
                                      openYouTubeChannel();
                                    },
                                    buttonHeight: mapValueDimensionBasedLockOnDesync(45, 80, sWidth, sHeight),
                                    buttonWidth: mapValueDimensionBasedLockOnDesync(45, 80, sWidth, sHeight),
                                    borderRadius: BorderRadius.circular(
                                      mapValueDimensionBasedLockOnDesync( 30, 80, sWidth, sHeight)),
                                    animationDuration:
                                      const Duration(milliseconds: 200),
                                    animationCurve: Curves.ease,
                                    subfac: mapValueDimensionBasedLockOnDesync( 3, 4, sWidth, sHeight),
                                    depth: mapValueDimensionBasedLockOnDesync( 3, 4, sWidth, sHeight),
                                    topDecoration: BoxDecoration(
                                    color: defaultPalette.primary,
                                    border: Border.all(),
                                    ),
                                    topLayerChild:Row(
                                      children: [
                                        Expanded(
                                          child: Icon(TablerIcons.player_play_filled,
                                          size: mapValueDimensionBasedLockOnDesync( 25, 35, sWidth, sHeight),
                                          ),
                                        ),],
                                    ),
                                    baseDecoration: BoxDecoration(
                                    color: defaultPalette.extras[0],
                                    // border: Border.all(),
                                      ),
                                    ),
                              ],
                            ),
                        ))),
                        
                        //
                        //Graph windowBGBLACKK &WHITE&SECONDARRY
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: topPadPosDistance 
                          +  mapValueDimensionBased(115, 275, sWidth, sHeight, b:false)
                          //height of greetings
                          +  mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight)
                          //some padding
                          + mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight) +5,
                          // bottom: mapValueDimensionBasedLockOnDesync(18, 28, sWidth, sHeight),
                          left: mapValueDimensionBasedLockOnDesync(65, 80, sWidth, sHeight)+5,
                          height: sHeight / 4+ mapValueDimensionBasedLockOnDesync(15, 30, sWidth, sHeight)+mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight),
                          width: mapValueDimensionBased(453, 1315, sWidth, sHeight,useWidth: true),
                          child:IgnorePointer(
                            ignoring: !isHomeTab,
                            child: AnimatedOpacity(
                              opacity: isHomeTab ? 1 : 0,
                              duration: Durations.medium2,
                              child: Container(decoration: BoxDecoration(
                                color:defaultPalette.extras[0],
                                borderRadius: BorderRadius.circular(30)
                                ),),
                            ),
                          ),
                          ),
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: topPadPosDistance 
                          +  mapValueDimensionBased(115, 275, sWidth, sHeight, b:false)
                          //height of greetings
                          +  mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight)
                          //some padding
                          + mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),
                          // bottom: mapValueDimensionBasedLockOnDesync(18+5, 28+5, sWidth, sHeight),
                          left: mapValueDimensionBasedLockOnDesync(65, 80, sWidth, sHeight),
                          height: sHeight / 4+ mapValueDimensionBasedLockOnDesync(15, 30, sWidth, sHeight)+mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight),
                          width: mapValueDimensionBased(453, 1315, sWidth, sHeight,useWidth: true),
                          child:IgnorePointer(
                            ignoring: !isHomeTab,
                            child: AnimatedOpacity(
                              opacity: isHomeTab ? 1 : 0,
                              duration: Durations.medium2,
                              child: Container(decoration: BoxDecoration(
                                color:defaultPalette.primary,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all()
                                ),),
                            ),
                          ),
                          ),
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: topPadPosDistance 
                          +  mapValueDimensionBased(115, 275, sWidth, sHeight, b:false)
                          //height of greetings
                          +  mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight)
                          //some padding
                          + mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),
                          // bottom: mapValueDimensionBasedLockOnDesync(18+5, 28+5, sWidth, sHeight),
                          left: mapValueDimensionBasedLockOnDesync(65, 80, sWidth, sHeight),
                          height: sHeight / 4 + mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight),
                          width: mapValueDimensionBased(453, 1315, sWidth, sHeight,useWidth: true),
                          child: IgnorePointer(
                            ignoring: !isHomeTab,
                            child: AnimatedOpacity(
                              opacity: isHomeTab ? 1 : 0,
                              duration: Durations.medium2,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                color:defaultPalette.black.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all()
                                ),),
                            ),
                          ),
                          ),
                        
                        //Graph window
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: topPadPosDistance 
                            +  mapValueDimensionBased(115, 275, sWidth, sHeight, b:false)
                            //height of greetings
                            +  mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight)
                            //some padding
                            + mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),
                          // bottom: mapValueDimensionBasedLockOnDesync(18+5, 28+5, sWidth, sHeight),
                          left: mapValueDimensionBasedLockOnDesync(65, 80, sWidth, sHeight),
                          height: sHeight / 4 + mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight),
                          width: mapValueDimensionBased(453, 1315, sWidth, sHeight,useWidth: true),
                          child: IgnorePointer(
                            ignoring: !isHomeTab,
                            child: AnimatedOpacity(
                              opacity: isHomeTab ? 1 : 0,
                              duration: Durations.medium2,
                              child: Padding(
                                padding: EdgeInsets.all(5),
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
                                        isCurved: true,
                                        curveSmoothness: 0.8,
                                        barWidth: 2,
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
                                          color: defaultPalette.extras[0],
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
                                        color: defaultPalette.extras[4],
                                        belowBarData: BarAreaData(show: false),
                                        dotData: FlDotData(show: false),
                                      ),
                                      LineChartBarData(
                                          spots: _dataPoints[5],
                                          isCurved: false,
                                          curveSmoothness: 0,
                                          barWidth: 1,
                                          color: defaultPalette.extras[3],
                                          belowBarData: BarAreaData(show: false),
                                          dotData: FlDotData(show: false),
                                          isStepLineChart: true),
                                      LineChartBarData(
                                        spots: _dataPoints[6],
                                        isCurved: false,
                                        curveSmoothness: 0,
                                        barWidth: 1,
                                        color: defaultPalette.primary,
                                        belowBarData: BarAreaData(show: false),
                                        dotData: FlDotData(show: false),
                                      ),
                                    ],
                                  
                                    backgroundColor:defaultPalette.transparent,
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
                                              reservedSize: 20,
                                              showTitles: false)),
                                      leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              reservedSize: 10,
                                              showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              reservedSize: 10,
                                              showTitles: true)),
                                    ),
                                    gridData: FlGridData(
                                        show: true,),
                                    borderData: FlBorderData(show: false),
                                    lineTouchData: LineTouchData(
                                     
                                    getTouchedSpotIndicator:
                                      (LineChartBarData barData,
                                          List<int> spotIndexes) {
                                    return spotIndexes.map((spotIndex) {
                                      final spot = barData.spots[spotIndex];
                                      if (barData.barWidth ==2)
                                      return TouchedSpotIndicatorData(
                                        FlLine(
                                          color: defaultPalette.extras[0],
                                          strokeWidth: 4,
                                        ),
                                        FlDotData(
                                          getDotPainter:
                                              (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 8,
                                              color: defaultPalette.primary,
                                              strokeWidth: 5,
                                              strokeColor:
                                                  defaultPalette.extras[0],
                                            );
                                          },
                                        ),
                                      );
                                    }).toList();
                                  },
                                    touchTooltipData: LineTouchTooltipData(
                                      tooltipBorder: BorderSide(
                                        color: defaultPalette.extras[0],
                                        width: 1,
                                      ),
                                      getTooltipColor: (touchedSpot) =>
                                        defaultPalette.primary,
                                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                        return touchedSpots.map((barSpot) {
                                          final spot = barSpot; // touched point
                                          final yVal = spot.y;
                                          final xVal = spot.x.toInt();
                               
                                          String label;
                                          if (barSpot.barIndex == 0) {
                                            // monthly line (mod 12)
                                            final monthIndex = xVal % 12;
                                            label = '${monthNames[monthIndex]} : ${_currencyFormatter.format(yVal)}';
                                          } else {
                                            final dayIndex = (xVal % 31) + 1;
                                            final date = DateTime(selectedYear, selectedMonth , dayIndex);
                               
                                            final weekday = DateFormat('EEE').format(date); // e.g. Tuesday
                                            final dayFormatted = DateFormat('d').format(date); // 10
                                            final monthFormatted = DateFormat('MMM').format(date); // Mar
                               
                                            label = '$weekday, $dayFormatted $monthFormatted : ${_currencyFormatter.format(yVal)}';
                                          }
                                          if (barSpot.barIndex ==0 || barSpot.barIndex ==1)
                                          return LineTooltipItem(
                                            label,
                                            TextStyle(                                fontFamily: 'Lexend',
                                              color:barSpot.barIndex == 0? defaultPalette.extras[0]:defaultPalette.tertiary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                    minX: isHomeTab
                                        ? _dataPoints[0].first.x
                                        : appinioMinTabChanged,
                               
                                    maxX: isHomeTab
                                        ? (_dataPoints[0].last.x <= 50
                                            ? 50
                                            : _dataPoints[0].last.x +
                                                ((_dataPoints[0].last.x - _dataPoints[0].first.x) * 0.2))
                                        : appinioMaxTabChanged,
                               
                                    minY: _globalMinY == double.infinity ? 0 : _globalMinY - _globalMaxY/2,
                                    maxY: _globalMaxY == double.negativeInfinity ? 1000 : _globalMaxY*1.3,
                               
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
                          top: topPadPosDistance 
                          +  mapValueDimensionBased(115, 275, sWidth, sHeight, b:false)
                          //height of greetings
                          +  mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight)
                          //some padding
                          + mapValueDimensionBasedLockOnDesync(5, 25, sWidth, sHeight)
                          //height of graph
                          + sHeight / 4
                          + mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight),
                          // bottom: mapValueDimensionBasedLockOnDesync(18, 28, sWidth, sHeight)+sHeight / 4,
                          left: mapValueDimensionBasedLockOnDesync(97, 122, sWidth, sHeight),
                          height: 20,
                          width: mapValueDimensionBased(380, 1215, sWidth, sHeight,useWidth: true),
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
                                  value: (_graphLineSpeedTween.value / 400),
                                  ropeLength: sHeight / 6,
                                  showRope: true,
                                  // onChangeStart: (val) {
                                  //   setState(() {
                                  //     _updateGraphLineSpeed(
                                  //         (val.clamp(0.1, 1.9) * 100).round());
                                  //     // _updateGraphLineSpeed(_graphLineSpeed);
                                  //   });
                                  // },
                                  onChanged: (val) {
                                    setState(() {
                                      _updateGraphLineSpeed(
                                          (val.clamp(0.01, 0.99) * 400).round());
                                    });
                                  },
                                  // onChangeEnd: (val) {
                                  //   setState(() {
                                  //     _updateGraphLineSpeed(
                                  //         (val.clamp(0.1, 1.9) * 100).round());
                                  //     // _updateGraphLineSpeed(_graphLineSpeed);
                                  //   });
                                  // },
                                  color: Colors.black),
                            ),
                          )),
                        //
                        //
                        //STATCARDSSS
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: topPadPosDistance 
                          +  mapValueDimensionBased(115, 275, sWidth, sHeight, b:false)
                          //height of greetings
                          +  mapValueDimensionBasedLockOnDesync(50, 80, sWidth, sHeight)
                          //some padding
                          + mapValueDimensionBasedLockOnDesync(10, 30, sWidth, sHeight)
                          //height of graphh
                          + sHeight / 4+ mapValueDimensionBasedLockOnDesync(15, 30, sWidth, sHeight)
                          //height of folderPath
                          +  mapValueDimensionBasedLockOnDesync(40, 80, sWidth, sHeight)
                          //some padding
                          // + mapValueDimensionBasedLockOnDesync(10, 30, sWidth, sHeight)
                          ,
                          left: mapValueDimensionBasedLockOnDesync(60, 75, sWidth, sHeight),
                          height: mapValueDimensionBasedLockOnDesync(100, 290, sWidth, sHeight),
                          width: mapValueDimensionBased(460, 1330, sWidth, sHeight,useWidth: true),
                          child: IgnorePointer(
                            ignoring: !isHomeTab,
                            child: AnimatedOpacity(
                              opacity: isHomeTab ? 1 : 0,
                              duration: Durations.medium1,
                              child: Row(
                                children: [
                                  //unPaid Bills
                                  Expanded(
                                    flex: 15,
                                    child: AppinioSwiper(
                                      backgroundCardCount: 1,
                                      // initialIndex: ref.read(cCardIndexProvider),
                                      backgroundCardOffset: Offset(4, 4),
                                      duration: Duration(milliseconds: 150),
                                      backgroundCardScale: 1,
                                      loop: isHomeTab,
                                      cardCount: 6,
                                      allowUnSwipe: true,
                                      controller: unpaidCardController,
                                      onCardPositionChanged: (position) {
                                        setState(() {
                                          _unpaidCardPosition = position.offset.dx.abs() + position.offset.dy.abs();
                                        });
                                      },
                                      onSwipeEnd: (a, b, direction) {
                                        // print(direction.toString());
                                        setState(() {
                                          ref
                                              .read(unpaidIndexProvider.notifier)
                                              .update((s) => s = b);
                                          // _currentCardIndex = b;
                                          _unpaidCardPosition = 0;
                                        });
                                      },
                                      cardBuilder: (BuildContext context, int index) {
                                        int currentCardIndex = ref.watch(unpaidIndexProvider);
                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: AnimatedContainer(
                                                duration: defaultDuration,
                                                margin: EdgeInsets.all(5),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(width: 1),
                                                  borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                ),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: AnimatedOpacity(
                                                opacity: currentCardIndex == index
                                                    ? 0
                                                    : (1 - (_unpaidCardPosition / 200).clamp(0.0, 1.0)),
                                                duration: Duration(milliseconds: 300),
                                                child: AnimatedContainer(
                                                  duration: Duration(milliseconds: 300),
                                                  margin: EdgeInsets.all(5),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: index == (currentCardIndex + 1) % 10
                                                        ? defaultPalette.extras[0]
                                                        : index == (currentCardIndex + 2) % 10
                                                            ? defaultPalette.extras[0]
                                                            : defaultPalette.extras[0],
                                                    border: Border.all(width: 2),
                                                    borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if(index==0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.extras[0],
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(totalUnpaid.toString(),
                                                                  textAlign: TextAlign.end,
                                                                  maxLines:1,
                                                                  overflow:TextOverflow.ellipsis,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.primary,
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                          Expanded(
                                                            child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                              child: Text('totalUnpaid',
                                                                maxLines:1,
                                                                overflow:TextOverflow.ellipsis,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(                                fontFamily: 'Lexend',
                                                                  color: defaultPalette.extras[4],
                                                                  fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                  letterSpacing: -1,
                                                                  fontWeight: FontWeight.w500,
                                                                  height: 0.6
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                        ],
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            if(index!=0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.extras[0],
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(((
                                                                    index==1
                                                                    ? typeStats[SheetType.taxInvoice]
                                                                    : index==2
                                                                      ? typeStats[SheetType.creditNote]
                                                                      : index==3
                                                                        ? typeStats[SheetType.debitNote]
                                                                        : index==4
                                                                        ? typeStats[SheetType.billOfSupply]
                                                                        : typeStats[SheetType.proformaInvoice]
                                                                    )?['unpaid']??0).round().toString(),
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.primary,
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                            Expanded(
                                                              child: FittedBox(
                                                                fit: BoxFit.scaleDown,
                                                                alignment: Alignment.centerRight,
                                                                child: Text(
                                                                  index==1
                                                                  ? 'unpaid TxInv'
                                                                  : index==2
                                                                    ? 'unpaid CrdNotes'
                                                                    : index==3
                                                                      ? 'unpaid DbtNotes'
                                                                      : index==4
                                                                      ? 'unpaid BOS'
                                                                      : 'unpaid ProInv',
                                                                  textAlign:TextAlign.center,
                                                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[4],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w500,
                                                                    height: 0.6
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                                                                        
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            
                                          ],
                                        );
                                      
                                      },
                                    ),
                                  ),
                                  SizedBox(width:mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                  //REVENUEE OF BILLS AND ALLAT CARDS
                                  Expanded(
                                    flex: 20,
                                    child: AppinioSwiper(
                                      backgroundCardCount: 1,
                                      // initialIndex: ref.read(cCardIndexProvider),
                                      backgroundCardOffset: Offset(4, 4),
                                      duration: Duration(milliseconds: 150),
                                      backgroundCardScale: 1,
                                      loop: isHomeTab,
                                      cardCount: 6,
                                      allowUnSwipe: true,
                                      controller: revCardController,
                                      onCardPositionChanged: (position) {
                                        setState(() {
                                          _revCardPosition = position.offset.dx.abs() + position.offset.dy.abs();
                                        });
                                      },
                                      onSwipeEnd: (a, b, direction) {
                                        // print(direction.toString());
                                        setState(() {
                                          ref
                                              .read(revIndexProvider.notifier)
                                              .update((s) => s = b);
                                          // _currentCardIndex = b;
                                          _revCardPosition = 0;
                                        });
                                      },
                                      cardBuilder: (BuildContext context, int index) {
                                        int currentCardIndex = ref.watch(revIndexProvider);
                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: AnimatedContainer(
                                                duration: defaultDuration,
                                                margin: EdgeInsets.all(5),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(width: 1),
                                                  borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                ),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: AnimatedOpacity(
                                                opacity: currentCardIndex == index
                                                    ? 0
                                                    :  (1 - (_revCardPosition / 200).clamp(0.0, 1.0)),
                                                duration: Duration(milliseconds: 300),
                                                child: AnimatedContainer(
                                                  duration: Duration(milliseconds: 300),
                                                  margin: EdgeInsets.all(5),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: index == (currentCardIndex + 1) % 10
                                                        ? defaultPalette.extras[0]
                                                        : index == (currentCardIndex + 2) % 10
                                                            ? defaultPalette.extras[0]
                                                            : defaultPalette.extras[0],
                                                    border: Border.all(width: 2),
                                                    borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if(index==0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.secondary,
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(_currencyFormatter.format(totalRevenue),
                                                                  textAlign: TextAlign.end,
                                                                  maxLines:1,
                                                                  overflow:TextOverflow.ellipsis,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                          Expanded(
                                                            child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                              child: Text('totalRevenue',
                                                                maxLines:1,
                                                                overflow:TextOverflow.ellipsis,
                                                                style: TextStyle(                                fontFamily: 'Lexend',
                                                                  color: defaultPalette.extras[0],
                                                                  fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                  letterSpacing: -1,
                                                                  fontWeight: FontWeight.w500,
                                                                  height: 0.6
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                  
                                                        ],
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            if(index!=0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.secondary,
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(_currencyFormatter.format((
                                                                    index==1
                                                                    ? typeStats[SheetType.taxInvoice]
                                                                    : index==2
                                                                      ? typeStats[SheetType.creditNote]
                                                                      : index==3
                                                                        ? typeStats[SheetType.debitNote]
                                                                        : index==4
                                                                        ? typeStats[SheetType.billOfSupply]
                                                                        : typeStats[SheetType.proformaInvoice]
                                                                    )?['payable']??0),
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                            Expanded(
                                                              child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                                child: Text(
                                                                  index==1
                                                                  ? 'txInv Revenue'
                                                                  : index==2
                                                                    ? 'crdNotes Revenue'
                                                                    : index==3
                                                                      ? 'dbtNotes Revenue'
                                                                      : index==4
                                                                      ? 'bOS Revenue'
                                                                      : 'proInv Revenue',
                                                                  textAlign:TextAlign.center,
                                                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w500,
                                                                    height: 0.6
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),                                            
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            
                                          ],
                                        );
                                      
                                      },
                                    ),
                                  ),
                                  SizedBox(width:mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                  //QUANITYYY OF BILLS AND ALLAT CARDS
                                  Expanded(
                                    flex: 20,
                                    child: AppinioSwiper(
                                      backgroundCardCount: 1,
                                      // initialIndex: ref.read(cCardIndexProvider),
                                      backgroundCardOffset: Offset(4, 4),
                                      duration: Duration(milliseconds: 150),
                                      backgroundCardScale: 1,
                                      loop: isHomeTab,
                                      cardCount: 6,
                                      allowUnSwipe: true,
                                      controller: qtyCardController,
                                      onCardPositionChanged: (position) {
                                        setState(() {
                                          _qtyCardPosition = position.offset.dx.abs() + position.offset.dy.abs();
                                        });
                                      },
                                      onSwipeEnd: (a, b, direction) {
                                        // print(direction.toString());
                                        setState(() {
                                          ref
                                              .read(qtyIndexProvider.notifier)
                                              .update((s) => s = b);
                                          // _currentCardIndex = b;
                                          _qtyCardPosition = 0;
                                        });
                                      },
                                      cardBuilder: (BuildContext context, int index) {
                                        int currentCardIndex =
                                            ref.watch(qtyIndexProvider);
                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: AnimatedContainer(
                                                duration: defaultDuration,
                                                margin: EdgeInsets.all(5),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(width: 1),
                                                  borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
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
                                                            (_qtyCardPosition / 200)
                                                                .clamp(0.0, 1.0)),
                                                duration: Duration(milliseconds: 300),
                                                child: AnimatedContainer(
                                                  duration: Duration(milliseconds: 300),
                                                  margin: EdgeInsets.all(5),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: index ==
                                                            (currentCardIndex + 1) % 10
                                                        ? defaultPalette.extras[0]
                                                        : index ==
                                                                (currentCardIndex + 2) % 10
                                                            ? defaultPalette.extras[0]
                                                            : defaultPalette.extras[0],
                                                    border: Border.all(width: 2),
                                                    borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if(index==0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.secondary,
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child:FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(totalBills.toString(),
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                          Expanded(
                                                            child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                              child: Text('totalBills',
                                                                style: TextStyle(                                fontFamily: 'Lexend',
                                                                  color: defaultPalette.extras[0],
                                                                  fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                  letterSpacing: -1,
                                                                  fontWeight: FontWeight.w500,
                                                                  height: 0.6
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                        ],
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            if(index!=0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.secondary,
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text((
                                                                    index==1
                                                                    ? typeStats[SheetType.taxInvoice]
                                                                    : index==2
                                                                      ? typeStats[SheetType.creditNote]
                                                                      : index==3
                                                                        ? typeStats[SheetType.debitNote]
                                                                        : index==4
                                                                        ? typeStats[SheetType.billOfSupply]
                                                                        : typeStats[SheetType.proformaInvoice]
                                                                    )?['count']?.toInt().toString()??'0',
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                          Expanded(
                                                            child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                              child: Text(index==1
                                                                      ? 'taxInvoices'
                                                                      : index==2
                                                                        ? 'creditNotes'
                                                                        : index==3
                                                                          ? 'debitNotes'
                                                                          : index==4
                                                                          ? 'billOfSupply'
                                                                          : 'proformaInvoices',
                                                                style: TextStyle(                                fontFamily: 'Lexend',
                                                                  color: defaultPalette.extras[0],
                                                                  fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                  letterSpacing: -1,
                                                                  fontWeight: FontWeight.w500,
                                                                  height: 0.6
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                  
                                                        ],
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            
                                          ],
                                        );
                                      
                                      },
                                    ),
                                  ),
                                  SizedBox(width:mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                  //PROFITSS OF BILLS AND ALLAT CARDSS
                                  Expanded(
                                    flex: 20,
                                    child: AppinioSwiper(
                                      backgroundCardCount: 1,
                                      // initialIndex: ref.read(cCardIndexProvider),
                                      backgroundCardOffset: Offset(4, 4),
                                      duration: Duration(milliseconds: 150),
                                      backgroundCardScale: 1,
                                      loop: isHomeTab,
                                      cardCount: 6,
                                      allowUnSwipe: true,
                                      controller: profitsCardController,
                                      onCardPositionChanged: (position) {
                                        setState(() {
                                          _profitsCardPosition = position.offset.dx.abs() + position.offset.dy.abs();
                                        });
                                      },
                                      onSwipeEnd: (a, b, direction) {
                                        // print(direction.toString());
                                        setState(() {
                                          ref
                                              .read(profitsIndexProvider.notifier)
                                              .update((s) => s = b);
                                          // _currentCardIndex = b;
                                          _profitsCardPosition = 0;
                                        });
                                      },
                                      cardBuilder: (BuildContext context, int index) {
                                        int currentCardIndex =
                                            ref.watch(profitsIndexProvider);
                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: AnimatedContainer(
                                                duration: defaultDuration,
                                                margin: EdgeInsets.all(5),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(width: 1),
                                                  borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
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
                                                            (_profitsCardPosition / 200)
                                                                .clamp(0.0, 1.0)),
                                                duration: Duration(milliseconds: 300),
                                                child: AnimatedContainer(
                                                  duration: Duration(milliseconds: 300),
                                                  margin: EdgeInsets.all(5),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: index ==
                                                            (currentCardIndex + 1) % 10
                                                        ? defaultPalette.extras[0]
                                                        : index ==
                                                                (currentCardIndex + 2) % 10
                                                            ? defaultPalette.extras[0]
                                                            : defaultPalette.extras[0],
                                                    border: Border.all(width: 2),
                                                    borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            if(index==0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.secondary,
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(_currencyFormatter.format(totalProfit),
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                          Expanded(
                                                            child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                              child: Text('totalProfits',
                                                                style: TextStyle(                                fontFamily: 'Lexend',
                                                                  color: defaultPalette.extras[0],
                                                                  fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                  letterSpacing: -1,
                                                                  fontWeight: FontWeight.w500,
                                                                  height: 0.6
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                  
                                                        ],
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            if(index!=0)...[
                                              Positioned.fill(
                                                child:Container(
                                                  margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  // padding: EdgeInsets.all(0).copyWith(left: 20, right:15,top: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(5).copyWith(bottom:0),
                                                          decoration: BoxDecoration(
                                                            color: defaultPalette.secondary,
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                            border: Border.all()
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),),
                                                              Expanded(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(_currencyFormatter.format((
                                                                    index==1
                                                                    ? typeStats[SheetType.taxInvoice]
                                                                    : index==2
                                                                      ? typeStats[SheetType.creditNote]
                                                                      : index==3
                                                                        ? typeStats[SheetType.debitNote]
                                                                        : index==4
                                                                        ? typeStats[SheetType.billOfSupply]
                                                                        : typeStats[SheetType.proformaInvoice]
                                                                    )?['profit']??0),
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(45, 85, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w700,
                                                                    height: 0.5
                                                                  ),),
                                                                ),
                                                              ),
                                                              SizedBox(width: mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),
                                                            Expanded(
                                                              child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                                child: Text(
                                                                  index==1
                                                                  ? 'txInv Profits'
                                                                  : index==2
                                                                    ? 'crdNotes Profits'
                                                                    : index==3
                                                                      ? 'dbtNotes Profits'
                                                                      : index==4
                                                                      ? 'bOS Profits'
                                                                      : 'proInv Profits',
                                                                  textAlign:TextAlign.center,
                                                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                    color: defaultPalette.extras[0],
                                                                    fontSize: mapValueDimensionBasedLockOnDesync(12, 35, sWidth, sHeight),
                                                                    letterSpacing: -1,
                                                                    fontWeight: FontWeight.w500,
                                                                    height: 0.6
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                           SizedBox(width: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),),                                             
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight),)
                                                    ],
                                                  ),
                                                )
                                              )
              
                                            ],
                                            
                                          ],
                                        );
                                      
                                      },
                                    ),
                                  ),
                                  SizedBox(width:mapValueDimensionBasedLockOnDesync(10, 15, sWidth, sHeight)),
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top:8),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.bottomCenter,
                                            child: Text(ref.watch(currencyCodeProvider).name,
                                            textAlign: TextAlign.end,
                                            maxLines:2,
                                            overflow:TextOverflow.ellipsis,
                                            style: TextStyle(                                fontFamily: 'Lexend',
                                              color: defaultPalette.extras[0],
                                              fontSize: mapValueDimensionBased(12, 85, sWidth, sHeight,b:false),
                                              letterSpacing: -1,
                                              fontWeight: FontWeight.w700,
                                              height: 0.3
                                            ),),
                                          ),
                                        ),
                                        SizedBox(height:mapValueDimensionBased(10, 15, sWidth, sHeight,b:false)),
                                        Expanded(
                                            child: AppinioSwiper(
                                                backgroundCardCount: 5,
                                                // initialIndex: ref.read(cCardIndexProvider),
                                                backgroundCardOffset: Offset(0.8, 0.8),
                                                duration: Duration(milliseconds: 150),
                                                backgroundCardScale: 1,
                                                loop: isHomeTab,
                                                cardCount: 1,
                                                isDisabled: false,
                                                allowUnSwipe: false,
                                                cardBuilder: (BuildContext context, int index) {
                                                  // int currentCardIndex =
                                                  //     ref.watch(profitsIndexProvider);
                                                  return Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: AnimatedContainer(
                                                          duration: defaultDuration,
                                                          margin: EdgeInsets.all(0).copyWith(bottom:5),
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(width: 1),
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned.fill(
                                                        child: AnimatedOpacity(
                                                          opacity: 0 == index
                                                              ? 0
                                                              : index >= 0 % 10
                                                                  ? 1
                                                                  : (1 -
                                                                      (_profitsCardPosition / 200)
                                                                          .clamp(0.0, 1.0)),
                                                          duration: Duration(milliseconds: 300),
                                                          child: AnimatedContainer(
                                                            duration: Duration(milliseconds: 300),
                                                            margin: EdgeInsets.all(0).copyWith(bottom:5),
                                                            alignment: Alignment.center,
                                                            decoration: BoxDecoration(
                                                              color: index ==
                                                                      (0 + 1) % 10
                                                                  ? defaultPalette.extras[0]
                                                                  : index ==
                                                                          (0 + 2) % 10
                                                                      ? defaultPalette.extras[0]
                                                                      : defaultPalette.extras[0],
                                                              border: Border.all(width: 2),
                                                              borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(18, 30, sWidth, sHeight)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      
                                                      Positioned.fill(
                                                        child:MouseRegion(
                                                          cursor: SystemMouseCursors.click,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              showCurrencySelectionDialog(context, ref);
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets.all(0).copyWith(bottom:5),
                                                              decoration: BoxDecoration(
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Expanded(
                                                                    child: Container(
                                                                      margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)).copyWith(bottom:0),
                                                                      decoration: BoxDecoration(
                                                                        color: defaultPalette.secondary,
                                                                        borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(16, 30, sWidth, sHeight)),
                                                                        border: Border.all()
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: FittedBox(
                                                                              fit: BoxFit.scaleDown,
                                                                              alignment: Alignment.center,
                                                                              child: Text(ref.watch(currencyCodeProvider).symbol,
                                                                              textAlign: TextAlign.end,
                                                                              style: TextStyle(                                fontFamily: 'Lexend',
                                                                                color: defaultPalette.extras[0],
                                                                                fontSize: mapValueDimensionBasedLockOnDesync(25, 95, sWidth, sHeight),
                                                                                letterSpacing: -1,
                                                                                fontWeight: FontWeight.w700,
                                                                                height: 0.5
                                                                              ),),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(4.0).copyWith(bottom: mapValueDimensionBasedLockOnDesync(2, 10, sWidth, sHeight),top:mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight)),
                                                                    child: FittedBox(
                                                                      fit: BoxFit.scaleDown,
                                                                      alignment: Alignment.bottomCenter,
                                                                      child: Text(ref.watch(currencyCodeProvider).code,
                                                                      textAlign: TextAlign.end,
                                                                      maxLines:1,
                                                                      overflow:TextOverflow.ellipsis,
                                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                                        color: defaultPalette.extras[0],
                                                                        fontSize: mapValueDimensionBased(15, 50, sWidth, sHeight,b:false),
                                                                        letterSpacing: -1,
                                                                        fontWeight: FontWeight.w700,
                                                                        height: 0.5
                                                                      ),),
                                                                    ),
                                                                  ),
                                                                  Icon(TablerIcons.chevron_compact_down,
                                                                    color: defaultPalette.extras[0],
                                                                    size: mapValueDimensionBasedLockOnDesync(15, 30, sWidth, sHeight),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      )
                        
                                                      
                                                    ],
                                                  );
                                                
                                                },
                                              ),
                                  
                                        ),
                                      ],
                                    ),
                                    
                                    ),
                                  // SizedBox(width:5)
                                  
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        //
                        //RECENTS CARDS
                        AnimatedPositioned(
                          duration: defaultDuration,
                          top: topPadPosDistance + 10,
                          right: 5,
                          height: sHeight -(topPadPosDistance + 10) -mapValueDimensionBasedLockOnDesync(8, 20, sWidth, sHeight),
                          width: sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                          child: IgnorePointer(
                            ignoring: !isHomeTab,
                            child: AnimatedOpacity(
                              duration: Durations.medium2,
                              opacity: isHomeTab? 1:0,
                              child: AppinioSwiper(
                                backgroundCardCount: 1,
                                initialIndex: ref.read(cCardIndexProvider),
                                backgroundCardOffset: Offset(5, 5),
                                duration: Duration(milliseconds: 150),
                                backgroundCardScale: 1,
                                loop: isHomeTab,
                                cardCount: 2,
                                allowUnSwipe: true,
                                controller: recentsCardController,
                                onCardPositionChanged: (position) {
                                  setState(() {
                                    _cardPosition = position.offset.dx.abs() + position.offset.dy.abs();
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
                                            border: Border.all(width: 1),
                                            borderRadius: BorderRadius.circular( mapValueDimensionBasedLockOnDesync(30, 50, sWidth, sHeight)),
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
                                              color: index ==
                                                      (currentCardIndex + 1) % 10
                                                  ? defaultPalette.extras[0]
                                                  : index ==
                                                          (currentCardIndex + 2) % 10
                                                      ? defaultPalette.extras[0]
                                                      : defaultPalette.extras[0],
                                              border: Border.all(width: 2),
                                              borderRadius: BorderRadius.circular( mapValueDimensionBasedLockOnDesync(30, 50, sWidth, sHeight)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      if(index==1)
                                      //MWL INTERFACE
                                      Positioned.fill(
                                          left: 15+mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),
                                          right: 15+mapValueDimensionBasedLockOnDesync(10, 25, sWidth, sHeight),
                                          top: 15+5,
                                          bottom: 15+5,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              //The made with love and socials
                                              SizedBox(
                                              height: mapValueDimensionBasedLockOnDesync(80, 200, sWidth, sHeight),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 15+mapValueDimensionBasedLockOnDesync(1, 25, sWidth, sHeight),),
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                          top:mapValueDimensionBasedLockOnDesync(
                                                                    10,
                                                                    20,
                                                                    sWidth,
                                                                    sHeight)+mapValueDimensionBasedLockOnDesync(
                                                                    5,
                                                                    45,
                                                                    sWidth,
                                                                    sHeight),
                                                          right:mapValueDimensionBasedLockOnDesync(
                                                                    12,
                                                                    32,
                                                                    sWidth,
                                                                    sHeight)),
                                                        child: Text(
                                                          'Made\nWith\nLove',
                                                          maxLines: 3,
                                                          overflow:TextOverflow.ellipsis,
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle( fontFamily: 'PressStart2P',
                                                            height:0.95,
                                                            fontSize: mapValueDimensionBasedLockOnDesync(
                                                                    18,
                                                                    45,
                                                                    sWidth,
                                                                    sHeight),
                                                            color: defaultPalette.extras[0],
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right:0,
                                                        top:mapValueDimensionBasedLockOnDesync(
                                                                    5,
                                                                    45,
                                                                    sWidth,
                                                                    sHeight),
                                                        child: ElevatedLayerButton(
                                                          onClick: () async {
                                                          },
                                                          buttonHeight: mapValueDimensionBasedLockOnDesync(
                                                                  30, 70, sWidth, sHeight),
                                                          buttonWidth: mapValueDimensionBasedLockOnDesync(
                                                                  30, 70, sWidth, sHeight),
                                                          borderRadius: BorderRadius.circular( mapValueDimensionBasedLockOnDesync(
                                                                  16, 30, sWidth, sHeight)),
                                                          animationDuration: const Duration(milliseconds: 200),
                                                          animationCurve: Curves.ease,
                                                          subfac: mapValueDimensionBasedLockOnDesync(
                                                              2, 4, sWidth, sHeight),
                                                          depth: mapValueDimensionBasedLockOnDesync(
                                                              2, 4, sWidth, sHeight),
                                                          topDecoration: BoxDecoration(
                                                            color: defaultPalette.transparent,
                                                          ),
                                                          topLayerChild: Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Icon(TablerIcons.heart_filled,size:mapValueDimensionBasedLockOnDesync(
                                                                  30, 70, sWidth, sHeight),color: defaultPalette.extras[0],),
                                                              Icon(TablerIcons.heart_filled,size:mapValueDimensionBasedLockOnDesync(
                                                                  25, 62, sWidth, sHeight),color: defaultPalette.extras[4],),
                                                            ],
                                                          ),
                                                          baseDecoration: BoxDecoration(
                                                            color: defaultPalette.transparent,
                                                            // border: Border.all(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: mapValueDimensionBasedLockOnDesync(1, 15, sWidth, sHeight),),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(0).copyWith(
                                                        top: mapValueDimensionBasedLockOnDesync(20, 75, sWidth, sHeight),
                                                        left: mapValueDimensionBasedLockOnDesync(1, 25, sWidth, sHeight),
                                                        bottom: mapValueDimensionBasedLockOnDesync(3, 10, sWidth, sHeight),
                                                        right: mapValueDimensionBasedLockOnDesync(1, 25, sWidth, sHeight),
                                                      ),
                                                      child: FittedBox(
                                                        fit:BoxFit.scaleDown,
                                                        alignment: Alignment.centerRight,
                                                          child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children:[
                                                                  Text('made by: ',
                                                                  maxLines:1,
                                                                  overflow:TextOverflow.ellipsis,
                                                                  style: TextStyle( fontFamily: 'Lexend',
                                                                  fontSize: 20,
                                                                  height: 0.8,
                                                                  color: defaultPalette.extras[0],
                                                                  fontWeight: FontWeight.w300,
                                                                  ),
                                                                ),
                                                                SizedBox(width: 60,),
                                                                //jepixoColor
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:GestureDetector(
                                                                            onTap:(){
                                                                              if (infoOverlayEntry != null) {
                                                                                setState(() {
                                                                                  infoOverlayEntry?.remove();
                                                                                  infoOverlayEntry = null;
                                                                                });
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                              padding:EdgeInsets.all(12),
                                                                              decoration: BoxDecoration(
                                                                              color: defaultPalette.primary.withOpacity(1),
                                                                              boxShadow: [
                                                                                BoxShadow(blurRadius: 15,spreadRadius: 2,color: defaultPalette.extras[0].withOpacity(0.2))
                                                                              ],
                                                                              border: Border.all(),
                                                                              borderRadius: BorderRadius.circular(15)),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Image.asset(
                                                                                        'assets/images/pixeldance.gif',
                                                                                        width: 33,
                                                                                        gaplessPlayback: true, // prevents flickering on rebuild
                                                                                      ),
                                                                                      SizedBox(width: 10,),
                                                                                      Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          RichText(
                                                                                            text: TextSpan(
                                                                                              children: [
                                                                                                TextSpan(
                                                                                                  text: 'Jepixo',
                                                                                                  style: TextStyle(
                                                                                                    fontFamily: 'Lexend',
                                                                                                    fontSize: 25,
                                                                                                    color: defaultPalette.extras[0],
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    decoration: TextDecoration.none,
                                                                                                  ),
                                                                                                ),
                                                                                                WidgetSpan(
                                                                                                  child: Transform.translate(
                                                                                                    offset: const Offset(2, -8), // adjust vertical position
                                                                                                    child: Text(
                                                                                                      'TM',// make it smaller
                                                                                                      style: TextStyle(
                                                                                                        fontFamily: 'Lexend',
                                                                                                        fontSize: 12,
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        color: defaultPalette.extras[0],
                                                                                                        decoration: TextDecoration.none, 
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            textAlign: TextAlign.start,
                                                                                          ),
                                                                                          SizedBox(height: 10,),
                                                                                          Text('Adapt, Adept. ',
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            textAlign: TextAlign.start,
                                                                                            style: TextStyle( fontFamily: 'Lexend',
                                                                                            fontSize: 18,
                                                                                            color: defaultPalette.extras[0],
                                                                                            fontWeight: FontWeight.w500,
                                                                                            decoration: TextDecoration.none, 
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  
                                                                                  SizedBox(height: 5,),
                                                                                  Text('''
                                                                                    \nCode a blunt sword and design rebellion. Sharpen them both on failure.
                                                                                    \nIn other words, I develop and design apps among other things. 
                                                                                    \nFeel free to learn more about me on LinkedIn, etc.
                                                                                    \nI go by @jepixo almost everywhere online.
                                                                                    \nAwful dance btw. Yup, Veo3 is awesome.
                                                                                    \nAnyway, wishing you the best!🤗✨''',
                                                                            
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  textAlign: TextAlign.start,
                                                                                  style: TextStyle( fontFamily: 'Lexend',
                                                                                  fontSize: 15,
                                                                                  height: 0.8,
                                                                                  color: defaultPalette.extras[0],
                                                                                  fontWeight: FontWeight.w400,
                                                                                  decoration: TextDecoration.none, 
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 5,),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                child: Text('@jepixo',
                                                                    maxLines:1,
                                                                    overflow:TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.end,
                                                                    style: TextStyle( fontFamily: 'Lexend',
                                                                    fontSize: 30,
                                                                    height: 0.8,
                                                                    color: defaultPalette.extras[0],
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                  ),
                                                                ),
                                                              ]
                                                              ),
                                                            SizedBox(height: 8,),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                //find me follow me
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'Follow me.',
                                                                          maxLines: 1,
                                                                          overflow:TextOverflow.ellipsis,
                                                                          textAlign: TextAlign.start,
                                                                          style: TextStyle( fontFamily: 'Lexend',
                                                                            fontSize: 20,
                                                                            height: 0.8,
                                                                            color: defaultPalette.extras[0],
                                                                            fontWeight: FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 8),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'Find me.',
                                                                          maxLines: 1,
                                                                          overflow:TextOverflow.ellipsis,
                                                                          textAlign: TextAlign.start,
                                                                          style: TextStyle( fontFamily: 'Lexend',
                                                                            fontSize: 20,
                                                                            color: defaultPalette.extras[0],
                                                                            fontWeight: FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(width: 14,),
                                                                //linkedincolor
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=11) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[11];
                                                                  }
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child: infoOverlayPanel(
                                                                            'LinkedIn.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/linkedin.svg',
                                                                              width: 50,
                                                                              height: 50,
                                                                            ),
                                                                            'linkedin.com/in/jepixo',
                                                                            '''
                                                                            \nExplore my work, projects, education, certifications, and skills on LinkedIn. 
                                                                            \nLet's connect and discover opportunities to collaborate.'''
                                                                          ),
                                                                          );});
                                                                  },);
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                  await changeTvChannel(true);
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                child: SvgPicture.asset(
                                                                  'assets/logos/linkedin.svg',
                                                                  width: 50,
                                                                  height: 50,
                                                                ),
                                                                ),SizedBox(width: 5,),
                                                                //instagramcolor
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=5
                                                                  && homePageUrls.indexOf(ref.read(homePageUrlProvider))!=6) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[5];
                                                                  }
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'Instagram.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/instagramcolor.svg',
                                                                              width: 50,
                                                                              height: 50,
                                                                            ),
                                                                            '@jepixo, @jovoxel, @billblazex - slide in DMs',
                                                                            '''
                                                                            \nI actually had the link for these handles loaded down there
                                                                            \nbut Zuccy Boy keeps redirecting it to the sign up page.
                                                                            \nAnd I'm not dealing with phishing allegations.
                                                                            \nSo be a darling and scan those.✨'''
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                  await changeTvChannel(true);
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                child: SvgPicture.asset(
                                                                  'assets/logos/instagram.svg',
                                                                  width: 50,
                                                                  height: 50,
                                                                ),
                                                                ),SizedBox(width: 5,),
                                                                //youtubecolor
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=8
                                                                  && homePageUrls.indexOf(ref.read(homePageUrlProvider))!=7) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[8];
                                                                  }
                                                                  await changeTvChannel(true);
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'Youtube.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/youtubecolor.svg',
                                                                              width: 50,
                                                                              height: 50,
                                                                            ),
                                                                            '@jepixo, @billblazex - feel free to indulge.',
                                                                            '''
                                                                            \nTutorials and updates on Billblaze.
                                                                            \nOther projects and videos on Jepixo.
                                                                            \nSubscribe and spread the word, but only if you like it.'''
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                  child: SvgPicture.asset(
                                                                    'assets/logos/youtube.svg',
                                                                    width: 50,
                                                                    height: 50,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 2,),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'Feed me.',
                                                                      maxLines: 1,
                                                                      overflow:TextOverflow.ellipsis,
                                                                      textAlign: TextAlign.start,
                                                                      style: TextStyle( fontFamily: 'Lexend',
                                                                        fontSize: 35,
                                                                        height: 0.8,
                                                                        letterSpacing: -1,
                                                                        color: defaultPalette.extras[0],
                                                                        fontWeight: FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(width: 2,),
                                                                //gumroad
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=0) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[0];
                                                                  }
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'Gumroad.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/gumroad.svg',
                                                                              width: 40,
                                                                              height: 40,
                                                                            ),
                                                                            'jepixo.gumroad.com',
                                                                            '''
                                                                            \nYou want a piece of my work? Happy to oblige.
                                                                            \nMy workshop open to you!'''
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                  await changeTvChannel(true);
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                  child: SvgPicture.asset(
                                                                    'assets/logos/gumroad.svg',
                                                                    width: 30,
                                                                    height: 30,
                                                                  ),
                                                                ),
                                                                //ko fi
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=4) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[4];
                                                                  }
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'Ko-Fi.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/kofi.svg',
                                                                              width: 50,
                                                                              height: 50,
                                                                            ),
                                                                            'ko-fi.com/jepixo',
                                                                            '''
                                                                            \nSupport my journey, snag exclusive products, 
                                                                            \nor commission me to make something unique for you.'''
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                  await changeTvChannel(true);
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                  child: SvgPicture.asset(
                                                                    'assets/logos/kofi.svg',
                                                                    width: 35,
                                                                    height: 35,
                                                                  ),
                                                                ),
                                                                //patreon
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=1) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[1];
                                                                  }
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'Patreon.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/patreon.svg',
                                                                              width: 40,
                                                                              height: 40,
                                                                            ),
                                                                            'patreon.com/Jepixo',
                                                                            '''
                                                                            \nBehind-the-scenes work, early drops, and the raw process.
                                                                            \nUnpolished, sometimes messy, but always genuine. 
                                                                            \nIf you want to breathe down my neck alongside the build, 
                                                                            \nthe break, and the rebuild then Patreon's the place.'''
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                  await changeTvChannel(true);
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                  child: SvgPicture.asset(
                                                                    'assets/logos/patreon.svg',
                                                                    width: 25,
                                                                    height: 25,
                                                                  ),
                                                                ),
                                                                SizedBox(width: 5,),
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom:4.0),
                                                                      child: Text(
                                                                          'Finger me.',
                                                                            maxLines: 1,
                                                                            overflow:TextOverflow.ellipsis,
                                                                            textAlign: TextAlign.start,
                                                                            style: TextStyle( fontFamily: 'Lexend',
                                                                              fontSize: 18,
                                                                              height: 0.8,
                                                                              color: defaultPalette.extras[0],
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                    ),
                                                                    Icon(TablerIcons.thumb_up_filled, size:30)
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 2,),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                
                                                                SizedBox(width: 2,),
                                                                //github
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=10) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[10];
                                                                  }
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'Github.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/github.svg',
                                                                              width: 40,
                                                                              height: 40,
                                                                              
                                                                            ),
                                                                            'github.com/jepixo',
                                                                            '''
                                                                            \nContribute, fork, or just get inspired.'''
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                  await changeTvChannel(true);
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                  child: SvgPicture.asset(
                                                                    'assets/logos/github.svg',
                                                                    width: 22,
                                                                    height: 22,
                                                                    colorFilter: ColorFilter.mode(defaultPalette.black, BlendMode.srcIn),
                                                                  ),
                                                                ),SizedBox(width: 2,),
                                                                //onlyfans
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if(homePageUrls.indexOf(ref.read(homePageUrlProvider))!=2) {
                                                                    ref.read(homePageUrlProvider.notifier).state = homePageUrls[2];
                                                                  }
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'OnlyFans',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/onlyfans.svg',
                                                                              width: 30,
                                                                              height: 30,
                                                                              colorFilter: ColorFilter.mode(defaultPalette.extras[3], BlendMode.srcIn),
                                                                            ),
                                                                            'Don\'t even get me started.',
                                                                            '\nKernels of wisdom: maybe ease up on the corn, champ.'
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                  
                                                                  await changeTvChannel(true);
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                  child: SvgPicture.asset(
                                                                    'assets/logos/onlyfans.svg',
                                                                    width: 18,
                                                                    height: 18,
                                                                    colorFilter: ColorFilter.mode(defaultPalette.extras[3], BlendMode.srcIn),
                                                                  ),
                                                                ),SizedBox(width: 2,),
                                                                //home
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                        var clickText = 'Click here to get my home address.';
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:GestureDetector(
                                                                            onTap:(){
                                                                              if (infoOverlayEntry!=null) {
                                                                                infoOverlayEntry?.remove();
                                                                                infoOverlayEntry =null;
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                              padding:EdgeInsets.all(12),
                                                                              decoration: BoxDecoration(
                                                                              color: defaultPalette.primary.withOpacity(1),
                                                                              boxShadow: [
                                                                                BoxShadow(blurRadius: 15,spreadRadius: 2,color: defaultPalette.extras[0].withOpacity(0.2))
                                                                              ],
                                                                              border: Border.all(),
                                                                              borderRadius: BorderRadius.circular(15)),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                        Icon(clickText.startsWith('Wow')?TablerIcons.prison:TablerIcons.home, size:30),
                                                                                      SizedBox(width: 10,),
                                                                                      Text(
                                                                                        clickText.startsWith('Wow')?'Jail':'Home.',
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        textAlign: TextAlign.start,
                                                                                        style: TextStyle( fontFamily: 'Lexend',
                                                                                          fontSize: 25,
                                                                                          color: defaultPalette.extras[0],
                                                                                          fontWeight: FontWeight.w600,
                                                                                          decoration: TextDecoration.none, 
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: 10,),
                                                                                  Text(clickText.startsWith('Wow')? clickText:'My Literal Address.',
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    textAlign: TextAlign.start,
                                                                                    style: TextStyle( fontFamily: 'Lexend',
                                                                                    fontSize: 18,
                                                                                    color: defaultPalette.extras[0],
                                                                                    fontWeight: FontWeight.w500,
                                                                                    decoration: TextDecoration.none, 
                                                                                    ),
                                                                                  ),
                                                                                  if(!clickText.startsWith('Wow'))
                                                                                  ...[SizedBox(height: 10,),
                                                                                  MouseRegion(
                                                                                    cursor: SystemMouseCursors.click,
                                                                                    child: GestureDetector(
                                                                                      onTap:(){
                                                                                        updateState((){
                                                                                          clickText = 'Wow creep, why do you want my address huh?';
                                                                                        });
                                                                                      },
                                                                                      child: Text(clickText,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        textAlign: TextAlign.start,
                                                                                        style: TextStyle( fontFamily: 'Lexend',
                                                                                        fontSize: 14,
                                                                                        height: 0.8,
                                                                                        color: defaultPalette.extras[0],
                                                                                        fontWeight: FontWeight.w700,
                                                                                        decoration: TextDecoration.none, 
                                                                                        fontStyle:  FontStyle.italic
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),],
                                                                                  SizedBox(height: 5,),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                },
                                                                onExit: (event) {
                                                                  // setState(() {
                                                                  //   infoOverlayEntry?.remove();
                                                                  //   infoOverlayEntry =null;
                                                                  // });
                                                                },
                                                                child: Icon(TablerIcons.home, size:23)),SizedBox(width: 4,),
                                                                //gmail
                                                                MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                onEnter: (event) async {
                                                                  
                                                                  if (infoOverlayEntry!=null) {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  }
                                                                  infoOverlayEntry = OverlayEntry(
                                                                    builder: (context) {
                                                                      return StatefulBuilder(builder: (context, updateState) {
                                                                        return Positioned(
                                                                          right:sWidth / 3 +mapValueDimensionBasedLockOnDesync(10, 40, sWidth, sHeight),
                                                                          top: topPadPosDistance + 50,
                                                                          child:infoOverlayPanel(
                                                                            'Gmail.',
                                                                            SvgPicture.asset(
                                                                              'assets/logos/gmail.svg',
                                                                              width: 40,
                                                                              height: 40,
                                                                            ),
                                                                            '''billblazex@gmail.com
                                                                            \njoelsanjay7@gmail.com''',
                                                                            '''
                                                                            \nReach me through mail. Queries or requests regarding billblaze
                                                                            \non billblazex@gmail.com. Other official or general things like
                                                                            \nasking for a date can be done on the other one.
                                                                            \nAnd it's a shame jepixo@gmail.com wasn't available 
                                                                            \nbut I do have jepixoo@gmail.com.'''
                                                                          ),
                                                                    );
                                                                    });
                                                                  },);
                                                                  
                                                                  setState(() {
                                                                    Overlay.of(context).insert(infoOverlayEntry!);
                                                                  });
                                                                },
                                                                onExit: (event) {
                                                                  setState(() {
                                                                    infoOverlayEntry?.remove();
                                                                    infoOverlayEntry =null;
                                                                  });
                                                                },
                                                                  child: SvgPicture.asset(
                                                                    'assets/logos/gmail.svg',
                                                                    width: 23,
                                                                    height: 23,
                                                                  ),
                                                                ),
                                                                SizedBox(width: 5,),
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom:6.0),
                                                                      child: Text(
                                                                          'Pass me around.',
                                                                            maxLines: 1,
                                                                            overflow:TextOverflow.ellipsis,
                                                                            textAlign: TextAlign.start,
                                                                            style: TextStyle( fontFamily: 'Lexend',
                                                                              fontSize: 18,
                                                                              height: 0.8,
                                                                              color: defaultPalette.extras[0],
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                    ),
                                                                    Iconify(Majesticons.share, size:28)
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          
                                                          ],
                                                        ),
                                                        ),
                                                    ),
                                                  ),
                                                  SizedBox(width: mapValueDimensionBasedLockOnDesync(5, 12, sWidth, sHeight),),
                                                ]
                                              ),
                                              ),
                                              

                                              SizedBox(height: mapValueDimensionBasedLockOnDesync(15, 50, sWidth, sHeight),),
                                              //TIPS AND TRICKS interfacee
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:BorderRadius.circular(35),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:defaultPalette.secondary,
                                                      borderRadius:BorderRadius.circular(35),
                                                      border: Border.all()
                                                    ),
                                                    child: Column(
                                                      children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(15, 50, sWidth, sHeight)),
                                                          decoration: BoxDecoration(
                                                            color:defaultPalette.primary,
                                                            border:Border.all(),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 2,
                                                                spreadRadius: 2,
                                                                offset: Offset(2, 2),
                                                                color: defaultPalette.black.withOpacity(0.1)
                                                              )
                                                            ],
                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(30, 60, sWidth, sHeight))
                                                          ),
                                                          child: ClipRRect(
                                                             borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(29, 59, sWidth, sHeight)),
                                                            child: InAppWebView(
                                                              initialUrlRequest: URLRequest(
                                                                  url: WebUri.uri(Uri.parse(ref
                                                                      .watch(homePageUrlProvider))),
                                                                  headers: {
                                                                    "User-Agent":
                                                                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
                                                                  },    
                                                                      ),
                                                              onWebViewCreated: (controller) async {
                                                                _controller2 = controller;
                                                            
                                                            print("WebView created");
                                                            },
                                                              onLoadStop: (controller, url) async {
                                                            print("Loaded: $url");
                                                            print("Loaded: ${homePageUrls.indexOf(ref.read(homePageUrlProvider))}");
                                                            try {
                                                              if(homePageUrls.indexOf(ref.read(homePageUrlProvider)) != 5
                                                              && homePageUrls.indexOf(ref.read(homePageUrlProvider)) != 6
                                                              && homePageUrls.indexOf(ref.read(homePageUrlProvider)) != 9
                                                              && homePageUrls.indexOf(ref.read(homePageUrlProvider)) != 0
                                                              && homePageUrls.indexOf(ref.read(homePageUrlProvider)) != -1
                                                              ) {
                                                                await controller.evaluateJavascript(
                                                                    source: """
                                                                    // Hide scrollbars visually but keep scroll functionality
                                                                    // document.documentElement.style.overflow = 'scroll';
                                                                    // document.body.style.overflow = 'scroll';
                                                                    
                                                                    // Apply zoom
                                                                    document.documentElement.style.zoom = '60%';
                                                                    
                                                                    // Hide scrollbars via CSS
                                                                    const style = document.createElement('style');
                                                                    style.innerHTML = `
                                                                      ::-webkit-scrollbar { 
                                                                        width: 0px; 
                                                                        background: transparent; 
                                                                      }
                                                                    `;
                                                                    document.head.appendChild(style);
                                                                  """
                                                                  );
                                                              } 
                                                              
                                                              
                                                            } on Exception catch (e,st) {
                                                              print('Nooo NOTION: '+st.toString());
                                                            }
                                                            },
                                                              // initialSettings: InAppWebViewSettings(
                                                              //     textZoom: 50,
                                                              //     horizontalScrollBarEnabled: false,
                                                              //     verticalScrollBarEnabled: false,
                                                              //     builtInZoomControls: true,
                                                              //     pageZoom: 10,
                                                              //     supportZoom: true,
                                                              //     displayZoomControls: true,
                                                              //     maximumZoomScale: 0.5),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                       Row(
                                                        children: [
                                                          SizedBox(width:  mapValueDimensionBasedLockOnDesync( 15, 25, sWidth, sHeight)),
                                                          ElevatedLayerButton(
                                                            onClick: () async {
                                                              ref.read(homePageUrlProvider.notifier).state = url(6);

                                                              await changeTvChannel(true);
                                                            },
                                                            
                                                            buttonHeight: mapValueDimensionBasedLockOnDesync( 30, 85, sWidth, sHeight),
                                                            buttonWidth:mapValueDimensionBasedLockOnDesync( 30, 85, sWidth, sHeight),
                                                            borderRadius: BorderRadius.circular( mapValueDimensionBasedLockOnDesync( 500, 800, sWidth, sHeight)),
                                                            animationDuration: const Duration(milliseconds: 200),
                                                            animationCurve: Curves.ease,
                                                            subfac: mapValueDimensionBasedLockOnDesync( 2, 4, sWidth, sHeight),
                                                            depth: mapValueDimensionBasedLockOnDesync( 2, 4, sWidth, sHeight),
                                                            topDecoration: BoxDecoration(
                                                              color: defaultPalette.tertiary,
                                                              border: Border.all(),
                                                            ),
                                                            topLayerChild:Container(
                                                                
                                                            child: Icon(
                                                              TablerIcons.vocabulary,
                                                              color: defaultPalette.primary,
                                                              size: mapValueDimensionBasedLockOnDesync( 15, 38, sWidth, sHeight), )),
                                                                                                            
                                                            baseDecoration: BoxDecoration(
                                                            color: defaultPalette.extras[0],
                                                            // border: Border.all(),
                                                              ),
                                                            ),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            child: FittedBox(
                                                              fit:BoxFit.scaleDown,
                                                              alignment: Alignment.centerLeft,
                                                              child: Text(homePageUrls.indexOf(ref.watch(homePageUrlProvider))==-1?'Documentation.':homePageUrltitles[homePageUrls.indexOf(ref.watch(homePageUrlProvider))],
                                                                maxLines:2,
                                                                overflow:TextOverflow.ellipsis,
                                                                style: TextStyle( fontFamily: 'Lexend',
                                                                fontSize: 20,
                                                                height: 0.8,
                                                                color: defaultPalette.extras[0],
                                                                fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 15),
                                                          Row(
                                                            children: [
                                                            ElevatedLayerButton(
                                                            onClick: () async {
                                                              final currentUrl = await _controller2?.getUrl()??WebUri.uri(Uri.parse(ref
                                                                      .watch(homePageUrlProvider))); // get current URL from WebViewController
                                                              final currentIndex = homePageUrls.indexOf(ref
                                                                      .watch(homePageUrlProvider));
                                                              print(currentIndex);
                                                              // If currentUrl not in the list, default to 0
                                                              final newIndex = currentIndex != -1
                                                              ? currentIndex == 0 
                                                                ? homePageUrls.length - 1 
                                                                : currentIndex - 1
                                                              : 0;

                                                              ref.read(homePageUrlProvider.notifier).state = homePageUrls[newIndex];

                                                              await changeTvChannel(true);
                                                            },
                                                            buttonHeight: mapValueDimensionBasedLockOnDesync( 35, 85, sWidth, sHeight),
                                                            buttonWidth:mapValueDimensionBasedLockOnDesync( 35, 85, sWidth, sHeight),
                                                            borderRadius: BorderRadius.circular( mapValueDimensionBasedLockOnDesync( 500, 800, sWidth, sHeight)),
                                                            animationDuration: const Duration(milliseconds: 200),
                                                            animationCurve: Curves.ease,
                                                            subfac: mapValueDimensionBasedLockOnDesync( 2, 4, sWidth, sHeight),
                                                            depth: mapValueDimensionBasedLockOnDesync( 2, 4, sWidth, sHeight),
                                                            topDecoration: BoxDecoration(
                                                              color: defaultPalette.extras[3],
                                                              border: Border.all(),
                                                            ),
                                                            topLayerChild: Container(
                                                            child: Icon(
                                                              TablerIcons.caret_left_filled,
                                                              color: defaultPalette.primary,
                                                              size: mapValueDimensionBasedLockOnDesync( 18, 38, sWidth, sHeight),
                                                                                                                        )),            
                                                            baseDecoration: BoxDecoration(
                                                            color: defaultPalette.extras[0],
                                                            // border: Border.all(),
                                                            ),
                                                          ),
                                                          SizedBox(width: 5),
                                                          ElevatedLayerButton(
                                                            onClick: () async {
                                                              final currentUrl = await _controller2?.getUrl()??WebUri.uri(Uri.parse(ref
                                                                      .watch(homePageUrlProvider))); // get current URL from WebViewController
                                                              final currentIndex = homePageUrls.indexOf(ref
                                                                      .watch(homePageUrlProvider));
                                                              // If currentUrl not in the list, default to 0
                                                              final newIndex = currentIndex != -1
                                                              ? currentIndex == homePageUrls.length - 1 
                                                                ? 0
                                                                : currentIndex + 1
                                                              : 0;

                                                              ref.read(homePageUrlProvider.notifier).state = homePageUrls[newIndex];

                                                              await changeTvChannel(true);
                                                            },
                                                            
                                                            buttonHeight: mapValueDimensionBasedLockOnDesync( 35, 85, sWidth, sHeight),
                                                            buttonWidth:mapValueDimensionBasedLockOnDesync( 35, 85, sWidth, sHeight),
                                                            borderRadius: BorderRadius.circular( mapValueDimensionBasedLockOnDesync( 500, 800, sWidth, sHeight)),
                                                            animationDuration: const Duration(milliseconds: 200),
                                                            animationCurve: Curves.ease,
                                                            subfac: mapValueDimensionBasedLockOnDesync( 2, 4, sWidth, sHeight),
                                                            depth: mapValueDimensionBasedLockOnDesync( 2, 4, sWidth, sHeight),
                                                            topDecoration: BoxDecoration(
                                                              color: defaultPalette.extras[3],
                                                              border: Border.all(),
                                                            ),
                                                            topLayerChild:Container(
                                                                
                                                            child: Icon(
                                                              TablerIcons.caret_right_filled,
                                                              color: defaultPalette.primary,
                                                              size: mapValueDimensionBasedLockOnDesync( 18, 38, sWidth, sHeight),
                                                                                                                        )),
                                                                                                            
                                                            baseDecoration: BoxDecoration(
                                                            color: defaultPalette.extras[0],
                                                            // border: Border.all(),
                                                              ),
                                                            ),
                                                          
                                                          ],),
                                                          SizedBox(width:  mapValueDimensionBasedLockOnDesync( 15, 25, sWidth, sHeight)),
                                                          ],
                                                        ),
                                                        SizedBox(height:  mapValueDimensionBasedLockOnDesync( 15, 25, sWidth, sHeight)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height:mapValueDimensionBasedLockOnDesync(5, 20, sWidth, sHeight)),
                                            ],
                                          ),
                                        )),
                                      //RECENTSS CARDD
                                      if(index==0)
                                      Positioned.fill(
                                        child: //the layout tiles
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(40),
                                            child: Column(
                                              children: [
                                                //RECENTSS TITLE
                                                Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15+8.0).copyWith(bottom: 0),
                                                      child: Text('RECENT'.toUpperCase(),
                                                          textAlign: TextAlign.left,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(                                fontFamily: 'PressStart2P',
                                                            color: defaultPalette.extras[0],
                                                            fontSize: mapValueDimensionBasedLockOnDesync(25, 45, sWidth, sHeight),
                                                            letterSpacing: -2,
                                                            fontWeight: FontWeight.w600,
                                                            height: 1.2)),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 0,
                                              ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffc0c0c0).withOpacity(0.5),
                                                      // color:defaultPalette.primary,
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    margin: EdgeInsets.all(15+mapValueDimensionBasedLockOnDesync(1, 10, sWidth, sHeight)),
                                                    child: ScrollConfiguration(
                                                      behavior:
                                                          ScrollBehavior().copyWith(scrollbars: false),
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
                                                                  margin: EdgeInsets.only(
                                                                      right: 3, top: 8, bottom: 8),
                                                                  decoration: BoxDecoration(
                                                                      color: defaultPalette.primary,
                                                                      border: Border.all(),
                                                                      borderRadius:
                                                                          BorderRadius.circular(15)),
                                                                  width: 6,
                                                                );
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(30),
                                                                child: ListView.builder(
                                                                  padding: EdgeInsets.only(right: 0,top: 0),
                                                                  controller: controller,
                                                                  physics: physics,
                                                                  // itemCount: layouts.length+1,
                                                                  itemCount:Boxes.getLayouts(ref).values.toList().length + 1,
                                                                  itemBuilder:(BuildContext context, int i) {
                                                                    final layouts = Boxes.getLayouts(ref).values.toList();
                                                                    layouts.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
                                                                                                
                                                                    
                                                                    if (i == layouts.length) {
                                                                      return const SizedBox(height: 5);
                                                                    }
                                                                                                        
                                                                    final layoutModel = layouts[i];
                                                                    if ( (layoutModel.deleted??false)) {
                                                                      return const SizedBox.shrink();
                                                                    }

                                                                    return Material(
                                                                        color: defaultPalette.transparent,
                                                                        child: InkWell(
                                                                          hoverColor: defaultPalette.extras[0].withOpacity(0.4),
                                                                          highlightColor: defaultPalette.extras[0].withOpacity(0.4),
                                                                          splashColor: defaultPalette
                                                                              .extras[0]
                                                                              .withOpacity(0.4),
                                                                          onTap: () {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(
                                                                              builder: (context) {
                                                                                // _timer?.cancel();
                                                                                return PopScope(
                                                                                  canPop: false,
                                                                                  child: LayoutDesigner(
                                                                                    id: layoutModel.id,
                                                                                    // layoutModel: layoutModel,
                                                                                    onPop: (pdf) {
                                                                                      setState(() {
                                                                                        filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ));
                                                                          },
                                                                          child: Container(
                                                                            height: mapValueDimensionBasedLockOnDesync(75, 170, sWidth, sHeight),
                                                                            width: 30,
                                                                            margin: EdgeInsets.only(
                                                                                bottom: 10, 
                                                                                right: 8, 
                                                                                top: mapValueDimensionBasedLockOnDesync(0+(i==0?8:1), 15, sWidth, sHeight),
                                                                                left:mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                                            color: defaultPalette
                                                                                .transparent,
                                                                            child: Row(
                                                                              children: [
                                                                                
                                                                                //layoutname and created modified
                                                                                Expanded(
                                                                                  child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    //layoutname
                                                                                      Expanded(
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.only(left: 8.0, top: 5),
                                                                                          child: Tooltip(
                                                                                            message:
                                                                                            layoutModel.name,
                                                                                            textStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                                              fontSize: mapValueDimensionBasedLockOnDesync(15,20, sWidth, sHeight),
                                                                                              color:defaultPalette.primary,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              letterSpacing:-0.2,
                                                                                            ),
                                                                                            decoration: BoxDecoration(
                                                                                                color: defaultPalette.extras[0].withOpacity( 0.8),
                                                                                                borderRadius: BorderRadius.circular( 50)),
                                                                                            child: Text(
                                                                                              layoutModel.name,
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              textAlign: TextAlign.end,
                                                                                              style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                fontSize: mapValueDimensionBasedLockOnDesync(15, 35, sWidth, sHeight),
                                                                                                color: defaultPalette.extras[0],
                                                                                                fontWeight: FontWeight.w600,
                                                                                                letterSpacing: -0.2,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    //created modified and pages
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        // color:  defaultPalette.primary,
                                                                                        borderRadius: BorderRadius.circular(12),
                                                                                        // border: Border.all()
                                                                                      ),
                                                                                      padding: EdgeInsets.all( 3  ).copyWith(left: 8),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          SingleChildScrollView(
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            child: RichText(
                                                                                              textAlign: TextAlign.start,
                                                                                              maxLines: 1,
                                                                                              // overflow: TextOverflow.ellipsis,
                                                                                              text: TextSpan(
                                                                                                style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                  fontSize: mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight),
                                                                                                  fontWeight: FontWeight.w300,
                                                                                                  letterSpacing: -0.2,
                                                                                                ),
                                                                                                children: [
                                                                                                  TextSpan(
                                                                                                    text: 'Created: ',
                                                                                                    style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                        color: defaultPalette.extras[0]),
                                                                                                  ),
                                                                                                  TextSpan(
                                                                                                    text: DateFormat("MMM d, y 'at' h:mm a")
                                                                                                        .format(layoutModel.createdAt),
                                                                                                    style:
                                                                                                        TextStyle(color: defaultPalette.extras[0]),
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
                                                                                                style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                  fontSize: mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight),
                                                                                                  fontWeight: FontWeight.w300,
                                                                                                  letterSpacing: -0.2,
                                                                                                ),
                                                                                                children: [
                                                                                                  TextSpan(
                                                                                                    text: 'Modified: ',
                                                                                                    style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                      color: defaultPalette.extras[0],
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                  ),
                                                                                                  TextSpan(
                                                                                                    text: DateFormat("MMM d, y 'at' h:mm a")
                                                                                                        .format(layoutModel.modifiedAt),
                                                                                                    style:
                                                                                                        TextStyle(color: defaultPalette.extras[0]),
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
                                                                                              style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                fontSize: mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight),
                                                                                                fontWeight: FontWeight.w300,
                                                                                                letterSpacing: -0.2,
                                                                                              ),
                                                                                              children: [
                                                                                                TextSpan(
                                                                                                  text:
                                                                                                      '${SheetType.values[layoutModel.type].name} · ',
                                                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                    fontSize: mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight),
                                                                                                    color: defaultPalette.extras[0],
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    letterSpacing: -0.2,
                                                                                                  ),
                                                                                                ),
                                                                                                TextSpan(
                                                                                                  text:
                                                                                                      'Pages: ${layoutModel.spreadSheetList.isEmpty ? '1' : layoutModel.spreadSheetList.length.toString()}',
                                                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                                                    fontSize: mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight),
                                                                                                    color: defaultPalette.extras[0],
                                                                                                    fontWeight: FontWeight.w400,
                                                                                                    letterSpacing: -0.2,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                ),
                                                                                SizedBox(width: 5),
                                                                                //mini layout pdf pages swiper
                                                                                SizedBox(
                                                                                  height: mapValueDimensionBasedLockOnDesync(75, 170, sWidth, sHeight),
                                                                                  width: mapValueDimensionBasedLockOnDesync(58, 125, sWidth, sHeight),
                                                                                  child: AppinioSwiper(
                                                                                    cardCount: (layoutModel.spreadSheetList.length.isNaN || layoutModel.docPropsList.isEmpty)
                                                                                        ? 1
                                                                                        : layoutModel.docPropsList.length,
                                                                                    backgroundCardCount: 5,
                                                                                    backgroundCardOffset: Offset( 0.8, 0.8),
                                                                                    duration: Duration( milliseconds: 220),
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
                                                                                              margin: EdgeInsets.only(
                                                                                                  left: 8,
                                                                                                  top: 8,
                                                                                                  bottom: 2),
                                                                                              decoration: BoxDecoration(
                                                                                                color: defaultPalette.primary,
                                                                                                border: Border.all(
                                                                                                    width: 1.2,
                                                                                                    color: defaultPalette.extras[0],
                                                                                                    strokeAlign: BorderSide.strokeAlignOutside),
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                image:( layoutModel.pdf == null || layoutModel.pdf!.isEmpty)
                                                                                                  ? null
                                                                                                  : DecorationImage(
                                                                                                      image: MemoryImage(
                                                                                                        layoutModel.pdf![indx],
                                                                                                      ),
                                                                                                      fit: BoxFit.fitWidth),
                                                                                              ),
                                                                                              // foregroundDecoration: BoxDecoration(
                                                                                              //   border: Border.all(width: 2, color:defaultPalette.extras[0]),
                                                                                              //   borderRadius: BorderRadius.circular(10),
                                                                                              // ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    
                                                                  },
                                                                ), 
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                                    
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        
                        
                      ],
                    ),
                  ),
                ),

              //SideNavbar
              Positioned(
                // duration: defaultDuration,
                top: 0,
                left: 100,
                height: 100,
                width: sHeight,
                child: Consumer(builder: (context, ref, c) {
                  return Transform.rotate(
                    angle: pi / 2,
                    alignment: Alignment.topLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: MouseRegion(
                        onEnter: (event) => keyboardFocusNode.requestFocus(),
                        onExit: (event) => keyboardFocusNode.unfocus(),
                        child: Focus(
                          // focusNode: keyboardFocusNode,
                          // onKeyEvent: (node, event) {
                          //   if (event is KeyDownEvent) {
                          //   if (event.logicalKey == LogicalKeyboardKey.digit1) {
                          //     ref.read(homeScreenTabIndexProvider.notifier).state =0;
                          //     tabSwitchOnTap(0, ref);
                          //     return KeyEventResult.handled;
                          //   }
                          //   if (event.logicalKey == LogicalKeyboardKey.digit2) {
                          //     ref.read(homeScreenTabIndexProvider.notifier).state =1;
                          //     tabSwitchOnTap(1, ref);
                          //     return KeyEventResult.handled;
                          //   }
                          //   if (event.logicalKey == LogicalKeyboardKey.digit3) {
                          //     ref.read(homeScreenTabIndexProvider.notifier).state =2;
                          //     tabSwitchOnTap(2, ref);
                          //     return KeyEventResult.handled;
                          //   }if (event.logicalKey == LogicalKeyboardKey.digit4) {
                          //     ref.read(homeScreenTabIndexProvider.notifier).state =3;
                          //     tabSwitchOnTap(3, ref);
                          //     return KeyEventResult.handled;
                          //   }
                          // }
                          //   return KeyEventResult.handled;
                          // },
                          child: CurvedNavigationBar(
                            disp: 50,
                            bgHeight: 50,
                            index: homeScreenTabIndex,
                            radius: 0,
                            width: sHeight,
                            s: mapValue(
                                value: sHeight,
                                inMin: 480,
                                inMax: 1190,
                                outMin: 0.2,
                                outMax: 0.1),
                            bottom: 0.7,
                            height: 70,
                            animationDuration: Duration(milliseconds: 300),
                            buttonBackgroundColor: defaultPalette.primary,
                            buttonBaseDecorationColor:
                            isHomeTab
                            ? defaultPalette.tertiary
                            : isLayoutTab
                              ? defaultPalette.extras[0]
                              : isBillTab
                                ? defaultPalette.extras[0]
                                : defaultPalette.extras[0],
                            buttonIconColor: defaultPalette.extras[0],
                            backgroundColor: Colors.transparent,
                            color: defaultPalette.extras[0],
                            items: [
                              Tooltip(
                                message: "Home",
                                preferBelow: true,
                                margin: EdgeInsets.only(left: 45),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                                textStyle: TextStyle(                                fontFamily: 'Lexend',
                                  fontSize: mapValueDimensionBased( 15, 20, sWidth, sHeight),
                                  color: defaultPalette.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                                decoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 2,color: defaultPalette.primary,),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      color: defaultPalette.black.withOpacity(0.2)
                                    )
                                  ]
                                ),
                                // verticalOffset: -16,
                                child: Icon(
                                  IconsaxPlusLinear.home_2,
                                  size: 25,
                                  color: defaultPalette.primary,
                                ),
                              ),
                              Tooltip(
                                message: "Layouts",
                                preferBelow: true,
                                margin: EdgeInsets.only(left: 45),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                                textStyle: TextStyle(                                fontFamily: 'Lexend',
                                  fontSize: mapValueDimensionBased( 15, 20, sWidth, sHeight),
                                  color: defaultPalette.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                                decoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 2,color: defaultPalette.primary,),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      color: defaultPalette.black.withOpacity(0.2)
                                    )
                                  ]
                                ),
                                // verticalOffset: -18,
                                child: Icon(
                                  IconsaxPlusLinear.receipt_1,
                                  size: 25,
                                  color: defaultPalette.primary,
                                ),
                              ),
                              Tooltip(
                                message: "Bills",
                                preferBelow: true,
                                margin: EdgeInsets.only(left: 45),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                                textStyle: TextStyle(                                fontFamily: 'Lexend',
                                  fontSize: mapValueDimensionBased( 15, 20, sWidth, sHeight),
                                  color: defaultPalette.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                                decoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 2,color: defaultPalette.primary,),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      color: defaultPalette.black.withOpacity(0.2)
                                    )
                                  ]
                                ),
                                // verticalOffset: -20,
                                child: Icon(
                                  IconsaxPlusLinear.direct,
                                  size: 25,
                                  color: defaultPalette.primary,
                                ),
                              ),
                              Tooltip(
                                message: "About",
                                preferBelow: true,
                                margin: EdgeInsets.only(left: 45),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                                textStyle: TextStyle(                                fontFamily: 'Lexend',
                                  fontSize: mapValueDimensionBased( 15, 20, sWidth, sHeight),
                                  color: defaultPalette.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                                decoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 2,color: defaultPalette.primary,),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      color: defaultPalette.black.withOpacity(0.2)
                                    )
                                  ]
                                ),
                                // verticalOffset: -20,
                                child: Icon(
                                  IconsaxPlusLinear.information,
                                  size: 25,
                                  color: defaultPalette.primary,
                                ),
                              ),
                            ],
                            onTap: (index) {
                              // Handle button tap
                              ref.read(homeScreenTabIndexProvider.notifier).update((state) => state = index);
                          
                              // print(ref.read(currentTabIndexProvider));
                              tabSwitchOnTap(index, ref);
                              if (index !=0) {
                                _updateGraphLineSpeed((10).round());
                              } else {
                                _updateGraphLineSpeed((300));
                              }
                              
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Windows top bar
              if (!kIsWeb && Platform.isWindows)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (details) {
                    appWindow.startDragging();
                  },
                  onDoubleTap: () {
                    appWindow.maximizeOrRestore();
                  },
                  child: SizedBox(
                    height: 50,
                    child: Consumer(builder: (context, ref, c) {
                      return Stack(
                        children: [
                          AnimatedPositioned(
                            right: 0,
                            top:  0,
                            duration: Durations.short4,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: AnimatedContainer(
                                duration: Durations.short4,
                                padding:
                                    const EdgeInsets.only(right: 9, bottom: 0),
                                margin: const EdgeInsets.only(top: 8),
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
                                        Future.delayed(Duration.zero).then((y) {
                                          appWindow.minimize();
                                        });
                                      },
                                      buttonHeight: 28,
                                      buttonWidth: 28,
                                      borderRadius: BorderRadius.circular(8),
                                      animationDuration:
                                          const Duration(milliseconds: 10),
                                      animationCurve: Curves.ease,
                                      topDecoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                      ),
                                      topLayerChild: const Icon(
                                        TablerIcons.rectangle_filled,
                                        size: 14,
                                        color: Colors.blue,
                                      ),
                                      baseDecoration: BoxDecoration(
                                        color: defaultPalette.extras[0],
                                        border: Border.all(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    //
                                    //maximize button
                                    ElevatedLayerButton(
                                      // isTapped: false,
                                      // toggleOnTap: true,
                                      depth: 2.5, subfac: 2.5,
                                      onClick: () {
                                        Future.delayed(Durations.short1)
                                            .then((y) {
                                          appWindow.maximizeOrRestore();
                                        });
                                      },
                                      buttonHeight: 28,
                                      buttonWidth: 28,
                                      borderRadius: BorderRadius.circular(8),
                                      animationDuration:
                                          const Duration(milliseconds: 1),
                                      animationCurve: Curves.ease,
                                      topDecoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                      ),
                                      topLayerChild: const Icon(
                                        TablerIcons.triangle_filled,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      baseDecoration: BoxDecoration(
                                        color: defaultPalette.extras[0],
                                        border: Border.all(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    //close button
                                    ElevatedLayerButton(
                                      // isTapped: false,
                                      // toggleOnTap: true,
                                      depth: 2.5, subfac: 2.5,
                                      onClick: () {
                                        Future.delayed(Duration.zero).then((y) {
                                          appWindow.close();
                                        });
                                      },
                                      buttonHeight: 28,
                                      buttonWidth: 28,
                                      borderRadius: BorderRadius.circular(8),
                                      animationDuration:
                                          const Duration(milliseconds: 1),
                                      animationCurve: Curves.ease,
                                      topDecoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                      ),
                                      topLayerChild:Icon(
                                        TablerIcons.circle_filled,
                                        size: 15,
                                        color: defaultPalette.extras[4],
                                      ),
                                      baseDecoration: BoxDecoration(
                                        color: defaultPalette.extras[0],
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
        )
        // ;})
    );
  }

  List<Widget> pagePropertyTile(int s, double sWidth, double sHeight) {
    
  return [
    MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onHorizontalDragCancel: () {
            fontFocusNodes[s].requestFocus();
        },
        onHorizontalDragUpdate: (details) {
          var multiplier = HardwareKeyboard.instance.isControlPressed
              ? pageUnit==1?100:10
              : HardwareKeyboard.instance.isShiftPressed
                  ?pageUnit==1?0.5: 0.1
                  :pageUnit==1?1: 1;
          setState(() {
            double currentValue =
                double.tryParse(pageFormatControllers[s].text) ??
                    0.0;
            double newValue = (currentValue + details.delta.dx * multiplier)
                .clamp(0.1, double.infinity);

            double parsedValue = double.parse(newValue.toStringAsFixed(4));
            switch (s) {
              case 0:
                tempLayoutModel.docPropsList[0].pageFormatController = {
                  'width': parsedValue/pageUnit, 
                  'height': tempLayoutModel.docPropsList[0].pageFormatController['height']??0};
                pageFormatControllers[0].text = parsedValue.toString();
                break;
              case 1:
                tempLayoutModel.docPropsList[0].pageFormatController = {
                  'width': tempLayoutModel.docPropsList[0].pageFormatController['width']??0, 
                  'height': parsedValue/pageUnit};
                pageFormatControllers[1].text = parsedValue.toString();
                break;
              case 2:
                layoutPageCount = parsedValue.clamp(1, double.infinity).round();
                pageFormatControllers[2].text = parsedValue.clamp(1, double.infinity).round().toString();
                break;   
              default:
            }
            
          });
        },
        child: Row(
          children: [
            Icon(
              s == 0 
              ? TablerIcons.ruler_measure
              : s==1
              ? TablerIcons.ruler_measure_2
              : s==2
              ? TablerIcons.file
              : TablerIcons.spacing_vertical,
              size: mapValueDimensionBasedLockOnDesync(15, 28, sWidth, sHeight),
              color: defaultPalette.extras[0]
            ),
            Text(
              s == 0 
              ? ' width ' 
              : s==1
              ? ' height '
              : s==2
              ? ' pages: '
              : ' line ',
              style: TextStyle(                                fontFamily: 'Lexend',
                  fontSize: mapValueDimensionBasedLockOnDesync(13, 26, sWidth, sHeight),
                  letterSpacing: -1,
                  fontWeight: FontWeight.w600,
                  color: defaultPalette.extras[0]),
            ),
          ],
        ),
      ),
    ),
    Expanded(
      flex: 10,
      child: SizedBox(
        height: mapValueDimensionBasedLockOnDesync(12, 24, sWidth, sHeight),
        child: TextFormField(
          onTapOutside: (event) => fontFocusNodes[s].unfocus(),
          focusNode: fontFocusNodes[s],
          controller: pageFormatControllers[s],
          inputFormatters: [
            NumericInputFormatter(allowNegative: true),
          ],
          cursorColor: defaultPalette.tertiary,
          selectionControls: NoMenuTextSelectionControls(),
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0),
            labelStyle: TextStyle(                                fontFamily: 'Lexend',color: defaultPalette.black),
            fillColor: defaultPalette.transparent,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
          style: GoogleFonts.mitr(
              fontSize: mapValueDimensionBasedLockOnDesync(12, 25, sWidth, sHeight),
              color: defaultPalette.extras[0],
              fontWeight: FontWeight.w400,
              letterSpacing: -1),
          onFieldSubmitted: (value) {
            setState(() {
           print(value);
            var parsedValue = (double.tryParse(value)??0.0)/pageUnit;
            switch (s) {
              case 0:
                tempLayoutModel.docPropsList[0].pageFormatController = {
                  'width': parsedValue, 
                  'height': tempLayoutModel.docPropsList[0].pageFormatController['height']??0};
                pageFormatControllers[s].text = parsedValue.toString();
                break;
              case 1:
                tempLayoutModel.docPropsList[0].pageFormatController = {
                  'width': tempLayoutModel.docPropsList[0].pageFormatController['width']??0, 
                  'height': parsedValue};
                pageFormatControllers[s].text = parsedValue.toString();
                break;   
              case 2:
                layoutPageCount = parsedValue.clamp(1, double.infinity).round();
                pageFormatControllers[s].text = parsedValue.clamp(1, double.infinity).round().toString();
              default:
            }
              

            });
          },
        ),
      ),
    ),
    if(s!=2)
    ...[SizedBox(
      width: 4,
    ),
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            switch (pageUnit) {
              case 1:
                pageUnit = 1/72;
                break;
              case const (1/72):
                pageUnit = 0.03528;
                break;
              case 0.03528:
              pageUnit =  1;
                break;
                
              default:
            }
            reassignPageFormatControllers();
          });
        },
        child: Text(
          pageUnit ==1
        ? 'pt'
        : pageUnit == 1 / 72
        ? 'in'
        : pageUnit == 0.03528
        ? 'cm'
        : '',
        style:TextStyle(                                fontFamily: 'Lexend',
          fontSize:mapValueDimensionBasedLockOnDesync(12, 25, sWidth, sHeight),
          fontWeight: FontWeight.w600,
          letterSpacing:-1,
        )
        ),
      ),
    ),
    ],SizedBox(
      width: 2,
    ),
  ];
  }
  String getPageFormatString(PdfPageFormat format) {
    if (format == PdfPageFormat.a4) return 'A4';
    if (format == PdfPageFormat.a3) return 'A3';
    if (format == PdfPageFormat.letter) return 'Lt';
    if (format == PdfPageFormat.legal) return 'Lg';
    if (format == PdfPageFormat.roll57) return 'Roll 57';
    if (format == PdfPageFormat.roll80) return 'Roll 80';
    if (format == PdfPageFormat.a5) return 'A5';
    if (format == PdfPageFormat.a6) return 'A6';
    if (format == PdfPageFormat.standard) return 'Standard';
    return 'cs';
  }
  PdfPageFormat getPageFormatFromString(String format) {
    switch (format) {
      case 'A4':
        return PdfPageFormat.a4;
      case 'A3':
        return PdfPageFormat.a3;
      case 'A5':
        return PdfPageFormat.a5;
      case 'A6':
        return PdfPageFormat.a6;
      case 'Letter':
        return PdfPageFormat.letter;
      case 'Legal':
        return PdfPageFormat.legal;
      case 'Standard':
        return PdfPageFormat.standard;
      case 'Roll 57':
        return PdfPageFormat.roll57;
      case 'Roll 80':
        return PdfPageFormat.roll80;
      default:
        return PdfPageFormat.a4;
    }
  }
  PdfPageFormat getPageFormatFromMap(Map<String, dynamic> format) {
    return PdfPageFormat(
      double.parse(format['width'].toString()),
      double.parse(format['height'].toString()),
    );
  }
  Map<String, double> getMapFromPageFormat(PdfPageFormat format) {
    return {
      'width': format.width,
      'height': format.height,
    };
  }
  void reassignPageFormatControllers(){
    pageFormatControllers[0].text = (getPageFormatFromMap(tempLayoutModel.docPropsList[0].pageFormatController).width * pageUnit)
    .toStringAsFixed(2);
    pageFormatControllers[1].text = (getPageFormatFromMap(tempLayoutModel.docPropsList[0].pageFormatController).height * pageUnit)
    .toStringAsFixed(2);
  }
  void showOpsFormatMenu(BuildContext context, Offset position, double sWidth, double sHeight) {
  final entries = buildOpsFormatContextMenuEntries(sWidth, sHeight);
  var menu = cm.ContextMenu(
    entries: entries,
    boxDecoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: defaultPalette.black.withOpacity(0.3),
          blurRadius: 2,
        )
      ],
      color: defaultPalette.extras[0],
      borderRadius: BorderRadius.circular(10),
    ),
    position: position,
  );
  menu.show(context);
}
  List<cm.ContextMenuEntry> buildOpsFormatContextMenuEntries(double sWidth, double sHeight) {
    final formats = ['A3', 'A4', 'A5', 'A6', 'Letter', 'Legal'];

    return formats.map((s) {
      return cm.MenuItem(
        label: s.replaceAll('Letter', 'LT').replaceAll('Legal', 'LG'),
        onSelected: () {
          setState(() {
            tempLayoutModel.docPropsList[0].pageFormatController = getMapFromPageFormat(getPageFormatFromString(s));
            print(tempLayoutModel.docPropsList[0].pageFormatController);
            reassignPageFormatControllers();
          });
        },
        hoverColor: defaultPalette.primary.withOpacity(0.02),
        unfocusedColor: defaultPalette.primary.withOpacity(0.2),
        style: TextStyle(                                fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
          color: defaultPalette.primary,
          fontSize: mapValueDimensionBasedLockOnDesync(12, 24, sWidth, sHeight),
        ),
      );
    }).toList();
  }
  void showLegalsMenu(BuildContext context, Offset position, double sWidth, double sHeight) {
  final entries = buildLegalsContextMenuEntries(sWidth, sHeight);
  var menu = cm.ContextMenu(
    entries: entries,
    boxDecoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: defaultPalette.black.withOpacity(0.3),
          blurRadius: 2,
        )
      ],
      color: defaultPalette.primary,
      borderRadius: BorderRadius.circular(10),
    ),
    position: position,
  );
  menu.show(context);
}
  
  List<cm.ContextMenuEntry> buildLegalsContextMenuEntries(double sWidth, double sHeight) {
    final formats = ['Terms Of Service', 'Privacy Policy', 'EULA','Licenses'];

    return formats.map((s) {
      return cm.MenuItem(
        label: s,
        onSelected: () async {
          switch (s) {
            case 'Terms Of Service':
              ref.read(loginPageUrlProvider.notifier).state = termsOfServiceUrl;
              await changeTvChannel();
              break;
            case 'Privacy Policy':
              ref.read(loginPageUrlProvider.notifier).state = privacyPolicyUrl;
              await changeTvChannel();
              break;
            case 'EULA':
              ref.read(loginPageUrlProvider.notifier).state = eulaUrl;
              await changeTvChannel();
              break;
            case 'Licenses':
              final licenses = await rootBundle.loadString('assets/oss_licenses.dart');
              final html = """
                <!DOCTYPE html>
                <html>
                  <head>
                    <meta charset="utf-8">
                    <style>
                      body {
                        font-family: monospace;
                        white-space: pre-wrap;
                        padding: 16px;
                        margin: 0;
                        background: #fafafa;
                        color: #222;
                      }
                      h2 {
                        text-align: center;
                      }
                    </style>
                  </head>
                  <body>
                    <h2>Licenses</h2>
                    <div>$licenses</div>
                  </body>
                </html>
                """;

                ref.read(loginPageUrlProvider.notifier).state = Uri.dataFromString(
                  html,
                  mimeType: 'text/html',
                  encoding: Encoding.getByName('utf-8'),
                ).toString();
                await changeTvChannel();
              break;
            default:
          }
        },
        hoverColor: defaultPalette.extras[0].withOpacity(0.02),
        unfocusedColor: defaultPalette.extras[0].withOpacity(0.2),
        style: TextStyle(                                fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
          color: defaultPalette.extras[0],
          fontSize: mapValueDimensionBasedLockOnDesync(12, 24, sWidth, sHeight),
        ),
      );
    }).toList();
  }
  Size getScaledPageSize(
    double sWidth,
    double sHeight,
    Map<String, dynamic> pageFormatController,
    bool isPortrait,
  ) {
    final double originalWidth = pageFormatController['width'];
    final double originalHeight = pageFormatController['height'];

    // max box the page should fit in
    final double maxWidth = (((sWidth / 2.15) - 70) * (55 / 75)) / 4;
    final double maxHeight = (sHeight / 2) / 3;

    // scale factor that keeps aspect ratio
    final double scale = (maxWidth / originalWidth < maxHeight / originalHeight)
        ? maxWidth / originalWidth
        : maxHeight / originalHeight;

    double newWidth = originalWidth * scale;
    double newHeight = originalHeight * scale;

    // If landscape, swap width and height
    if (!isPortrait) {
      final temp = newWidth;
      newWidth = newHeight;
      newHeight = temp;
    }

    return Size(newWidth, newHeight);
  }
  Future<void> changeTvChannel([bool isHome = false]) async {
    var controller = isHome? _controller2:_controller;
    var url = isHome? ref.read(homePageUrlProvider):ref.read(loginPageUrlProvider);
    if (controller != null && url.isNotEmpty) {
      // startWhiteNoise();
      if (!isHome) {
        final htmlString = await rootBundle.loadString('assets/static.html');
        
        await (controller!.loadData(data: htmlString, mimeType: 'text/html', encoding: 'utf8'));
        
        await Future.delayed(
            const Duration(
                milliseconds: 100));
        startWhiteNoise();
        await Future.delayed( const Duration( milliseconds: 400));
      }
      controller!.loadUrl(
        urlRequest: URLRequest(
            url: WebUri.uri(Uri
                .parse(url))),
      );
      await Future.delayed( const Duration( milliseconds: 100));
      stopWhiteNoise();
    }
    setState(() {});
  }
  Widget infoOverlayPanel(String heading, Widget img, String subheading, String body, [String body2='']){
    return  GestureDetector(
      onTap:(){
        if (infoOverlayEntry != null) {
          setState(() {
            infoOverlayEntry?.remove();
            infoOverlayEntry = null;
          });
        }
      },
      child: Container(
        padding:EdgeInsets.all(12),
        decoration: BoxDecoration(
        color: defaultPalette.primary.withOpacity(1),
        boxShadow: [
          BoxShadow(blurRadius: 15,spreadRadius: 2,color: defaultPalette.extras[0].withOpacity(0.2))
        ],
        border: Border.all(),
        borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                img,
                SizedBox(width: 10,),
                Text(
                  heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 25,
                    color: defaultPalette.extras[0],
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none, 
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(subheading,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                    fontFamily: 'Lexend',
              fontSize: 18,
              height: 0.8,
              color: defaultPalette.extras[0],
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none, 
              ),
            ),
            SizedBox(height: 5,),
            Text(body,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle( fontFamily: 'Lexend',
              fontSize: 15,
              height: 0.8,
              color: defaultPalette.extras[0],
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none, 
              ),
            ),
            Text(body2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle( fontFamily: 'Lexend',
              fontSize: 8,
              height: 0.8,
              color: defaultPalette.extras[0],
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none, 
              ),
            ),
            SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }

  Future<void> saveFile(LayoutModel newLayout) async {
    final payload = newLayout.toJson();
    final content = payload is String ? payload : jsonEncode(payload);

    // Get folder path from provider
    String safeName = newLayout.name.trim();
    if (!safeName.endsWith('.bbc')) {
      safeName='$safeName.bbc';
      newLayout.name = safeName;
      newLayout.save();
    }
    final filePath = '$dir\\$safeName';

    try {
      final file = File(filePath);

      if (await file.exists()) {
        // ✅ Update existing
        await file.writeAsString(content, encoding: utf8, flush: true);
     print("Updated existing layout: $filePath");
      } else {
        // ✅ Create new
        await file.create(recursive: true);
        await file.writeAsString(content, encoding: utf8, flush: true);
     print("Created new layout: $filePath");
      }
    } catch (e, st) {
   print("Error writing file: $e");
   print(st);
    }
  }

  Future<void> forceDelete(String path) async {
    final result = await Process.run(
      'powershell',
      ['Remove-Item', '-Force', path],
    );
    print(result.stdout);
    print(result.stderr);
  }

  //Windows/web
  Widget _getLayoutAndTemplates(
      BuildContext context, WidgetRef ref, double topPadPosDistance) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    int homeScreenTabIndex = ref.watch(homeScreenTabIndexProvider);
    String processMessage = ref.watch(processMessageProvider);
    bool isHomeTab = homeScreenTabIndex == 0;
    bool isLayoutTab = homeScreenTabIndex == 1;
    double dotSize = sHeight / 50;
    // print(sWidth);
    return AnimatedPositioned(
      duration: Durations.short2,
      // top: (topPadPosDistance * 1.08),
      height: sHeight,
      child: IgnorePointer(
        ignoring: !isLayoutTab,
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
                  child: GraphWindow(sWidth: sWidth, sHeight: sHeight, s: 0),
                ),
              ),

              AnimatedPositioned(
                  duration: Durations.medium2,
                  height: (sHeight / 2),
                  width: (sWidth / 2.15) - 70,
                  // bottom: isLayoutTab
                  //     ? mapValueDimensionBased(
                  //             -70,
                  //             -110 -
                  //                 (mapValueDimensionBased(
                  //                     0, 15, sWidth, sHeight,
                  //                     useWidth: true)),
                  //             sWidth,
                  //             sHeight,
                  //             b: false) -
                  //         5
                  //     : sHeight,
                  bottom: isLayoutTab?mapValueDimensionBased(
                              20,
                              45 - (mapValueDimensionBased( 0, 1, sWidth, sHeight, useWidth: true)),
                              sWidth,
                              sHeight,
                              b: false):sHeight,
                  left: (sWidth / 20).clamp(90, double.infinity) + 5,
                  child: AnimatedContainer(
                    duration: Durations.extralong1,
                    curve: Curves.bounceOut,
                    transform: Matrix4.identity()
                      // Translate
                      ..translate(
                        isLayoutTab ? 0.0 : 50.0,
                        isLayoutTab ? 0.0 : -30.0,
                      )
                      // Rotate (in radians)
                      ..rotateZ(isLayoutTab ? 0 : 0.7)
                      ..rotateX(isLayoutTab ? 0 : 0.8)
                      // Scale
                      ..scale(isLayoutTab ? 1.0 : 1.3, isLayoutTab ? 1.0 : 0.6)
                      // Skew-like effect
                      ..setEntry(0, 1, isLayoutTab ? 0 : 1)
                      ..setEntry(1, 0, isLayoutTab ? 0 : -0.4),
                    decoration: BoxDecoration(
                        color:
                            // Color(0xffc0c0c0),
                            defaultPalette.extras[0],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all()),
                  )),
              //  presettings Panel + addLaYOUT+addBILL+cloudBUTTONS
              AnimatedPositioned(
                duration: Durations.medium2,
                height: (sHeight / 2),
                width: (sWidth / 2.15) - 70,
                // bottom: isLayoutTab
                //     ? mapValueDimensionBased(
                //         -70,
                //         -110 -
                //             (mapValueDimensionBased(0, 15, sWidth, sHeight,
                //                 useWidth: true)),
                //         sWidth,
                //         sHeight,
                //         b: false)
                //     : sHeight,
                bottom: isLayoutTab?mapValueDimensionBased(
                  25,
                  50 - (mapValueDimensionBased( 0, 1, sWidth, sHeight, useWidth: true)),
                  sWidth,
                  sHeight,
                  b: false):sHeight,
                left: (sWidth / 20).clamp(90, double.infinity),
                child: AnimatedContainer(
                  duration: Durations.extralong1,
                  curve: Curves.bounceOut,
                  transform: Matrix4.identity()
                    // Translate
                    ..translate(
                      isLayoutTab ? 0.0 : 50.0,
                      isLayoutTab ? 0.0 : -30.0,
                    )
                    // Rotate (in radians)
                    ..rotateZ(isLayoutTab ? 0 : 0.7)
                    ..rotateX(isLayoutTab ? 0 : 0.8)
                    // Scale
                    ..scale(isLayoutTab ? 1.0 : 1.3, isLayoutTab ? 1.0 : 0.6)
                    // Skew-like effect
                    ..setEntry(0, 1, isLayoutTab ? 0 : 1)
                    ..setEntry(1, 0, isLayoutTab ? 0 : -0.4),
                  decoration: BoxDecoration(
                      color:
                          // Color(0xffc0c0c0),
                          defaultPalette.primary,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all()),
                  padding: EdgeInsets.all( mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                // Color(0xffc0c0c0),
                                defaultPalette.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(2, 15, sWidth, sHeight)),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              //pagepreview and docPRopss
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 8,),
                                  //page previeww
                                  Container(
                                    width: getScaledPageSize(sWidth, sHeight, tempLayoutModel.docPropsList[0].pageFormatController,tempLayoutModel.docPropsList[0].orientationController).width,
                        
                                    height: getScaledPageSize(sWidth, sHeight, tempLayoutModel.docPropsList[0].pageFormatController,tempLayoutModel.docPropsList[0].orientationController).height,
                        
                                    margin: EdgeInsets.all(5),
                                    decoration:BoxDecoration(
                                      color:defaultPalette.primary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: defaultPalette.black
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      )
                                  ),
                                  
                                  //number of pagess && ORIENTATIONN // to do createdAT
                                  Expanded(
                                    child: SizedBox(
                                      height: math.max(getScaledPageSize(sWidth, sHeight, tempLayoutModel.docPropsList[0].pageFormatController, tempLayoutModel.docPropsList[0].orientationController).height, (sHeight / 2)/3),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'docProps ',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                    fontSize:
                                                        mapValueDimensionBasedLockOnDesync(
                                                            15,
                                                            33,
                                                            sWidth,
                                                            sHeight,),
                                                    color: defaultPalette
                                                        .extras[0],
                                                    letterSpacing: -0.3,
                                                    height: 1,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              height: 8,
                                            ),
                                          ),
                                          //pAGE COUNTT
                                          Row(
                                            children:[ 
                                              ...pagePropertyTile(2, sWidth, sHeight)],
                                          ),
                                          //createdAt
                                          Row(
                                            children:[ 
                                               Icon(
                                                TablerIcons.calendar_event,
                                                size: mapValueDimensionBasedLockOnDesync(15, 28, sWidth, sHeight),
                                                color: defaultPalette.extras[0]
                                              ),
                                              Expanded(
                                                child: Text(' date: ',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                      fontSize: mapValueDimensionBasedLockOnDesync(13, 26, sWidth, sHeight),
                                                      letterSpacing: -1,
                                                      fontWeight: FontWeight.w600,
                                                      color: defaultPalette.extras[0]),
                                                ),
                                              ),
                                              Expanded(child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                  if (sheetTypeBrowserEntry != null) {
                                                    sheetTypeBrowserEntry!.remove();
                                                    sheetTypeBrowserEntry = null;
                                                  }
                                                  tempLayoutModel.createdAt =  ((await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime.now(),
                                                          firstDate: DateTime(1800),
                                                          lastDate: DateTime.now(),
                                                          barrierColor: defaultPalette.extras[0].withOpacity(0.5),
                                                          builder: (context, child) {
                                                            return Theme(
                                                              data: Theme.of(context).copyWith(
                                                                inputDecorationTheme: InputDecorationTheme(
                                                                  labelStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 12,
                                                                    color: defaultPalette.extras[0],
                                                                  ),
                                                                  hintStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 15,
                                                                    color: defaultPalette.extras[0].withOpacity(0.6),
                                                                  ),
                                                                  errorStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 15,
                                                                    color: defaultPalette.extras[0].withOpacity(0.6),
                                                                  ),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderSide: BorderSide(color: defaultPalette.tertiary, width: 2),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                textTheme: Theme.of(context).textTheme.copyWith(
                                                                  titleLarge: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 24,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: defaultPalette.black,
                                                                  ),
                                                                  headlineSmall: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: defaultPalette.black,
                                                                  ),
                                                                  headlineMedium: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: defaultPalette.black,
                                                                  ),
                                                                ),
                                                                textButtonTheme: TextButtonThemeData(
                                                                  style: ButtonStyle(
                                                                    textStyle: WidgetStateProperty.all(
                                                                      TextStyle(                                fontFamily: 'Lexend',fontSize: 15, letterSpacing: -1),
                                                                    ),
                                                                    foregroundColor: WidgetStateProperty.all(defaultPalette.tertiary),
                                                                  ),
                                                                ),
                                                                datePickerTheme: DatePickerThemeData(
                                                                  backgroundColor: defaultPalette.primary,
                                                                  rangePickerBackgroundColor: defaultPalette.tertiary,
                                                                  elevation: 20,
                                                                  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                    if (states.contains(WidgetState.selected)) {
                                                                      return defaultPalette.tertiary;
                                                                    }
                                                                    return null;
                                                                  }),
                                                                  locale: const Locale('en', 'IN'),
                                                                  todayBorder: BorderSide.none,
                                                                  todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                    if (states.contains(WidgetState.selected)) {
                                                                      return defaultPalette.tertiary;
                                                                    } else {
                                                                      return defaultPalette.primary;
                                                                    }
                                                                  }),
                                                                  todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                                                                    if (states.contains(WidgetState.selected)) {
                                                                      return defaultPalette.primary;
                                                                    } else {
                                                                      return defaultPalette.extras[0];
                                                                    }
                                                                  }),
                                                                  yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                                                                    if (states.contains(WidgetState.selected)) {
                                                                      return defaultPalette.primary;
                                                                    }
                                                                    return null;
                                                                  }),
                                                                  yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                    if (states.contains(WidgetState.selected)) {
                                                                      return defaultPalette.tertiary;
                                                                    } else {
                                                                      return defaultPalette.transparent;
                                                                    }
                                                                  }),
                                                                  dividerColor: defaultPalette.extras[0].withOpacity(0.4),
                                                                  confirmButtonStyle: ButtonStyle(
                                                                    textStyle: WidgetStateProperty.all(
                                                                      TextStyle(                                fontFamily: 'Lexend',
                                                                        fontSize: 15,
                                                                        letterSpacing: -1,
                                                                        color: defaultPalette.tertiary,
                                                                        fontWeight: FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  cancelButtonStyle: ButtonStyle(
                                                                    textStyle: WidgetStateProperty.all(
                                                                      TextStyle(                                fontFamily: 'Lexend',
                                                                        fontSize: 15,
                                                                        letterSpacing: -1,
                                                                        color: defaultPalette.tertiary,
                                                                        fontWeight: FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  yearStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 15,
                                                                    color: defaultPalette.tertiary,
                                                                    letterSpacing: -1,
                                                                  ),
                                                                  dayStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 15,
                                                                    color: defaultPalette.tertiary,
                                                                    letterSpacing: -1,
                                                                  ),
                                                                  weekdayStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 14,
                                                                    letterSpacing: -1,
                                                                    color: defaultPalette.tertiary,
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                  headerHeadlineStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 30,
                                                                    letterSpacing: -1,
                                                                    color: defaultPalette.tertiary,
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                  rangePickerHeaderHeadlineStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 14,
                                                                    letterSpacing: -1,
                                                                    color: defaultPalette.tertiary,
                                                                  ),
                                                                  rangePickerHeaderHelpStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                    fontSize: 14,
                                                                    letterSpacing: -1,
                                                                    color: defaultPalette.tertiary,
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                headerHelpStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                  fontSize: 14,
                                                                  letterSpacing: -1,
                                                                  color: defaultPalette.tertiary,
                                                                ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(16),
                                                                ),
                                                              ),
                                                            ),
                                                            child: child!,
                                                          );
                                                        },
                                                      )??DateTime.now())).copyWith(
                                                      hour:(tempLayoutModel.createdAt).hour,
                                                      minute: (tempLayoutModel.createdAt).minute,
                                                      second: (tempLayoutModel.createdAt).second,
                                                      millisecond: (tempLayoutModel.createdAt).millisecond,
                                                      microsecond: (tempLayoutModel.createdAt).microsecond
                                                      
                                                      );
                                                  
                                                  setState(() {
                                                    
                                                  });
                                                  },
                                                  child: Text(
                                                    tempLayoutModel.createdAt.toIso8601String(),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(                                fontFamily: 'Lexend',
                                                      fontSize: mapValueDimensionBasedLockOnDesync(12, 24, sWidth, sHeight),
                                                      letterSpacing: -1,
                                                      fontWeight: FontWeight.w500,
                                                      color: defaultPalette.extras[0]),
                                                    ),
                                                ),
                                              ),),
                                            ],
                                          ),
                                          // SizedBox(
                                          //   height: mapValueDimensionBasedLockOnDesync(6, 12, sWidth, sHeight),
                                          // ),
                                          //porttaittt and landscapee
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              //PORTRAIT BUTTON
                                              Expanded(child: ElevatedLayerButton(
                                                    isTapped: tempLayoutModel.docPropsList[0].orientationController,
                                                    // toggleOnTap: true,
                                                    depth: 3, subfac: 3,
                                                    onClick: () {
                                                      setState(() {
                                                          tempLayoutModel.docPropsList[0].orientationController = true;
                                                        });
                                                    },
                                                    buttonHeight: mapValueDimensionBasedLockOnDesync(
                                                            30, 50, sWidth, sHeight),
                                                    buttonWidth: (((sWidth / 2.15) - 70)*(55/75)
                                                    -getScaledPageSize(sWidth, sHeight, tempLayoutModel.docPropsList[0].pageFormatController, tempLayoutModel.docPropsList[0].orientationController).width
                                                    )/2-mapValueDimensionBasedLockOnDesync(30, 50, sWidth, sHeight),
                                                    borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                    animationDuration:
                                                        const Duration(milliseconds: 10),
                                                    animationCurve: Curves.ease,
                                                    topDecoration: BoxDecoration(
                                                        color:!tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0],
                                                        borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0],)
                                                      ),
                                                    topLayerChild: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          TablerIcons.building_estate,
                                                          size:mapValueDimensionBasedLockOnDesync(18, 25, sWidth, sHeight), 
                                                          color: tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0]),
                                                        
                                                      ],
                                                    ),
                                                    baseDecoration: BoxDecoration(
                                                        color: tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0],
                                                        borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                        border: Border.all()
                                                      ),
                                                  ),
                                              ),
                                              //LANDSCAPE BUTTON
                                              SizedBox(width:5),
                                              Expanded(child: ElevatedLayerButton(
                                                    isTapped: !tempLayoutModel.docPropsList[0].orientationController,
                                                    // toggleOnTap: true,
                                                    depth: 3, subfac: 3,
                                                    onClick: () {
                                                      setState(() {
                                                          tempLayoutModel.docPropsList[0].orientationController = false;
                                                        });
                                                    },
                                                    buttonHeight:
                                                        mapValueDimensionBasedLockOnDesync(
                                                            30, 50, sWidth, sHeight),
                                                    buttonWidth:(((sWidth / 2.15) - 70)*(55/75)
                                                    -getScaledPageSize(sWidth, sHeight, tempLayoutModel.docPropsList[0].pageFormatController, tempLayoutModel.docPropsList[0].orientationController).width
                                                    )/2-mapValueDimensionBasedLockOnDesync(30, 50, sWidth, sHeight),
                                                    borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                    animationDuration:
                                                        const Duration(milliseconds: 10),
                                                    animationCurve: Curves.ease,
                                                    topDecoration: BoxDecoration(
                                                        color:tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0],
                                                        borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: !tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0],)
                                                      ),
                                                    topLayerChild: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          TablerIcons.sunset_2,
                                                          size:mapValueDimensionBasedLockOnDesync(18, 25, sWidth, sHeight), 
                                                          color: !tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0]),
                                                        
                                                      ],
                                                    ),
                                                    baseDecoration: BoxDecoration(
                                                        color: !tempLayoutModel.docPropsList[0].orientationController?defaultPalette.primary: defaultPalette.extras[0],
                                                        borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                                        border: Border.all()
                                                      ),
                                                  ),
                                              
                                              ),

                                              
                                            ],
                                          ),
                                    
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                ],
                              ),
                               SizedBox(
                                height: mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight,),
                              ),
                              //PAGE DIMENSIONS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                SizedBox(width: 8,),
                                ElevatedLayerButton(
                                  depth: 3, subfac: 3,
                                  onTapDown:  (details) {
                                            showOpsFormatMenu(context, details.globalPosition, sWidth, sHeight);
                                          },
                                  buttonWidth: (((sWidth / 2.15) - 70) * (55 / 75)) / 4.2,
                                  buttonHeight: mapValueDimensionBasedLockOnDesync(35, 75, sWidth, sHeight),
                                  borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                  animationDuration:
                                      const Duration(milliseconds: 10),
                                  animationCurve: Curves.ease,
                                  topDecoration: BoxDecoration(
                                      color:defaultPalette.primary,
                                      borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                      border: Border.all(
                                        width: 1,
                                        color:  defaultPalette.extras[0],)
                                    ),
                                  topLayerChild: Center(
                                              child: SizedBox(
                                                width: (((sWidth / 2.15) - 70) * (55 / 75)) / 10,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Text(
                                                      getPageFormatString(
                                                        getPageFormatFromMap(tempLayoutModel.docPropsList[0].pageFormatController),
                                                      ),
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                        fontSize: mapValueDimensionBasedLockOnDesync(15, 35, sWidth, sHeight),
                                                        color: defaultPalette.extras[0],
                                                        fontWeight: FontWeight.w800
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                  baseDecoration: BoxDecoration(
                                      color: defaultPalette.extras[0],
                                      borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(5, 15, sWidth, sHeight)),
                                      border: Border.all()
                                    ), onClick: () {  },
                                ),
                                 
                                
                                SizedBox(width:8),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          children:pagePropertyTile(0, sWidth, sHeight)
                                        ),
                                        Row(
                                          children:pagePropertyTile(1, sWidth, sHeight)
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(width: 8,),
                                ],
                              ),
                              //SHEET TYPE REQUIRED TEXTS
                              Expanded(
                                // height: mapValueDimensionBasedLockOnDesync(75, 235, sWidth, sHeight),
                                child: Stack(
                                  children: [
                                    //required fields card
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0)
                                            .copyWith(top: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(mapValueDimensionBasedLockOnDesync(8, 15, sWidth, sHeight)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              //teh horizontal layout scroll
                                              Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      // color: defaultPalette
                                                      //     .primary,
                                                      borderRadius: BorderRadius.circular( 7),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              Stack(
                                                                children: [
                                                                  Container(
                                                                    // height: 112,
                                                                    margin: const EdgeInsets.all(0).copyWith(left: 4, top: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: defaultPalette.extras[0],
                                                                      borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(12, 30, sWidth, sHeight)),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    // height: 112,
                                                                    margin: const EdgeInsets.all(0).copyWith(left: 0, right: 4,bottom: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: defaultPalette.primary,
                                                                      borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(12, 30, sWidth, sHeight)),
                                                                      border:Border.all()
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    right: -10,
                                                                    top: -15,
                                                                    child: Icon(
                                                                      TablerIcons.north_star,
                                                                      size: 150,
                                                                      color: defaultPalette.extras[0].withOpacity(0.05),
                                                                    )),
                                                                  Container(
                                                                    margin: const EdgeInsets.all(2).copyWith(left: 0, right: 0,bottom: 4),
                                                                    child: Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        //req numbersss 19 13 7
                                                                        Container(
                                                                          width:mapValueDimensionBasedLockOnDesync(35, 140, sWidth, sHeight),
                                                                          margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(4, 8, sWidth, sHeight)),
                                                                          padding: EdgeInsets.all(0).copyWith(left: mapValueDimensionBasedLockOnDesync(1, 8, sWidth, sHeight)),
                                                                          alignment: Alignment(0, -0.8),
                                                                          decoration: BoxDecoration(
                                                                            color: defaultPalette.extras[0], 
                                                                            border: Border.all(width:0.5),
                                                                            borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(10, 28, sWidth, sHeight))),
                                                                          child: SingleChildScrollView(
                                                                            child: Column(
                                                                              children: [
                                                                                Text(
                                                                                  getLabelList(SheetType.values[tempLayoutModel.type], null).length.toString(),
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                                                    height:1.35,
                                                                                    fontSize: mapValueDimensionBasedLockOnDesync(
                                                                                      20 + mapValueDimensionBased(-4, -6, sWidth, sHeight,useWidth: true), 
                                                                                      70, sWidth, sHeight), letterSpacing: -1, color: defaultPalette.primary, fontWeight: FontWeight.w500),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        getLabelList(SheetType.values[tempLayoutModel.type], null)
                                                                                            .where(
                                                                                              (el) => !el.isOptional,
                                                                                            )
                                                                                            .toList()
                                                                                            .length
                                                                                            .toString(),
                                                                                        maxLines: 1,
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(                                fontFamily: 'Lexend',fontSize: mapValueDimensionBasedLockOnDesync(11, 50, sWidth, sHeight), letterSpacing: -1, color: defaultPalette.extras[4], fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        getLabelList(SheetType.values[tempLayoutModel.type], null)
                                                                                            .where( (el) => el.isOptional, )
                                                                                            .toList()
                                                                                            .length
                                                                                            .toString(),
                                                                                        maxLines: 1,
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(                                fontFamily: 'Lexend',
                                                                                          fontSize: mapValueDimensionBasedLockOnDesync(11, 50, sWidth, sHeight), letterSpacing: -1, color: defaultPalette.primary, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        //the scrolllist of fields
                                                                        Expanded(
                                                                            child: ScrollConfiguration(
                                                                              behavior: ScrollBehavior().copyWith(scrollbars: false),
                                                                              child: DynMouseScroll(
                                                                                  durationMS: 500,
                                                                                  scrollSpeed: 1,
                                                                                  builder: (context, controller, physics) {
                                                                                    return ScrollbarUltima(
                                                                                      alwaysShowThumb: true,
                                                                                      controller: controller,
                                                                                      scrollbarPosition: ScrollbarPosition.left,
                                                                                      backgroundColor: defaultPalette.primary,
                                                                                      isDraggable: true,
                                                                                      maxDynamicThumbLength: 50,
                                                                                      minDynamicThumbLength: 20,
                                                                                      scrollbarPadding: EdgeInsets.only(bottom: 8, top: 20, left: 0),
                                                                                      thumbBuilder: (context, animation, widgetStates) {
                                                                                        return Container(
                                                                                          decoration: BoxDecoration(color: defaultPalette.extras[0], borderRadius: BorderRadius.circular(mapValueDimensionBasedLockOnDesync(2, 30, sWidth, sHeight))),
                                                                                          width: mapValueDimensionBasedLockOnDesync(4, 10, sWidth, sHeight),
                                                                                        );
                                                                                      },
                                                                                      child: SingleChildScrollView(
                                                                                        controller: controller,
                                                                                        physics: physics,
                                                                                        padding: EdgeInsets.only(
                                                                                          left:mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight),
                                                                                        ),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            SizedBox(
                                                                                              height: mapValueDimensionBasedLockOnDesync(30, 100, sWidth, sHeight),
                                                                                            ),
                                                                                            ...getLabelList(SheetType.values[tempLayoutModel.type], null).asMap().entries.map(
                                                                                              (ent) {
                                                                                                return RichText(
                                                                                                    maxLines: 1,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    text: TextSpan(children: [
                                                                                                      TextSpan(
                                                                                                        text: '${ent.key + 1}.',
                                                                                                        style: TextStyle(                                fontFamily: 'Lexend',fontSize: mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight), letterSpacing: -0.2, color: ent.value.isOptional ? defaultPalette.extras[0].withOpacity(0.95) : defaultPalette.extras[4], fontWeight: FontWeight.w300),
                                                                                                      ),
                                                                                                      TextSpan(
                                                                                                        text: ' ${ent.value.name}',
                                                                                                        style: TextStyle(                                fontFamily: 'Lexend',fontSize: mapValueDimensionBasedLockOnDesync(10, 18, sWidth, sHeight), letterSpacing: -0.2, color: defaultPalette.extras[0].withOpacity(0.95), fontWeight: FontWeight.w300),
                                                                                                      )
                                                                                                    ]));
                                                                                              },
                                                                                            ).toList(),
                                                                                            SizedBox(
                                                                                              height: mapValueDimensionBasedLockOnDesync(5, 20, sWidth, sHeight),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }),
                                                                            )),
                                                                        //the type name and bar below
                                                                        SizedBox(
                                                                          // height: 110,
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.only(right:mapValueDimensionBasedLockOnDesync(12, 20, sWidth, sHeight),top:mapValueDimensionBasedLockOnDesync(4, 10, sWidth, sHeight)),
                                                                                  child: Text(
                                                                                    SheetType.values[tempLayoutModel.type].name.replaceFirstMapped(RegExp(r'^[a-z]+(?=[A-Z])'), (m) => '${m[0]}\n'),
                                                                                    maxLines: 2,
                                                                                    textAlign: TextAlign.end,
                                                                                    style: TextStyle(                                fontFamily: 'Lexend',fontSize:  mapValueDimensionBasedLockOnDesync(11, 30, sWidth, sHeight), letterSpacing: -1, height: 1, color: defaultPalette.extras[0], fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                height: mapValueDimensionBasedLockOnDesync(4, 10, sWidth, sHeight),
                                                                                width: mapValueDimensionBasedLockOnDesync(50, 130, sWidth, sHeight),
                                                                                margin: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(8, 12, sWidth, sHeight)).copyWith(right: mapValueDimensionBasedLockOnDesync(8, 20, sWidth, sHeight)),
                                                                                decoration: BoxDecoration(color: defaultPalette.extras[0], borderRadius: BorderRadius.circular(100)),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    //asterisk button
                                    Positioned(
                                      top: mapValueDimensionBased(
                                          2, 4, sWidth, sHeight),
                                      left: mapValueDimensionBased(
                                          2, 0, sWidth, sHeight),
                                      child: ElevatedLayerButton(
                                        onClick: () {
                                          void showPositionedSheetTypeOverlay({
                                            required BuildContext context,
                                            required Offset position,
                                            required double width,
                                            List<InputBlock>? inputBlocks,
                                          }) {
                                            var oWidth = width;
                                            var oHeight = (sHeight / 1.09) - 30;
                                            var typeList = SheetType.values;
                                            final overlay = Overlay.of(context);
                                            // Remove overlay on outside tap
                                            if (sheetTypeBrowserEntry != null) {
                                              sheetTypeBrowserEntry!.remove();
                                              sheetTypeBrowserEntry = null;
                                            }
                                            sheetTypeBrowserEntry = OverlayEntry(
                                              builder: (context) {
                                                return StatefulBuilder(builder:
                                                    (context, updateState) {
                                                  return Positioned(
                                                    left: position.dx,
                                                    top: position.dy,
                                                    child: GestureDetector(
                                                      onPanUpdate: (details) {
                                                        updateState(() {
                                                          position = Offset(
                                                          position.dx + details.delta.dx,
                                                          position.dy + details.delta.dy);
                                                        });
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          SizedBox(
                                                            height: oHeight,
                                                            width: oWidth,
                                                          ),
                                                          Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: Container(
                                                              width: oWidth,
                                                              height: oHeight,
                                                              padding:
                                                                EdgeInsets.all( mapValueDimensionBased(10, 15, sWidth, sHeight)),
                                                              decoration: BoxDecoration(
                                                                color: defaultPalette.primary,
                                                                borderRadius: BorderRadius.circular( 20),
                                                                border: Border.all(
                                                                  width: 1,
                                                                  color: defaultPalette
                                                                      .extras[0],
                                                                )),
                                                              child: Column(
                                                                children: [
                                                                  // Search Bar
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all( color: defaultPalette.primary),
                                                                      borderRadius: BorderRadius.circular(15),
                                                                    ),
                                                                    height: 30,
                                                                    child:
                                                                        TextFormField(
                                                                      style: GoogleFonts
                                                                          .lexend(
                                                                        color: defaultPalette
                                                                            .extras[0],
                                                                        letterSpacing:
                                                                            -1,
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                      onChanged: (value) =>
                                                                          updateState(
                                                                              () {
                                                                        typeList = SheetType
                                                                            .values
                                                                            .where((sheetType) => sheetType
                                                                                .name
                                                                                .toLowerCase()
                                                                                .contains(value.toLowerCase()))
                                                                            .toList();
                                                                      }),
                                                                      cursorColor:
                                                                          defaultPalette
                                                                              .tertiary,
                                                                      controller:
                                                                          textFieldSearchController,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        contentPadding:
                                                                            EdgeInsets.all(
                                                                                0),
                                                                        hintText:
                                                                            'searchTypes...',
                                                                        focusColor:
                                                                            defaultPalette.extras[0],
                                                                        hintStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                            color: defaultPalette.extras[0],
                                                                            letterSpacing: -1,
                                                                            fontSize: 15),
                                                                        prefixIcon: Icon(
                                                                            TablerIcons.search,
                                                                            size: 25,
                                                                            color: defaultPalette.extras[0]),
                                                                        suffixIcon:
                                                                            MouseRegion(
                                                                              cursor: SystemMouseCursors.click,
                                                                              child: GestureDetector(                                                 
                                                                                onTap: () {
                                                                              sheetTypeBrowserEntry?.remove();
                                                                              sheetTypeBrowserEntry =
                                                                                  null;},
                                                                              child: Icon(
                                                                                TablerIcons.x,
                                                                                size: 25,
                                                                                color: defaultPalette.extras[0]),
                                                                              ),
                                                                            ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none,
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height: 10),
                                
                                                                  // Filtered list inside styled container
                                                                  Expanded(
                                                                    child:
                                                                        ScrollConfiguration(
                                                                      behavior: ScrollBehavior().copyWith(
                                                                          scrollbars:
                                                                              false),
                                                                      child: DynMouseScroll(
                                                                          durationMS: 500,
                                                                          scrollSpeed: 1,
                                                                          builder: (context, controller, physics) {
                                                                            return ClipRRect(
                                                                              borderRadius:
                                                                                  BorderRadius.circular(15),
                                                                              child:
                                                                                  SingleChildScrollView(
                                                                                controller: controller,
                                                                                physics: physics,
                                                                                padding: const EdgeInsets.all(4).copyWith(left: 6, right: 6),
                                                                                child: Column(
                                                                                  children: [
                                                                                    ...typeList.asMap().entries.map(
                                                                                      (entry) {
                                                                                        return MouseRegion(
                                                                                          cursor: SystemMouseCursors.click,
                                                                                          child: GestureDetector(
                                                                                            onTap: () {
                                                                                              setState(() {
                                                                                                // lm!.type = entry.value.index;
                                                                                                // lm!.save();
                                                                                                // labelList = getLabelList(SheetType.values[entry.value.index], labelList);
                                                                                                tempLayoutModel.type = entry.value.index;
                                                                                                // assignIndexPathsAndDisambiguate(labelList, spreadSheetList);
                                                                                              });
                                                                                              updateState(
                                                                                                () {},
                                                                                              );
                                                                                            },
                                                                                            child: Stack(
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: oWidth,
                                                                                                  height: 112,
                                                                                                  margin: const EdgeInsets.all(2).copyWith(left: 0, right: 0),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: defaultPalette.extras[0],
                                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                                  ),
                                                                                                ),
                                                                                                if (tempLayoutModel.type == entry.value.index)
                                                                                                  Positioned(
                                                                                                      right: -10,
                                                                                                      top: -15,
                                                                                                      child: Icon(
                                                                                                        TablerIcons.north_star,
                                                                                                        size: 150,
                                                                                                        color: defaultPalette.primary.withOpacity(0.05),
                                                                                                      )),
                                                                                                Container(
                                                                                                  margin: const EdgeInsets.all(2).copyWith(left: 0, right: 0),
                                                                                                  child: Row(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        height: 100,
                                                                                                        width: 65,
                                                                                                        margin: const EdgeInsets.all(6),
                                                                                                        alignment: Alignment(0, -0.8),
                                                                                                        decoration: BoxDecoration(color: defaultPalette.primary, borderRadius: BorderRadius.circular(10)),
                                                                                                        child: Column(
                                                                                                          children: [
                                                                                                            Text(
                                                                                                              getLabelList(entry.value, null).length.toString(),
                                                                                                              maxLines: 1,
                                                                                                              style: TextStyle(                                fontFamily: 'Lexend',fontSize: 45, letterSpacing: -1, color: defaultPalette.extras[0], fontWeight: FontWeight.w500),
                                                                                                            ),
                                                                                                            Row(
                                                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  getLabelList(entry.value, null)
                                                                                                                      .where(
                                                                                                                        (el) => !el.isOptional,
                                                                                                                      )
                                                                                                                      .toList()
                                                                                                                      .length
                                                                                                                      .toString(),
                                                                                                                  maxLines: 1,
                                                                                                                  style: TextStyle(                                fontFamily: 'Lexend',fontSize: 25, letterSpacing: -1, color: defaultPalette.extras[4], fontWeight: FontWeight.w500),
                                                                                                                ),
                                                                                                                Text(
                                                                                                                  getLabelList(entry.value, null)
                                                                                                                      .where(
                                                                                                                        (el) => el.isOptional,
                                                                                                                      )
                                                                                                                      .toList()
                                                                                                                      .length
                                                                                                                      .toString(),
                                                                                                                  maxLines: 1,
                                                                                                                  style: TextStyle(                                fontFamily: 'Lexend',fontSize: 25, letterSpacing: -1, color: defaultPalette.extras[0], fontWeight: FontWeight.w500),
                                                                                                                ),
                                                                                                              ],
                                                                                                            )
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                      Expanded(
                                                                                                          child: SizedBox(
                                                                                                        height: 110,
                                                                                                        child: ScrollConfiguration(
                                                                                                          behavior: ScrollBehavior().copyWith(scrollbars: false),
                                                                                                          child: DynMouseScroll(
                                                                                                              durationMS: 500,
                                                                                                              scrollSpeed: 1,
                                                                                                              builder: (context, controller, physics) {
                                                                                                                return ScrollbarUltima(
                                                                                                                  alwaysShowThumb: true,
                                                                                                                  controller: controller,
                                                                                                                  scrollbarPosition: ScrollbarPosition.left,
                                                                                                                  backgroundColor: defaultPalette.primary,
                                                                                                                  isDraggable: true,
                                                                                                                  maxDynamicThumbLength: 50,
                                                                                                                  minDynamicThumbLength: 20,
                                                                                                                  scrollbarPadding: EdgeInsets.only(bottom: 8, top: 20, left: 0),
                                                                                                                  thumbBuilder: (context, animation, widgetStates) {
                                                                                                                    return Container(
                                                                                                                      decoration: BoxDecoration(color: defaultPalette.primary, borderRadius: BorderRadius.circular(2)),
                                                                                                                      width: 5,
                                                                                                                    );
                                                                                                                  },
                                                                                                                  child: SingleChildScrollView(
                                                                                                                    controller: controller,
                                                                                                                    physics: physics,
                                                                                                                    padding: EdgeInsets.only(
                                                                                                                      left: 10,
                                                                                                                    ),
                                                                                                                    child: Column(
                                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                      children: [
                                                                                                                        SizedBox(
                                                                                                                          height: 60,
                                                                                                                        ),
                                                                                                                        ...getLabelList(entry.value, null).asMap().entries.map(
                                                                                                                          (ent) {
                                                                                                                            return RichText(
                                                                                                                                maxLines: 1,
                                                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                                                text: TextSpan(children: [
                                                                                                                                  TextSpan(
                                                                                                                                    text: '${ent.key + 1}.',
                                                                                                                                    style: TextStyle(                                fontFamily: 'Lexend',fontSize: 12, letterSpacing: -0.2, color: ent.value.isOptional ? defaultPalette.primary.withOpacity(0.6) : defaultPalette.extras[4], fontWeight: FontWeight.w300),
                                                                                                                                  ),
                                                                                                                                  TextSpan(
                                                                                                                                    text: ' ${ent.value.name}',
                                                                                                                                    style: TextStyle(                                fontFamily: 'Lexend',fontSize: 12, letterSpacing: -0.2, color: defaultPalette.primary.withOpacity(0.6), fontWeight: FontWeight.w300),
                                                                                                                                  )
                                                                                                                                ]));
                                                                                                                          },
                                                                                                                        ).toList()
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                );
                                                                                                              }),
                                                                                                        ),
                                                                                                      )),
                                                                                                      SizedBox(
                                                                                                        height: 110,
                                                                                                        child: Column(
                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                          children: [
                                                                                                            Expanded(
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.all(10),
                                                                                                                child: Text(
                                                                                                                  entry.value.name.replaceFirstMapped(RegExp(r'^[a-z]+(?=[A-Z])'), (m) => '${m[0]}\n'),
                                                                                                                  maxLines: 2,
                                                                                                                  textAlign: TextAlign.end,
                                                                                                                  style: TextStyle(                                fontFamily: 'Lexend',fontSize: 17, letterSpacing: -1, height: 1, color: defaultPalette.primary, fontWeight: FontWeight.w500),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            Container(
                                                                                                              height: 5,
                                                                                                              width: 50,
                                                                                                              margin: EdgeInsets.all(8),
                                                                                                              decoration: BoxDecoration(color: defaultPalette.primary, borderRadius: BorderRadius.circular(10)),
                                                                                                            )
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          //left handle resize
                                                          Positioned(
                                                              child: MouseRegion(
                                                            cursor:
                                                                SystemMouseCursors
                                                                    .resizeLeftRight,
                                                            child:
                                                                GestureDetector(
                                                                    behavior:
                                                                        HitTestBehavior
                                                                            .opaque,
                                                                    onPanUpdate:
                                                                        (details) {
                                                                      updateState(
                                                                          () {
                                                                        if (oWidth >
                                                                                200 &&
                                                                            oWidth <
                                                                                sWidth) {
                                                                          position = Offset(
                                                                              position.dx +
                                                                                  details.delta.dx,
                                                                              position.dy);
                                                                        }
                                                                        oWidth = (oWidth +
                                                                                (-details
                                                                                    .delta.dx))
                                                                            .clamp(
                                                                                200,
                                                                                sWidth);
                                                                      });
                                                                    },
                                                                    child:
                                                                        SizedBox(
                                                                      width: 5,
                                                                      height:
                                                                          sHeight,
                                                                    )),
                                                          )),
                                                          //right handle resize
                                                          Positioned(
                                                              right: 0,
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors
                                                                    .resizeLeftRight,
                                                                child:
                                                                    GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior
                                                                                .opaque,
                                                                        onPanUpdate:
                                                                            (details) {
                                                                          updateState(
                                                                              () {
                                                                            oWidth = (oWidth + (details.delta.dx)).clamp(
                                                                                200,
                                                                                sWidth);
                                                                          });
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              5,
                                                                          height:
                                                                              sHeight,
                                                                        )),
                                                              )),
                                                          //top handle resize
                                                          Positioned(
                                                              top: 0,
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors
                                                                    .resizeUpDown,
                                                                child:
                                                                    GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior
                                                                                .opaque,
                                                                        onPanUpdate:
                                                                            (details) {
                                                                          updateState(
                                                                              () {
                                                                            if (oHeight >
                                                                                200) {
                                                                              position =
                                                                                  Offset(position.dx, position.dy + details.delta.dy);
                                                                            }
                                                                            oHeight = (oHeight + (-details.delta.dy)).clamp(
                                                                                200,
                                                                                sHeight);
                                                                          });
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              oWidth,
                                                                          height:
                                                                              5,
                                                                        )),
                                                              )),
                                                          //bottom handle resize
                                                          Positioned(
                                                              top: oHeight - 5,
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors
                                                                    .resizeUpDown,
                                                                child:
                                                                    GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior
                                                                                .opaque,
                                                                        onPanUpdate:
                                                                            (details) {
                                                                          updateState(
                                                                              () {
                                                                            oHeight = (oHeight + (details.delta.dy)).clamp(
                                                                                200,
                                                                                sHeight);
                                                                          });
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              oWidth,
                                                                          height:
                                                                              5,
                                                                        )),
                                                              )),
                                                          //bottomLeft handle resize
                                                          Positioned(
                                                              top: oHeight - 5,
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors
                                                                    .resizeUpRightDownLeft,
                                                                child:
                                                                    GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior
                                                                                .opaque,
                                                                        onPanUpdate:
                                                                            (details) {
                                                                          updateState(
                                                                              () {
                                                                            oHeight = (oHeight + (details.delta.dy)).clamp(
                                                                                200,
                                                                                sHeight);
                                                                            if (oWidth > 200 &&
                                                                                oWidth < sWidth) {
                                                                              position =
                                                                                  Offset(position.dx + details.delta.dx, position.dy);
                                                                            }
                                                                            oWidth = (oWidth + (-details.delta.dx)).clamp(
                                                                                200,
                                                                                sWidth);
                                                                          });
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              10,
                                                                          height:
                                                                              10,
                                                                        )),
                                                              )),
                                                          //bottomRight handle resize
                                                          Positioned(
                                                              top: oHeight - 5,
                                                              right: 0,
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors
                                                                    .resizeUpLeftDownRight,
                                                                child:
                                                                    GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior
                                                                                .opaque,
                                                                        onPanUpdate:
                                                                            (details) {
                                                                          updateState(
                                                                              () {
                                                                            oHeight = (oHeight + (details.delta.dy)).clamp(
                                                                                200,
                                                                                sHeight);
                                
                                                                            oWidth = (oWidth + (details.delta.dx)).clamp(
                                                                                200,
                                                                                sWidth);
                                                                          });
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              10,
                                                                          height:
                                                                              10,
                                                                        )),
                                                              )),
                                                          //topRight handle resize
                                                          Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors
                                                                    .resizeUpRightDownLeft,
                                                                child:
                                                                    GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior
                                                                                .opaque,
                                                                        onPanUpdate:
                                                                            (details) {
                                                                          updateState(
                                                                              () {
                                                                            if (oHeight >
                                                                                200) {
                                                                              position =
                                                                                  Offset(position.dx, position.dy + details.delta.dy);
                                                                            }
                                                                            oHeight = (oHeight + (-details.delta.dy)).clamp(
                                                                                200,
                                                                                sHeight);
                                                                            oWidth = (oWidth + (details.delta.dx)).clamp(
                                                                                200,
                                                                                sWidth);
                                                                          });
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              10,
                                                                          height:
                                                                              10,
                                                                        )),
                                                              )),
                                                          //topLeft handle resize
                                                          Positioned(
                                                              top: 0,
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors
                                                                    .resizeUpLeftDownRight,
                                                                child:
                                                                    GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior
                                                                                .opaque,
                                                                        onPanUpdate:
                                                                            (details) {
                                                                          updateState(
                                                                              () {
                                                                            if (oHeight >
                                                                                200) {
                                                                              position =
                                                                                  Offset(position.dx, position.dy + details.delta.dy);
                                                                            }
                                                                            oHeight = (oHeight + (-details.delta.dy)).clamp(
                                                                                200,
                                                                                sHeight);
                                                                            if (oWidth > 200 &&
                                                                                oWidth < sWidth) {
                                                                              position =
                                                                                  Offset(position.dx + details.delta.dx, position.dy);
                                                                            }
                                                                            oWidth = (oWidth + (-details.delta.dx)).clamp(
                                                                                200,
                                                                                sWidth);
                                                                          });
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              10,
                                                                          height:
                                                                              10,
                                                                        )),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                              },
                                            );
                                
                                            overlay
                                                .insert(sheetTypeBrowserEntry!);
                                          }
                                
                                          if (sheetTypeBrowserEntry == null) {
                                            showPositionedSheetTypeOverlay(
                                              context: context,
                                              position: Offset(
                                                  ((sWidth)-15-2)-((sWidth / 2)-30),
                                                  topPadPosDistance + 10+15),
                                              width: (sWidth / 2)-30,
                                            );
                                          } else {
                                            sheetTypeBrowserEntry!.remove();
                                            sheetTypeBrowserEntry = null;
                                          }
                                        },
                                        buttonHeight: mapValueDimensionBasedLockOnDesync(
                                            25, 53, sWidth, sHeight),
                                        buttonWidth: mapValueDimensionBasedLockOnDesync(
                                            25, 53, sWidth, sHeight),
                                        borderRadius: BorderRadius.circular(999),
                                        animationDuration:
                                            const Duration(milliseconds: 100),
                                        animationCurve: Curves.ease,
                                        topDecoration: BoxDecoration(
                                          color: defaultPalette
                                              .extras[4],
                                          border: Border.all(
                                            width: 2,
                                            color: defaultPalette.extras[0],
                                          ),
                                        ),
                                        topLayerChild: Center(
                                            child: Icon(
                                          TablerIcons.north_star,
                                          color: defaultPalette.primary,
                                          size: mapValueDimensionBasedLockOnDesync(
                                              13, 28, sWidth, sHeight),
                                        )),
                                        subfac: 3,
                                        depth: 3,
                                        baseDecoration: BoxDecoration(
                                          color: defaultPalette.extras[0],
                                          border: Border.all(
                                              color: defaultPalette.extras[0]),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            //   SizedBox(
                            //     height: mapValueDimensionBased(
                            //       61,
                            //       110  +
                            // (mapValueDimensionBased(0, 15, sWidth, sHeight,
                            //     useWidth: true)),
                            //       sWidth,
                            //       sHeight,b: false),
                            //   )
                            ],
                          ),
                        ),
                      ),
                      //ADD BUTONS CLOUD BUTTONS
                      Expanded(
                          flex: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //addLAYOUT
                              ElevatedLayerButton(
                                onClick: () async {
                                  var layoutId = 'LY-${Uuid().v4()}';
                                  final List<DocumentPropertiesBox> docPropsList = List.generate(
                                    layoutPageCount,
                                    (index) => DocumentPropertiesBox(
                                      pageNumberController: index.toString(),
                                      marginAllController: '0',
                                      marginLeftController: '0',
                                      marginRightController: '0',
                                      marginBottomController: '0',
                                      marginTopController: '0',
                                      orientationController: tempLayoutModel.docPropsList[0].orientationController,
                                      pageFormatController: tempLayoutModel.docPropsList[0].pageFormatController,
                                    ),
                                  );

                                  final List<SheetListBox> spreadSheetList = List.generate(
                                    layoutPageCount,
                                    (index) => SheetListBox(
                                      sheetList: [], 
                                      direction: true, 
                                      id:'LI-${Uuid().v4()}', 
                                      parentId: layoutId, 
                                      decorationId: 'yo', 
                                      indexPath: IndexPath(index: index)), // or your spreadsheet object if defined
                                  );

                                  var newLayout = LayoutModel(
                                    name: Boxes.getLayoutName(ref),
                                    id: layoutId,
                                    type: tempLayoutModel.type,
                                    docPropsList: docPropsList,
                                    spreadSheetList: spreadSheetList,
                                    createdAt: tempLayoutModel.createdAt,
                                    modifiedAt: DateTime.now(),
                                  );

                                  final box = Boxes.getLayouts(ref);
                                  await box.put(layoutId, newLayout);

                                  // Convert to JSON string safely
                                  // saveFile(newLayout);
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c)  {
                                        //unsubscribeStream();
                                        // _timer?.cancel();
                                        return Material(
                                        child: PopScope(
                                      canPop: false,
                                      child: LayoutDesigner(
                                        onPop: (pdf) {
                                        setState(() {
                                          filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                        });
                                        },
                                        id: layoutId,
                                        // layoutModel: newLayout,
                                      ),
                                    ));}));
                                },
                                buttonHeight: mapValueDimensionBasedLockOnDesync(
                                        75, 155, sWidth, sHeight),
                                buttonWidth: ((sWidth / 2.15) - 70) * (20 / 75) - mapValueDimensionBased(
                                            20, 30, sWidth, sHeight),
                                borderRadius: BorderRadius.circular( mapValueDimensionBasedLockOnDesync( 16, 30, sWidth, sHeight)),
                                animationDuration: const Duration(milliseconds: 200),
                                animationCurve: Curves.ease,
                                subfac: mapValueDimensionBased( 4, 8, sWidth, sHeight),
                                depth: mapValueDimensionBased( 4, 8, sWidth, sHeight),
                                topDecoration: BoxDecoration(
                                  color: defaultPalette.primary,
                                  border: Border.all(),
                                ),
                                topLayerChild: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Layout',
                                      style: TextStyle(                                fontFamily: 'Lexend',
                                          fontSize:
                                              mapValueDimensionBasedLockOnDesync(
                                            15.5,
                                            30,
                                            sWidth,
                                            sHeight,
                                          ),
                                          color: defaultPalette.extras[0],
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.w500,
                                          height: 0.8),
                                    ),
                                    Text(
                                      'New',
                                      style: TextStyle(                                fontFamily: 'Lexend',
                                        fontSize:
                                            mapValueDimensionBasedLockOnDesync(
                                          15.5,
                                          30,
                                          sWidth,
                                          sHeight,
                                        ),
                                        color: defaultPalette.tertiary,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                                baseDecoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  // border: Border.all(),
                                ),
                              ),
                              SizedBox(
                                  height: mapValueDimensionBased(
                                      5, 10, sWidth, sHeight)),
                                      //addBILL
                              ElevatedLayerButton(
                                onClick: () async {
                                  var billId = 'BI-${Uuid().v4()}';
                                  final List<DocumentPropertiesBox> docPropsList = List.generate(
                                    layoutPageCount,
                                    (index) => DocumentPropertiesBox(
                                      pageNumberController: index.toString(),
                                      marginAllController: '0',
                                      marginLeftController: '0',
                                      marginRightController: '0',
                                      marginBottomController: '0',
                                      marginTopController: '0',
                                      orientationController: tempLayoutModel.docPropsList[0].orientationController,
                                      pageFormatController: tempLayoutModel.docPropsList[0].pageFormatController,
                                    ),
                                  );

                                  final List<SheetListBox> spreadSheetList = List.generate(
                                    layoutPageCount,
                                    (index) => SheetListBox(
                                      sheetList: [], 
                                      direction: true, 
                                      id:'LI-${Uuid().v4()}', 
                                      parentId: billId, 
                                      decorationId: 'yo', 
                                      indexPath: IndexPath(index: index)), // or your spreadsheet object if defined
                                  );

                                  var newLayout = LayoutModel(
                                    name: Boxes.getBillName(ref),
                                    id: billId,
                                    type: tempLayoutModel.type,
                                    docPropsList: docPropsList,
                                    spreadSheetList: spreadSheetList,
                                    createdAt: tempLayoutModel.createdAt,
                                    modifiedAt: DateTime.now(),
                                  );

                                  final box = Boxes.getLayouts(ref);
                                  await box.put(billId, newLayout);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c){ 
                                            //unsubscribeStream();
                                            // _timer?.cancel();
                                            return Material(
                                                  child: PopScope(
                                                    canPop: false,
                                                child: LayoutDesigner(
                                                  id: billId,
                                                  // layoutModel: newLayout,
                                                  onPop: (pdf) {
                                                  setState(() {
                                                    filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                  });
                                                  },
                                                ),
                                              ));
                                            }));
                                },
                                buttonHeight: mapValueDimensionBasedLockOnDesync( 70, 155, sWidth, sHeight),
                                buttonWidth: ((sWidth / 2.15) - 70) * (20 / 75) - mapValueDimensionBased( 20, 30, sWidth, sHeight),
                                borderRadius: BorderRadius.circular( mapValueDimensionBased(16, 30, sWidth, sHeight)),
                                animationDuration: const Duration(milliseconds: 200),
                                animationCurve: Curves.ease,
                                subfac: mapValueDimensionBased( 4, 8, sWidth, sHeight),
                                depth: mapValueDimensionBased( 4, 8, sWidth, sHeight),
                                topDecoration: BoxDecoration(
                                  color: defaultPalette.primary,
                                  border: Border.all(),
                                ),
                                topLayerChild: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 2,
                                    ),
                                    RichText(
                                      // textAlign: TextAlign.start,
                                      maxLines: 1,
                                      // overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style: TextStyle(                                fontFamily: 'Lexend',
                                            fontSize:
                                                mapValueDimensionBasedLockOnDesync(
                                              15.5,
                                              30,
                                              sWidth,
                                              sHeight,
                                            ),
                                            color: defaultPalette.extras[0],
                                            letterSpacing: -1,
                                            fontWeight: FontWeight.w500,
                                            height: 0.8),
                                        children: [
                                          TextSpan(
                                            text: 'Bill',
                                          ),
                                          TextSpan(
                                            text: 'out',
                                            style: TextStyle(                                fontFamily: 'Lexend',
                                                color: defaultPalette.primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'New',
                                      style: TextStyle(                                fontFamily: 'Lexend',
                                        fontSize:
                                            mapValueDimensionBasedLockOnDesync(
                                          15.5,
                                          30,
                                          sWidth,
                                          sHeight,
                                        ),
                                        color: defaultPalette.extras[3],
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                                baseDecoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  // border: Border.all(),
                                ),
                              ),
                              SizedBox( height: mapValueDimensionBased( 5, 10, sWidth, sHeight)),
                              //CLOUD BUTTONS
                              Expanded(
                                child: Stack(
                                  children: [
                                    // BG templatelbutton
                                    Positioned(
                                      right: 0,
                                      top: mapValueDimensionBased( 4, 8, sWidth, sHeight),
                                      child: AnimatedContainer(
                                        duration: Durations.medium3,
                                        curve: Curves.easeIn,
                                        height: (mapValueDimensionBasedLockOnDesync( 60, 155, sWidth, sHeight) -
                                                mapValueDimensionBased(4, 8, sWidth, sHeight)).clamp(0, double.infinity),
                                        width:(((sWidth / 2.15) - 70) * (20 / 75) - mapValueDimensionBased( 20, 30, sWidth, sHeight) -
                                                mapValueDimensionBased( 4, 8, sWidth, sHeight)).clamp(0, double.infinity),
                                        alignment: Alignment.topLeft,
                                        decoration: BoxDecoration(
                                            color: defaultPalette.extras[0],
                                            borderRadius: BorderRadius.circular(
                                                mapValueDimensionBased(300, 300,
                                                    sWidth, sHeight))),
                                      ),
                                    ),
                                    //
                                    // Cloud buttons
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Row(
                                        children: [
                                          ElevatedLayerButton(
                                            onClick: () async {
                                              OverlayEntry? overlay;
                                              overlay = OverlayEntry(
                                                builder: (context) => Scaffold(
                                                  backgroundColor:
                                                      defaultPalette.tertiary,
                                                  body: Stack(
                                                    children: [
                                                      Center(
                                                          child: SizedBox(
                                                        height: 150,
                                                        child: LoadingIndicator(
                                                            indicatorType:
                                                                Indicator
                                                                    .pacman,

                                                            /// Required, The loading type of the widget
                                                            colors: [
                                                              defaultPalette
                                                                  .extras[0],
                                                              defaultPalette
                                                                  .extras[0],
                                                              defaultPalette
                                                                  .extras[0]
                                                            ],

                                                            /// Optional, The color collections
                                                            strokeWidth: 2,

                                                            /// Optional, The stroke of the line, only applicable to widget which contains line
                                                            backgroundColor:
                                                                defaultPalette
                                                                    .transparent,

                                                            /// Optional, Background of the widget
                                                            pathBackgroundColor:
                                                                defaultPalette
                                                                    .tertiary

                                                            /// Optional, the stroke backgroundColor
                                                            ),
                                                      )),
                                                      Positioned(
                                                        bottom: 10,
                                                        left: 0,
                                                        right: 0,
                                                        child: Text(
                                                          ref.watch(
                                                              processMessageProvider),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .lexend(
                                                            fontSize:
                                                                mapValueDimensionBased(
                                                                    15,
                                                                    30,
                                                                    sWidth,
                                                                    sHeight),
                                                            color:
                                                                defaultPalette
                                                                    .extras[0],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      if (!kIsWeb && Platform.isWindows)
                                                        GestureDetector(
                                                          behavior:
                                                              HitTestBehavior
                                                                  .translucent,
                                                          onPanStart:
                                                              (details) {
                                                            appWindow
                                                                .startDragging();
                                                          },
                                                          onDoubleTap: () {
                                                            appWindow
                                                                .maximizeOrRestore();
                                                          },
                                                          child: SizedBox(
                                                            height: 30,
                                                            child: Consumer(
                                                                builder:
                                                                    (context,
                                                                        ref,
                                                                        c) {
                                                              return Stack(
                                                                children: [
                                                                  AnimatedPositioned(
                                                                    right: 0,
                                                                    top: 0,
                                                                    duration:
                                                                        Durations
                                                                            .short4,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Durations.short4,
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                6,
                                                                            bottom:
                                                                                0),
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                5),
                                                                        decoration: const BoxDecoration(
                                                                            color: Colors.transparent,
                                                                            borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(12),
                                                                              bottomLeft: Radius.circular(12),
                                                                            )),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            //minimize button
                                                                            ElevatedLayerButton(
                                                                              // isTapped: false,
                                                                              // toggleOnTap: true,
                                                                              depth: 2.5,
                                                                              subfac: 2.5,
                                                                              onClick: () {
                                                                                Future.delayed(Duration.zero).then((y) {
                                                                                  appWindow.minimize();
                                                                                });
                                                                              },
                                                                              buttonHeight: 22,
                                                                              buttonWidth: 22,
                                                                              borderRadius: BorderRadius.circular(5),
                                                                              animationDuration: const Duration(milliseconds: 10),
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
                                                                            SizedBox(
                                                                              width: 7,
                                                                            ),
                                                                            //
                                                                            //maximize button
                                                                            ElevatedLayerButton(
                                                                              // isTapped: false,
                                                                              // toggleOnTap: true,
                                                                              depth: 2.5,
                                                                              subfac: 2.5,
                                                                              onClick: () {
                                                                                Future.delayed(Durations.short1).then((y) {
                                                                                  appWindow.maximizeOrRestore();
                                                                                });
                                                                              },
                                                                              buttonHeight: 22,
                                                                              buttonWidth: 22,
                                                                              borderRadius: BorderRadius.circular(5),
                                                                              animationDuration: const Duration(milliseconds: 1),
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
                                                  ),
                                                ),
                                              );
                                              Overlay.of(context)
                                                  .insert(overlay);
                                              var box = Boxes.getLayouts(ref);
                                              final gmap =
                                                  await fetchAndReconstructLayoutModels(
                                                      ref, overlay);

                                              for (var lmEntry
                                                  in gmap.entries) {
                                                final id = lmEntry.key;
                                                final incoming = lmEntry.value
                                                    as LayoutModel;
                                                final existing = box.get(id);

                                                if (existing != null &&
                                                    (incoming.modifiedAt
                                                            .isBefore(existing
                                                                .modifiedAt) ||
                                                        incoming.createdAt
                                                            .isBefore(existing
                                                                .createdAt))) {
                                                  if (!mounted) return;

                                                  final shouldOverwrite =
                                                      await showDialog<int>(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        AlertDialog(
                                                      backgroundColor:
                                                          defaultPalette
                                                              .primary,
                                                      title: Text(
                                                        "Older ${incoming.id.startsWith('LY-') ? 'Layout' : incoming.type == 0 ? 'Bill' : SheetType.values[incoming.type].name} In The Cloud!",
                                                        style:
                                                            TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize: 25,
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Do you want to overwrite it?",
                                                            style: GoogleFonts
                                                                .lexend(
                                                              fontSize: 14,
                                                              color:
                                                                  defaultPalette
                                                                      .extras[0],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              //incoming lm
                                                              Row(
                                                                children: [
                                                                  Icon(TablerIcons
                                                                      .cloud),
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    " ${incoming.name}",
                                                                    style: GoogleFonts
                                                                        .lexend(
                                                                      fontSize:
                                                                          14,
                                                                      color: defaultPalette
                                                                          .extras[0],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                maxLines: 1,
                                                                // overflow: TextOverflow.ellipsis,
                                                                text: TextSpan(
                                                                  style:
                                                                      GoogleFonts
                                                                          .lexend(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    letterSpacing:
                                                                        -0.2,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Created: ',
                                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                                          color:
                                                                              defaultPalette.extras[0]),
                                                                    ),
                                                                    TextSpan(
                                                                      text: DateFormat(
                                                                              "EEE MMM d, y 'at' h:mm a")
                                                                          .format(
                                                                              incoming.createdAt),
                                                                      style: TextStyle(
                                                                          color:
                                                                              defaultPalette.extras[0]),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                maxLines: 1,
                                                                // overflow: TextOverflow.ellipsis,
                                                                text: TextSpan(
                                                                  style:
                                                                      GoogleFonts
                                                                          .lexend(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    letterSpacing:
                                                                        -0.2,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Modified: ',
                                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                                          color:
                                                                              defaultPalette.extras[0]),
                                                                    ),
                                                                    TextSpan(
                                                                      text: DateFormat(
                                                                              "EEE MMM d, y 'at' h:mm a")
                                                                          .format(
                                                                              incoming.modifiedAt),
                                                                      style: TextStyle(
                                                                          color:
                                                                              defaultPalette.extras[4]),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              //existing lm
                                                              Row(
                                                                children: [
                                                                  Icon(TablerIcons
                                                                      .server),
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    " ${existing.name}",
                                                                    style: GoogleFonts
                                                                        .lexend(
                                                                      fontSize:
                                                                          14,
                                                                      color: defaultPalette
                                                                          .extras[0],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                maxLines: 1,
                                                                // overflow: TextOverflow.ellipsis,
                                                                text: TextSpan(
                                                                  style:
                                                                      GoogleFonts
                                                                          .lexend(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    letterSpacing:
                                                                        -0.2,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Created: ',
                                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                                          color:
                                                                              defaultPalette.extras[0]),
                                                                    ),
                                                                    TextSpan(
                                                                      text: DateFormat(
                                                                              "EEE MMM d, y 'at' h:mm a")
                                                                          .format(
                                                                              existing.createdAt),
                                                                      style: TextStyle(
                                                                          color:
                                                                              defaultPalette.extras[0]),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                maxLines: 1,
                                                                // overflow: TextOverflow.ellipsis,
                                                                text: TextSpan(
                                                                  style:
                                                                      GoogleFonts
                                                                          .lexend(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    letterSpacing:
                                                                        -0.2,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Modified: ',
                                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                                          color:
                                                                              defaultPalette.extras[0]),
                                                                    ),
                                                                    TextSpan(
                                                                      text: DateFormat(
                                                                              "EEE MMM d, y 'at' h:mm a")
                                                                          .format(
                                                                              existing.modifiedAt),
                                                                      style: TextStyle(
                                                                          color:
                                                                              defaultPalette.tertiary),
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
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  ctx, 0),
                                                          child: Text(
                                                            "Nah",
                                                            style: GoogleFonts
                                                                .lexend(
                                                              fontSize: 14,
                                                              color:
                                                                  defaultPalette
                                                                      .extras[0],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  ctx, 1),
                                                          child: Text(
                                                            "Overwrite",
                                                            style: GoogleFonts
                                                                .lexend(
                                                              fontSize: 14,
                                                              color:
                                                                  defaultPalette
                                                                      .extras[4],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  ctx, 2),
                                                          child: Text(
                                                            "Keep Both",
                                                            style: GoogleFonts
                                                                .lexend(
                                                              fontSize: 14,
                                                              color:
                                                                  defaultPalette
                                                                      .tertiary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (shouldOverwrite == 0)
                                                    continue;
                                                  if (shouldOverwrite == 1) {
                                                    await box.put(
                                                        id,
                                                        incoming.copyWith(
                                                            pdf: existing.pdf));
                                                  } else if (shouldOverwrite ==
                                                      2) {
                                                    var newId =
                                                        '${existing.id.substring(0, 4)}${Uuid().v4()}';
                                                    var newlm = LayoutModel(
                                                      docPropsList:
                                                          incoming.docPropsList,
                                                      spreadSheetList: incoming
                                                          .spreadSheetList,
                                                      id: newId,
                                                      name: incoming.name +
                                                          '-old',
                                                      createdAt:
                                                          incoming.createdAt,
                                                      modifiedAt:
                                                          incoming.modifiedAt,
                                                      labelList:
                                                          incoming.labelList,
                                                      pdf: existing.pdf,
                                                      type: incoming.type,
                                                    );
                                                    await box.put(newId, newlm);
                                                  }
                                                } else if (existing == null) {
                                                  await box.put(
                                                      id,
                                                      incoming
                                                          .copyWith(pdf: []));
                                                }
                                              }

                                              setState(() {
                                                filteredLayoutBox =
                                                    box.values.toList();
                                              });
                                            },
                                            buttonHeight:
                                                mapValueDimensionBasedLockOnDesync(
                                                    60, 155, sWidth, sHeight),
                                            buttonWidth:
                                                (((sWidth / 2.15) - 70) *
                                                            (20 / 75) -
                                                        mapValueDimensionBased(
                                                            20,
                                                            30,
                                                            sWidth,
                                                            sHeight)) /
                                                    2,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  mapValueDimensionBased(300,
                                                      300, sWidth, sHeight)),
                                              bottomLeft: Radius.circular(
                                                  mapValueDimensionBased(300,
                                                      300, sWidth, sHeight)),
                                              topRight: Radius.circular(
                                                  mapValueDimensionBased(
                                                      50, 80, sWidth, sHeight)),
                                              bottomRight: Radius.circular(
                                                  mapValueDimensionBased(
                                                      50, 80, sWidth, sHeight)),
                                            ),
                                            animationDuration: const Duration(
                                                milliseconds: 200),
                                            animationCurve: Curves.ease,
                                            subfac: mapValueDimensionBased(
                                                4, 8, sWidth, sHeight),
                                            depth: mapValueDimensionBased(
                                                4, 8, sWidth, sHeight),
                                            topDecoration: BoxDecoration(
                                              color: defaultPalette.primary,
                                              border: Border.all(),
                                            ),
                                            topLayerChild: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                          top:
                                                              mapValueDimensionBasedLockOnDesync(
                                                                  5,
                                                                  20,
                                                                  sWidth,
                                                                  sHeight),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Icon(
                                                              TablerIcons
                                                                  .cloud_filled,
                                                              size:
                                                                  mapValueDimensionBasedLockOnDesync(
                                                                      16,
                                                                      40,
                                                                      sWidth,
                                                                      sHeight),
                                                              color:
                                                                  defaultPalette
                                                                      .extras[4],
                                                            ),
                                                            Icon(
                                                              TablerIcons
                                                                  .download,
                                                              size:
                                                                  mapValueDimensionBasedLockOnDesync(
                                                                      16,
                                                                      40,
                                                                      sWidth,
                                                                      sHeight),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ]),
                                            baseDecoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                          ElevatedLayerButton(
                                            onClick: () async {
                                              OverlayEntry? overlay;
                                              overlay = OverlayEntry(
                                                builder: (context) => Scaffold(
                                                  backgroundColor:
                                                      defaultPalette.tertiary,
                                                  body: Stack(
                                                    children: [
                                                      Center(
                                                          child: SizedBox(
                                                        height: 150,
                                                        child: LoadingIndicator(
                                                            indicatorType:
                                                                Indicator
                                                                    .pacman,

                                                            /// Required, The loading type of the widget
                                                            colors: [
                                                              defaultPalette
                                                                  .primary,
                                                              defaultPalette
                                                                  .primary,
                                                            ],

                                                            /// Optional, The color collections
                                                            strokeWidth: 2,

                                                            /// Optional, The stroke of the line, only applicable to widget which contains line
                                                            backgroundColor:
                                                                defaultPalette
                                                                    .transparent,

                                                            /// Optional, Background of the widget
                                                            pathBackgroundColor:
                                                                defaultPalette
                                                                    .tertiary

                                                            /// Optional, the stroke backgroundColor
                                                            ),
                                                      )),
                                                      Positioned(
                                                        bottom: 10,
                                                        left: 0,
                                                        right: 0,
                                                        child: Text(
                                                          ref.watch(
                                                              processMessageProvider),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .lexend(
                                                            fontSize:
                                                                mapValueDimensionBased(
                                                                    15,
                                                                    30,
                                                                    sWidth,
                                                                    sHeight),
                                                            color:
                                                                defaultPalette
                                                                    .extras[0],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      if (!kIsWeb && Platform.isWindows)
                                                        GestureDetector(
                                                          behavior:
                                                              HitTestBehavior
                                                                  .translucent,
                                                          onPanStart:
                                                              (details) {
                                                            appWindow
                                                                .startDragging();
                                                          },
                                                          onDoubleTap: () {
                                                            appWindow
                                                                .maximizeOrRestore();
                                                          },
                                                          child: SizedBox(
                                                            height: 30,
                                                            child: Consumer(
                                                                builder:
                                                                    (context,
                                                                        ref,
                                                                        c) {
                                                              return Stack(
                                                                children: [
                                                                  AnimatedPositioned(
                                                                    right: 0,
                                                                    top: 0,
                                                                    duration:
                                                                        Durations
                                                                            .short4,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Durations.short4,
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                6,
                                                                            bottom:
                                                                                0),
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                5),
                                                                        decoration: const BoxDecoration(
                                                                            color: Colors.transparent,
                                                                            borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(12),
                                                                              bottomLeft: Radius.circular(12),
                                                                            )),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            //minimize button
                                                                            ElevatedLayerButton(
                                                                              // isTapped: false,
                                                                              // toggleOnTap: true,
                                                                              depth: 2.5,
                                                                              subfac: 2.5,
                                                                              onClick: () {
                                                                                Future.delayed(Duration.zero).then((y) {
                                                                                  appWindow.minimize();
                                                                                });
                                                                              },
                                                                              buttonHeight: 22,
                                                                              buttonWidth: 22,
                                                                              borderRadius: BorderRadius.circular(5),
                                                                              animationDuration: const Duration(milliseconds: 10),
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
                                                                            SizedBox(
                                                                              width: 7,
                                                                            ),
                                                                            //
                                                                            //maximize button
                                                                            ElevatedLayerButton(
                                                                              // isTapped: false,
                                                                              // toggleOnTap: true,
                                                                              depth: 2.5,
                                                                              subfac: 2.5,
                                                                              onClick: () {
                                                                                Future.delayed(Durations.short1).then((y) {
                                                                                  appWindow.maximizeOrRestore();
                                                                                });
                                                                              },
                                                                              buttonHeight: 22,
                                                                              buttonWidth: 22,
                                                                              borderRadius: BorderRadius.circular(5),
                                                                              animationDuration: const Duration(milliseconds: 1),
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
                                                  ),
                                                ),
                                              );
                                              Overlay.of(context)
                                                  .insert(overlay);
                                              await authenticateAndSyncLayoutModels(
                                                      Boxes.getLayouts(ref),
                                                      ref,
                                                      overlay)
                                                  .then(
                                                (value) {
                                                  overlay?.remove();
                                                },
                                              );
                                            },
                                            buttonHeight:
                                                mapValueDimensionBasedLockOnDesync(
                                                    60, 155, sWidth, sHeight),
                                            buttonWidth:
                                                (((sWidth / 2.15) - 70) *
                                                            (20 / 75) -
                                                        mapValueDimensionBased(
                                                            20,
                                                            30,
                                                            sWidth,
                                                            sHeight)) /
                                                    2,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(
                                                  mapValueDimensionBased(300,
                                                      300, sWidth, sHeight)),
                                              bottomRight: Radius.circular(
                                                  mapValueDimensionBased(300,
                                                      300, sWidth, sHeight)),
                                              topLeft: Radius.circular(
                                                  mapValueDimensionBased(
                                                      50, 80, sWidth, sHeight)),
                                              bottomLeft: Radius.circular(
                                                  mapValueDimensionBased(
                                                      50, 80, sWidth, sHeight)),
                                            ),
                                            animationDuration: const Duration(
                                                milliseconds: 200),
                                            animationCurve: Curves.ease,
                                            subfac: mapValueDimensionBased(
                                                4, 8, sWidth, sHeight),
                                            depth: mapValueDimensionBased(
                                                4, 8, sWidth, sHeight),
                                            topDecoration: BoxDecoration(
                                              color: defaultPalette.primary,
                                              border: Border.all(),
                                            ),
                                            topLayerChild: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                        top:
                                                            mapValueDimensionBasedLockOnDesync(
                                                                5,
                                                                20,
                                                                sWidth,
                                                                sHeight),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Icon(
                                                            TablerIcons
                                                                .cloud_filled,
                                                            size:
                                                                mapValueDimensionBasedLockOnDesync(
                                                                    16,
                                                                    40,
                                                                    sWidth,
                                                                    sHeight),
                                                            color: defaultPalette.extras[4],
                                                          ),
                                                          Icon(
                                                            TablerIcons.upload,
                                                            size:
                                                                mapValueDimensionBasedLockOnDesync(
                                                                    16,
                                                                    40,
                                                                    sWidth,
                                                                    sHeight),
                                                          ),
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                ),
              ),

              //layTEXT TITLE
              AnimatedPositioned(
                duration: Durations.long1,
                left: isLayoutTab ? 120 : 0,
                top: mapValueDimensionBased(
                    // 162,
                    130,
                    // 400 
                    390 + (mapValueDimensionBased(0, -60, sWidth, sHeight, useWidth: true)),
                    sWidth,
                    sHeight,
                    b: false),
                child: IgnorePointer(
                  ignoring: !isLayoutTab,
                  child: Text('LAYOUT'.toUpperCase(),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.micro5(
                          color: defaultPalette.extras[0],
                          // fontSize: math.min( (sHeight / 8).clamp(0, 85), (sWidth/12).clamp(0, 85)),
                          fontSize: mapValueDimensionBased(
                              // 45,
                              120,
                              120 + (mapValueDimensionBased( 0, 120, sWidth, sHeight, useWidth: true)),
                              sWidth,
                              sHeight,
                              b: false),
                          letterSpacing: -2,
                          fontWeight: FontWeight.w400,
                          height: 0.9)),
                ),
              ),
              //quote
              // AnimatedPositioned(
              //   duration: Durations.medium2,
              //   left: ((sWidth / 20).clamp(90, double.infinity) +
              //       (sWidth / 20) / 1.5),
              //   bottom: isLayoutTab
              //       ? 1.6 * (sHeight / 18) +
              //           (sHeight / 2.6) -
              //           mapValueDimensionBased(85, 115, sWidth, sHeight)
              //       : 0,
              //   child: Text(
              //     ' Pay up, \n buttercup!',
              //     maxLines: 2,
              //     overflow: TextOverflow.ellipsis,
              //     // textAlign: TextAlign.end,
              //     style: TextStyle(                                fontFamily: 'Lexend',
              //         fontSize: mapValueDimensionBased(15, 30, sWidth, sHeight),
              //         color: defaultPalette.extras[0].withOpacity(0.4),
              //         letterSpacing: -0.2,
              //         height: 1),
              //   ),
              // ),
              
              //LayoutList backbgBLACKKK
              AnimatedPositioned(
                  duration: Durations.long4,
                  top: isLayoutTab ? topPadPosDistance + 10 + 5 : sHeight * 2,
                  right: 2 - 5,
                  height: sHeight / 1.09,
                  width: sWidth / 2,
                  curve: Curves.decelerate,
                  child: AnimatedOpacity(
                      duration: Durations.extralong1,
                      opacity: isLayoutTab ? 1 : 0,
                      curve: Curves.bounceOut,
                      child: AnimatedContainer(
                        duration: Durations.long4,
                        margin: EdgeInsets.all(15),
                        // curve: Curves.bounceOut,
                        padding: EdgeInsets.all(
                                mapValueDimensionBased(5, 10, sWidth, sHeight))
                            .copyWith(top: 10),
                        transform: Matrix4.identity()
                          // Translate
                          ..translate(
                            isLayoutTab ? 0.0 : 50.0,
                            isLayoutTab ? 0.0 : -30.0,
                          )
                          // Rotate (in radians)
                          ..rotateZ(isLayoutTab ? 0 : 0.7)
                          ..rotateX(isLayoutTab ? 0 : 0.8)
                          // Scale
                          ..scale(
                              isLayoutTab ? 1.0 : 1.3, isLayoutTab ? 1.0 : 0.6)
                          // Skew-like effect
                          ..setEntry(0, 1, isLayoutTab ? 0 : 1)
                          ..setEntry(1, 0, isLayoutTab ? 0 : -0.4),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(isLayoutTab ? 20 : 520),
                            border: Border.all(),
                            color: defaultPalette.extras[0]),
                      ))),
              //LayoutList
              AnimatedPositioned(
                duration: Durations.long4,
                top: isLayoutTab ? topPadPosDistance + 10 : sHeight * 2,
                right: 2,
                height: sHeight / 1.09,
                width: sWidth / 2,
                curve: Curves.decelerate,
                child: AnimatedOpacity(
                  duration: Durations.long3,
                  opacity: isLayoutTab ? 1 : 0,
                  curve: Curves.bounceOut,
                  child: AnimatedContainer(
                    duration: Durations.long4,
                    margin: EdgeInsets.all(15),
                    // curve: Curves.bounceOut,
                    padding: EdgeInsets.all(
                            mapValueDimensionBased(10, 20, sWidth, sHeight)).copyWith(top: 10),
                    transform: Matrix4.identity()
                      // Translate
                      ..translate(
                        isLayoutTab ? 0.0 : 50.0,
                        isLayoutTab ? 0.0 : -30.0,
                      )
                      // Rotate (in radians)
                      ..rotateZ(isLayoutTab ? 0 : 0.7)
                      ..rotateY(isLayoutTab ? 0 : 0.8)
                      // Scale
                      ..scale(isLayoutTab ? 1.0 : 1.3, isLayoutTab ? 1.0 : 0.6)
                      // Skew-like effect
                      ..setEntry(0, 1, isLayoutTab ? 0 : 1)
                      ..setEntry(1, 0, isLayoutTab ? 0 : -0.4),
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(isLayoutTab ? 20 : 520),
                        border: Border.all(),
                        color: defaultPalette.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //my layouts title search bar list page toggle
                        Row(
                          children: [
                            SizedBox(
                              width: 8,
                            ),
                            ExpandableSearchBar(
                              onTap: () {},
                              onChange: (value) {
                                setState(() {
                                  if (value.isNotEmpty) {
                                    filteredLayoutBox = Boxes.getLayouts(ref)
                                        .values
                                        .where((i) => i.name
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  } else {
                                    filteredLayoutBox =
                                        Boxes.getLayouts(ref).values.toList();
                                  }
                                });
                              },
                              hintText: "search layout...",
                              editTextController: layoutSearchController,
                              focusNode: layoutSearchFocusNode,
                              boxShadow: [],
                              iconBackgroundColor: defaultPalette.primary,
                              iconColor: defaultPalette.extras[0],
                              iconSize: mapValueDimensionBased(
                                  20, 30, sWidth, sHeight),
                              backgroundColor: defaultPalette.secondary,
                            ),
                            Expanded(
                                child: SizedBox(
                              width: 3,
                            )),
                            AnimatedToggleSwitch<bool>.dual(
                              current: isLayoutTileView,
                              first: true,
                              second: false,
                              onChanged: (value) {
                                setState(() {
                                  isLayoutTileView = value;
                                });
                              },
                              animationCurve: Curves.easeInOutExpo,
                              animationDuration: Durations.medium4,
                              borderWidth:
                                  2, // backgroundColor is set independently of the current selection
                              styleBuilder: (value) => ToggleStyle(
                                  borderRadius: BorderRadius.circular(50),
                                  indicatorBorderRadius:
                                      BorderRadius.circular(5),
                                  borderColor: defaultPalette.secondary,
                                  backgroundColor: defaultPalette.secondary,
                                  indicatorColor: defaultPalette.extras[
                                      0]), // indicatorColor changes and animates its value with the selection
                              iconBuilder: (value) {
                                return Icon(
                                    value
                                        ? TablerIcons.grip_horizontal
                                        : TablerIcons.grip_vertical,
                                    size: 12,
                                    color: defaultPalette.primary);
                              },
                              textBuilder: (value) {
                                return Text(
                                  value ? 'list' : 'page',
                                  style: GoogleFonts.bungee(fontSize: 12),
                                );
                              },
                              height: mapValueDimensionBased(
                                  22, 32, sWidth, sHeight),
                              spacing: mapValueDimensionBased(
                                  10, 30, sWidth, sHeight),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        //the layout tiles
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffc0c0c0).withOpacity(0.5),
                              // color:defaultPalette.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.all(5),
                            child: ScrollConfiguration(
                              behavior:
                                  ScrollBehavior().copyWith(scrollbars: false),
                              child: DynMouseScroll(
                                  durationMS: 500,
                                  scrollSpeed: 1,
                                  builder: (context, controller, physics) {
                                    // final layoutstream = ref.watch(layoutStreamProvider);
                                    return ScrollbarUltima(
                                      alwaysShowThumb: true,
                                      controller: controller,
                                      scrollbarPosition: ScrollbarPosition.right,
                                      backgroundColor: defaultPalette.primary,
                                      isDraggable: true,
                                      maxDynamicThumbLength: 90,
                                      minDynamicThumbLength: 50,
                                      thumbBuilder: (context, animation, widgetStates) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              right: 3, top: 8, bottom: 8),
                                          decoration: BoxDecoration(
                                              color: defaultPalette.primary,
                                              border: Border.all(),
                                              borderRadius: BorderRadius.circular(15)),
                                          width: 6,
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ListView.builder(
                                          padding: EdgeInsets.only(right: 0),
                                          controller: controller,
                                          physics: physics,
                                          itemCount: layoutSearchController.text == ''
                                                  ? Boxes.getLayouts(ref)
                                                          .values
                                                          .toList()
                                                          .length + 1
                                                  : filteredLayoutBox.length +1,
                                          // itemCount: filteredLayouts.length+1,
                                          itemBuilder: (BuildContext context, int i) {
                                            if (i == (layoutSearchController.text == ''
                                                    ? Boxes.getLayouts(ref).values.toList().length
                                                    // ? layouts.length
                                                    : filteredLayoutBox.length
                                                    // : filteredLayouts.length
                                                    )) {
                                              return const SizedBox( height: 5,);
                                            }
                                            final layoutModel = layoutSearchController.text ==  ''
                                                ? Boxes.getLayouts(ref).values.toList()[i]
                                                : filteredLayoutBox[i];
                                                // ? layouts[i]
                                                // : filteredLayouts[i];
                                            if (layoutModel.id.startsWith('BI-')|| (layoutModel.deleted??false)) {
                                              return const SizedBox.shrink();
                                            }
                                            if (!isLayoutTileView) {
                                              return Material(
                                                color:
                                                    defaultPalette.transparent,
                                                child: InkWell(
                                                  hoverColor: defaultPalette.extras[0].withOpacity(0.4),
                                                  highlightColor: defaultPalette.extras[0].withOpacity(0.4),
                                                  splashColor: defaultPalette.extras[0].withOpacity(0.4),
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                      builder: (context) {
                                                        //unsubscribeStream();
                                                        // _timer?.cancel();
                                                        return PopScope(
                                                          canPop: false,
                                                          child: LayoutDesigner(
                                                            // layoutModel:layoutModel,
                                                            id: Boxes.getLayouts(ref).keyAt(i),
                                                            onPop: (pdf) {
                                                            setState(() {
                                                              filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                            });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ));
                                                  },
                                                  child: Container(
                                                    height: 135,
                                                    width: 30,
                                                    margin: EdgeInsets.only(
                                                        bottom: 10, right: 8),
                                                    color: defaultPalette
                                                        .transparent,
                                                    child: Row(
                                                      children: [
                                                        //mini layout pdf pages swiper
                                                        SizedBox(
                                                          height: 135,
                                                          width: 100,
                                                          child: AppinioSwiper(
                                                            cardCount: (layoutModel
                                                                        .spreadSheetList
                                                                        .length
                                                                        .isNaN ||
                                                                    layoutModel
                                                                            .docPropsList
                                                                            .length ==
                                                                        0)
                                                                ? 1
                                                                : layoutModel
                                                                    .docPropsList
                                                                    .length,
                                                            backgroundCardCount:
                                                                5,
                                                            backgroundCardOffset:
                                                                Offset(
                                                                    0.8, 0.8),
                                                            duration: Duration(
                                                                milliseconds:
                                                                    220),
                                                            backgroundCardScale:
                                                                1,
                                                            loop: true,
                                                            allowUnSwipe: true,
                                                            allowUnlimitedUnSwipe:
                                                                true,
                                                            initialIndex: 0,
                                                            cardBuilder:
                                                                (context,
                                                                    indx) {
                                                              // print(layoutModel.pdf?.length);
                                                              return Stack(
                                                                children: [
                                                                  //The main bgCOLOR OF THE CARD
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                        AnimatedContainer(
                                                                      duration:
                                                                          Durations
                                                                              .short3,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              8,
                                                                          top:
                                                                              8,
                                                                          bottom:
                                                                              2),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: defaultPalette
                                                                            .primary,
                                                                        border: Border.all(
                                                                            width:
                                                                                1.2,
                                                                            color:
                                                                                defaultPalette.extras[0],
                                                                            strokeAlign: BorderSide.strokeAlignOutside),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        image: layoutModel.pdf  ==
                                                                                null || (layoutModel.pdf?.isEmpty??false)
                                                                            ? null
                                                                            : DecorationImage(
                                                                                image: MemoryImage(
                                                                                  layoutModel.pdf![indx],
                                                                                ),
                                                                                fit: BoxFit.fitWidth),
                                                                      ),
                                                                      // foregroundDecoration: BoxDecoration(
                                                                      //   border: Border.all(width: 2, color:defaultPalette.extras[0]),
                                                                      //   borderRadius: BorderRadius.circular(10),
                                                                      // ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        //layoutname and created modified
                                                        _getCreatedAndModified(
                                                            layoutModel,
                                                            sWidth,
                                                            sHeight,
                                                            !isLayoutTileView),
                                                        SizedBox(width: 5),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            //Make a bill out of the Layout button
                                                            Tooltip(
                                                              message:
                                                                  '  Create a Bill based on ${layoutModel.name} layout.  ',
                                                              textStyle:
                                                                  GoogleFonts
                                                                      .lexend(
                                                                fontSize: mapValueDimensionBased(
                                                                        15, 20, sWidth, sHeight),
                                                                color: defaultPalette.primary,
                                                                fontWeight: FontWeight.w600,
                                                                letterSpacing: -0.2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  color: defaultPalette.extras[0].withOpacity(0.8),
                                                                  borderRadius: BorderRadius.circular(50)),
                                                              child:
                                                                  ElevatedLayerButton(
                                                                onClick: () async {
                                                                  final box = Boxes.getLayouts(ref);
                                                                  final name = Boxes.getBillName(ref);
                                                                  var key ='BI-${const Uuid().v4()}';
                                                                  var prevLm = box.getAt(i);
                                                                  // keyIndex = box.length;
                                                                  var lm =
                                                                      LayoutModel(
                                                                    createdAt:tempLayoutModel.createdAt,
                                                                    modifiedAt:
                                                                        DateTime
                                                                            .now(),
                                                                    name: name,
                                                                    docPropsList:
                                                                        [...(prevLm?.docPropsList ??
                                                                            [])],
                                                                    spreadSheetList:
                                                                        [...(prevLm?.spreadSheetList ??
                                                                            [])],
                                                                    id: key,
                                                                    type: prevLm?.type??0,
                                                                    labelList:prevLm?.labelList??tempLayoutModel.labelList,
                                                                    pdf: prevLm?.pdf,
                                                                    sheetDecorationMap: prevLm?.sheetDecorationMap
                                                                  );
                                        
                                                                  await box.put( key, lm);
                                                                  lm.save();
                                                                  // saveFile(lm);
                                                                  ref.read(homeScreenTabIndexProvider.notifier).update((state) =>2,);
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (c) {
                                                                          //unsubscribeStream();
                                                                          // _timer?.cancel();
                                                                          return Material(
                                                                                child: PopScope(
                                                                              child: LayoutDesigner(
                                                                                id: key,
                                                                                // layoutModel: lm,
                                                                                onPop: (pdf) {
                                                                                setState(() {
                                                                                  filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                                                });
                                                                                },
                                                                              ),
                                                                              canPop: false,
                                                                            ));}));
                                                                },
                                                                buttonHeight: 30,
                                                                buttonWidth: 30,
                                                                borderRadius: BorderRadius.circular(50)
                                                                // .copyWith(
                                                                //     topLeft: Radius.circular(80),
                                                                //     bottomRight: Radius.circular(100)
                                                                //   )
                                                                ,
                                                                animationDuration: const Duration( milliseconds: 200),
                                                                animationCurve: Curves.ease,
                                                                topDecoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  border: Border.all(),
                                                                ),
                                                                subfac: 3,
                                                                depth: 3,
                                                                topLayerChild:
                                                                    Icon(
                                                                  TablerIcons
                                                                      .receipt,
                                                                  size: 15,
                                                                ),
                                                                baseDecoration:
                                                                    BoxDecoration(
                                                                  color: defaultPalette
                                                                      .extras[0],
                                                                  border: Border
                                                                      .all(),
                                                                ),
                                                              ),
                                                            ),
                                        
                                                            //Delete a Layout button
                                                            SizedBox(height: 5),
                                                            ElevatedLayerButton(
                                                              onClick:
                                                                  () async {
                                                                    
                                                                await showConfirmDeleteDialog(context, () async {
                                                                  final layoutsBox = Boxes.getLayouts(ref);
                                                                  // Delete the item
                                                                  layoutsBox.get(layoutsBox.keyAt(i))?..deleted = true..save();
                                                                  setState(() {
                                                                    filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                                  });
                                                                }, sWidth, sHeight);
                                                              },
                                                              buttonHeight: 45,
                                                              buttonWidth: 45,
                                                              borderRadius: BorderRadius.circular( 10),
                                                              animationDuration: const Duration( milliseconds:200),
                                                              animationCurve: Curves.ease,
                                                              topDecoration: BoxDecoration(
                                                                color: Colors.white,
                                                                border: Border.all(),
                                                              ),
                                                              topLayerChild: Icon(
                                                                TablerIcons.trash,
                                                                size: 20,
                                                              ),
                                                              subfac: 3,
                                                              depth: 3,
                                                              baseDecoration:
                                                                  BoxDecoration(
                                                                color: defaultPalette.extras[0],
                                                                border: Border.all(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(width: 5),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Material(
                                                color:
                                                    defaultPalette.transparent,
                                                child: InkWell(
                                                  hoverColor: defaultPalette
                                                      .extras[0]
                                                      .withOpacity(0.4),
                                                  highlightColor: defaultPalette
                                                      .extras[0]
                                                      .withOpacity(0.4),
                                                  splashColor: defaultPalette
                                                      .extras[0]
                                                      .withOpacity(0.4),
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                      builder: (context) {
                                                        //unsubscribeStream();
                                                        // _timer?.cancel();
                                                        return PopScope(
                                                          canPop: false,
                                                          child: LayoutDesigner(
                                                            id: Boxes.getLayouts(ref).keyAt(i),
                                                            // layoutModel: layoutModel,
                                                            onPop: (pdf) {
                                                            setState(() {
                                                              filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                            });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ));
                                                  },
                                                  child: Container(
                                                    height: 70,
                                                    width: 30,
                                                    margin: EdgeInsets.only(
                                                        bottom: 10, right: 8),
                                                    color: defaultPalette
                                                        .transparent,
                                                    child: Row(
                                                      children: [
                                                        //layoutname
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 12,
                                                                    top: 0),
                                                            child: Text(
                                                              layoutModel.name,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: GoogleFonts
                                                                  .lexend(
                                                                fontSize:
                                                                    mapValueDimensionBased(
                                                                        20,
                                                                        30,
                                                                        sWidth,
                                                                        sHeight),
                                                                color: defaultPalette
                                                                    .extras[0],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        //layoutname and created modified
                                                        _getCreatedAndModified(
                                                            layoutModel,
                                                            sWidth,
                                                            sHeight,
                                                            !isLayoutTileView),
                                                        SizedBox(width: 5),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            SizedBox(height: 5),
                                                            //make bill out of a Layout button
                                                            Tooltip(
                                                              message:
                                                                  '  Create a Bill based on ${layoutModel.name} layout.  ',
                                                              textStyle:
                                                                  GoogleFonts
                                                                      .lexend(
                                                                fontSize:
                                                                    mapValueDimensionBased(
                                                                        15,
                                                                        20,
                                                                        sWidth,
                                                                        sHeight),
                                                                color:
                                                                    defaultPalette
                                                                        .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  color: defaultPalette
                                                                      .extras[0]
                                                                      .withOpacity(
                                                                          0.8),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50)),
                                                              child:
                                                                  ElevatedLayerButton(
                                                                onClick: () async {
                                                                  final box = Boxes
                                                                      .getLayouts(ref);
                                                                  final name = Boxes
                                                                      .getBillName(ref);
                                                                  var key =
                                                                      'BI-${const Uuid().v4()}';
                                                                  var prevLm =
                                                                      box.getAt(
                                                                          i);
                                                                  // keyIndex = box.length;
                                                                  var lm =
                                                                      LayoutModel(
                                                                    createdAt:
                                                                        DateTime
                                                                            .now(),
                                                                    modifiedAt:
                                                                        DateTime
                                                                            .now(),
                                                                    name: name,
                                                                    docPropsList:
                                                                        prevLm?.docPropsList ??
                                                                            [],
                                                                    spreadSheetList:
                                                                        prevLm?.spreadSheetList ??
                                                                            [],
                                                                    id: key,
                                                                    type: prevLm?.type??0,
                                                                    labelList:prevLm?.labelList??tempLayoutModel.labelList,
                                                                    pdf: prevLm?.pdf,
                                                                    sheetDecorationMap: prevLm?.sheetDecorationMap,
                                                                  );
                                        
                                                                  await box.put(key, lm);
                                                                  lm.save();
                                                                  saveFile(lm);
                                                                  ref.read(homeScreenTabIndexProvider.notifier) .update(
                                                                        (state) => 2,);
                                                                  //unsubscribeStream();
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (c) => Material(
                                                                                  child: PopScope(
                                                                                child: LayoutDesigner(
                                                                                  id: key,
                                                                                  // layoutModel: lm,
                                                                                  onPop: (pdf) {
                                                                                  setState(() {
                                                                                    filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                                                  });
                                                                                  },
                                                                                ),
                                                                                canPop: false,
                                                                              ))));
                                                                },
                                                                buttonHeight:
                                                                    30,
                                                                buttonWidth: 30,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                animationDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            200),
                                                                animationCurve:
                                                                    Curves.ease,
                                                                topDecoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(),
                                                                ),
                                                                subfac: 3,
                                                                depth: 3,
                                                                topLayerChild:
                                                                    Icon(
                                                                  TablerIcons
                                                                      .receipt,
                                                                  size: 15,
                                                                ),
                                                                baseDecoration:
                                                                    BoxDecoration(
                                                                  color: defaultPalette
                                                                      .extras[0],
                                                                  border: Border
                                                                      .all(),
                                                                ),
                                                              ),
                                                            ),
                                        
                                                            //Delete a Layout button
                                                            SizedBox(height: 5),
                                                            ElevatedLayerButton(
                                                              onClick:
                                                                  () async {
                                                                    await showConfirmDeleteDialog(context, () async {
                                                                  final layoutsBox = Boxes.getLayouts(ref);
                                                                // Delete the item
                                                                // await layoutsBox.get(layoutsBox .keyAt( i)) ?.delete();
                                                                layoutsBox.get(layoutsBox.keyAt(i))?..deleted = true..save();
                                                                setState(() {});
                                                                
                                                                }, sWidth, sHeight);
                                                                
                                                              },
                                                              buttonHeight: 30,
                                                              buttonWidth: 30,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              animationDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                              animationCurve:
                                                                  Curves.ease,
                                                              topDecoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border
                                                                    .all(),
                                                              ),
                                                              topLayerChild:
                                                                  Icon(
                                                                TablerIcons
                                                                    .trash,
                                                                size: 20,
                                                              ),
                                                              subfac: 3,
                                                              depth: 3,
                                                              baseDecoration:
                                                                  BoxDecoration(
                                                                color: defaultPalette
                                                                    .extras[0],
                                                                border: Border
                                                                    .all(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(width: 5),
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
                                  }),
                            ),
                          ),
                        ),
                      
                      ],
                    ),
                  ),
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBillsAndCharts(
      BuildContext context, WidgetRef ref, double topPadPosDistance) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    int homeScreenTabIndex = ref.watch(homeScreenTabIndexProvider);
    bool isHomeTab = homeScreenTabIndex == 0;
    bool isBillTab = homeScreenTabIndex == 2;
    double dotSize = sHeight / 35;
    // print(sWidth);
    return AnimatedPositioned(
      duration: Durations.short2,
      // top: (topPadPosDistance * 1.08),
      height: sHeight,
      child: IgnorePointer(
        ignoring: !isBillTab,
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
                  child: GraphWindow(sWidth: sWidth, sHeight: sHeight, s: 1),
                ),
              ),

              //
              // //BillsListBGBLACKK
              AnimatedPositioned(
                duration: Durations.extralong2,
                top: isBillTab ? 60+5 : sHeight / 4,
                // top: isBillTab
                //     ?  topPadPosDistance + 10
                //     : sHeight,
                left: 90+5,
                // right: 15-5,
                height: (sHeight) -
                    60 -
                    20, //60 from the top padding difference and 20 for bottom padding
                width: sWidth / 2.5,
                child: IgnorePointer(
                  ignoring: !isBillTab,
                  child: AnimatedOpacity(
                    duration: Durations.extralong3 * 2,
                    opacity: isBillTab ? 1 : 0,
                    curve: Curves.bounceInOut,
                    child: AnimatedContainer(
                      duration: Durations.extralong1,
                  curve: Curves.decelerate,
                  transform: Matrix4.identity()
                    // Translate
                    ..translate(
                      isBillTab ? 0.0 : 50.0,
                      isBillTab ? 0.0 : -30.0,
                    )
                     // Skew-like effect
                    ..setEntry(0, 1, isBillTab ? 0 : 1)
                    ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                    // Rotate (in radians)
                    ..rotateZ(isBillTab ? 0 : -0.7)
                    ..rotateX(isBillTab ? 0 : 0.8)
                    // Scale
                    ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6),
                      padding: EdgeInsets.all(
                          mapValueDimensionBased(5, 8, sWidth, sHeight)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isBillTab ?20:1560),
                          color: defaultPalette.extras[0]),)))),

              // BillsList
              AnimatedPositioned(
                duration: Durations.extralong2,
                top: isBillTab ? 60 : sHeight / 4,
                // top: isBillTab
                //     ?  topPadPosDistance + 10
                //     : sHeight,
                left: 90,
                // right: 15,
                height: (sHeight) -
                    60 -
                    20, //60 from the top padding difference and 20 for bottom padding
                width: sWidth / 2.5,
                child: IgnorePointer(
                  ignoring: !isBillTab,
                  child: AnimatedOpacity(
                    duration: Durations.extralong3 * 2,
                    opacity: isBillTab ? 1 : 0,
                    curve: Curves.decelerate,
                    child: AnimatedContainer(
                      duration: Durations.extralong1,
                  curve: Curves.decelerate,
                  transform: Matrix4.identity()
                    // Translate
                    ..translate(
                      isBillTab ? 0.0 : -300.0,
                      isBillTab ? 0.0 : -160.0,
                    )
                    // Rotate (in radians)
                    ..rotateZ(isBillTab ? 0 : 0.7)
                    
                  // Skew-like effect
                    ..setEntry(0, 1, isBillTab ? 0 : 1)
                    ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                    ..rotateX(isBillTab ? 0 : 0.8)
                    // Scale
                    ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6),
                   
                      padding: EdgeInsets.all(
                          mapValueDimensionBased(5, 8, sWidth, sHeight)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isBillTab ?20:1560),
                          border: Border.all(),
                          color: defaultPalette.primary),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //my bills title search bar list page toggle
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Bills'.toUpperCase(),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  style: TextStyle(                                fontFamily: 'PressStart2P',
                                      color: defaultPalette.extras[0],
                                      fontSize: mapValueDimensionBasedLockOnDesync(25, 75, sWidth, sHeight),
                                      letterSpacing: -2,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2)),
                                ),
                              ),
                              ExpandableSearchBar(
                                onTap: () {},
                                onChange: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      filteredLayoutBox = Boxes.getLayouts(ref)
                                          .values
                                          .where((i) => i.name
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList();
                                    } else {
                                      filteredLayoutBox =
                                          Boxes.getLayouts(ref).values.toList();
                                    }
                                  });
                                },
                                width: (sWidth / 2.5) / 3,
                                hintText: "search bill...",
                                editTextController: layoutSearchController,
                                focusNode: layoutSearchFocusNode,
                                boxShadow: [],
                                iconBackgroundColor: defaultPalette.primary,
                                iconColor: defaultPalette.extras[0],
                                iconSize: mapValueDimensionBased(
                                    20, 30, sWidth, sHeight),
                                backgroundColor: defaultPalette.secondary,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Column(
                                children: [
                                  AnimatedToggleSwitch<bool>.dual(
                                    current: isLayoutTileView,
                                    first: true,
                                    second: false,
                                    onChanged: (value) {
                                      setState(() {
                                        isLayoutTileView = value;
                                      });
                                    },
                                    animationCurve: Curves.easeInOutExpo,
                                    animationDuration: Durations.medium4,
                                    borderWidth:
                                        2, // backgroundColor is set independently of the current selection
                                    styleBuilder: (value) => ToggleStyle(
                                        borderRadius: BorderRadius.circular(
                                            mapValueDimensionBased(
                                                50, 999, sWidth, sHeight)),
                                        indicatorBorderRadius:
                                            BorderRadius.circular(
                                                mapValueDimensionBased(
                                                    5, 32, sWidth, sHeight)),
                                        borderColor: defaultPalette.secondary,
                                        backgroundColor: defaultPalette.secondary,
                                        indicatorColor: defaultPalette.extras[
                                            0]), // indicatorColor changes and animates its value with the selection
                                    iconBuilder: (value) {
                                      return Icon(
                                          value
                                              ? TablerIcons.grip_horizontal
                                              : TablerIcons.grip_vertical,
                                          size: 12,
                                          color: defaultPalette.primary);
                                    },
                                    textBuilder: (value) {
                                      return Text(
                                        value ? 'list' : 'page',
                                        style: GoogleFonts.bungee(fontSize: 11),
                                      );
                                    },
                                    height: mapValueDimensionBased(
                                        20, 30, sWidth, sHeight),
                                    spacing: mapValueDimensionBased(
                                        10, 30, sWidth, sHeight),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  AnimatedToggleSwitch<int>.rolling(
                                    current: showUnpaid,
                                    values: [0,1,2,3],
                                    // first: true, second: false,
                                    onChanged: (value) {
                                      setState(() {
                                        showUnpaid = value;
                                      });
                                    },
                                    animationCurve: Curves.easeInOutExpo,
                                    animationDuration: Durations.medium4,
                                    borderWidth: 2, // backgroundColor is set independently of the current selection
                                    styleBuilder: (value) => ToggleStyle(
                                        borderRadius: BorderRadius.circular(
                                            mapValueDimensionBased(
                                                50, 999, sWidth, sHeight)),
                                        indicatorBorderRadius:
                                            BorderRadius.circular(
                                                mapValueDimensionBased(
                                                    5, 32, sWidth, sHeight)),
                                        borderColor: defaultPalette.secondary,
                                        backgroundColor: defaultPalette.secondary,
                                        indicatorColor: defaultPalette.extras[0]), // indicatorColor changes and animates its value with the selection
                                    iconBuilder: (value,c) {
                                      return Tooltip(
                                        message: value ==0
                                          ? 'Show All Bills.'
                                          : value ==1
                                            ?'Show Unpaid Bills.'
                                            : value ==2
                                              ?'Show Owed Bills.'
                                              :'Show Settled Bills.',
                                        textStyle: TextStyle(                                fontFamily: 'Lexend',
                                          fontSize: mapValueDimensionBased( 15, 20, sWidth, sHeight),
                                          color: defaultPalette.primary,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (value ==3?defaultPalette.tertiary:defaultPalette.extras[value ==0?0: value ==1 ? 4 : 3 ]).withOpacity(0.9),
                                          borderRadius:
                                                BorderRadius.circular(
                                                    50)),
                                        child: Icon(
                                          value ==0
                                              ? TablerIcons.file_stack
                                              : value ==1
                                                ?TablerIcons.alert_circle
                                                : value ==2
                                                  ? TablerIcons.user_dollar
                                                  : TablerIcons.checks,
                                          size: 12,
                                          color:c? defaultPalette.primary
                                          :value ==3
                                            ?defaultPalette.tertiary
                                            :defaultPalette.extras[
                                            value ==0
                                              ? 0
                                              : value ==1
                                                ? 4
                                                : 3
                                            ]),
                                      );
                                    },
                                    // textBuilder: (value) {
                                    //   return Text(
                                    //     value ? 'unpaid' : 'all',
                                    //     style: GoogleFonts.bungee(fontSize: 10),
                                    //   );
                                    // },
                                    inactiveOpacity: 1,
                                    iconOpacity: 1,
                                    height: mapValueDimensionBased(
                                        20, 30, sWidth, sHeight),
                                    minTouchTargetSize: mapValueDimensionBased(
                                        20, 50, sWidth, sHeight),
                                    // spacing: mapValueDimensionBased(
                                    //     0, 0, sWidth, sHeight),
                                    indicatorSize: Size(mapValueDimensionBased(
                                        25, 31, sWidth, sHeight), mapValueDimensionBased(
                                        20, 30, sWidth, sHeight)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),

                          //the bills tiles
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: defaultPalette.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: EdgeInsets.all(5),
                              child: ScrollConfiguration(
                                behavior: ScrollBehavior()
                                    .copyWith(scrollbars: false),
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
                                            margin: EdgeInsets.only(
                                                right: 3, top: 8, bottom: 8),
                                            decoration: BoxDecoration(
                                                color: defaultPalette.primary,
                                                border: Border.all(),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            width: isLayoutTileView ? 4 : 6,
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: ListView.builder(
                                            controller: controller,
                                            physics: physics,
                                            itemCount: layoutSearchController.text == ''
                                                ? Boxes.getLayouts(ref).values.toList().length + 1
                                                : filteredLayoutBox.length + 1,
                                            itemBuilder: (BuildContext context, int i) {
                                              var layoutBox = Boxes.getLayouts(ref).values.toList();
                                              if (i == (layoutSearchController.text == ''
                                                      ? layoutBox.length
                                                      : filteredLayoutBox.length)) {
                                                return SizedBox(
                                                  height: 5,
                                                );
                                              }
                                              final layoutModel =
                                                  layoutSearchController.text == ''
                                                      ? layoutBox[i]
                                                      : filteredLayoutBox[i];
                                              if (layoutModel.id.startsWith('LY-')|| (layoutModel.deleted??false)) {
                                                return SizedBox.shrink();
                                              }
                                              final isPaidLabel = layoutModel.labelList.firstWhere(
                                                (lbl) => lbl.name == 'isPaid',
                                                orElse: () => RequiredText(name: 'isPaid', sheetTextType: SheetTextType.bool.index, indexPath: IndexPath(index: -951), isOptional: true),
                                              );
                                              bool isPaid = false;

                                              if (isPaidLabel.indexPath.index != -951){ 
                                              final isPaidItem = getItemAtPath(isPaidLabel.indexPath, layoutModel.spreadSheetList);
                                              isPaid =bool.tryParse(isPaidItem is! SheetTextBox? 'false': buildCombinedTextFromBlocks((isPaidItem).inputBlocks, layoutModel.spreadSheetList))?? false;
                                              }

                                              switch (showUnpaid) {
                                                case 1:
                                                  if(isPaid || layoutModel.type == SheetType.creditNote.index){return SizedBox.shrink();}
                                                  break;
                                                case 2:
                                                 if(isPaid || layoutModel.type != SheetType.creditNote.index){return SizedBox.shrink();}
                                                  break;
                                                case 3:
                                                 if(!isPaid){return SizedBox.shrink();}
                                                  break;
                                                default:
                                              }

                                              if (!isLayoutTileView) {
                                                return Material(
                                                  color: defaultPalette.transparent,
                                                  child: InkWell(
                                                    hoverColor: defaultPalette
                                                        .extras[isPaid?0: layoutModel.type == SheetType.creditNote.index?3:4]
                                                        .withOpacity(0.4),
                                                    highlightColor: defaultPalette.extras[isPaid?0: layoutModel.type == SheetType.creditNote.index?3:4].withOpacity(0.4),
                                                    splashColor: defaultPalette.extras[isPaid?0: layoutModel.type == SheetType.creditNote.index?3:4].withOpacity(0.4),
                                                    onTap: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                        builder: (context) {
                                                          //unsubscribeStream();
                                                          return PopScope(
                                                            canPop: false,
                                                            child: LayoutDesigner(
                                                              id: Boxes .getLayouts(ref).keyAt(i),
                                                              // layoutModel: layoutModel,
                                                              onPop: (pdf) {
                                                              setState(() {
                                                                filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                              });
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ));
                                                      filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                    },
                                                    child: Container(
                                                      height: 110,
                                                      width: 30,
                                                      margin: EdgeInsets.only( bottom: 0, right: 8),
                                                      color: defaultPalette.transparent,
                                                      child: Row(
                                                        children: [
                                                          //mini layout pdf pages swiper
                                                          SizedBox(
                                                            height: 100,
                                                            width: 80,
                                                            child:
                                                                AppinioSwiper(
                                                              cardCount: (layoutModel
                                                                          .spreadSheetList
                                                                          .length
                                                                          .isNaN ||
                                                                      layoutModel
                                                                              .docPropsList
                                                                              .length ==
                                                                          0)
                                                                  ? 1
                                                                  : layoutModel
                                                                      .docPropsList
                                                                      .length,
                                                              backgroundCardCount:
                                                                  5,
                                                              backgroundCardOffset:
                                                                  Offset(
                                                                      0.8, 0.8),
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      220),
                                                              backgroundCardScale:
                                                                  1,
                                                              loop: true,
                                                              allowUnSwipe:
                                                                  true,
                                                              allowUnlimitedUnSwipe:
                                                                  true,
                                                              initialIndex: 0,
                                                              cardBuilder:
                                                                  (context,
                                                                      indx) {
                                                                // print(layoutModel.pdf?.length);
                                                                return Stack(
                                                                  children: [
                                                                    //The main bgCOLOR OF THE CARD
                                                                    Positioned
                                                                        .fill(
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Durations.short3,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        margin: EdgeInsets.only(
                                                                            left:
                                                                                8,
                                                                            top:
                                                                                0,
                                                                            bottom:
                                                                                4),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              defaultPalette.primary,
                                                                          border: Border.all(
                                                                              width: 1.2,
                                                                              color: defaultPalette.extras[0]),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          image: (layoutModel.pdf == null || (layoutModel.pdf?.isEmpty ?? false))
                                                                              ? null
                                                                              : DecorationImage(
                                                                                  image: MemoryImage(
                                                                                    layoutModel.pdf![indx],
                                                                                  ),
                                                                                  fit: BoxFit.fitWidth),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          //billname and created modified
                                                          _getCreatedAndModified(
                                                              layoutModel,
                                                              sWidth,
                                                              sHeight,
                                                              !isLayoutTileView,
                                                              isBill: true),
                                          
                                                          SizedBox(width: 5),
                                                          Column(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              //Export as pdf of the bill button
                                                              Tooltip(
                                                                message: '  Export ${layoutModel.name} as pdf.  ',
                                                                textStyle: TextStyle(                                fontFamily: 'Lexend',
                                                                  fontSize: mapValueDimensionBased( 15, 20, sWidth, sHeight),
                                                                  color: defaultPalette.primary,
                                                                  fontWeight: FontWeight.w600,
                                                                  letterSpacing: -0.2,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: defaultPalette.extras[ 0].withOpacity(0.8),
                                                                  borderRadius:
                                                                        BorderRadius.circular(
                                                                            50)),
                                                                child:
                                                                    ElevatedLayerButton(
                                                                  onClick: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                            //unsubscribeStream();
                                                                        return PopScope(
                                                                          canPop:
                                                                              false,
                                                                          child:
                                                                              LayoutDesigner(
                                                                            id: Boxes.getLayouts(ref).keyAt(i),
                                                                            // layoutModel: layoutModel,
                                                                            onPop:
                                                                                (pdf) {
                                                                            setState(() {
                                                                              filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                                            });
                                                                            },
                                                                            exportPdf:
                                                                                true,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ));
                                                                  },
                                                                  buttonHeight:
                                                                      30,
                                                                  buttonWidth:
                                                                      30,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50)
                                                                  // .copyWith(
                                                                  //     topLeft: Radius.circular(80),
                                                                  //     bottomRight: Radius.circular(100)
                                                                  //   )
                                                                  ,
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                  animationCurve:
                                                                      Curves
                                                                          .ease,
                                                                  topDecoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border
                                                                        .all(),
                                                                  ),
                                                                  subfac: 3,
                                                                  depth: 2,
                                                                  topLayerChild:
                                                                      Icon(
                                                                    TablerIcons
                                                                        .upload,
                                                                    size: 15,
                                                                  ),
                                                                  baseDecoration:
                                                                      BoxDecoration(
                                                                    color: defaultPalette
                                                                        .extras[0],
                                                                    border: Border
                                                                        .all(),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5),
                                                              //Make a revised bill out of the bill button
                                                              Tooltip(
                                                                message:
                                                                    '  Create a revised ${(SheetType.values[layoutModel.type].name == 'none' ? 'document' : SheetType.values[layoutModel.type].name)} of ${layoutModel.name}.  ',
                                                                textStyle:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontSize:
                                                                      mapValueDimensionBased(
                                                                          15,
                                                                          20,
                                                                          sWidth,
                                                                          sHeight),
                                                                  color: defaultPalette
                                                                      .primary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      -0.2,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    color: defaultPalette
                                                                        .extras[
                                                                            0]
                                                                        .withOpacity(
                                                                            0.8),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50)),
                                                                child:
                                                                    ElevatedLayerButton(
                                                                  onClick: () async {
                                                                    final box =
                                                                        Boxes
                                                                            .getLayouts(ref);
                                                                    final name =
                                                                        Boxes
                                                                            .getBillName(ref);
                                                                    var key =
                                                                        'BI-${const Uuid().v4()}';
                                                                    var prevLm =
                                                                        box.getAt(
                                                                            i);
                                                                    // keyIndex = box.length;
                                                                    var lm =
                                                                        LayoutModel(
                                                                      createdAt:
                                                                          DateTime
                                                                              .now(),
                                                                      modifiedAt:
                                                                          DateTime
                                                                              .now(),
                                                                      name:
                                                                          '${prevLm?.name ?? ''}-revised',
                                                                      docPropsList:
                                                                          prevLm?.docPropsList ??
                                                                              [],
                                                                      spreadSheetList:
                                                                          prevLm?.spreadSheetList ??
                                                                              [],
                                                                      id: key,
                                                                      type: prevLm?.type??0,
                                                                      labelList:prevLm?.labelList??tempLayoutModel.labelList,
                                                                      pdf: prevLm?.pdf,
                                                                      sheetDecorationMap: prevLm?.sheetDecorationMap,
                                                                    );
                                          
                                                                    await box.put(key,lm);
                                                                    lm.save();
                                                                    saveFile(lm);
                                                                    //unsubscribeStream();
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (c) => Material(
                                                                                    child: PopScope(
                                                                                  child: LayoutDesigner(
                                                                                    id: key,
                                                                                    // layoutModel: lm,
                                                                                    onPop: (pdf) {
                                                                                    setState(() {
                                                                                        filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                  canPop: false,
                                                                                ))));
                                                                  },
                                                                  buttonHeight:
                                                                      30,
                                                                  buttonWidth:
                                                                      30,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50)
                                                                  // .copyWith(
                                                                  //     topLeft: Radius.circular(80),
                                                                  //     bottomRight: Radius.circular(100)
                                                                  //   )
                                                                  ,
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                  animationCurve:
                                                                      Curves
                                                                          .ease,
                                                                  topDecoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border
                                                                        .all(),
                                                                  ),
                                                                  subfac: 3,
                                                                  depth: 2,
                                                                  topLayerChild:
                                                                      Icon(
                                                                    TablerIcons
                                                                        .edit,
                                                                    size: 15,
                                                                  ),
                                                                  baseDecoration:
                                                                      BoxDecoration(
                                                                    color: defaultPalette
                                                                        .extras[0],
                                                                    border: Border
                                                                        .all(),
                                                                  ),
                                                                ),
                                                              ),
                                          
                                                              //Delete a Layout button
                                                              SizedBox(
                                                                  height: 5),
                                                              ElevatedLayerButton(
                                                                onClick:
                                                                    () async {
                                                                  await showConfirmDeleteDialog(context, () async {
                                                                  final layoutsBox = Boxes.getLayouts(ref);
                                                                      // Delete the item
                                                                  // print(  layoutsBox);
                                                                  // await layoutsBox.get(layoutsBox.keyAt(i))?.delete();
                                                                  layoutsBox.get(layoutsBox.keyAt(i))?..deleted = true..save();
                                                                  print('delete');
                                                                  setState(() {
                                                                    filteredLayoutBox = Boxes.getLayouts(ref)
                                                                        .values
                                                                        .toList();
                                                                  });
                                                                }, sWidth, sHeight, 'Are you sure you want to delete this bill?');
                                                                
                                                                },
                                                                buttonHeight:30,
                                                                buttonWidth: 30,
                                                                borderRadius:
                                                                    BorderRadius.circular(10),
                                                                animationDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            200),
                                                                animationCurve:
                                                                    Curves.ease,
                                                                topDecoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(),
                                                                ),
                                                                topLayerChild:
                                                                    Icon(
                                                                  TablerIcons
                                                                      .trash,
                                                                  size: 20,
                                                                ),
                                                                subfac: 3,
                                                                depth: 3,
                                                                baseDecoration:
                                                                    BoxDecoration(
                                                                  color: defaultPalette
                                                                      .extras[0],
                                                                  border: Border
                                                                      .all(),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5),
                                                            ],
                                                          ),
                                                          SizedBox(width: 7),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Material(
                                                  color: defaultPalette
                                                      .transparent,
                                                  child: InkWell(
                                                    hoverColor: defaultPalette
                                                        .extras[isPaid?0: layoutModel.type == SheetType.creditNote.index?3:4]
                                                        .withOpacity(0.4),
                                                    highlightColor:
                                                        defaultPalette.extras[isPaid?0: layoutModel.type == SheetType.creditNote.index?3:4]
                                                            .withOpacity(0.4),
                                                    splashColor: defaultPalette
                                                        .extras[isPaid?0: layoutModel.type == SheetType.creditNote.index?3:4]
                                                        .withOpacity(0.4),
                                                    onTap: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                        builder: (context) {
                                                          //unsubscribeStream();
                                                          return PopScope(
                                                            canPop: false,
                                                            child:
                                                                LayoutDesigner(
                                                              id: Boxes.getLayouts(ref).keyAt(i),
                                                              // layoutModel: layoutModel,
                                                              onPop: (pdf) {
                                                              setState(() {
                                                                filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                              });
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
                                                      color: defaultPalette
                                                          .transparent,
                                                      child: Row(
                                                        children: [
                                                          //billname
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 12,
                                                                      top: 0),
                                                              child: Text(
                                                                layoutModel
                                                                    .name,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontSize:
                                                                      mapValueDimensionBased(
                                                                          20,
                                                                          30,
                                                                          sWidth,
                                                                          sHeight),
                                                                  color: defaultPalette
                                                                      .extras[0],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      -0.2,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          //billname and created modified
                                                          _getCreatedAndModified(
                                                              layoutModel,
                                                              sWidth,
                                                              sHeight,
                                                              !isLayoutTileView,
                                                              isBill: true),
                                                          SizedBox(width: 5),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              //make a revised bill out of a bill button
                                                              Tooltip(
                                                                message:
                                                                    '  Create a revised ${(SheetType.values[layoutModel.type].name == 'none' ? 'document' : SheetType.values[layoutModel.type].name)} of ${layoutModel.name}.  ',
                                                                textStyle:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontSize:
                                                                      mapValueDimensionBased(
                                                                          15,
                                                                          20,
                                                                          sWidth,
                                                                          sHeight),
                                                                  color: defaultPalette
                                                                      .primary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      -0.2,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    color: defaultPalette
                                                                        .extras[
                                                                            0]
                                                                        .withOpacity(
                                                                            0.8),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50)),
                                                                child:
                                                                    ElevatedLayerButton(
                                                                  onClick: () async {
                                                                    final box =
                                                                        Boxes
                                                                            .getLayouts(ref);
                                                                    final name =
                                                                        Boxes
                                                                            .getBillName(ref);
                                                                    var key =
                                                                        'BI-${const Uuid().v4()}';
                                                                    var prevLm =
                                                                        box.getAt(
                                                                            i);
                                                                    // keyIndex = box.length;
                                                                    var lm = LayoutModel(
                                                                      createdAt: DateTime .now(),
                                                                      modifiedAt: DateTime .now(),
                                                                      name: '${prevLm?.name ?? ''}-revised',
                                                                      docPropsList: prevLm?.docPropsList ?? [],
                                                                      spreadSheetList: prevLm?.spreadSheetList ?? [],
                                                                      id: key,
                                                                      type: prevLm?.type??0,
                                                                      labelList:prevLm?.labelList??tempLayoutModel.labelList,
                                                                      pdf: prevLm?.pdf,
                                                                      sheetDecorationMap: prevLm?.sheetDecorationMap
                                                                    );
                                          
                                                                    await box.put(key,lm);
                                                                    lm.save();
                                                                    saveFile(lm);
                                                                   //unsubscribeStream();
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (c) => Material(
                                                                                    child: PopScope(
                                                                                  child: LayoutDesigner(
                                                                                    id: key,
                                                                                    // layoutModel: lm,
                                                                                    onPop: (pdf) {
                                                                                    setState(() {
                                                                                        filteredLayoutBox = Boxes.getLayouts(ref).values.toList();
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                  canPop: false,
                                                                                ))));
                                                                  },
                                                                  buttonHeight:
                                                                      20,
                                                                  buttonWidth:
                                                                      20,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                  animationCurve:
                                                                      Curves
                                                                          .ease,
                                                                  topDecoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border
                                                                        .all(),
                                                                  ),
                                                                  subfac: 1,
                                                                  depth: 1,
                                                                  topLayerChild:
                                                                      Icon(
                                                                    TablerIcons
                                                                        .edit,
                                                                    size: 12,
                                                                  ),
                                                                  baseDecoration:
                                                                      BoxDecoration(
                                                                    color: defaultPalette
                                                                        .extras[0],
                                                                    border: Border
                                                                        .all(),
                                                                  ),
                                                                ),
                                                              ),
                                          
                                                              //Delete a bill button
                                                              SizedBox(
                                                                  height: 5),
                                                              ElevatedLayerButton(
                                                                onClick:
                                                                    () async {
                                                                      await showConfirmDeleteDialog(context, () async {
                                                                  final layoutsBox = Boxes.getLayouts(ref);
                                                                  // Delete the item
                                                                  // await layoutsBox.get(layoutsBox.keyAt(i))?.delete();
                                                                  layoutsBox.get(layoutsBox.keyAt(i))?..deleted = true..save();
                                                                  setState(() {});
                                                                }, sWidth, sHeight, 'Are you sure you want to delete this bill?');
                                                                
                                                                  
                                                                
                                                                },
                                                                buttonHeight:20,
                                                                buttonWidth: 20,
                                                                borderRadius: BorderRadius.circular( 10),
                                                                animationDuration: const Duration( milliseconds: 200),
                                                                animationCurve: Curves.ease,
                                                                topDecoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  border: Border.all(),
                                                                ),
                                                                topLayerChild:
                                                                    Icon(
                                                                  TablerIcons
                                                                      .trash,
                                                                  size: 12,
                                                                ),
                                                                subfac: 1,
                                                                depth: 1,
                                                                baseDecoration:
                                                                    BoxDecoration(
                                                                  color: defaultPalette
                                                                      .extras[0],
                                                                  border: Border
                                                                      .all(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 10),
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
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // charts revenue analyticalBGBLACCKKKK
              AnimatedPositioned(
                duration: Durations.medium2,
                right: 15-5,
                // left: 90+5,
                top: isBillTab ? 60+5 : sHeight / 4,
                child:AnimatedContainer(
                  duration: Durations.extralong1,
                  curve: Curves.decelerate,
                  transform: Matrix4.identity()
                    // Translate
                    ..translate(
                      isBillTab ? 0.0 : -300.0,
                      isBillTab ? 0.0 : -160.0,
                    )
                    // Rotate (in radians)
                    ..rotateZ(isBillTab ? 0 : 0.7)
                    
                  // Skew-like effect
                    ..setEntry(0, 1, isBillTab ? 0 : 1)
                    ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                    ..rotateX(isBillTab ? 0 : 0.8)
                    // Scale
                    ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6),
                  width: (sWidth / 1.73 - 100).clamp(0, double.infinity),
                  height: (sHeight / 1.8-10).clamp(0, double.infinity),
                  padding: EdgeInsets.all(5).copyWith(right: 10),
                  decoration: BoxDecoration(
                      color: defaultPalette.extras[0],
                      borderRadius: BorderRadius.circular(20)),
                  )
                ),
              // charts revenue analytical
              AnimatedPositioned(
                duration: Durations.medium2,
                // right: 15,
                // left: 90,
                right: 15,
                top: isBillTab ? 60 : sHeight / 4,
                width:(isBillTab ? (sWidth / 1.73 - 100).clamp(0, double.infinity):450),
                height:( sHeight / 1.8-10),
                child: ValueListenableBuilder(
                    valueListenable: Hive.box<LayoutModel>(ref.read(authPr).currentUser?.uid??'layouts').listenable(),
                    builder: (context, Box<LayoutModel> box, _) {
                      monthRevenueMap = {};
                      dayRevenueMap = {};
                      if (isDragging) {
                        dateTextControllers = [
                          TextEditingController()..text = monthNames[selectedMonth - 1],
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
                        if (layout.id.startsWith('LY-')) return false;
                        if (name.endsWith('-old')) return false;
                        if (layout.deleted?? false) return false;
                        if (revisedNames.contains(name))
                          return false; // exclude if revised version exists
                        return true;
                      }).toList();

                      totalRevenue = 0;
                      totalUnpaidRevenue = 0;
                      // 👇 Month-wise totalPayable collector with 'YYYY-MM' as key

                      for (final layout in layouts) {
                        try {
                          final totalPayableLabel = layout.labelList.firstWhere(
                            (lbl) => lbl.name == 'totalPayable',
                          );
                          final isPaidLabel = layout.labelList.firstWhere(
                            (lbl) => lbl.name == 'isPaid',
                            orElse:()=> RequiredText(name: 'isPaid', sheetTextType: SheetTextType.bool.index, indexPath: IndexPath(index: -951), isOptional: true),
                          );
                          final currencyLabel = layout.labelList.firstWhere(
                            (lbl) => lbl.name == 'currency',
                            orElse:()=> RequiredText(name: 'currency', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
                          );
                          // if (isPaidLabel.indexPath.index == -951) continue;
                          
                          final currencyItem = getItemAtPath(currencyLabel.indexPath, layout.spreadSheetList);
                          Currency currency = CurrencyService().findByCode(
                            currencyItem is! SheetTextBox
                            ? 'INR'
                            : buildCombinedTextFromBlocks((currencyItem).inputBlocks, layout.spreadSheetList))??CurrencyService().findByCode('INR')!;
                            
                          
                          final isPaidItem = getItemAtPath(isPaidLabel.indexPath, layout.spreadSheetList);
                          // print(item);
                          // if (isPaidItem is! SheetTextBox) continue;
                          // print(item.inputBlocks);
                          
                          final isPaid =isPaidItem is! SheetTextBox? 'false': buildCombinedTextFromBlocks((isPaidItem).inputBlocks, layout.spreadSheetList);

                          if ( totalPayableLabel.indexPath.index != -951 ) {
                            final item = getItemAtPath(
                              totalPayableLabel.indexPath,
                              layout.spreadSheetList);
                            if (item is SheetTextBox) {
                              final rawText = buildCombinedTextFromBlocks(item.inputBlocks, layout.spreadSheetList);
                              double value = double.tryParse(rawText.replaceAll(RegExp(r'[^0-9.]'), '')) ??0;
                              // print(value.toString()+currency.code.toString()+layout.name);
                              // print(ref.read(currencyCodeProvider).code);
                              if (currency.code != ref.read(currencyCodeProvider).code) {
                                try {
                                  final rates = ref.read(fxRatesProvider);
                                  // print('rates::'+ref.read(fxRatesProvider).toString());
                                  value = convertCurrency(
                                    amount: value,
                                    from: currency.code,
                                    to: ref.read(currencyCodeProvider).code,
                                    rates: rates,
                                  );
                                  // print(value.toString()+ref.read(currencyCodeProvider).code.toString()+layout.name);
                                } catch (e) {
                                  // Handle conversion error, e.g., log it
                                  // print('Currency conversion error: $e');
                                  value = value; // Fallback to original value if conversion fails
                                }
                                
                              }
                              // If it's a credit note, negate the value
                              if (layout.type == SheetType.creditNote.index) {
                                value *= -1;
                              }
                              if (layout.type == SheetType.proformaInvoice.index ) {
                                value *= 0;
                              }
                              
                              if(isPaid == 'true'){
                              totalRevenue += value;

                              if (layout.createdAt.year == selectedYear) {
                                final month = layout.createdAt.month
                                    .ceilToDouble(); // 1 to 12
                                monthRevenueMap.update(
                                    month, (existing) => existing + value,
                                    ifAbsent: () => value);
                              }
                              final date = layout.createdAt;
                              if (date.year == selectedYear &&
                                  date.month == selectedMonth) {
                                final day = date.day.toDouble(); // 1 to 31
                                dayRevenueMap.update(
                                    day, (existing) => existing + value,
                                    ifAbsent: () => value);
                              }} else{
                                totalUnpaidRevenue +=value;
                              }
                            }
                          }
                        } catch (_) {
                          // Skip this layout
                        }
                      }

                      // Ensure all months and days are initialized
                      monthRevenueMap = Map.fromEntries(
                        List.generate(12, (i) => i + 1).map((month) => MapEntry(
                            month.ceilToDouble(),
                            monthRevenueMap[month.toDouble()] ?? 0)),
                      );

                      final daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
                      dayRevenueMap = Map.fromEntries(
                        List.generate(daysInMonth, (i) => i + 1).map((day) =>
                            MapEntry(day.toDouble(),
                                dayRevenueMap[day.toDouble()] ?? 0)),
                      );

                      
                      return AnimatedContainer(
                      duration: Durations.extralong1,
                      curve: Curves.decelerate,
                      transform: Matrix4.identity()
                      // Translate
                      ..translate(
                        isBillTab ? 0.0 : -300.0,
                        isBillTab ? 0.0 : -160.0,
                      )
                      // Rotate (in radians)
                      ..rotateZ(isBillTab ? 0 : 0.7)
                      
                      // Skew-like effect
                      ..setEntry(0, 1, isBillTab ? 0 : 1)
                      ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                      ..rotateX(isBillTab ? 0 : 0.8)
                      // Scale
                      ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6),
                    
                      width:isBillTab ? sWidth / 1.73 - 100:450,
                      height: sHeight / 1.8-10,
                      padding: EdgeInsets.all( mapValueDimensionBased(5, 10, sWidth, sHeight)).copyWith(right:  mapValueDimensionBased(10, 20, sWidth, sHeight)),
                      decoration: BoxDecoration(
                          color: defaultPalette.primary,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20)),
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
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                TablerIcons.chart_dots_3,
                                size: mapValueDimensionBased(
                                    20, 25, sWidth, sHeight),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  'Revenue',
                                  style: TextStyle(                                fontFamily: 'Lexend',
                                      fontSize: mapValueDimensionBased(
                                          20, 23, sWidth, sHeight),
                                      color: defaultPalette.extras[0],
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -1),
                                ),
                              ),
                              ...datePropertyTile(1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        //yearly revenue
                        Expanded(
                            child: LineChart(
                          LineChartData(
                            backgroundColor: defaultPalette.secondary,
                            lineTouchData: LineTouchData(
                              touchSpotThreshold: 25,
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                final isMainChart = barData.barWidth == 5;
                                return spotIndexes.map((spotIndex) {
                                  final spot = barData.spots[spotIndex];
                                  if (!isMainChart) {
                                    return TouchedSpotIndicatorData(
                                      FlLine(
                                          strokeWidth: 0,
                                          color: Colors.transparent),
                                      FlDotData(show: false),
                                    );
                                  }
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: defaultPalette.tertiary,
                                      strokeWidth: 4,
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 8,
                                          color: defaultPalette.primary,
                                          strokeWidth: 5,
                                          strokeColor:
                                              defaultPalette.tertiary,
                                        );
                                      },
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpot) =>
                                    defaultPalette.extras[0],
                                getTooltipItems:
                                    (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    final flSpot = barSpot;
                                    if (barSpot.x == 0 ||
                                        barSpot.x == 13 ||
                                        barSpot.barIndex == 1) {
                                      return null;
                                    }

                                    return LineTooltipItem(
                                        '${monthNames[(barSpot.x - 1).clamp(0, 12).round()]}',
                                        TextStyle(                                fontFamily: 'Lexend',
                                          color: defaultPalette.tertiary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' Revenue: \n',
                                            style: TextStyle(                                fontFamily: 'Lexend',
                                              color: defaultPalette.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                _currencyFormatter
                                                    .format(monthRevenueMap[
                                                        (barSpot.x)
                                                            .clamp(1, 12)
                                                            .round()]??0),
                                            style: TextStyle(                                fontFamily: 'Lexend',
                                              color: defaultPalette.primary,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                        textAlign: TextAlign.left);
                                  }).toList();
                                },
                              ),
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? lineTouch) {
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
                                  for (var entry in monthRevenueMap.entries)
                                    FlSpot(entry.key, entry.value),
                                  const FlSpot(13, 0),
                                ],
                                isCurved: false,
                                barWidth: 5,
                                color: defaultPalette.secondary,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      defaultPalette.extras[0],
                                      defaultPalette.extras[0],
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
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotSquarePainter(
                                      size: 8.5,
                                      color: defaultPalette.primary,
                                      strokeWidth: 3,
                                      strokeColor: defaultPalette.extras[0],
                                    );
                                  },
                                  checkToShowDot: (spot, barData) {
                                    return (spot.y > 1 && spot.x != 0);
                                  },
                                ),
                              ),
                              LineChartBarData(
                                isStepLineChart: true,
                                spots: [
                                  const FlSpot(0, 0),
                                  for (var entry in monthRevenueMap.entries)
                                    entry.value < 0
                                        ? FlSpot(entry.key, (entry.value))
                                        : FlSpot(entry.key, 0),
                                  const FlSpot(13, 0),
                                ],
                                isCurved: false,
                                barWidth: 2,
                                color: defaultPalette.secondary,
                                belowBarData: BarAreaData(
                                  show: true,
                                  applyCutOffY: true,
                                  cutOffY: 0,
                                  gradient: LinearGradient(
                                    colors: [
                                      defaultPalette.extras[0],
                                      defaultPalette.extras[0],
                                    ],
                                    stops: [0.5, 1],
                                    begin: Alignment(0, 0),
                                    end: Alignment(0, 3),
                                  ),
                                  spotsLine: BarAreaSpotsLine(
                                    show: true,
                                    flLineStyle: FlLine(
                                      color: defaultPalette.extras[0],
                                      strokeWidth: mapValueDimensionBased(
                                          25, 80, sWidth, sHeight,
                                          useWidth: true),
                                    ),
                                  ),
                                ),
                                dotData: FlDotData(
                                  show: monthRevenueMap.values.reduce(min) <
                                      -1,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotSquarePainter(
                                      size: 8.5,
                                      color: defaultPalette.primary,
                                      strokeWidth: 3,
                                      strokeColor: defaultPalette.extras[0],
                                    );
                                  },
                                  checkToShowDot: (spot, barData) {
                                    return (spot.y.round() != 0 &&
                                        spot.x != 0 &&
                                        (spot.y < 0));
                                  },
                                ),
                              ),
                            ],
                            minY: monthRevenueMap.values.fold(0.0,
                                (min, val) => val < (min ?? 0) ? val : min),
                            maxY: max(
                                monthRevenueMap.values.isNotEmpty
                                    ? monthRevenueMap.values.reduce(max)
                                    : 0,
                                1),
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
                                  return FlLine(
                                    color: defaultPalette.tertiary,
                                    strokeWidth: 2,
                                  );
                                } else {
                                  return FlLine(
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
                                  return FlLine(
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
                                  reservedSize: mapValueDimensionBased(
                                      25, 38, sWidth, sHeight),
                                  interval: getSmartInterval(
                                    max(
                                        monthRevenueMap.values.isNotEmpty
                                            ? monthRevenueMap.values
                                                .reduce(max)
                                            : 0,
                                        1),
                                  ),
                                  getTitlesWidget: (value, meta) {
                                    if (meta.min == value ||
                                        meta.max == value ||
                                        value == 0) {
                                      return const SizedBox
                                          .shrink(); // Hide first and last labels
                                    }
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                      ref.read(currencyCodeProvider).symbol +  meta.formattedValue.toLowerCase(),
                                        style: TextStyle(                                fontFamily: 'Lexend',
                                          fontSize: mapValueDimensionBased(
                                              10, 15, sWidth, sHeight),
                                          letterSpacing: -1,
                                        ),
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
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0 || value == 13) {
                                      return SizedBox.shrink();
                                    }
                                    return Text(
                                      monthNames[(value - 1)
                                          .clamp(0, double.infinity)
                                          .round()],
                                      style: TextStyle(                                fontFamily: 'Lexend',
                                        fontSize: mapValueDimensionBased(
                                            10, 15, sWidth, sHeight),
                                        letterSpacing: -1,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )),
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
                        Expanded(
                            child: LineChart(
                          LineChartData(
                            backgroundColor: defaultPalette.secondary,
                            lineTouchData: LineTouchData(
                              touchSpotThreshold: 25,
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                final isMainChart = barData.barWidth == 5;

                                return spotIndexes.map((spotIndex) {
                                  final spot = barData.spots[spotIndex];
                                  if (!isMainChart) {
                                    return TouchedSpotIndicatorData(
                                      FlLine(
                                          strokeWidth: 0,
                                          color: Colors.transparent),
                                      FlDotData(show: false),
                                    );
                                  }

                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: defaultPalette.tertiary,
                                      strokeWidth: 4,
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 8,
                                          color: defaultPalette.primary,
                                          strokeWidth: 5,
                                          strokeColor:
                                              defaultPalette.tertiary,
                                        );
                                      },
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                maxContentWidth: 220,
                                getTooltipColor: (touchedSpot) =>
                                    defaultPalette.tertiary,
                                getTooltipItems:
                                    (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    final flSpot = barSpot;

                                    if (barSpot.x == 0 ||
                                        barSpot.x == 32 ||
                                        DateTime(
                                                    selectedYear,
                                                    selectedMonth,
                                                    barSpot.x.toInt())
                                                .month !=
                                            selectedMonth ||
                                        barSpot.barIndex == 1) {
                                      return null;
                                    }

                                    return LineTooltipItem(
                                        '${DateFormat.MMMMEEEEd().format(DateTime(selectedYear, selectedMonth, barSpot.x.toInt()))}${getOrdinal(barSpot.x.toInt())}\n',
                                        TextStyle(                                fontFamily: 'Lexend',
                                          color: defaultPalette.extras[0],
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Revenue: \n',
                                            style: TextStyle(                                fontFamily: 'Lexend',
                                              color: defaultPalette.primary,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                _currencyFormatter
                                                    .format(dayRevenueMap[
                                                        (barSpot.x)
                                                            .clamp(1, 31)
                                                            .round()]??0),
                                            style: TextStyle(                                fontFamily: 'Lexend',
                                              color: defaultPalette.primary,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                        textAlign: TextAlign.left);
                                  }).toList();
                                },
                              ),
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? lineTouch) {
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
                            extraLinesData: ExtraLinesData(),
                            lineBarsData: [
                              LineChartBarData(
                                isStepLineChart: true,
                                spots: [
                                  const FlSpot(0, 0),
                                  for (var entry in dayRevenueMap.entries)
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
                                  gradient: LinearGradient(
                                    colors: [
                                      defaultPalette.extras[0],
                                      defaultPalette.extras[0],
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
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotSquarePainter(
                                      size: 8.5,
                                      color: defaultPalette.primary,
                                      strokeWidth: 3,
                                      strokeColor: defaultPalette.extras[0],
                                    );
                                  },
                                  checkToShowDot: (spot, barData) {
                                    return (spot.y > 1 && spot.x != 0);
                                  },
                                ),
                              ),
                              LineChartBarData(
                                isStepLineChart: true,
                                spots: [
                                  const FlSpot(0, 0),
                                  for (var entry in dayRevenueMap.entries)
                                    entry.value < 0
                                        ? FlSpot(entry.key, (entry.value))
                                        : FlSpot(entry.key, 0),
                                  const FlSpot(32, 0),
                                ],
                                isCurved: false,
                                barWidth: 2,
                                color: defaultPalette.secondary,
                                belowBarData: BarAreaData(
                                  show: true,
                                  applyCutOffY: true,
                                  cutOffY: 0,
                                  gradient: LinearGradient(
                                    colors: [
                                      defaultPalette.extras[0],
                                      defaultPalette.extras[0],
                                    ],
                                    stops: [0.5, 1],
                                    begin: Alignment(0, 0),
                                    end: Alignment(0, 3),
                                  ),
                                  spotsLine: BarAreaSpotsLine(
                                    show: true,
                                    flLineStyle: FlLine(
                                      color: defaultPalette.extras[0],
                                      strokeWidth: mapValueDimensionBased(
                                          6, 30, sWidth, sHeight,
                                          useWidth: true),
                                    ),
                                  ),
                                ),
                                dotData: FlDotData(
                                  show: dayRevenueMap.values.fold(
                                          0.0,
                                          (min, val) => val < (min ?? 0)
                                              ? val
                                              : min) <
                                      0,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotSquarePainter(
                                      size: 8.5,
                                      color: defaultPalette.primary,
                                      strokeWidth: 3,
                                      strokeColor: defaultPalette.extras[0],
                                    );
                                  },
                                  checkToShowDot: (spot, barData) {
                                    return (spot.y.round() != 0 &&
                                        spot.x != 0);
                                  },
                                ),
                              ),
                            ],
                            minY: dayRevenueMap.values.fold(0.0,
                                (min, val) => val < (min ?? 0) ? val : min),
                            maxY: max(
                                dayRevenueMap.values.isNotEmpty
                                    ? dayRevenueMap.values.reduce(max)
                                    : 0,
                                1),
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
                                    width:
                                        dayRevenueMap.values.reduce(min) < 0
                                            ? 12
                                            : 5),
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
                                  return FlLine(
                                    color: defaultPalette.tertiary,
                                    strokeWidth: 2,
                                  );
                                } else {
                                  return FlLine(
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
                                  return FlLine(
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
                                  reservedSize: mapValueDimensionBased(
                                      25, 38, sWidth, sHeight),
                                  interval: getSmartInterval(
                                      max(
                                          dayRevenueMap.values.isNotEmpty
                                              ? dayRevenueMap.values
                                                  .reduce(max)
                                              : 0,
                                          1),
                                      minValue:
                                          dayRevenueMap.values.reduce(min)),
                                  getTitlesWidget: (value, meta) {
                                    if (meta.min == value ||
                                        (!isCleanRoundedNumber(meta.max) &&
                                                meta.max == value ||
                                            value == 0)) {
                                      return const SizedBox.shrink();
                                    }
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                      ref.read(currencyCodeProvider).symbol + meta.formattedValue.toLowerCase(),
                                        style: TextStyle(                                fontFamily: 'Lexend',
                                          fontSize: mapValueDimensionBased(
                                              10, 15, sWidth, sHeight),
                                          letterSpacing: -1,
                                        ),
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
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0 || value == 32) {
                                      return SizedBox.shrink();
                                    }
                                    return Text(
                                      (value)
                                          .clamp(0, double.infinity)
                                          .round()
                                          .toString(),
                                      style: TextStyle(                                fontFamily: 'Lexend',
                                        fontSize: mapValueDimensionBased(
                                            10, 15, sWidth, sHeight),
                                        letterSpacing: -1,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ))
                      ],
                    ),
                  );
                }),
              ),
              // summary analyticalBGGBLACCKKKK
              AnimatedPositioned(
                duration: Durations.medium2,
                // right: 15,
                // left: 90+5,
                right: 15-5,
                top: isBillTab ? 70 + sHeight / 1.8 +5: sHeight / 4,
                child: AnimatedContainer(
                      duration: Durations.extralong1,
                  curve: Curves.decelerate,
                  transform: Matrix4.identity()
                    // // Translate
                    // ..translate(
                    //   isBillTab ? 0.0 : -300.0,
                    //   isBillTab ? 0.0 : -160.0,
                    // )
                    // Rotate (in radians)
                    ..rotateZ(isBillTab ? 0 : 0.7)
                    
                  // Skew-like effect
                    ..setEntry(0, 1, isBillTab ? 0 : 1)
                    ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                    ..rotateX(isBillTab ? 0 : 0.8)
                    // Scale
                    ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6)
                    ,
                        width: ((sWidth / 1.73 - 100) / 2 -10).clamp(0, double.infinity),
                        height: (sHeight - (sHeight / 1.8) - 90).clamp(0, double.infinity), // 90 is 70+10+10, 70 for the top bar, 10 for the bottom padding, and 10 for the padding in between the chart above
                        padding: EdgeInsets.all(5).copyWith(
                            right: 8,
                            bottom: 8,
                            left:
                                mapValueDimensionBased(8, 10, sWidth, sHeight)),
                        decoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            borderRadius: BorderRadius.circular(20)),)
              ),
              // summary analytical
              AnimatedPositioned(
                duration: Durations.medium2,
                right: 15,
                // left: 90,
                top: isBillTab ? 70 + sHeight / 1.8 : sHeight / 4,
                child: ValueListenableBuilder(
                    valueListenable:
                        Hive.box<LayoutModel>(ref.read(authPr).currentUser?.uid??'layouts').listenable(),
                    builder: (context, Box<LayoutModel> box, _) {
                      final allLayouts = box.values.toList();

                      // Collect all revised layout base names
                      final revisedNames = allLayouts
                          .where((l) => l.name.endsWith('-revised'))
                          .map((l) => l.name.replaceAll('-revised', ''))
                          .toSet();
                      
                      // print('hello');
                      // Now filter the layouts
                      final layouts = allLayouts.where((layout) {
                        final name = layout.name;
                        if (layout.id.startsWith('LY-')) return false;
                        if (name.endsWith('-old')) return false;
                        if (layout.deleted?? false) return false;
                        if (revisedNames.contains(name)) return false; // exclude if revised version exists
                        return true;
                      }).toList();
                      typeStats = {};
                      totalProfit = 0;
                      totalUnpaid = 0;
                      totalBills = layouts .where((l) => SheetType.values[ l.type] !=SheetType.none).length;
                      for (final layout in layouts) {
                        final type = SheetType.values[layout.type];
                        // print(layout.name);
                        double totalPayable = 0;
                        double profit = 0;
                        var isPaid = false;
                        if (type == SheetType.proformaInvoice) {
                          continue;
                        }

                        try {
                          final totalPayableLabel = layout.labelList.firstWhere(
                            (lbl) => lbl.name == 'totalPayable',
                          );
                          final isPaidLabel = layout.labelList.firstWhere(
                            (lbl) => lbl.name == 'isPaid',
                            orElse:()=> RequiredText(name: 'isPaid', sheetTextType: SheetTextType.bool.index, indexPath: IndexPath(index: -951), isOptional: true),
                          );
                          final currencyLabel = layout.labelList.firstWhere(
                            (lbl) => lbl.name == 'currency',
                            orElse:()=> RequiredText(name: 'currency', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
                          );
                          // if (isPaidLabel.indexPath.index == -951) continue;
                          
                          final currencyItem = getItemAtPath(currencyLabel.indexPath, layout.spreadSheetList);
                          Currency currency = CurrencyService().findByCode(
                            currencyItem is! SheetTextBox
                            ? 'INR'
                            : buildCombinedTextFromBlocks((currencyItem).inputBlocks, layout.spreadSheetList))??CurrencyService().findByCode('INR')!;
                          

                          final isPaidItem = getItemAtPath(isPaidLabel.indexPath, layout.spreadSheetList);
                          
                          isPaid =bool.tryParse(isPaidItem is! SheetTextBox? 'false': buildCombinedTextFromBlocks((isPaidItem).inputBlocks, layout.spreadSheetList))??false;
                          // print( isPaid);
                          // print(totalPayableLabel.indexPath);
                          if (totalPayableLabel != null && totalPayableLabel.indexPath.index != -951 ) {
                            final item = getItemAtPath(
                              totalPayableLabel.indexPath,
                              layout.spreadSheetList);
                            //  print(item);

                            if (item is SheetTextBox) {
                              try {
                                final rawText = buildCombinedTextFromBlocks(item.inputBlocks, layout.spreadSheetList);
                                double value = double.tryParse(rawText.replaceAll(RegExp(r'[^0-9.]'), '')) ??0;
                                // print('rawText:'+rawText);
                                if (currency.code != ref.read(currencyCodeProvider).code) {
                                  try {
                                    final rates = ref.read(fxRatesProvider);
                                    // print('rates::'+ref.read(fxRatesProvider).toString());
                                    value = convertCurrency(
                                      amount: value,
                                      from: currency.code,
                                      to: ref.read(currencyCodeProvider).code,
                                      rates: rates,
                                    );
                                    // print(value.toString()+ref.read(currencyCodeProvider).code.toString()+layout.name);
                                  } catch (e) {
                                    // Handle conversion error, e.g., log it
                                    // print('Currency conversion error: $e');
                                    value = value; // Fallback to original value if conversion fails
                                  }
                                  
                                }
                                // If it's a credit note, negate the value
                                if (layout.type == SheetType.creditNote.index) {
                                  value *= -1;
                                }
                                if (layout.type == SheetType.proformaInvoice.index ) {
                                  value *= 0;
                                }
                                
                                // if(isPaid){
                                  totalPayable =value;
                                  // print(totalPayable);
                                  // print(label.indexPath);
                                
                                // } 
                              } on Exception catch (e,st) {
                                print(st);
                              }
                            }
                          }

                          
                          for (final label in layout.labelList) {
                           
                            if (label.indexPath.index == -951) continue;
                            if (label.name != 'profits') continue;
                            final item = getItemAtPath(label.indexPath, layout.spreadSheetList);
                            // print(item);
                            if (item is! SheetTextBox) continue;
                            // print(item.inputBlocks);

                            final rawText = buildCombinedTextFromBlocks(item.inputBlocks, layout.spreadSheetList);
                            var cleaned = double.tryParse(rawText.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
                            if (currency.code != ref.read(currencyCodeProvider).code) {
                                try {
                                  final rates = ref.read(fxRatesProvider);
                                  // print('rates::'+ref.read(fxRatesProvider).toString());
                                  cleaned = convertCurrency(
                                    amount: cleaned,
                                    from: currency.code,
                                    to: ref.read(currencyCodeProvider).code,
                                    rates: rates,
                                  );
                                  // print(value.toString()+ref.read(currencyCodeProvider).code.toString()+layout.name);
                                } catch (e) {
                                  // Handle conversion error, e.g., log it
                                  // print('Currency conversion error: $e');
                                  cleaned = cleaned; // Fallback to original value if conversion fails
                                }
                                
                              }
                           if (label.name == 'profits') {
                              profit = cleaned;
                            } 
                            
                          }
                        } catch (_) {
                          // silently skip errors
                        }

                        // Update or initialize the stat object
                        typeStats[type] = {
                          'count': (typeStats[type]?['count'] ?? 0) + 1,
                          'payable': (typeStats[type]?['payable'] ?? 0.0) + (isPaid?totalPayable:0),
                          'profit': (typeStats[type]?['profit'] ?? 0.0) + (isPaid?profit:0),
                          'unpaid':  (typeStats[type]?['unpaid'] ?? 0) +(isPaid?0:1),
                          'unpaidRevenue': (typeStats[type]?['unpaidRevenue'] ?? 0.0) +(isPaid?0:totalPayable)
                        };
                        // print('typeStats:'+typeStats[type].toString() +'and isPaid:' +(isPaid?0:totalPayable).toString());
                        if (!isPaid) {
                          totalUnpaid +=1;
                        } else {
                          totalProfit += profit;
                        }
                      }

                      return AnimatedContainer(
                      duration: Durations.extralong1,
                      curve: Curves.decelerate,
                      transform: Matrix4.identity()
                        // Translate
                        ..translate(
                          isBillTab ? 0.0 : -300.0,
                          isBillTab ? 0.0 : -160.0,
                        )
                        // Rotate (in radians)
                        ..rotateZ(isBillTab ? 0 : 0.7)
                        
                      // Skew-like effect
                        ..setEntry(0, 1, isBillTab ? 0 : 1)
                        ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                        ..rotateX(isBillTab ? 0 : 0.8)
                        // Scale
                        ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6),
                        width:isBillTab ? ((sWidth / 1.73 - 100) / 2 -10).clamp(0, double.infinity):80,
                        height:( sHeight - (sHeight / 1.8) - 90).clamp(0, double.infinity), // 90 is 70+10+10, 70 for the top bar, 10 for the bottom padding, and 10 for the padding in between the chart above
                        padding: EdgeInsets.all( mapValueDimensionBased(5, 10, sWidth, sHeight)).copyWith(
                            right:  mapValueDimensionBased(8, 10, sWidth, sHeight),
                            bottom: 8,
                            left: mapValueDimensionBased(8, 10, sWidth, sHeight)),
                        decoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border:Border.all(),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // title Revenue
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  TablerIcons.chart_arcs,
                                  size: mapValueDimensionBased(
                                      16, 30, sWidth, sHeight),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    'Summary',
                                    style: TextStyle(                                fontFamily: 'Lexend',
                                        fontSize: mapValueDimensionBased(
                                            15, 25, sWidth, sHeight),
                                        color: defaultPalette.extras[0],
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -1),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6000),
                                  child: Material(
                                    color: defaultPalette.transparent,
                                    child: InkWell(
                                      hoverColor: defaultPalette.extras[0].withOpacity(0.2),
                                      splashColor: defaultPalette.extras[0].withOpacity(0.2),
                                      highlightColor: defaultPalette.extras[0].withOpacity(0.2),
                                      onTap:()async{
                                        showCurrencySelectionDialog(context, ref);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                        child: Text(
                                        ref.read(currencyCodeProvider).symbol,
                                        style: TextStyle(                                fontFamily: 'Lexend',
                                            fontSize: mapValueDimensionBased(
                                                12, 25, sWidth, sHeight),
                                            color: defaultPalette.extras[0],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -1),
                                                                          ),
                                      ),
                                  
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: ScrollConfiguration(
                                behavior: ScrollBehavior()
                                    .copyWith(scrollbars: false),
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
                                              //Total Revenue
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  ...[
                                                    Icon(
                                                      TablerIcons.moneybag,
                                                      size:
                                                          mapValueDimensionBased(
                                                              15,
                                                              30,
                                                              sWidth,
                                                              sHeight),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      'Total Revenue',
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                                  10,
                                                                  23,
                                                                  sWidth,
                                                                  sHeight),
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -1),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      _currencyFormatter.format(totalRevenue),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                                  10,
                                                                  23,
                                                                  sWidth,
                                                                  sHeight),
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -1),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              //Total Profit
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox( width: 2,),
                                                  ...[
                                                    Icon(
                                                      TablerIcons.cash,
                                                      size: mapValueDimensionBased( 15, 30, sWidth, sHeight),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      'Total Profit',
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize: mapValueDimensionBased( 10, 23, sWidth, sHeight),
                                                          color: defaultPalette.extras[0],
                                                          fontWeight: FontWeight.w500,
                                                          letterSpacing: -1),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      _currencyFormatter.format(totalProfit),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize: mapValueDimensionBased( 10, 23, sWidth, sHeight),
                                                          color: defaultPalette.extras[0],
                                                          fontWeight: FontWeight.w500,
                                                          letterSpacing: -1),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              //Total Bills
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  ...[
                                                    Icon(
                                                      TablerIcons.file_stack,
                                                      size:
                                                          mapValueDimensionBased(
                                                              15,
                                                              30,
                                                              sWidth,
                                                              sHeight),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      'Total Bills',
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                                  10,
                                                                  23,
                                                                  sWidth,
                                                                  sHeight),
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -1),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      layouts
                                                          .where((l) =>
                                                              SheetType.values[
                                                                  l.type] !=
                                                              SheetType.none)
                                                          .length
                                                          .toString(),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                                  10,
                                                                  23,
                                                                  sWidth,
                                                                  sHeight),
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -1),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              //Total Unpaid
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox( width: 2,),
                                                  ...[
                                                    Icon(
                                                      TablerIcons.exclamation_circle,
                                                      size: mapValueDimensionBased( 15, 30, sWidth,sHeight),
                                                      color: defaultPalette.extras[totalUnpaid==0?0:4],
                                                    ),
                                                    SizedBox( width: 5,),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      'Total Unpaid',
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize: mapValueDimensionBased( 10,23,sWidth, sHeight),
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -1),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      totalUnpaid.toString(),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                        fontSize: mapValueDimensionBased( 10, 23, sWidth, sHeight),
                                                        color: defaultPalette.extras[totalUnpaid==0?0:4],
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: -1),
                                                    ),
                                                  ),
                                                  SizedBox( width: 5, ),
                                                ],
                                              ),
                                              //Total Unpaid Revenue
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  ...[
                                                    Icon(
                                                      TablerIcons.moneybag,
                                                      size: mapValueDimensionBased( 15,30, sWidth,sHeight),
                                                      color: defaultPalette.extras[totalUnpaidRevenue ==0.0?0:4],
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      'Total Pending',
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                                  10,
                                                                  23,
                                                                  sWidth,
                                                                  sHeight),
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight: FontWeight.w500,
                                                          letterSpacing: -0.5),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      _currencyFormatter.format(totalUnpaidRevenue),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                                  10,
                                                                  23,
                                                                  sWidth,
                                                                  sHeight),
                                                          color: defaultPalette
                                                              .extras[totalUnpaidRevenue ==0.0?0:4],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -0.5),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              
                                              SizedBox( height: 8, ),
                                              summaryTile(
                                                'Tax Invoices',
                                                typeStats[
                                                        SheetType.taxInvoice] ??
                                                    {
                                                      'count': 0,
                                                      'payable': 0.0,
                                                      'profit': 0.0,
                                                      'unpaid': 0,
                                                      'unpaidRevenue': 0.0,
                                                    },
                                                TablerIcons.file_invoice,
                                                sWidth,
                                                sHeight,
                                              ),
                                              summaryTile(
                                                'Credit Notes',
                                                typeStats[
                                                        SheetType.creditNote] ??
                                                    {
                                                      'count': 0,
                                                      'payable': 0.0,
                                                      'profit': 0.0,
                                                      'unpaid': 0,
                                                      'unpaidRevenue': 0.0,
                                                    },
                                                TablerIcons.credit_card_pay,
                                                sWidth,
                                                sHeight,
                                              ),
                                              summaryTile(
                                                'Debit Notes',
                                                typeStats[
                                                        SheetType.debitNote] ??
                                                    {
                                                      'count': 0,
                                                      'payable': 0.0,
                                                      'profit': 0.0,
                                                      'unpaid': 0,
                                                      'unpaidRevenue': 0.0,
                                                    },
                                                TablerIcons.credit_card_refund,
                                                sWidth,
                                                sHeight,
                                              ),
                                              summaryTile(
                                                'Bills of Supply',
                                                typeStats[SheetType
                                                        .billOfSupply] ??
                                                    {
                                                      'count': 0,
                                                      'payable': 0.0,
                                                      'profit': 0.0,
                                                      'unpaid': 0,
                                                      'unpaidRevenue': 0.0,
                                                    },
                                                TablerIcons.receipt_2,
                                                sWidth,
                                                sHeight,
                                              ),
                                              summaryTile(
                                                'Proforma Invoices',
                                                typeStats[SheetType
                                                        .proformaInvoice] ??
                                                    {
                                                      'count': 0,
                                                      'payable': 0.0,
                                                      'profit': 0.0,
                                                      'unpaid': 0,
                                                      'unpaidRevenue': 0.0,
                                                    },
                                                TablerIcons.receipt_filled,
                                                sWidth,
                                                sHeight,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            
                          ],
                        ),
                      );
                    }),
              ),
              // charts quantity analyticalBGGBLLACCKK
              AnimatedPositioned(
                duration: Durations.medium2,
                right: 15+ (sWidth / 1.73 - 100) / 2 + 10-5,
                // left: 90 + (sWidth / 1.73 - 100) / 2 + 10+5,
                top: isBillTab ? 70 + sHeight / 1.8+5 : sHeight / 4,
                child: AnimatedContainer(
                      duration: Durations.extralong1,
                  curve: Curves.decelerate,
                  transform: Matrix4.identity()
                    // // Translate
                    // ..translate(
                    //   isBillTab ? 0.0 : -300.0,
                    //   isBillTab ? 0.0 : -160.0,
                    // )
                    // Rotate (in radians)
                    ..rotateZ(isBillTab ? 0 : 0.7)
                    
                  // Skew-like effect
                    ..setEntry(0, 1, isBillTab ? 0 : 1)
                    ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                    ..rotateX(isBillTab ? 0 : 0.8)
                    // Scale
                    ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6)
                    ,
                  width: ((sWidth / 1.73 - 100) / 2 - 10).clamp(0, double.infinity), // -10 because of the gap between the two charts
                  height: (sHeight - (sHeight / 1.8) - 90).clamp(0, double.infinity), // 90 is 70+10+10, 70 for the top bar, 10 for the bottom padding, and 10 for the padding in between the chart above
                  padding: EdgeInsets.all(5).copyWith(right: 5),
                  decoration: BoxDecoration(
                      color: defaultPalette.extras[0],
                      borderRadius: BorderRadius.circular(20)),)),
              // charts quantity analytical
              AnimatedPositioned(
                duration: Durations.medium2,
                right: 15+ (sWidth / 1.73 - 100) / 2 + 10,
                // left: 90 + (sWidth / 1.73 - 100) / 2 + 10,
                top: isBillTab ? 70 + sHeight / 1.8 : sHeight / 4,
                child: ValueListenableBuilder(
                    valueListenable:
                        Hive.box<LayoutModel>(ref.read(authPr).currentUser?.uid??'layouts').listenable(),
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
                        if (!layout.id.startsWith('BI-')) return false; // ✅ Only include 'BI-' layouts
                        if (name.endsWith('-old')) return false;
                        if (layout.deleted?? false) return false;
                        if (layout.type ==0) return false;
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
                            monthlyCounts[type] =
                                (monthlyCounts[type] ?? 0) + 1;
                          }
                        }
                      }
                      // Sort the monthlyCounts by index
                      monthlyCounts = Map.fromEntries(monthlyCounts.entries
                          .toList()
                        ..sort((a, b) => a.key.index.compareTo(b.key.index)));

                      return AnimatedContainer(
                      duration: Durations.extralong1,
                  curve: Curves.decelerate,
                  transform: Matrix4.identity()
                    // Translate
                    ..translate(
                      isBillTab ? 0.0 : -300.0,
                      isBillTab ? 0.0 : -160.0,
                    )
                    // Rotate (in radians)
                    ..rotateZ(isBillTab ? 0 : 0.7)
                    
                  // Skew-like effect
                    ..setEntry(0, 1, isBillTab ? 0 : 1)
                    ..setEntry(1, 0, isBillTab ? 0 : -0.4)
                    ..rotateX(isBillTab ? 0 : 0.8)
                    // Scale
                    ..scale(isBillTab ? 1.0 : 1.3, isBillTab ? 1.0 : 0.6),
                        width: ((sWidth / 1.73 - 100) / 2 - 10).clamp(0, double.infinity), // -10 because of the gap between the two charts
                        height: (sHeight - (sHeight / 1.8) - 90).clamp(0, double.infinity), // 90 is 70+10+10, 70 for the top bar, 10 for the bottom padding, and 10 for the padding in between the chart above
                        padding: EdgeInsets.all( mapValueDimensionBased(5, 10, sWidth, sHeight)).copyWith(right:  mapValueDimensionBased(5, 10, sWidth, sHeight)),
                        decoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  TablerIcons.tallymarks,
                                  size: mapValueDimensionBased(
                                      15, 30, sWidth, sHeight),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    'Quantity',
                                    style: TextStyle(                                fontFamily: 'Lexend',
                                        fontSize: mapValueDimensionBased(
                                            14, 23, sWidth, sHeight),
                                        color: defaultPalette.extras[0],
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -1),
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                  '$selectedMonth/${selectedYear.toString().substring(2, 4)}',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(                                fontFamily: 'Lexend',
                                    fontSize: mapValueDimensionBased(
                                        10, 15, sWidth, sHeight),
                                    color: defaultPalette.extras[0],
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                                SizedBox(
                                  width: 5,
                                ),
                                // ...datePropertyTile(2),
                              ],
                            ),
                            //type revenue
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 6.0, bottom: 5, left: 5),
                                        child: LineChart(
                                          LineChartData(
                                            backgroundColor:
                                                defaultPalette.secondary,
                                            lineTouchData: LineTouchData(
                                              touchSpotThreshold: 25,
                                              getTouchedSpotIndicator:
                                                  (LineChartBarData barData,
                                                      List<int> spotIndexes) {
                                                return spotIndexes
                                                    .map((spotIndex) {
                                                  final spot =
                                                      barData.spots[spotIndex];

                                                  return TouchedSpotIndicatorData(
                                                    FlLine(
                                                      color: defaultPalette
                                                          .tertiary,
                                                      strokeWidth: 4,
                                                    ),
                                                    FlDotData(
                                                      getDotPainter: (spot,
                                                          percent,
                                                          barData,
                                                          index) {
                                                        return FlDotCirclePainter(
                                                          radius: 8,
                                                          color: defaultPalette
                                                              .primary,
                                                          strokeWidth: 5,
                                                          strokeColor:
                                                              defaultPalette
                                                                  .tertiary,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                              touchTooltipData:
                                                  LineTouchTooltipData(
                                                maxContentWidth:
                                                    mapValueDimensionBased(120,
                                                        200, sWidth, sHeight),
                                                getTooltipColor:
                                                    (touchedSpot) =>
                                                        defaultPalette.tertiary,
                                                getTooltipItems:
                                                    (List<LineBarSpot>
                                                        touchedBarSpots) {
                                                  return touchedBarSpots
                                                      .map((barSpot) {
                                                    final flSpot = barSpot;
                                                    if (barSpot.x == 0 ||
                                                        barSpot.x ==
                                                            monthlyCounts
                                                                    .length +
                                                                1) {
                                                      return null;
                                                    }

                                                    return LineTooltipItem(
                                                        '${DateFormat.yMMMM().format(DateTime(selectedYear, selectedMonth))}\n',
                                                        TextStyle(                                fontFamily: 'Lexend',
                                                          color: defaultPalette
                                                              .extras[0],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                                  15,
                                                                  20,
                                                                  sWidth,
                                                                  sHeight),
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${monthlyCounts.keys.toList()[(barSpot.x - 1).clamp(0, monthlyCounts.length).round()].name}: \n',
                                                            style: GoogleFonts
                                                                .lexend(
                                                              color:
                                                                  defaultPalette
                                                                      .primary,
                                                              fontSize:
                                                                  mapValueDimensionBased(
                                                                      10,
                                                                      20,
                                                                      sWidth,
                                                                      sHeight),
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: NumberFormat
                                                                    .decimalPattern(
                                                                        'en_IN')
                                                                .format(monthlyCounts
                                                                    .values
                                                                    .toList()[(barSpot
                                                                            .x -
                                                                        1)
                                                                    .clamp(
                                                                        0,
                                                                        monthlyCounts
                                                                            .length)
                                                                    .round()]),
                                                            style: GoogleFonts
                                                                .lexend(
                                                              color:
                                                                  defaultPalette
                                                                      .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize:
                                                                  mapValueDimensionBased(
                                                                      10,
                                                                      20,
                                                                      sWidth,
                                                                      sHeight),
                                                            ),
                                                          ),
                                                        ],
                                                        textAlign:
                                                            TextAlign.left);
                                                  }).toList();
                                                },
                                              ),
                                              touchCallback:
                                                  (FlTouchEvent event,
                                                      LineTouchResponse?
                                                          lineTouch) {
                                                if (!event
                                                        .isInterestedForInteractions ||
                                                    lineTouch == null ||
                                                    lineTouch.lineBarSpots ==
                                                        null) {
                                                  setState(() {
                                                    // touchedValue = -1;
                                                  });
                                                  return;
                                                }
                                              },
                                            ),
                                            extraLinesData: ExtraLinesData(),
                                            lineBarsData: [
                                              LineChartBarData(
                                                isStepLineChart: true,
                                                spots: [
                                                  const FlSpot(0, 0),
                                                  for (final entry
                                                      in monthlyCounts.entries
                                                          .toList()
                                                        ..sort((a, b) => a
                                                            .key.index
                                                            .compareTo(
                                                                b.key.index)))
                                                    FlSpot(
                                                        entry.key.index
                                                            .toDouble(),
                                                        entry.value.toDouble()),
                                                  FlSpot(
                                                      monthlyCounts.length + 1,
                                                      0),
                                                ],
                                                isCurved: false,
                                                barWidth: 2,
                                                color: defaultPalette.extras[0],
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      defaultPalette.secondary,
                                                      defaultPalette.secondary,
                                                    ],
                                                    stops: [0.5, 1],
                                                    begin: Alignment(0, -1),
                                                    end: Alignment(0, 1),
                                                  ),
                                                  spotsLine: BarAreaSpotsLine(
                                                    show: false,
                                                    flLineStyle: FlLine(
                                                      color: defaultPalette
                                                          .extras[0],
                                                      strokeWidth: 1,
                                                    ),
                                                  ),
                                                ),
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent,
                                                      barData, index) {
                                                    return FlDotCirclePainter(
                                                      radius: 4.5,
                                                      color: defaultPalette
                                                          .primary,
                                                      strokeWidth: 2,
                                                      strokeColor:
                                                          defaultPalette
                                                              .extras[0],
                                                    );
                                                  },
                                                  checkToShowDot:
                                                      (spot, barData) {
                                                    return (spot.x != 0 &&
                                                        spot.x !=
                                                            monthlyCounts
                                                                    .length +
                                                                1);
                                                  },
                                                ),
                                              ),
                                            ],
                                            minY: 0,
                                            maxY: max(
                                                monthlyCounts.values.isNotEmpty
                                                    ? monthlyCounts.values
                                                        .reduce(max)
                                                        .toDouble()
                                                    : 0,
                                                1),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border(
                                                left: BorderSide(
                                                    color: defaultPalette
                                                        .secondary,
                                                    width: 0),
                                                right: BorderSide(
                                                    color: defaultPalette
                                                        .secondary,
                                                    width: 0),
                                                bottom: BorderSide(
                                                    color: defaultPalette
                                                        .secondary,
                                                    width: 5),
                                                top: BorderSide(
                                                    color: defaultPalette
                                                        .secondary,
                                                    width: 12),
                                              ),
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawHorizontalLine: false,
                                              drawVerticalLine: false,
                                              getDrawingHorizontalLine:
                                                  (value) {
                                                if (value == 0) {
                                                  return FlLine(
                                                    color:
                                                        defaultPalette.tertiary,
                                                    strokeWidth: 2,
                                                  );
                                                } else {
                                                  return FlLine(
                                                    color:
                                                        defaultPalette.tertiary,
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
                                                  return FlLine(
                                                    color:
                                                        defaultPalette.tertiary,
                                                    strokeWidth: 0.5,
                                                  );
                                                }
                                              },
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize:
                                                      mapValueDimensionBased(12,
                                                          38, sWidth, sHeight),
                                                  interval: getSmartInterval(
                                                    max(
                                                        monthlyCounts.values
                                                                .isNotEmpty
                                                            ? monthlyCounts
                                                                .values
                                                                .reduce(max)
                                                                .toDouble()
                                                            : 0,
                                                        1),
                                                  ),
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    if (meta.min == value ||
                                                        meta.max == value) {
                                                      return const SizedBox
                                                          .shrink(); // Hide first and last labels
                                                    }
                                                    return Text(
                                                      value.toString() + '  ',
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                        fontSize:
                                                            mapValueDimensionBased(
                                                                8,
                                                                15,
                                                                sWidth,
                                                                sHeight),
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
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    if (value == 0 ||
                                                        value ==
                                                            monthlyCounts
                                                                    .length +
                                                                1) {
                                                      return SizedBox.shrink();
                                                    }
                                                    return Text(
                                                      monthlyCounts.keys
                                                          .toList()[(value - 1)
                                                              .clamp(
                                                                  0,
                                                                  double
                                                                      .infinity)
                                                              .round()]
                                                          .name,
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                        fontSize:
                                                            mapValueDimensionBased(
                                                                10,
                                                                15,
                                                                sWidth,
                                                                sHeight),
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
                                          touchCallback: (FlTouchEvent event,
                                              pieTouchResponse) {
                                            setState(() {
                                              if (!event
                                                      .isInterestedForInteractions ||
                                                  pieTouchResponse == null ||
                                                  pieTouchResponse
                                                          .touchedSection ==
                                                      null) {
                                                touchedIndex = -1;
                                                return;
                                              }
                                              touchedIndex = pieTouchResponse
                                                  .touchedSection!
                                                  .touchedSectionIndex;
                                              // print('Touched index: $touchedIndex');
                                            });
                                          },
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                        ),
                                        sectionsSpace: 1,
                                        centerSpaceRadius:
                                            mapValueDimensionBasedLockOnDesync(
                                          10,
                                          50,
                                          sWidth,
                                          sHeight,
                                        ),
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
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCreatedAndModified(LayoutModel layoutModel, double sWidth,
      double sHeight, bool isNotLayoutTileView,
      {bool isBill = false, isRecent = false}) {
    double fontSize = isBill ? 10 :isRecent?8: 12;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //layoutname
          if (isNotLayoutTileView)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 15),
                child: Tooltip(
                  message:
                  layoutModel.name,
                  textStyle: TextStyle(                                fontFamily: 'Lexend',
                    fontSize: mapValueDimensionBased(15,20, sWidth, sHeight),
                    color:defaultPalette.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing:-0.2,
                  ),
                  decoration: BoxDecoration(
                      color: defaultPalette.extras[0].withOpacity( 0.8),
                      borderRadius: BorderRadius.circular( 50)),
                  child: Text(
                    layoutModel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(
                          isBill ? 18 :isRecent?10: 25, isBill ? 20 :isRecent?15: 35, sWidth, sHeight),
                      color: defaultPalette.extras[0],
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          //created modified and pages
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: isBill ? 0 : 5,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    // color:  defaultPalette.primary,
                    borderRadius: BorderRadius.circular(12),
                    // border: Border.all()
                  ),
                  padding: EdgeInsets.all(isBill
                      ? isNotLayoutTileView
                          ? 3
                          : 0
                      : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: isBill ? 8 : 15,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: RichText(
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(                                fontFamily: 'Lexend',
                              fontSize: fontSize,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.2,
                            ),
                            children: [
                              TextSpan(
                                text: 'Created: ',
                                style: TextStyle(                                fontFamily: 'Lexend',
                                    color: defaultPalette.extras[0]),
                              ),
                              TextSpan(
                                text: DateFormat("EEE MMM d, y 'at' h:mm a")
                                    .format(layoutModel.createdAt),
                                style:
                                    TextStyle(color: defaultPalette.extras[0]),
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
                            style: TextStyle(                                fontFamily: 'Lexend',
                              fontSize: fontSize,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.2,
                            ),
                            children: [
                              TextSpan(
                                text: 'Modified: ',
                                style: TextStyle(                                fontFamily: 'Lexend',
                                  color: defaultPalette.extras[0],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: DateFormat("EEE MMM d, y 'at' h:mm a")
                                    .format(layoutModel.modifiedAt),
                                style:
                                    TextStyle(color: defaultPalette.extras[0]),
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
                          style: TextStyle(                                fontFamily: 'Lexend',
                            fontSize: fontSize,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.2,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${SheetType.values[layoutModel.type].name} · ',
                              style: TextStyle(                                fontFamily: 'Lexend',
                                fontSize: fontSize,
                                color: defaultPalette.extras[0],
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Pages: ${layoutModel.spreadSheetList.isEmpty ? '1' : layoutModel.spreadSheetList.length.toString()}',
                              style: TextStyle(                                fontFamily: 'Lexend',
                                fontSize: fontSize,
                                color: defaultPalette.extras[0],
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: isBill ? 7 : 5,
                      ),
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

  Widget _getProfile(BuildContext context, WidgetRef ref,
      double topPadPosDistance, double titleFontSize) {
    final User? user = ref.watch(authPr).currentUser;
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    int homeScreenTabIndex = ref.watch(homeScreenTabIndexProvider);
    bool isHomeTab = homeScreenTabIndex == 0;
    bool isBillTab = homeScreenTabIndex == 2;
    bool isProfileTab = homeScreenTabIndex == 3;
    double dotSize = sHeight / 35;
    double fontSize = mapValueDimensionBasedLockOnDesyncWeb(
      10,15,sWidth,sHeight
    );
    // print(sWidth);
    return AnimatedPositioned(
      duration: Durations.short2,
      // top: (topPadPosDistance * 1.08),
      height: sHeight,
      child: IgnorePointer(
        ignoring: !isProfileTab,
        child: AnimatedOpacity(
          opacity: isProfileTab ? 1 : 0,
          duration: Duration(milliseconds: 100),
          child: Stack(
            children: [
              IgnorePointer(
                ignoring: !isProfileTab,
                child: Container(
                  // duration: Durations.extra,
                  height: sHeight,
                  width: sWidth,
                  alignment: Alignment.centerRight,
                  color: isHomeTab ? Colors.transparent : Colors.white,
                  padding: EdgeInsets.only(
                    top: 0,
                  ),
                  //ProfGraph
                  child: GraphWindow(sWidth: sWidth, sHeight: sHeight, s: 2)
                ),
              ),
              //leftSideButtons and elevated
              AnimatedPositioned(
                duration: Durations.medium2,
                bottom: isProfileTab ? 20 : -150,
                left:90,
                // right: isProfileTab
                //     ? mapValueDimensionBased(40, 50, sWidth, sHeight, useWidth: true)
                //     : -sWidth / 2,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color:Color(0xffd5d5d5),)
                        
                      )),
                    //secondary colored ground substitute
                    Positioned(
                    bottom:0,
                    child: Container(
                        width:(15 + 65 + 15 + 65 + 15 + 65 + 15 + 45) +
                          mapValueDimensionBasedLockOnDesync(-30, 250, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),
                        alignment: Alignment(0,0.8),
                        height:mapValueDimensionBasedLockOnDesync(60, 120, sWidth, sHeight),
                        decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(45).copyWith(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                          color:defaultPalette.secondary,),
                        
                      )),
                    //thanks gif
                    Positioned(
                      right:mapValueDimensionBasedLockOnDesync(5, 30, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),
                      bottom:mapValueDimensionBasedLockOnDesync(20, 60, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),
                      child: Image.asset(
                        'assets/images/pixelthanks.gif',
                        width: mapValueDimensionBasedLockOnDesync(60, 220, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),

                        gaplessPlayback: true, // prevents flickering on rebuild
                      ),
                    ),
                    //billblaze svg and text
                    Positioned(
                      left:20 + mapValueDimensionBasedLockOnDesync( 5, 10, sWidth, sHeight),
                      bottom:mapValueDimensionBasedLockOnDesyncWeb(120, 400, sWidth, sHeight,)-
                      mapValueDimensionBasedLockOnDesync(20, 60, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),
                      child: Stack(
                        children: [
                          SizedBox(
                            height:mapValueDimensionBasedLockOnDesyncWeb(60, 120, sWidth, sHeight,),
                            width:2*mapValueDimensionBasedLockOnDesyncWeb(60, 120, sWidth, sHeight,),
                            ),
                          SizedBox(
                            height:mapValueDimensionBasedLockOnDesyncWeb(60, 120, sWidth, sHeight,),
                            child: FittedBox(
                              fit:BoxFit.scaleDown,
                              child: SvgPicture.asset(
                                'assets/logos/billblazeLogoSplashTM.svg',
                                // height: 300,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom:0,
                            left: 0,
                            child: Container(
                              margin: EdgeInsets.only(left:mapValueDimensionBasedLockOnDesyncWeb(40, 80, sWidth, sHeight,)),
                              alignment: Alignment.bottomRight,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Billblaze',
                                      style: GoogleFonts.alexBrush(
                                        fontSize: mapValueDimensionBasedLockOnDesyncWeb(20, 40, sWidth, sHeight),
                                        color: defaultPalette.extras[0],
                                        letterSpacing: -1,
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: Transform.translate(
                                        offset: Offset(2, mapValueDimensionBasedLockOnDesyncWeb(-10, -25, sWidth, sHeight)), // adjust vertical position
                                        child: Text(
                                          'TM',// make it smaller
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: mapValueDimensionBasedLockOnDesyncWeb(6, 8, sWidth, sHeight),
                                            fontWeight: FontWeight.w500,
                                            color: defaultPalette.extras[0],
                                            decoration: TextDecoration.none, 
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //brought to you by
                    Positioned(
                      left:20 + mapValueDimensionBasedLockOnDesync( 5, 10, sWidth, sHeight),
                      bottom:mapValueDimensionBasedLockOnDesyncWeb(120, 400, sWidth, sHeight,)-
                      mapValueDimensionBasedLockOnDesyncWeb(40, 80, sWidth, sHeight,),
                      child: Stack(
                        children: [
                          SizedBox(
                            height:mapValueDimensionBasedLockOnDesyncWeb(60, 120, sWidth, sHeight,),
                            width:2*mapValueDimensionBasedLockOnDesyncWeb(60, 120, sWidth, sHeight,),
                            ),
                          Positioned(
                            bottom:0,
                            left: 0,
                            child: Container(
                              alignment: Alignment.bottomRight,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'brought to you by:   ',
                                      style: TextStyle(
                                            fontFamily: 'Lexend',
                                        fontSize: mapValueDimensionBasedLockOnDesyncWeb(8, 13.6, sWidth, sHeight),
                                        color: defaultPalette.extras[0],
                                        letterSpacing: -0.5,
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Jepixo',
                                      style: TextStyle(
                                            fontFamily: 'Lexend',
                                        fontSize: mapValueDimensionBasedLockOnDesyncWeb(10, 25, sWidth, sHeight),
                                        color: defaultPalette.extras[0],
                                        letterSpacing: -1,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: Transform.translate(
                                        offset: Offset(2, mapValueDimensionBasedLockOnDesyncWeb(-10, -15, sWidth, sHeight)), // adjust vertical position
                                        child: Text(
                                          'TM',// make it smaller
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: mapValueDimensionBasedLockOnDesyncWeb(6, 8, sWidth, sHeight),
                                            fontWeight: FontWeight.w500,
                                            color: defaultPalette.extras[0],
                                            decoration: TextDecoration.none, 
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Message
                    Positioned(
                      left:mapValueDimensionBasedLockOnDesync(5, 30, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),
                      bottom:mapValueDimensionBasedLockOnDesyncWeb(20, 90, sWidth, sHeight,
                        ),
                      child:  AnimatedTextKit(
                        key: ValueKey((isProfileTab) ? sHeight * sWidth : (isProfileTab)),
                        animatedTexts: [
                          typewriterText(isHomeTab, sWidth, sHeight, '(どうもありがとう, Dōmo arigatō),', fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "which means 'Thank you very much.'", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "Grateful you spent a moment here.", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "This app is as much yours as it is mine.", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "If there's something you'd like added,", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "or if you run into any issues,", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "please reach me anytime at billblazex@gmail.com.", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "Your thoughts and support mean the world.", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "From the bottom of my heart — Grazie mille.", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "A gentle bow, as a sign of respect.", fontSize),
                          typewriterText(isHomeTab, sWidth, sHeight, "Keep being awesome!.", fontSize),
                        ],
                        // totalRepeatCount: 1,
                        repeatForever: true,
                        pause: const Duration(milliseconds: 2000),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,

                      ),
                    ),
                    //corner button
                    Container(
                      height: sHeight - (1.5 * titleFontSize),
                      width: (15 + 65 + 15 + 65 + 15 + 65 + 15 + 45) +
                          mapValueDimensionBasedLockOnDesync(-30, 250, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),
                      decoration: BoxDecoration(
                        color: defaultPalette.transparent,
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 15 + mapValueDimensionBasedLockOnDesync( 0, 5, sWidth, sHeight),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15 + mapValueDimensionBasedLockOnDesync( 0, 5, sWidth, sHeight),
                              ),
                              //Corner button
                              ElevatedLayerButton(
                                depth: 3,
                                subfac: 3,
                                extrudeLeft: false,
                                isNavigation: true,
                                onTapDown: (d) async {
                                  showLegalsMenu(context, d.globalPosition, sWidth, sHeight);
                                },
                                buttonHeight: mapValueDimensionBasedLockOnDesync( 75, 120, sWidth, sHeight),
                                buttonWidth: mapValueDimensionBasedLockOnDesync( 75, 120, sWidth, sHeight),
                                borderRadius: BorderRadius.circular(450).copyWith(
                                  bottomRight: Radius.circular(100),
                                ),
                                animationDuration: const Duration(milliseconds: 100),
                                animationCurve: Curves.ease,
                                topDecoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                ),
                                topLayerChild: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    TablerIcons.rosette_discount_check_filled,
                                    size: mapValueDimensionBasedLockOnDesync( 35, 60, sWidth, sHeight),
                                    color: defaultPalette.extras[0],
                                  ),
                                ),
                                baseDecoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  border: Border.all(),
                                ), onClick: () {  },
                              ),
                              Expanded(child: SizedBox())
                            ],
                          ),
                          Expanded(child: SizedBox())
                        ],
                      ),
                    ),
                    // ToS, Privacy Policy, EULA
                    Positioned(
                      bottom:0,
                      child: Container(
                        width:(15 + 65 + 15 + 65 + 15 + 65 + 15 + 45) +
                          mapValueDimensionBasedLockOnDesync(-30, 250, sWidth, sHeight,
                        baseHeight: 150,
                        baseWidth: 250,
                        ),
                        alignment: Alignment(0,0.8),
                        height:mapValueDimensionBasedLockOnDesync(60, 120, sWidth, sHeight),
                        decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(45).copyWith(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                          color:defaultPalette.transparent,),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width:3),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child:GestureDetector(
                                onTap: () async {
                                  ref.read(loginPageUrlProvider.notifier).state = termsOfServiceUrl;
                                  await changeTvChannel();
                                },
                                child:Container(
                                  child: Text(
                                    'Terms Of Service',
                                    maxLines:1,
                                    overflow:TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Lexend',
                                    fontSize: mapValueDimensionBasedLockOnDesyncWeb(8, 13.6, sWidth, sHeight),
                                    color: defaultPalette.extras[0].withOpacity(0.4),
                                    letterSpacing: -0.5,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),
                                  ),
                                )
                              )
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child:GestureDetector(
                                onTap: () async {
                                  ref.read(loginPageUrlProvider.notifier).state = privacyPolicyUrl;
                                  await changeTvChannel();
                                },
                                child:Container(
                                  child: Text(
                                    'Privacy Policy',
                                    maxLines:1,
                                    overflow:TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Lexend',
                                    fontSize: mapValueDimensionBasedLockOnDesyncWeb(8, 13.6, sWidth, sHeight),
                                    color: defaultPalette.extras[0].withOpacity(0.4),
                                    letterSpacing: -0.5,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),
                                  ),
                                )
                              )
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child:GestureDetector(
                                onTap: () async {
                                  ref.read(loginPageUrlProvider.notifier).state = eulaUrl;
                                  await changeTvChannel();
                                },
                                child:Container(
                                  child: Text(
                                    'EULA',
                                    maxLines:1,
                                    overflow:TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Lexend',
                                    fontSize: mapValueDimensionBasedLockOnDesyncWeb(8, 13.6, sWidth, sHeight),
                                    color: defaultPalette.extras[0].withOpacity(0.4),
                                    letterSpacing: -0.5,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),
                                  ),
                                )
                              )
                            ),
                            SizedBox(width:3),
                        ],)
                        
                      )),
                    
                  ],
                ),
              ),
              //TVTV
              AnimatedPositioned(
                duration: Durations.medium2,
                bottom: isProfileTab ? 20 : -400,
                // left: 90,
                right: isProfileTab
                    ? mapValueDimensionBased(20, 50, sWidth, sHeight, useWidth: true)
                    : -sWidth / 2,
                child: AnimatedRotation(
                  duration: Durations.medium2,
                  turns: isProfileTab ? 0 : -0.1,
                  child: ElevatedLayerButton(
                    // isTapped: false,
                    // toggleOnTap: true,
                    depth: 4, subfac: 4,
                    onClick: () {},
                    buttonWidth: (sWidth -
                            (15 + 65 + 15 + 65 + 15 + 65 + 15 + 65 + 65) -
                            80 -
                            mapValueDimensionBased(0, 250, sWidth, sHeight,
                                useWidth: true))
                        .clamp(0, double.infinity),
                    buttonHeight: sHeight - (4 * titleFontSize),
                    borderRadius: BorderRadius.circular(35),
                    animationDuration: const Duration(milliseconds: 100),
                    animationCurve: Curves.ease,
                    topDecoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                    ),
                    topLayerChild: Container(
                      padding: const EdgeInsets.all(9),
                      color: Colors.white.withOpacity(0.2),
                      child: Row(
                        children: [
                          Expanded(
                            flex:70,
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: InAppWebView(
                                      initialUrlRequest: URLRequest(
                                          url: WebUri.uri(Uri.parse(ref
                                              .watch(loginPageUrlProvider)))),
                                      onWebViewCreated: (controller) async {
                                        _controller = controller;

                                     print("WebView created");
                                      },
                                      onLoadStop: (controller, url) async {
                                     print("Loaded: $url");
                                        await controller.evaluateJavascript(
                                            source:
                                                "document.documentElement.style.zoom = '100%';");
                                      },
                                      initialSettings: InAppWebViewSettings(
                                          textZoom: 50,
                                          horizontalScrollBarEnabled: false,
                                          verticalScrollBarEnabled: false,
                                          builtInZoomControls: true,
                                          pageZoom: 10,
                                          supportZoom: true,
                                          displayZoomControls: true,
                                          minimumZoomScale: 0.8,
                                          maximumZoomScale: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              // width: mapValueDimensionBasedLockOnDesync(30, 500, sWidth, sHeight,
                              // baseHeight: 150,
                              // baseWidth: 250,
                              // ),
                              flex:30,
                              child: Stack(
                                children: [
                                  //speaker graph of the TV
                                  Container(
                                    margin:  EdgeInsets.all(0).copyWith(left: 10),
                                    decoration: BoxDecoration(
                                        color: defaultPalette.secondary.withAlpha(50),
                                        border: Border.all(width: 0.2),
                                        borderRadius:  BorderRadius.circular(30)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Opacity(
                                        opacity: 0.35,
                                        child: LineChart(LineChartData(
                                            lineBarsData: [LineChartBarData()],
                                            titlesData:
                                                const FlTitlesData(show: false),
                                            gridData: FlGridData(
                                                getDrawingVerticalLine: (value) => FlLine(
                                                    color: defaultPalette.extras[0]
                                                        .withOpacity(0.7),
                                                    dashArray: [2, 8],
                                                    strokeWidth: 0.5),
                                                getDrawingHorizontalLine:
                                                    (value) => FlLine(
                                                        color: defaultPalette
                                                            .extras[0]
                                                            .withOpacity(0.7),
                                                        dashArray: [2, 8],
                                                        strokeWidth: 0.5),
                                                show: true,
                                                horizontalInterval: 1,
                                                verticalInterval: 60),
                                            borderData:
                                                FlBorderData(show: false),
                                            minY: 0,
                                            maxY: 50,
                                            maxX: DateTime.now()
                                                        .millisecondsSinceEpoch
                                                        .ceilToDouble() /
                                                    500 +
                                                250,
                                            minX: DateTime.now().millisecondsSinceEpoch.ceilToDouble() / 500)),
                                      ),
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      SizedBox(
                                        height: mapValueDimensionBased(
                                          25,
                                          55,
                                          sWidth,
                                          sHeight,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width:5
                                          ),
                                          Expanded(
                                            child:  RichText(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            // overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              style: TextStyle(                                fontFamily: 'Lexend',
                                                fontSize:
                                                    mapValueDimensionBasedLockOnDesync(
                                                  12,
                                                  35,
                                                  sWidth,
                                                  sHeight,
                                                ),
                                                color: defaultPalette.extras[0],
                                                letterSpacing: mapValueDimensionBasedLockOnDesync( 5, 15, sWidth, sHeight,
                                                ),
                                                height: 1,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: ' FLUX',
                                                  style: TextStyle(                                fontFamily: 'Lexend',
                                                      color: defaultPalette.extras[0]),
                                                ),
                                                TextSpan(
                                                  text: 'TV',
                                                  style:
                                                      TextStyle(
                                                        fontSize:
                                                    mapValueDimensionBasedLockOnDesync(
                                                  8,
                                                  30,
                                                  sWidth,
                                                  sHeight,
                                                ),
                                                        color: defaultPalette.extras[0]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ),
                                        ],
                                      ),
                                      Expanded(child: SizedBox()),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: ElevatedLayerButton(
                                                // isTapped: false,
                                                // toggleOnTap: true,
                                                depth: 3, subfac: 3,
                                                onClick: () async {
                                                  ref.read(loginPageUrlProvider.notifier)
                                                          .state =
                                                      loginPageUrls[Random()
                                                          .nextInt(loginPageUrls
                                                                  .length -
                                                              1)];
                                                  if (_controller != null &&
                                                      ref
                                                          .read(
                                                              loginPageUrlProvider)
                                                          .isNotEmpty) {
                                                    // startWhiteNoise();
                                                    final htmlString = await rootBundle.loadString('assets/static.html');
                                    
                                                    await _controller!.loadData(data: htmlString, mimeType: 'text/html', encoding: 'utf8');
                                    
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 100));
                                                    startWhiteNoise();
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 400));
                                                    _controller!.loadUrl(
                                                      urlRequest: URLRequest(
                                                          url: WebUri.uri(Uri
                                                              .parse(ref.read(
                                                                  loginPageUrlProvider)))),
                                                    );
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 100));
                                                    stopWhiteNoise();
                                                  }
                                                  setState(() {});
                                                },
                                                buttonHeight:
                                                    mapValueDimensionBasedLockOnDesync(
                                                        30,
                                                        80,
                                                        sWidth,
                                                        sHeight),
                                                buttonWidth:
                                                    mapValueDimensionBasedLockOnDesync(
                                                        30,
                                                        80,
                                                        sWidth,
                                                        sHeight),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        450000),
                                                animationDuration:
                                                    const Duration(
                                                        milliseconds: 100),
                                                animationCurve: Curves.ease,
                                                topDecoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(),
                                                ),
                                                topLayerChild: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      TablerIcons .rosette_filled,
                                                      size:
                                                          mapValueDimensionBasedLockOnDesync(
                                                              15,
                                                              45,
                                                              sWidth,
                                                              sHeight),
                                                    )
                                                  ],
                                                ),
                                                baseDecoration: BoxDecoration(
                                                  color:
                                                      defaultPalette.extras[0],
                                                  border: Border.all(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: ElevatedLayerButton(
                                                // isTapped: false,
                                                // toggleOnTap: true,
                                                depth: 3, subfac: 3,
                                                onClick: () async {
                                                  final urls = loginPageUrls;
                                                  if (urls.isEmpty)
                                                    return; // nothing to do

                                                  final current = ref.read(
                                                      loginPageUrlProvider);
                                                  final idx = urls.indexOf(
                                                      current); // -1 if not found
                                                  final nextIndex = (idx == -1)
                                                      ? 0
                                                      : (idx + 1) % urls.length;

                                                  // update provider
                                                  ref
                                                      .read(loginPageUrlProvider
                                                          .notifier)
                                                      .state = urls[nextIndex];

                                                  // load into webview if available
                                                  final newUrl = ref.read(
                                                      loginPageUrlProvider);
                                                  if (_controller != null &&
                                                      newUrl.isNotEmpty) {
                                                    // startWhiteNoise();
                                                    final htmlString = await rootBundle.loadString('assets/static.html');
                                    
                                                    await _controller!.loadData(data: htmlString, mimeType: 'text/html', encoding: 'utf8');
                                    
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 100));
                                                    startWhiteNoise();
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 400));
                                                    _controller!.loadUrl(
                                                      urlRequest: URLRequest(
                                                          url: WebUri.uri(
                                                              Uri.parse(
                                                                  newUrl))),
                                                    );
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 100));
                                                    stopWhiteNoise();
                                                  }

                                                  setState(
                                                      () {}); // if you still need local UI refresh
                                                },

                                                buttonHeight:
                                                    mapValueDimensionBasedLockOnDesync(
                                                        30,
                                                        80,
                                                        sWidth,
                                                        sHeight),
                                                buttonWidth:
                                                    mapValueDimensionBasedLockOnDesync(
                                                        30,
                                                        80,
                                                        sWidth,
                                                        sHeight),
                                                borderRadius: BorderRadius.circular( 450000),
                                                animationDuration:
                                                    const Duration(
                                                        milliseconds: 100),
                                                animationCurve: Curves.ease,
                                                topDecoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(),
                                                ),
                                                topLayerChild: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      TablerIcons.blob_filled,
                                                      size:
                                                          mapValueDimensionBasedLockOnDesync(
                                                              14,
                                                              40,
                                                              sWidth,
                                                              sHeight),
                                                    )
                                                  ],
                                                ),
                                                baseDecoration: BoxDecoration(
                                                  color:
                                                      defaultPalette.extras[0],
                                                  border: Border.all(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: mapValueDimensionBased(
                                              0,
                                              0,
                                              sWidth,
                                              sHeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            mapValueDimensionBasedLockOnDesync(
                                                10, 50, sWidth, sHeight),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final url =
                                              ref.read(loginPageUrlProvider);
                                          Clipboard.setData(
                                              ClipboardData(text: url));
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width:mapValueDimensionBasedLockOnDesync(
                                                            6, 20, sWidth, sHeight),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height:
                                                    mapValueDimensionBasedLockOnDesync(
                                                        15, 50, sWidth, sHeight),
                                                margin: EdgeInsets.all(0).copyWith(
                                                    left: 10 +
                                                        mapValueDimensionBasedLockOnDesync(
                                                            6, 20, sWidth, sHeight),
                                                    right:
                                                        mapValueDimensionBasedLockOnDesync(
                                                            2, 5, sWidth, sHeight)),
                                                decoration: BoxDecoration(
                                                    color: defaultPalette.extras[0],
                                                    borderRadius:
                                                        BorderRadius.circular(50)),
                                                padding: EdgeInsets.all(0)
                                                    .copyWith(left: 10, right: 10),
                                                alignment: Alignment(0, 0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      ' //',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(                                fontFamily: 'Lexend',
                                                        fontSize:
                                                            mapValueDimensionBased(
                                                          8,
                                                          25,
                                                          sWidth,
                                                          sHeight,
                                                        ),
                                                        color: defaultPalette.primary,
                                                        letterSpacing: -1,
                                                        height: 1,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        ref.watch(
                                                            loginPageUrlProvider),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                        style: GoogleFonts
                                                            .redactedScript(
                                                          fontSize:
                                                              mapValueDimensionBased(
                                                            8,
                                                            25,
                                                            sWidth,
                                                            sHeight,
                                                          ),
                                                          color:
                                                              defaultPalette.primary,
                                                          letterSpacing: -1,
                                                          height: 1,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Tooltip(
                                              message:'FluxTV showcases cool websites made by cool creators. \nAll content belongs to its original owners.',
                                              textStyle: TextStyle(                                fontFamily: 'Lexend',
                                                fontSize: mapValueDimensionBasedLockOnDesync(10,20, sWidth, sHeight),
                                                color:defaultPalette.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              padding: EdgeInsets.all(mapValueDimensionBasedLockOnDesync(8,16, sWidth, sHeight)).copyWith(left:mapValueDimensionBasedLockOnDesync(15,25, sWidth, sHeight)),
                                              decoration: BoxDecoration(
                                                  color: defaultPalette.extras[0].withOpacity(0.95),
                                                  borderRadius: BorderRadius.circular( 50)),
                                            child: Icon(TablerIcons.info_circle_filled,
                                            color: defaultPalette.extras[0],
                                             size: mapValueDimensionBasedLockOnDesync(18,65, sWidth, sHeight),)),
                                            SizedBox(
                                              width:mapValueDimensionBasedLockOnDesync(
                                                            6, 20, sWidth, sHeight),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ],
                            )
                          )
                        
                        ],
                      ),
                    ),

                    baseDecoration: BoxDecoration(
                      color: defaultPalette.extras[0],
                    ),
                  ),
                ),
              ),
              //ThankYou
              AnimatedPositioned(
                duration: Durations.medium2,
                height: mapValueDimensionBasedLockOnDesync(30, 305, sWidth, sHeight,
                  baseHeight: 150,
                  baseWidth: 250,
                ),
                top: mapValueDimensionBased( 40, 110, sWidth, sHeight,b: false),
                width: sWidth,
                left: isProfileTab
                    ? 0
                    : -sWidth / 2,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    padding: EdgeInsets.only(left: 5, right: 20, top: 10),
                    // width: sWidth,
                    decoration: BoxDecoration(
                      // color:defaultPalette.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: mapValueDimensionBasedLockOnDesyncWeb(230, 420, sWidth, sHeight,),
                        ),
                        Text('THANK YOU'.toUpperCase(),
                          textAlign: TextAlign.end,
                          style: GoogleFonts.micro5(
                            color: defaultPalette.extras[0],
                            // fontSize: mapValueDimensionBasedLockOnDesync(
                            //     35, 110, sWidth, sHeight),
                            fontSize: mapValueDimensionBasedLockOnDesync(60, 250, sWidth, sHeight,
                              baseHeight: 150,
                              baseWidth: 250,
                              ),
                            letterSpacing: -2,
                            fontWeight: FontWeight.w400,
                            height: 0.6)),
                        Expanded(
                          child:FittedBox(
                            fit:BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom:4.0),
                              child: Text('You\'re a legend',
                              maxLines:1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.alexBrush(
                              color: defaultPalette.extras[0],
                              // fontSize: mapValueDimensionBasedLockOnDesync(
                              //     35, 110, sWidth, sHeight),
                              fontSize: mapValueDimensionBasedLockOnDesync(20, 120, sWidth, sHeight,
                                baseHeight: 150,
                                baseWidth: 250,
                                ),
                              letterSpacing: -2,
                              fontWeight: FontWeight.w400,
                              height: 0.6)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              //PFP BUTTONs 3
              AnimatedPositioned(
                duration: Durations.extralong4,
                top: mapValueDimensionBasedLockOnDesyncWeb( 40, 140, sWidth, sHeight, ),
                right: isProfileTab
                    ? mapValueDimensionBased(40, 80, sWidth, sHeight, useWidth: true)
                    : -sWidth / 2,
                child: Row(
                  children: [
                    ElevatedLayerButton(
                      // isTapped: false,
                      // toggleOnTap: true,
                      depth: 2, subfac: 2,
                      onClick: () async {
                        ref.read(loginPageUrlProvider.notifier).state= url(4);
                        await changeTvChannel();
                      },
                      buttonHeight: mapValueDimensionBasedLockOnDesync( 35, 80, sWidth, sHeight),
                      buttonWidth: mapValueDimensionBasedLockOnDesync( 35, 80, sWidth, sHeight),
                      borderRadius: BorderRadius.circular(450000000),
                      animationDuration: const Duration(milliseconds: 100),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      topLayerChild: Padding(
                        padding: EdgeInsets.all(mapValueDimensionBasedLockOnDesyncWeb( 5, 10, sWidth, sHeight)),
                        child: FittedBox(
                          fit:BoxFit.fitHeight,
                          child: SvgPicture.asset(
                            'assets/logos/github.svg',
                            colorFilter: ColorFilter.mode(defaultPalette.extras[0], BlendMode.srcIn),
                            height: 300,
                          ),
                        ),
                      ),
                      baseDecoration: BoxDecoration(
                        color: defaultPalette.extras[0],
                        border: Border.all(),
                      ),
                    ),
                    SizedBox(width:5),
                    ElevatedLayerButton(
                      // isTapped: false,
                      // toggleOnTap: true,
                      depth: 2, subfac: 2,
                      onClick: () async {
                        ref.read(loginPageUrlProvider.notifier).state= homePageUrls[3];
                        await changeTvChannel();
                      },
                      buttonHeight: mapValueDimensionBasedLockOnDesync( 35, 80, sWidth, sHeight),
                      buttonWidth: mapValueDimensionBasedLockOnDesync( 35, 80, sWidth, sHeight),
                      borderRadius: BorderRadius.circular(450000000),
                      animationDuration: const Duration(milliseconds: 100),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      topLayerChild:Padding(
                        padding: EdgeInsets.all(mapValueDimensionBasedLockOnDesyncWeb( 5, 10, sWidth, sHeight)),
                        child: FittedBox(
                          fit:BoxFit.fitHeight,
                          child: SvgPicture.asset(
                            'assets/logos/bmc-logo.svg',
                            colorFilter: ColorFilter.mode(defaultPalette.extras[0], BlendMode.srcIn),
                          ),
                        ),
                      ),
                      baseDecoration: BoxDecoration(
                        color: defaultPalette.extras[0],
                        border: Border.all(),
                      ),
                    ),
                    SizedBox(width:5),
                    ElevatedLayerButton(
                      // isTapped: false,
                      // toggleOnTap: true,
                      depth: 2, subfac: 2,
                      onClick: () async {
                        ref.read(loginPageUrlProvider.notifier).state= homePageUrls[4];
                        await changeTvChannel();
                      },
                      buttonHeight: mapValueDimensionBasedLockOnDesync( 35, 80, sWidth, sHeight),
                      buttonWidth: mapValueDimensionBasedLockOnDesync( 35, 80, sWidth, sHeight),
                      borderRadius: BorderRadius.circular(450000000),
                      animationDuration: const Duration(milliseconds: 100),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      topLayerChild: Padding(
                        padding: EdgeInsets.all(mapValueDimensionBasedLockOnDesyncWeb( 3, 8, sWidth, sHeight)).copyWith(left: mapValueDimensionBasedLockOnDesyncWeb( 6, 12, sWidth, sHeight)),
                        child: FittedBox(
                          fit:BoxFit.fitHeight,
                          child: SvgPicture.asset(
                            'assets/logos/kofibw.svg',
                            colorFilter: ColorFilter.mode(defaultPalette.extras[0], BlendMode.srcIn),
                            height: 300,
                          ),
                        ),
                      ),
                      baseDecoration: BoxDecoration(
                        color: defaultPalette.extras[0],
                        border: Border.all(),
                      ),
                    ),
                  
                  ],
                ),
              ),
            
            ],
          ),
        ),
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
            enabled: s == 1,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0),
              labelStyle: TextStyle(                                fontFamily: 'Lexend',color: defaultPalette.black),
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
                var newValue = (double.tryParse(value) ?? 0)
                    .clamp(s == 0 ? 1 : 1900,
                        s == 0 ? 12 : DateTime.now().year.ceilToDouble())
                    .round();
             print(newValue);
                switch (s) {
                  case 0:
                    selectedMonth = newValue;
                    dateTextControllers = [
                      TextEditingController()
                        ..text = monthNames[selectedMonth - 1],
                      TextEditingController()..text = selectedYear.toString()
                    ];
                    break;
                  case 1:
                    selectedYear = newValue;
                    dateTextControllers = [
                      TextEditingController()
                        ..text = monthNames[selectedMonth - 1],
                      TextEditingController()..text = selectedYear.toString()
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
                    selectedMonth = (selectedMonth - 1)
                        .clamp(s == 0 ? 1 : 1900,
                            s == 0 ? 12 : DateTime.now().year.ceilToDouble())
                        .round();
                    dateTextControllers = [
                      TextEditingController()
                        ..text = monthNames[selectedMonth - 1],
                      TextEditingController()..text = selectedYear.toString()
                    ];
                    break;
                  case 1:
                    selectedYear = (selectedYear - 1)
                        .clamp(s == 0 ? 1 : 1900,
                            s == 0 ? 12 : DateTime.now().year.ceilToDouble())
                        .round();
                    dateTextControllers = [
                      TextEditingController()
                        ..text = monthNames[selectedMonth - 1],
                      TextEditingController()..text = selectedYear.toString()
                    ];
                    break;

                  default:
                }
             print(selectedYear);
              });
            },
            child: Icon(
              TablerIcons.chevron_left,
              size: mapValueDimensionBased(15, 20, sWidth, sHeight),
            )),
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
           print(selectedYear);
              setState(() {
                switch (s) {
                  case 0:
                    selectedMonth = (selectedMonth + 1)
                        .clamp(s == 0 ? 1 : 1900,
                            s == 0 ? 12 : DateTime.now().year.ceilToDouble())
                        .round();
                    dateTextControllers = [
                      TextEditingController()
                        ..text = monthNames[selectedMonth - 1],
                      TextEditingController()..text = selectedYear.toString()
                    ];
                    break;
                  case 1:
                    selectedYear = (selectedYear + 1)
                        .clamp(s == 0 ? 1 : 1900,
                            s == 0 ? 12 : DateTime.now().year.ceilToDouble())
                        .round();
                    dateTextControllers = [
                      TextEditingController()
                        ..text = monthNames[selectedMonth - 1],
                      TextEditingController()..text = selectedYear.toString()
                    ];
                    break;

                  default:
                }
             print(selectedYear);
              });
            },
            child: Icon(
              TablerIcons.chevron_right,
              size: mapValueDimensionBased(15, 20, sWidth, sHeight),
            )),
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

  double getSmartInterval(double maxValue, {double minValue = 0}) {
    final cleanSteps = [
      0.5,
      1,
      2,
      5,
      10,
      20,
      25,
      50,
      100,
      200,
      250,
      500,
      1000,
      2000,
      2500,
      5000,
      10000,
      20000,
      25000,
      50000,
      100000,
      200000,
      500000,
      1000000,
      2000000,
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
    if (totalBills == 0) {
      final radius =
          mapValueDimensionBasedLockOnDesync(25, 90, sWidth, sHeight);
      final fontSize =
          mapValueDimensionBasedLockOnDesync(18, 40, sWidth, sHeight);

      return [
        PieChartSectionData(
          color: Colors.grey[300], // Neutral color
          value: 100,
          title: "0",
          radius: radius,
          titleStyle: TextStyle(                                fontFamily: 'Lexend',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
          badgeWidget: Container(
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(4),
            child: Text(
              "No\nBills",
              textAlign: TextAlign.center,
              style: TextStyle(                                fontFamily: 'Lexend',
                fontSize: fontSize * 0.4,
                color: Colors.white,
              ),
            ),
          ),
          badgePositionPercentageOffset: 1.1,
          titlePositionPercentageOffset: 0.3,
        ),
      ];
    }

    final visibleEntries =
        billCounts.entries.where((entry) => entry.value > 0).toList();

    return List.generate(visibleEntries.length, (i) {
      final entry = visibleEntries[i];
      final type = entry.key;
      final count = entry.value;
      final isTouched = i == touchedIndex;
      final fontSize = isTouched
          ? mapValueDimensionBasedLockOnDesync(25, 40, sWidth, sHeight)
          : mapValueDimensionBasedLockOnDesync(13, 30, sWidth, sHeight);
      final radius = isTouched
          ? mapValueDimensionBasedLockOnDesync(40, 180, sWidth, sHeight)
          : mapValueDimensionBasedLockOnDesync(25, 90, sWidth, sHeight);
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      String badgeLabel = type.name.replaceFirstMapped(
        RegExp(r'[A-Z]'),
        (m) => '\n${m[0]}',
      );

      return PieChartSectionData(
        color: defaultPalette.extras[0], // You can customize per type if needed
        value: count.toDouble() / totalBills * 100,
        title: count.toString(),
        radius: radius,
        titleStyle: TextStyle(                                fontFamily: 'Lexend',
          fontSize: fontSize *
              mapValueDimensionBasedLockOnDesync(
                  isTouched ? 0.5 : 0.8, isTouched ? 0.7 : 1, sWidth, sHeight),
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
            style: TextStyle(                                fontFamily: 'Lexend',
              fontSize: fontSize *
                  mapValueDimensionBasedLockOnDesync(0.4, 0.5, sWidth, sHeight),
              color: defaultPalette.extras[0],
            ),
          ),
        ),
        badgePositionPercentageOffset: mapValueDimensionBasedLockOnDesync(
            isTouched ? 1.2 : 1.2, isTouched ? 0.8 : 1, sWidth, sHeight),
        titlePositionPercentageOffset: 0.3,
      );
    });
  }

  Widget summaryTile(String s, Map<String, double> stats, IconData icon,
      double sWidth, double sHeight,
      {textAlign = TextAlign.start}) {
    return Container(
      padding: EdgeInsets.all(mapValueDimensionBased(5, 10, sWidth, sHeight)),
      margin: EdgeInsets.only(
          bottom: mapValueDimensionBased(5, 10, sWidth, sHeight), right: 1,left:1),
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
              ...[
                Icon(
                  icon,
                  size: mapValueDimensionBased(15, 30, sWidth, sHeight),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
              Expanded(
                child: Text(
                  s,
                  textAlign: textAlign,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[0],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1),
                ),
              ),
              Expanded(
                child: Text(
                  NumberFormat.decimalPattern('en_IN').format(stats['count']),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(12, 23, sWidth, sHeight),
                      color: defaultPalette.extras[0],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1),
                ),
              ),
              SizedBox(
                width: 2,
              )
            ],
          ),
          //revenue
          Row(
            children: [
              Expanded(
                child: Text(
                  s == 'Credit Notes'
                      ? 'settled '
                      : 'revenue  ',
                  textAlign: textAlign,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[0],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.8),
                ),
              ),
              Expanded(
                child: Text(
                  _currencyFormatter.format(stats['payable']??0),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(                                fontFamily: 'Lexend',
                    fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                    color: defaultPalette.extras[0],
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1),
                ),
              ),
            ],
          ),
          //profits
          Row(
            children: [
              Expanded(
                child: Text(
                  'profit  ',
                  textAlign: textAlign,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[0],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1),
                ),
              ),
              Expanded(
                child: Text(
                  s == 'Credit Notes'
                      ? '~~~~~~~~'
                      : _currencyFormatter.format(stats['profit']??0),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[0],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1),
                ),
              ),
            ],
          ),
          //unpaid count
          Row(
            children: [
              Expanded(
                child: Text(
                  'unpaid  ',
                  textAlign: textAlign,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[stats['unpaid']==0?0:4],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1),
                ),
              ),
              Expanded(
                child: Text(
                  (stats['unpaid']??0).round().toString(),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[stats['unpaid']==0?0:4],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5),
                ),
              ),
            ],
          ),
          
          //pending
          Row(
            children: [
              Expanded(
                child: Text(
                 s == 'Credit Notes'
                      ? 'owed'
                      :  'pending  ',
                  textAlign: textAlign,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[stats['unpaidRevenue']==0.0?0:4],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1),
                ),
              ),
              Expanded(
                child: Text(
                  _currencyFormatter.format(stats['unpaidRevenue']??0),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(                                fontFamily: 'Lexend',
                      fontSize: mapValueDimensionBased(10, 23, sWidth, sHeight),
                      color: defaultPalette.extras[stats['unpaidRevenue']==0.0?0:4],
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5),
                ),
              ),
            ],
          ),
          
          SizedBox(
            height: 2,
          ),
        ],
      ),
    );
  }
  
  void showCurrencySelectionDialog(BuildContext context, WidgetRef ref) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      favorite: [ref.read(currencyCodeProvider).code,'USD', 'INR', 'EUR',],
      theme: CurrencyPickerThemeData(
      flagSize: 24,
      titleTextStyle: TextStyle(                                fontFamily: 'Lexend',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: defaultPalette.black,
      ),
      subtitleTextStyle: TextStyle(                                fontFamily: 'Lexend',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: defaultPalette.extras[0],
      ),
      bottomSheetHeight: 500,
      backgroundColor: defaultPalette.primary,
      inputDecoration: InputDecoration(
        hintText: 'Search currency',
        hintStyle: TextStyle(                                fontFamily: 'Lexend',
          fontSize: 16,
          color: defaultPalette.extras[0].withOpacity(0.6),
        ),
        prefixIcon: const Icon(TablerIcons.search),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: defaultPalette.tertiary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: defaultPalette.extras[0].withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: defaultPalette.primary.withOpacity(0.8),
      ),
      currencySignTextStyle:   TextStyle(                                fontFamily: 'Lexend',
          fontSize: 16,
          color: defaultPalette.extras[0].withOpacity(0.6),
        ),
      
      ),
      onSelect: (Currency currency) {
        setState(() {
          
          print('Selected currency: ${currency.code}');
          if (currency.code == null) return;
          ref.read(currencyCodeProvider.notifier).state = currency;
        });
      },
    );
  }

  Future<void> showConfirmDeleteDialog(BuildContext context, Function func, double sWidth, double sHeight,[String message = 'Are you sure you want to delete this layout?']) async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete',style: GoogleFonts
          .lexend(
            fontSize: mapValueDimensionBased( 18, 25, sWidth, sHeight),
            color: defaultPalette.extras[0],
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),),
          content: Text(message,style: GoogleFonts
          .lexend(
            fontSize: mapValueDimensionBased( 12, 20, sWidth, sHeight),
            color: defaultPalette.extras[0],
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel',style: GoogleFonts
          .lexend(
            fontSize: mapValueDimensionBased( 15, 22, sWidth, sHeight),
            color: defaultPalette.extras[0],
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),),
            ),
            TextButton(
              onPressed: () { 
                func();
                Navigator.of(context).pop(true);
                
                },
              style: TextButton.styleFrom(foregroundColor: defaultPalette.extras[4]),
              child: Text('Delete',style: GoogleFonts
          .lexend(
            fontSize: mapValueDimensionBased(
                    15, 22, sWidth, sHeight),
            color: defaultPalette.extras[4],
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          )),
          ),
          ],
        ); },
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

double mapValueDimensionBased(double outMin, double outMax, double w, double h, {bool b = true, bool useWidth = false}) {
  return mapValue(
      value: b
          ? useWidth
              ? w
              : h * w
          : h,
      inMin: b
          ? useWidth
              ? 800
              : 500 * 800
          : 500,
      inMax: b
          ? useWidth
              ? 2194
              : 1187 * 2194
          : 1187,
      outMin: outMin,
      outMax: outMax);
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
  final widthProgress =
      ((sWidth - baseWidth) / (maxWidth - baseWidth)).clamp(0.0, 1.0);
  final heightProgress =
      ((sHeight - baseHeight) / (maxHeight - baseHeight)).clamp(0.0, 1.0);

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

double mapValueDimensionBasedLockOnDesyncWeb(double outMin,
  double outMax,
  double sWidth,
  double sHeight, {
  double baseWidth = 400,
  double baseHeight = 250,
  double maxWidth = 2194,
  double maxHeight = 1187,
}){
  return mapValueDimensionBasedLockOnDesync(outMin, outMax, sWidth, sHeight,
  baseHeight: baseHeight,
  baseWidth: baseWidth,
  maxHeight: maxHeight,
  maxWidth: maxWidth,
  );
}

String buildCombinedTextFromBlocks(
  List<InputBlock> inputBlocks,
  List<SheetListBox> spreadSheetList, {
  Map<List<InputBlock>, int>? visited,
}) {
  final mergedDelta = Delta();
  visited ??= {};
  visited[inputBlocks] = (visited[inputBlocks] ?? 0) + 1;
  if (visited[inputBlocks]! > 50) {
    return '';
  }
  // print(inputBlocks);
  for (int blockIdx = 0; blockIdx < inputBlocks.length; blockIdx++) {
    final block = inputBlocks[blockIdx];
    // print(block);

    // if(block.function is InputBlockFunction) print(block.useConst);
    if (block.function != null) {
      if (block.function is InputBlockFunction && block.useConst == false) {
        // Recursive call with updated visited map
        //  print('hello');
        final result = buildCombinedTextFromBlocks(
          (block.function as InputBlockFunction).inputBlocks,
          spreadSheetList,
          visited: visited,
        );
        // print(result);
        mergedDelta.push(Operation.insert(
          '$result${blockIdx == inputBlocks.length - 1 ? '\n' : ''}',
        ));

        // Back-patch result if needed
        if (block.indexPath.index != -77) {
          final targetItem = getItemAtPath(block.indexPath, spreadSheetList);
          if (targetItem is SheetText) {
            final controller = targetItem.textEditorConfigurations.controller;
            controller.replaceText(
              0,
              controller.document.length,
              result,
              TextSelection.collapsed(offset: result.length),
            );
          }
        }

        continue;
      } else if (block.function is! InputBlockFunction) {
        final raw = block.function!.result(
            getItemAtPath, buildCombinedTextFromBlocks,
            spreadSheet: spreadSheetList);
        // print(block.function.toString()+raw.toString());
        // 1) If it’s a styled Quill Document, pull in its ops
        if (raw is Document) {
          // print(block.function.toString()+raw.toPlainText());
          final ops = raw.toDelta().toList();
          final isLast = blockIdx == inputBlocks.length - 1;

          for (var op in ops) {
            if (!isLast &&
                op.data is String &&
                (op.data as String).endsWith('\n')) {
              // trim stray newline on non-last blocks
              final trimmed = (op.data as String)
                  .substring(0, (op.data as String).length - 1);
              mergedDelta.push(Operation.insert(trimmed, op.attributes));
            } else {
              mergedDelta.push(op);
            }
          }
        }
        // 2) Otherwise if it’s just a number or string, insert as before
        else if (raw is num || raw is String) {
          print(raw);
          final text = '$raw${blockIdx == inputBlocks.length - 1 ? '\n' : ''}';
          mergedDelta.push(Operation.insert(text));
        }

        // 3) Back-patch the cell’s controller with its plain text
        if (block.indexPath.index != -77) {
          final targetItem = getItemAtPath(block.indexPath, spreadSheetList);
          if (targetItem is SheetText) {
            final ctl = targetItem.textEditorConfigurations.controller;
            final plain = raw is Document ? raw.toPlainText() : raw.toString();
            ctl.replaceText(
              0,
              ctl.document.length,
              plain,
              TextSelection.collapsed(offset: plain.length),
            );
          }
        }

        continue;
      }
    }

    final item = getItemAtPath(block.indexPath, spreadSheetList);
    Delta delta;

    if (item is SheetTextBox) {
      delta = Delta.fromJson(item.textEditorControllerString.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList());
    } else if (item is SheetText) {
      delta = item.textEditorConfigurations.controller.document.toDelta();
    } else {
      continue;
    }

    final ops = delta.toList();
    final isLastBlock = blockIdx == inputBlocks.length - 1;

    if (!isLastBlock && ops.isNotEmpty) {
      final last = ops.last;
      if (last.data is String) {
        final String data = last.data as String;
        if (data == '\n') {
          ops.removeLast();
        } else if (data.endsWith('\n')) {
          final trimmed = data.substring(0, data.length - 1);
          ops[ops.length - 1] = Operation.insert(trimmed, last.attributes);
        }
      }
    }

    if (block.blockIndex.isNotEmpty && block.blockIndex.first == -2) {
      for (final op in ops) {
        mergedDelta.push(op);
      }
    } else {
      for (final i in block.blockIndex) {
        if (i >= 0 && i < ops.length) {
          mergedDelta.push(ops[i]);
        }
      }
    }
  }

  if (inputBlocks.isEmpty || mergedDelta.isEmpty) {
    mergedDelta.insert('\n');
  }

  final doc = Document.fromDelta(mergedDelta);
  return doc.toPlainText().trimRight();
}

List<Widget> windowsTopBar(){
  // Windows top bar
  if (!kIsWeb && Platform.isWindows){
  return [
    GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        appWindow.startDragging();
      },
      onDoubleTap: () {
        appWindow.maximizeOrRestore();
      },
      child: SizedBox(
        height: 50,
        child: Consumer(builder: (context, ref, c) {
          return Stack(
            children: [
              AnimatedPositioned(
                right: 0,
                top:  0,
                duration: Durations.short4,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AnimatedContainer(
                    duration: Durations.short4,
                    padding:
                        const EdgeInsets.only(right: 9, bottom: 0),
                    margin: const EdgeInsets.only(top: 8),
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
                            Future.delayed(Duration.zero).then((y) {
                              appWindow.minimize();
                            });
                          },
                          buttonHeight: 28,
                          buttonWidth: 28,
                          borderRadius: BorderRadius.circular(8),
                          animationDuration:
                              const Duration(milliseconds: 10),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                          ),
                          topLayerChild: const Icon(
                            TablerIcons.rectangle_filled,
                            size: 14,
                            color: Colors.blue,
                          ),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        //
                        //maximize button
                        ElevatedLayerButton(
                          // isTapped: false,
                          // toggleOnTap: true,
                          depth: 2.5, subfac: 2.5,
                          onClick: () {
                            Future.delayed(Durations.short1)
                                .then((y) {
                              appWindow.maximizeOrRestore();
                            });
                          },
                          buttonHeight: 28,
                          buttonWidth: 28,
                          borderRadius: BorderRadius.circular(8),
                          animationDuration:
                              const Duration(milliseconds: 1),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                          ),
                          topLayerChild: const Icon(
                            TablerIcons.triangle_filled,
                            size: 14,
                            color: Colors.green,
                          ),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        //close button
                        ElevatedLayerButton(
                          // isTapped: false,
                          // toggleOnTap: true,
                          depth: 2.5, subfac: 2.5,
                          onClick: () {
                            Future.delayed(Duration.zero).then((y) {
                              appWindow.close();
                            });
                          },
                          buttonHeight: 28,
                          buttonWidth: 28,
                          borderRadius: BorderRadius.circular(8),
                          animationDuration:
                              const Duration(milliseconds: 1),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                          ),
                          topLayerChild:Icon(
                            TablerIcons.circle_filled,
                            size: 15,
                            color: defaultPalette.extras[4],
                          ),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
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
    AnimatedPositioned(
      duration: Durations.medium2,
      top:  12,
      left: 12,
      child: SvgPicture.asset(
        'assets/logos/Asset12.svg',
        width: 35,
        height: 25,
        colorFilter: ColorFilter.mode(defaultPalette.primary, BlendMode.srcIn),
      ),
    ),
    ];
  } else return[ SizedBox.shrink()];
              
}