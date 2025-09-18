import 'dart:async';
import 'dart:io';

import 'package:billblaze/components/elevated_button.dart' show ElevatedLayerButton;
import 'package:billblaze/hive/hive_registrar.g.dart';
import 'package:billblaze/home.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/firebase_options.dart';
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
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
// import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
// import 'package:llama_cpp_dart/llama_cpp_dart.dart';


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

  if (kIsWeb) {
    // Web: No real directories. Hive will use IndexedDB automatically.
    await Hive.initFlutter();

    // You can define a virtual "path" if you need it logically
    const billBlazeVirtualPath = '/virtual/BillBlaze';
    print('Using virtual path for web: $billBlazeVirtualPath');
  } else {
    final directory = await getApplicationSupportDirectory();

    // Create BillBlaze folder
    final billBlazeDir = Directory('${directory.path}/BillBlaze');
    if (!(await billBlazeDir.exists())) {
      await billBlazeDir.create(recursive: true);
    }

    Hive.init('${billBlazeDir.path}/hive');
  }
  Hive.registerAdapters();
  // Hive.registerAdapter(DocumentPropertiesBoxAdapter());
  // Hive.registerAdapter(SheetItemAdapter());
  // Hive.registerAdapter(SheetListBoxAdapter());
  // Hive.registerAdapter(SheetTextBoxAdapter());
  // Hive.registerAdapter(LayoutModelAdapter());
  // Hive.registerAdapter(SheetDecorationAdapter());
  // Hive.registerAdapter(SuperDecorationBoxAdapter());
  // Hive.registerAdapter(AccessAdapter());
  // Hive.registerAdapter(ItemDecorationBoxAdapter());
  // Hive.registerAdapter(SheetTableBoxAdapter());
  // Hive.registerAdapter(SheetTableCellBoxAdapter());
  // Hive.registerAdapter(SheetTableRowBoxAdapter());
  // Hive.registerAdapter(SheetTableColumnBoxAdapter());
  // Hive.registerAdapter(IndexPathAdapter());
  // Hive.registerAdapter(InputBlockAdapter());
  // Hive.registerAdapter(SheetFunctionAdapter());
  // Hive.registerAdapter(RequiredTextAdapter());
  // Hive.registerAdapter(ColumnFunctionAdapter());
  // Hive.registerAdapter(InputBlockFunctionAdapter());
  // Hive.registerAdapter(UniStatFunctionAdapter());
  // Hive.registerAdapter(BiStatFunctionAdapter());
  // Hive.registerAdapter(UidGeneratorFunctionAdapter());
  // Hive.registerAdapter(SheetSizedItemAdapter());
  // await Hive.deleteBoxFromDisk('decorations');
  // await Hive.deleteBoxFromDisk('layouts');
  // await Hive.deleteBoxFromDisk('fetchedLayoutBox');
  // await Hive.box<LayoutModel>('decorations').clear();
  debugPaintSizeEnabled = false; // Disable size debug outlines.
  debugPaintBaselinesEnabled = false; // Disable baseline rendering.
  debugPaintPointersEnabled = false;
  await dotenv.load(fileName: ".env");
  // Llama.libraryPath = "D:/Jepixo/CurrYaar/App/billblaze/build/windows/x64/runner/Release/llama.dll";
  // Llama.libraryPath = 'llama.dll';
  // InAppWebViewPlatform.instance = WebInAppWebViewPlatform();
  // InAppWebViewPlatform.instance = WebPlatformInAppWebViewPlatform();
  // if (args.isEmpty && kDebugMode) {
  //   args = ['C:\\Users\\ANTEC\\AppData\\Roaming\\com.jepixo\\billblaze\\BillBlaze\\1Idn8T7QbydncSOmqLv7yHYKztF2\\main\\Bill-0.bbc'];
  // }
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
  if (!kIsWeb && Platform.isWindows) {
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
          await Hive.openBox<LayoutModel>('layouts');
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
                if (!kIsWeb && Platform.isWindows)
                ...windowsTopBar(),   
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
                if (!kIsWeb && Platform.isWindows)
                ...windowsTopBar(),   
              ]
            ),
          ),)
      : Consumer(builder: (context, ref, c) {
        // RefHolder.ref = ref;
        return const Home();
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
            if (!kIsWeb && Platform.isWindows)
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

