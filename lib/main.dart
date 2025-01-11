import 'dart:io';

import 'package:billblaze/Home.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:billblaze/firebase_options.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/spread_sheet_lib/text_editor_item.dart';
import 'package:billblaze/screens/LoginSignUp.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

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
  Hive.registerAdapter(TextEditorItemBoxAdapter());
  Hive.registerAdapter(LayoutModelAdapter());
  // await Hive.deleteBoxFromDisk('layouts');
  await Hive.openBox<LayoutModel>('layouts');
  // await Hive.box<LayoutModel>('layouts').clear();
  debugPaintSizeEnabled = false; // Disable size debug outlines.
  debugPaintBaselinesEnabled = false; // Disable baseline rendering.
  debugPaintPointersEnabled = false;
  runApp(const ProviderScope(child: MainApp()));
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = Size(700, 400);

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
                // return LayoutDesigner3();
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

final currentTabIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final itemListProvider = StateProvider<List<String>>((ref) {
  return ['A1', 'B2'];
});
