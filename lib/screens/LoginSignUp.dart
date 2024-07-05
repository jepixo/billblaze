import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/providers/auth_provider.dart';

class LoginSignUp extends StatefulWidget {
  final bool withClose;

  const LoginSignUp({super.key, this.withClose = false});

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, c) {
      return Scaffold(
        backgroundColor: drabDarkBrown,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: -500,
              child: Opacity(
                opacity: 0.8,
                child: Container(color: Colors.redAccent),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.8),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 18, sigmaY: 18, tileMode: TileMode.mirror),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
            widget.withClose
                ? Positioned(
                    // top: 5,
                    right: 6,
                    child: SafeArea(
                      child: Transform.rotate(
                        angle: -7,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Hero(
                            tag: 'addclose',
                            child: Icon(
                              Icons.add,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            Padding(
                padding: const EdgeInsets.only(left: 30, top: 60),
                child: Text('Billblaze\nHai Bhai',
                    style: GoogleFonts.alata(
                        fontSize: 50, color: defaultPalette.secondary))),
            Padding(
                padding: const EdgeInsets.only(left: 30, top: 200),
                child: Text('Bhai login karega toh hi samjhega na',
                    style: GoogleFonts.alata(
                        fontSize: 20, color: defaultPalette.secondary))),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "LogIn Using :",
                  style:
                      GoogleFonts.bebasNeue(fontSize: 20, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () async {
                    await ref.read(authRepositoryProvider).googleLogin(ref);
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          color: Colors.white.withOpacity(0.2),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                "Google",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ),
                          ]),
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
    });
  }
}
