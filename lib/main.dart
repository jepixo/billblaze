import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
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
import 'package:billblaze/providers/auth_provider.dart';
import 'package:billblaze/repo/llama_repository.dart';
import 'package:billblaze/screens/login_sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
// import 'package:llama_cpp_dart/llama_cpp_dart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
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
  // await Hive.deleteBoxFromDisk('decorations');
  // await Hive.deleteBoxFromDisk('layouts');
  // await Hive.deleteBoxFromDisk('fetchedLayoutBox');
  await Hive.openBox<LayoutModel>('layouts');
  await Hive.openBox<SheetDecoration>('decorations');
  
  // await Hive.box<LayoutModel>('decorations').clear();
  debugPaintSizeEnabled = false; // Disable size debug outlines.
  debugPaintBaselinesEnabled = false; // Disable baseline rendering.
  debugPaintPointersEnabled = false;
  await dotenv.load(fileName: ".env");
  Llama.libraryPath = "D:/Jepixo/CurrYaar/App/billblaze/build/windows/x64/runner/Release/llama.dll";

  InAppWebViewPlatform.instance = WindowsInAppWebViewPlatform();
  // await LlamaRepository.init(
  //   modelPath: Directory.current.path +"/assets/models/Phi-3-mini-4k-instruct-q4.gguf",
  // );
  
  

  runApp(const ProviderScope(child: MainApp()));
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = Size(800, 500);

      win.size = Size(800, 600);
      win.alignment = Alignment.center;
      win.show();
    });
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'GB'),
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: defaultPalette.extras[0], // Cursor color
          selectionColor:
              defaultPalette.tertiary.withOpacity(0.5), // Text highlight color
          selectionHandleColor:
              Colors.blue, // Handle color when dragging selection
        ),
      ),
      // home: RootRouter(),
      home: Consumer(builder: (context, ref, c) {
        return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, stream) {
              if (stream.hasData) {
                // ref
                //     .read(authRepositoryProvider)
                //     .checkAndCreateUserDocument(context, ref);
                return Home();
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
                return const Center(child: Center(child: Text("im coming")));
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

class RootRouter extends ConsumerStatefulWidget {
  const RootRouter({Key? key}) : super(key: key);

  @override
  ConsumerState<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends ConsumerState<RootRouter> {
  bool _listenerRegistered = false;
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    // Register the listener exactly once, but do it from inside build
    if (!_listenerRegistered) {
      ref.listen<AsyncValue<User?>>(authStateStreamProvider, (prev, next) {
        next.whenData((user) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_navigated) return; // guard against double navigation
            _navigated = true;

            if (user != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => Home()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginSignUp()),
              );
            }
          });
        });
      });

      _listenerRegistered = true;
    }

    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;
    double titleFontSize = sHeight / 9;
    return Scaffold(body: 
    Stack(
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
                    //BILLBLAZE MAIN TITLE
                    AnimatedPositioned(
                      duration: Durations.medium3,
                      top: 60,
                      left: 70,
                      child: Hero(
                        tag: 'login',
                        child: AnimatedTextKit(
                          key: ValueKey(sHeight*sWidth),
                          animatedTexts: [
                            TypewriterAnimatedText(
                              "Bill\nBlaze.",
                              textStyle: GoogleFonts.abrilFatface(
                                  fontSize: titleFontSize,
                                  color: defaultPalette.primary,
                                  height: 0.9),
                              speed: const Duration(milliseconds: 100)),
                            TypewriterAnimatedText(
                              "Bill\nBlaze.",
                              textStyle: GoogleFonts.zcoolKuaiLe(
                                  fontSize:titleFontSize,
                                  color: defaultPalette.primary,
                                  height: 0.9),
                              speed: const Duration(milliseconds: 100)),
                            TypewriterAnimatedText(
                              "Bill\nBlaze.",
                              textStyle: GoogleFonts.ballet(
                                  fontSize: titleFontSize,
                                  color:defaultPalette.primary,
                                  height: 0.9),
                              speed: const Duration(milliseconds: 100)),
                            TypewriterAnimatedText(
                              "Bill\nBlaze",
                              textStyle: GoogleFonts.rubikDoodleShadow(
                                  fontSize: titleFontSize ,
                                  letterSpacing: -0.5,
                                  height: 1),
                              speed: const Duration(milliseconds: 100)),
                            TypewriterAnimatedText(
                              "Bill\nBlaze.",
                              textStyle: GoogleFonts.redactedScript(
                                  fontSize: titleFontSize,
                                  color: defaultPalette.primary,
                                  height: 0.9),
                              speed: const Duration(milliseconds: 100)),
                            TypewriterAnimatedText("Bill\nBlaze.",
                                textStyle: GoogleFonts.silkscreen(
                                    fontSize: titleFontSize,
                                    color: defaultPalette.primary,
                                    height: 0.9),
                                speed: const Duration(milliseconds: 100)),
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
                    ),
            
                  ],
                );
              }),
            ),
          ),

      ],
    ),);
  }
}
