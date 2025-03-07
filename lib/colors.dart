// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

final smokyBlack = Color(0xFF5A6B0F);
final drabDarkBrown = Color(0xFF262A10);
final brown = Color(0xFF54442B);
final honeyDew = Color(0xFFE8F7EE);
final pigmentGreen = Color(0xFF53A548);
final seaGreen = Color(0xFF4C934C);

class ColorPalette {
  Color primary;
  Color secondary;
  Color tertiary;
  Color? quaternary;
  Color white;
  Color black;
  Color transparent;
  List<Color> extras;
  ColorPalette(
      {required this.primary,
      required this.secondary,
      required this.tertiary,
      this.extras = const [],
      this.quaternary,
      this.white = Colors.white,
      this.black = Colors.black,
      this.transparent = Colors.transparent});

  ColorPalette copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? quaternary,
    Color? white,
    Color? black,
  }) {
    return ColorPalette(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      quaternary: quaternary ?? this.quaternary,
      white: white ?? this.white,
      black: black ?? this.black,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'primary': primary.value,
      'secondary': secondary.value,
      'tertiary': tertiary.value,
      'quaternary': quaternary?.value,
      'white': white.value,
      'black': black.value,
    };
  }

  factory ColorPalette.fromMap(Map<String, dynamic> map) {
    return ColorPalette(
      primary: Color(map['primary'] as int),
      secondary: Color(map['secondary'] as int),
      tertiary: Color(map['tertiary'] as int),
      quaternary:
          map['quaternary'] != null ? Color(map['quaternary'] as int) : null,
      white: Color(map['white'] as int),
      black: Color(map['black'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory ColorPalette.fromJson(String source) =>
      ColorPalette.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ColorPalette(primary: $primary, secondary: $secondary, tertiary: $tertiary, quaternary: $quaternary, white: $white, black: $black)';
  }

  @override
  bool operator ==(covariant ColorPalette other) {
    if (identical(this, other)) return true;

    return other.primary == primary &&
        other.secondary == secondary &&
        other.tertiary == tertiary &&
        other.quaternary == quaternary &&
        other.white == white &&
        other.black == black;
  }

  @override
  int get hashCode {
    return primary.hashCode ^
        secondary.hashCode ^
        tertiary.hashCode ^
        quaternary.hashCode ^
        white.hashCode ^
        black.hashCode;
  }
}

ColorPalette OGPalette = ColorPalette(
  primary: const Color(0xFF4C934C), //seaGreen
  secondary: const Color(0xFFE8F7EE), //honeyDew
  tertiary: const Color(0xFF54442B), //brown
);

ColorPalette defaultPalette = againPalette;

ColorPalette anotherOne = ColorPalette(
    primary: Color(0xFF322C2B),
    secondary: Color(0xFFE4C59E),
    tertiary: Color(0xFFAF8260),
    quaternary: Color(0xFF803D3B));

ColorPalette darkPalette = ColorPalette(
    primary: Color(0xFF242424),
    secondary: Color(0xFFBBBBBB),
    tertiary: Color(0xFFAF8260),
    quaternary: Color(0xFF4C6B93));

ColorPalette againPalette = ColorPalette(
    primary: Colors.white,
    secondary: Color(0xFFEAEAEA),
    tertiary: Colors.green,
    quaternary: Color(0xFF1C110A),
    extras: [
      Color(0xff293132),
      Color(0xffF9DC5C),
      Color(0xffEB5E28),
      Color(0xffe94f37),
      Color(0xffFF8C61),
      Color(0xffE54B4B),
      Color(0xffD62828),
      
      Color(0xff664C43),
      
      Color(0xffC4D7F2),
      Color(0xff4D7EA8),
      Color(0xff3C91E6),
      Color(0xff916953),
    ]);
