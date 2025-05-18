import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SliderTitle extends StatelessWidget {
  const SliderTitle(
    this.title,
    this.text, {
    Key? key,
  }) : super(key: key);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        children: <Widget>[
          Opacity(
            opacity: 0.7,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 12,
                     fontFamily: GoogleFonts.bungee().fontFamily
                  ),
            ),
          ),
          const Spacer(),
          Text(
            text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 12,
                   fontFamily: GoogleFonts.bungee().fontFamily
                ),
          ),
        ],
      ),
    );
  }
}
