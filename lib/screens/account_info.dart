import 'dart:io';
import 'dart:ui';
import 'package:billblaze/components/elevated_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo>
    with SingleTickerProviderStateMixin {
  //Animation Variables
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glPos;

  //User Auth Variables

  //
  //Functions
  //
  @override
  void initState() {
    super.initState();

//Animation Controller Initialization
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

//OpacityAnimated value used for multiple things later
    _opacityAnimation = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
//Animation plays as the page is called
    _controller.forward();

//FETCHING USERNAME if exists
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

//
//
//Actual Widget Building
//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final User? user = ref.watch(authPr).currentUser;
          // String username = ref.watch(usernameProvider);

          return Stack(
            children: [
              Stack(
                children: [
                  //Switcher for fading when account changes.
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 1500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: Container(
                      //I think based on the key the switch is toggled.
                      key: ValueKey<String>(user?.photoURL ?? ''),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          //
                          // Background Blurred Image
                          //
                          image: NetworkImage(user?.photoURL ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 8,
                          sigmaY: 8,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                    ),
                  ),
              
                  //
                  // End Background blur image
                  //
                  
                ],
              ),
              //
              //
              //
              // THE INFO TAB FLYING IN
              //
              //
              //
              LayoutBuilder(
                builder: (context, constraints) {
                  _glPos = Tween<double>(
                    end: constraints.maxHeight / 3,
                    begin: constraints.maxHeight / 1.5,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                  );
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _glPos.value),
                        child: Container(
                          width: MediaQuery.of(context).size.width -
                              (1.6 * (MediaQuery.of(context).size.width / 10)),
                          height: MediaQuery.of(context).size.height / 1.2,
                          decoration: BoxDecoration(
                            color: Color(0xFF1F1F1D)
                                .withOpacity(_opacityAnimation.value),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(30),
                            ),
                          ),
                          //
                          // Details in the INFO TAB
                          //
                          child: Stack(
                            children: [
                              Username(text: user!.email!),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 25.0, top: 20),
                                child:
                                    // Animated
                                    Text(
                                  user.displayName ?? 'anonymussy',
                                  // positionCurve: Curves.easeInOut,
                                  // opacityFromCurve: Curves.easeInOut,
                                  // duration: const Duration(milliseconds: 500),
                                  style: GoogleFonts.outfit(
                                    decoration: TextDecoration.none,
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              //
              //
              //END TAB FLYING IN
              //
              //
              Positioned(
                right: 8,
                top: MediaQuery.of(context).size.height / 3,
                child: Column(children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    child: GestureDetector(
                      onTap: () async {  
                          await ref.read(authRepositoryProvider).googleLogOut(ref);
                        
                        // Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.logout,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ]),
              ),
              
            ],
          );
        },
      ),
    );
  }
}

class Username extends StatelessWidget {
  final String text;

  const Username({Key? key, required this.text}) : super(key: key);

  List<String> divideWord(String word) {
    int wordlen = word.length;
    int sym2 = wordlen % 2;
    int sym3 = wordlen % 3;
    int div2 = wordlen ~/ 2;
    int div3 = wordlen ~/ 3;
    int div4 = wordlen ~/ 4;
    int idealDivd = 1;
    //
    if (div4 >= div3 && div4 > 1 && div2 <= 4) {
      idealDivd = 4;
    } else if (div3 >= div4 && (div3 <= div2 && sym3 <= sym2)) {
      idealDivd = 3;
    } else {
      idealDivd = 2;
    }

    List<String> dividedWord = [];
    int startIndex = 0;
    int endIndex = 0;
    while (endIndex <= word.length) {
      endIndex = startIndex + idealDivd;
      if (startIndex <= wordlen && endIndex <= wordlen) {
        dividedWord.add(word.substring(startIndex, endIndex));
      }
      startIndex = endIndex;
    }
    if (wordlen % idealDivd != 0) {
      dividedWord.add(word.substring(wordlen - (wordlen % idealDivd), wordlen));
    }
    return dividedWord;
  }

  @override
  Widget build(BuildContext context) {
    List<String> substrings = divideWord(text);

    return Positioned(
      top: 100,
      right: -20,
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.end,
        spacing: -60,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: substrings
            .map((substring) =>
                // Animated
                Text(
                  substring,
                  style: GoogleFonts.bebasNeue(
                      color: Colors.white.withOpacity(0.1),
                      fontSize: 150,
                      decoration: TextDecoration.none),
                  // duration: const Duration(milliseconds: 500),
                ))
            .toList(),
      ),
    );
  }
}
