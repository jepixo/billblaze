import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';

/// Textfield for entering the Hex color code (RRGGBB).
class HexPicker extends StatefulWidget {
  HexPicker({
    required this.color,
    required this.onChanged,
    required this.controller,
    Key? key,
  })  :  
        super(key: key);

  final Color color;
  final ValueChanged<Color> onChanged;
  final TextEditingController controller;

  @override
  State<HexPicker> createState() => _HexPickerState();
}

class _HexPickerState extends State<HexPicker> {
  void textOnSubmitted(String value) => widget.onChanged(
        textOnChenged(value),
      );
  Color textOnChenged(String text) {
    print(text);

      print(hexToColor(text));
      return hexToColor(text);
    
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '#',
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 12, fontFamily: GoogleFonts.bungee().fontFamily),
          ),
        ),

        // TextField
        Expanded(
          child: TextField(
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 12,  fontFamily: GoogleFonts.bungee().fontFamily),
            focusNode: FocusNode()..addListener(() {}),
            controller: widget.controller,
            onSubmitted: textOnSubmitted,
            decoration: const InputDecoration.collapsed(hintText: 'hex code'),
          ),
        )
      ],
    );
  }
}

 