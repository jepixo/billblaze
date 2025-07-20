import 'dart:io';

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
import 'package:billblaze/repo/llama_repository.dart';
import 'package:billblaze/screens/login_sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
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
  Hive.registerAdapter(SumFunctionAdapter());
  Hive.registerAdapter(RequiredTextAdapter());
  Hive.registerAdapter(ColumnFunctionAdapter());
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


final itemListProvider = StateProvider<List<String>>((ref) {
  return ['A1', 'B2'];
});
