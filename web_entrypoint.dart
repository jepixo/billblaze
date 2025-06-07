// import 'package:billblaze/Home.dart';
import 'package:billblaze/home.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/firebase_options.dart';
import 'package:billblaze/screens/LoginSignUp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billblaze/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MainApp()));
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
          stream: ref.read(authPr).authStateChanges(),
          builder: (context, stream) {
            if (stream.hasData) {
              // return SafeArea(
              //   child: Material(
              //     child: SpreadSheet(
              //         // items: ref.watch(itemListProvider),
              //         ),
              //   ),
              // );
              return Home();
            } else if (stream.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (stream.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading..."));
            } else {
              return const LoginSignUp();
            }
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
