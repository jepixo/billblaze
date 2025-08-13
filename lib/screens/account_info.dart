import 'dart:io';
import 'dart:ui';
import 'package:billblaze/colors.dart';
import 'package:billblaze/components/elevated_button.dart';
import 'package:billblaze/home.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';


class Username extends StatelessWidget {
  final String text;
  final double sWidth;
  final double sHeight;

  const Username({
    Key? key,
    required this.text,
    required this.sWidth,
    required this.sHeight,
    }) : super(key: key);

  List<String> divideWord(String word) {
    int wordlen = word.length;
    int sym2 = wordlen % 4;
    int sym3 = wordlen % 5;
    int div2 = wordlen ~/ 3;
    int div3 = wordlen ~/ 4;
    int div4 = wordlen ~/ 5;
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

    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.end,
      spacing: -60,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: substrings
          .map((substring) =>
              // Animated
              Text(
                substring.toUpperCase(),
                textAlign: TextAlign.start,
                style: GoogleFonts.leagueSpartan(
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                  letterSpacing: -6,
                    color: defaultPalette.extras[0].withOpacity(0.2),
                    fontSize: mapValueDimensionBasedLockOnDesync(100, 140, sWidth, sHeight),
                    decoration: TextDecoration.none),
                // duration: const Duration(milliseconds: 500),
              ))
          .toList(),
    );
  }
}
