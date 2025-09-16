import 'dart:async';
import 'dart:io';

import 'package:billblaze/components/elevated_button.dart' show ElevatedLayerButton;
import 'package:billblaze/home.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_functions.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_cell.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_column.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_row.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/firebase_options.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/models/spread_sheet_lib/sized_item.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:billblaze/providers/box_provider.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:billblaze/screens/login_sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hive/hive.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
// import 'package:llama_cpp_dart/llama_cpp_dart.dart';
// void redirectPrintToFile() {
//   final logFile = File('${Directory.systemTemp.path}\\my_app_log.txt');
//   final logSink = logFile.openWrite(mode: FileMode.append);
//   Zone.current.fork(specification: ZoneSpecification(
//     print: (self, parent, zone, line) {
//       final ts = DateTime.now().toIso8601String();
//       logSink.writeln('[$ts] $line');
//       logSink.flush();
//       parent.print(zone, line);
//     },
//   )).run(() {
//     runApp(const ProviderScope(child: MainApp()));
//   });
// }

String? pendingFilePath;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
   if (args.isNotEmpty) {
    pendingFilePath = args.first;
  }
  try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await Hive.close();

  // Get Hive directory
  final directory = await getApplicationSupportDirectory();
  // final files = directory.listSync().where((f) => f.path.endsWith('.hive'));
  // for (var file in files) {
  //   await file.delete();
  // }
  
  // Create BillBlaze folder inside it
  final billBlazeDir = Directory('${directory.path}/BillBlaze');

  if (!(await billBlazeDir.exists())) {
    await billBlazeDir.create(recursive: true);
  }


  Hive.init('${directory.path}/hive');
  Hive.registerAdapter(DocumentPropertiesBoxAdapter());
  Hive.registerAdapter(SheetItemAdapter());
  Hive.registerAdapter(SheetListBoxAdapter());
  Hive.registerAdapter(SheetTextBoxAdapter());
  Hive.registerAdapter(LayoutModelAdapter());
  Hive.registerAdapter(SheetDecorationAdapter());
  Hive.registerAdapter(SuperDecorationBoxAdapter());
  Hive.registerAdapter(AccessAdapter());
  Hive.registerAdapter(ItemDecorationBoxAdapter());
  Hive.registerAdapter(SheetTableBoxAdapter());
  Hive.registerAdapter(SheetTableCellBoxAdapter());
  Hive.registerAdapter(SheetTableRowBoxAdapter());
  Hive.registerAdapter(SheetTableColumnBoxAdapter());
  Hive.registerAdapter(IndexPathAdapter());
  Hive.registerAdapter(InputBlockAdapter());
  Hive.registerAdapter(SheetFunctionAdapter());
  Hive.registerAdapter(RequiredTextAdapter());
  Hive.registerAdapter(ColumnFunctionAdapter());
  Hive.registerAdapter(InputBlockFunctionAdapter());
  Hive.registerAdapter(UniStatFunctionAdapter());
  Hive.registerAdapter(BiStatFunctionAdapter());
  Hive.registerAdapter(UidGeneratorFunctionAdapter());
  Hive.registerAdapter(SheetSizedItemAdapter());
  // await Hive.deleteBoxFromDisk('decorations');
  // await Hive.deleteBoxFromDisk('layouts');
  // await Hive.deleteBoxFromDisk('fetchedLayoutBox');
  // await Hive.box<LayoutModel>('decorations').clear();
  debugPaintSizeEnabled = false; // Disable size debug outlines.
  debugPaintBaselinesEnabled = false; // Disable baseline rendering.
  debugPaintPointersEnabled = false;
  await dotenv.load(fileName: ".env");
  // Llama.libraryPath = "D:/Jepixo/CurrYaar/App/billblaze/build/windows/x64/runner/Release/llama.dll";
  Llama.libraryPath = 'llama.dll';
  InAppWebViewPlatform.instance = WindowsInAppWebViewPlatform();
  if (args.isEmpty && kDebugMode) {
    args = ['C:\\Users\\ANTEC\\AppData\\Roaming\\com.jepixo\\billblaze\\BillBlaze\\1Idn8T7QbydncSOmqLv7yHYKztF2\\main\\Bill-0.bbc'];
  }
  if (args.isNotEmpty) {
    pendingFilePath = args.first;
    print('Pending file path: $pendingFilePath');
    runApp(const ProviderScope(child: MainApp()));
  } else {
  // await LlamaRepository.init(
  await Hive.openBox<LayoutModel>('layouts');
  await Hive.openBox<String>('folderPaths');
  // await Hive.openBox<SheetDecoration>('decorations');
  
  
  //   modelPath: Directory.current.path +"/assets/models/Phi-3-mini-4k-instruct-q4.gguf",
  // );
  

  runApp(const ProviderScope(child: MainApp()));
  
  }
  // redirectPrintToFile();
  }catch (e, st) {
    // If any exception happens, show a fallback UI with the error
    runApp(ErrorApp(error: e, stackTrace: st));
  }
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = const Size(800, 500);

      win.size = const Size(800, 600);
      win.alignment = Alignment.center;
      win.show();
    });
  }
}


class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends ConsumerState<MainApp> {
  bool isLoading = true;
  String log = 'loading';
  LayoutModel? layout;
  @override
  void initState() {
    super.initState();
    isLoading = true;
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      if (pendingFilePath == null) {
        try {
          await Hive.openBox<LayoutModel>(ref.read(authPr).currentUser?.email??'layouts');
        } on Exception catch (e) {
          log = e.toString();
        } finally{
        setState((){
          isLoading = false;
        });}
      } else {
        
        final file = File( pendingFilePath!);
        final content = await file.readAsString();
        setState((){
          layout = LayoutModel.fromJson(content);
          isLoading = false;
        });
      }
    },);
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;
    if(pendingFilePath != null) {
      print('Hello There!');
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'GB'),
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: defaultPalette.extras[0], // Cursor color
          selectionColor:
              defaultPalette.tertiary.withValues(alpha: 0.5), // Text highlight color
          selectionHandleColor:
              Colors.green, // Handle color when dragging selection
        ),
      ),home:  isLoading
      ? Scaffold(
          backgroundColor: defaultPalette.extras[0],
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
                      'assets/logos/Asset6.svg',
                      // allowDrawingOutsideViewBox: true,
                      // theme: SvgTheme(currentColor: defaultPalette.primary),
                    )
                  ),
                )),
                if (Platform.isWindows)
                Positioned(
                  top:0,
                  width: sWidth,
                  height: 50,
                  child: GestureDetector(
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
                                      const SizedBox(
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
                                      const SizedBox(
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
                ),
                    
              ]
            ),
          ),)
      :LayoutDesigner(layoutModel: layout!, onPop: (_) {},id: null,));
    
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'GB'),
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: defaultPalette.extras[0], // Cursor color
          selectionColor:
              defaultPalette.tertiary.withValues(alpha: 0.5), // Text highlight color
          selectionHandleColor:
              Colors.green, // Handle color when dragging selection
        ),
      ),
      // home: RootRouter(),
      home: isLoading
      ? Scaffold(
          backgroundColor: defaultPalette.extras[0],
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
                      'assets/logos/Asset6.svg',
                      // allowDrawingOutsideViewBox: true,
                      // theme: SvgTheme(currentColor: defaultPalette.primary),
                    )
                  ),
                )),
                if (Platform.isWindows)
                Positioned(
                  top:0,
                  width: sWidth,
                  height: 50,
                  child: GestureDetector(
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
                                      const SizedBox(
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
                                      const SizedBox(
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
                ),
                    
              ]
            ),
          ),)
      : Consumer(builder: (context, ref, c) {
        // RefHolder.ref = ref;
        return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, stream) {
              if (stream.hasData) {
                // ref
                //     .read(authRepositoryProvider)
                //     .checkAndCreateUserDocument(context, ref);
                () async{await Hive.openBox<LayoutModel>(ref.read(authPr).currentUser?.email??'layouts');}();
                return const Home();
                // return SafeArea(
                //     child: Material(
                //         child: SpreadSheet(
                //             // items: ref.watch(itemListProvider),
                //             )
                //         //  MultiBoardListExample()
                //         ));
                // return LayoutDesigner();
              } else if (stream.hasError) {
                return const Center(child: Text('Gone Wrong'));
              } else if (stream.connectionState == ConnectionState.waiting) {
                return const LoginSignUp();
                // return  Container(
                //   color: defaultPalette.extras[0],
                //   child: Center(
                //       child: SvgPicture.asset(
                //         'assets/logos/Asset6.svg',
                //         // allowDrawingOutsideViewBox: true,
                //         // theme: SvgTheme(currentColor: defaultPalette.primary),
                //       )
                //     ),
                // );
              } else {
                return const LoginSignUp();
                // return Container();
              }
            });
      }),
    
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ErrorApp extends ConsumerStatefulWidget {
  final Object error;
  final StackTrace stackTrace;

  const ErrorApp({required this.error, required this.stackTrace, Key? key}) : super(key: key);

  @override
  ConsumerState<ErrorApp> createState() => _ErrorAppState();
}

class _ErrorAppState extends ConsumerState<ErrorApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'GB'),
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: defaultPalette.extras[0], // Cursor color
          selectionColor:
              defaultPalette.tertiary.withValues(alpha: 0.5), // Text highlight color
          selectionHandleColor:
              Colors.green, // Handle color when dragging selection
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Startup Error '+(pendingFilePath != null?' - Opening file: $pendingFilePath':'')),),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'An error occurred:\n\n${widget.error}\n\nStackTrace:\n${widget.stackTrace}',
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ),
            ),
            // Windows top bar
              if (Platform.isWindows)
                Positioned.fill(
                  top: 0,
                  child: GestureDetector(
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
                ),
              
          ],
        ),
      ),
    );
  }
}

  Future<void> loadBBCFile(String path, WidgetRef ref, BuildContext context) async {
    try {
      final file = File(path);
      final content = await file.readAsString();
      final layout = LayoutModel.fromJson(content);

      final box = Boxes.getLayouts(ref);
      if (!box.containsKey(layout.id)) {
        box.put(layout.id, layout);
      }
      pendingFilePath =null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LayoutDesigner(id: layout.id, onPop: (_) {}),
          ),
        );
      });
    } catch (e) {
      debugPrint("❌ Failed to open .bbc file: $e");
    }
  }
