import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pickers/hsv_picker.dart';
import 'pickers/palette_hue_picker.dart';
import 'pickers/palette_saturation_picker.dart';
import 'pickers/palette_value_picker.dart';
import 'pickers/rgb_picker.dart';
import 'pickers/swatches_picker.dart';
import 'pickers/wheel_picker.dart';
import 'widgets/alpha_picker.dart';
import 'widgets/hex_picker.dart';

enum Picker {
  swatches,
  rgb,
  hsv,
  wheel,
  paletteHue,
  paletteSaturation,
  paletteValue,
}

/// The orientation of the ColorPicker.
enum PickerOrientation {
  /// The orientation is inherited from device's orientation.
  /// On web, if window width > height, the orientation is landscape.
  inherit,

  /// Always portrait mode.
  portrait,

  /// Always landscape mode.
  landscape,
}

/// Main color picker including all color pickers of this package.
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    required this.onChanged,
    this.color = Colors.blue,
    this.initialPicker = Picker.paletteHue,
    this.pickerOrientation = PickerOrientation.inherit,
    this.paletteHeight = 280,
    this.expanded = false,
    required this.controller,
    Key? key,
  }) : super(key: key);

  final ValueChanged<Color> onChanged;
  final Color color;
  final TextEditingController controller;
  /// The first picker widget that is shown.
  ///
  /// See also:
  ///
  ///  * [Picker] Enumeration of pickers.
  final Picker initialPicker;

  final PickerOrientation pickerOrientation;

  final bool expanded;

  final double paletteHeight;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  _ColorPickerState();

  // Color
  late int _alpha;
  late Color _color;
  late HSVColor _hSVColor;
  late List<_IPicker> _pickers;
  late int _index;

  void _alphaOnChanged(int value) {
    _updateColor(_color.withAlpha(value));
  }

  void _colorOnChanged(Color value) {
    _updateColor(value.withAlpha(_color.alpha));
  }

  void _hSVColorOnChanged(HSVColor value) {
    _updateColor(value.toColor().withAlpha(_color.alpha));
  }

  void _colorWithAlphaOnChanged(Color value) {
    _updateColor(value);
  }

  void _updateColor(Color color) {
    _alpha = color.alpha;
    _color = color;
    _hSVColor = HSVColor.fromColor(color);
    widget.onChanged(color);
  }

  void _pickerOnChanged(_IPicker? value) {
    if (value != null) {
      _index = _pickers.indexOf(value);
    } else {
      _index = -1;
    }
  }

  @override
  void initState() {
    super.initState();

    _color = widget.color;
    _alpha = _color.alpha;
    _hSVColor = HSVColor.fromColor(_color);

    // Pickers
    _pickers = <_IPicker>[
      // HSVPicker
      _IPicker(
        name: 'HSV',
        picker: Picker.hsv,
        builder: (BuildContext context) => HSVPicker(
          color: _hSVColor,
          onChanged: (HSVColor value) => super.setState(
            () => _hSVColorOnChanged(value),
          ),
        ),
      ),

      // WheelPicker
      _IPicker(
        name: 'Wheel',
        picker: Picker.wheel,
        builder: (BuildContext context) => WheelPicker(
          color: _hSVColor,
          onChanged: (HSVColor value) => super.setState(
            () => _hSVColorOnChanged(value),
          ),
        ),
      ),
    ];

    _index = _pickers.indexOf(
      _pickers.firstWhere((element) => element.picker == widget.initialPicker),
    );
  }

  // Dropdown
  DropdownMenuItem<_IPicker> _buildDropdownMenuItems(_IPicker item) {
    return DropdownMenuItem<_IPicker>(
      value: item,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0.0, 0.0),
        child: Text(
          item.name,
          style: _index == _pickers.indexOf(item)
              ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 12,
                    fontFamily: GoogleFonts.bungee().fontFamily,
                  )
              : Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 12, fontFamily: GoogleFonts.bungee().fontFamily),
        ),
      ),
    );
  }

  Widget _buildHead() {
    return Container(
      decoration: BoxDecoration(
          color: defaultPalette.secondary,
          borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.all(5).copyWith(top: 5, left: 0),
      alignment: Alignment.center,
      height: 25,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Avator
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: defaultPalette.extras[0], width: 1),
                ),
                color: _color,
              ),
            ),
          ),

          // HexPicker
          Expanded(
            flex: 2,
            child: HexPicker(
              color: _color,
              controller: widget.controller,
              onChanged: (Color value) => super.setState(
                () => _colorOnChanged(value),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdownLandscapeMode() {
    return SizedBox(
      height: 38,
      child: Material(
        type: MaterialType.button,
        color: Theme.of(context).cardColor,
        shadowColor: Colors.black26,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: DropdownButton<_IPicker>(
          iconSize: 32.0,
          isExpanded: true,
          isDense: true,
          style:
              Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
          value: _pickers[_index],
          onChanged: (_IPicker? value) => super.setState(
            () => _pickerOnChanged(value),
          ),
          items: _pickers.map(_buildDropdownMenuItems).toList(),
        ),
      ),
    );
  }

  Widget _buildDropdownPortraitMode() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<_IPicker>(
        iconSize: 15.0,
        isExpanded: true,
        isDense: true,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 12, fontFamily: GoogleFonts.bungee().fontFamily),
        value: _pickers[_index],
        onChanged: (_IPicker? value) => super.setState(
          () => _pickerOnChanged(value),
        ),
        items: _pickers.map(_buildDropdownMenuItems).toList(),
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      child: _pickers[_index].builder(context),
    );
  }

  Widget _buildAlphaPicker() {
    return AlphaPicker(
      alpha: _alpha,
      onChanged: (int value) => super.setState(
        () => _alphaOnChanged(value),
      ),
    );
  }

  Orientation _getOrientation(PickerOrientation pickerOrientation) {
    switch (pickerOrientation) {
      case PickerOrientation.inherit:
        return MediaQuery.of(context).orientation;
      case PickerOrientation.portrait:
        return Orientation.portrait;
      case PickerOrientation.landscape:
        return Orientation.landscape;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = _getOrientation(widget.pickerOrientation);

    switch (orientation) {
      case Orientation.portrait:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildHead(),

            if(widget.expanded)
            ...[_buildBody(),
            _buildAlphaPicker(),
            _buildDropdownPortraitMode(),]
          ],
        );

      case Orientation.landscape:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildHead(),
                  _buildDropdownLandscapeMode(),
                  _buildAlphaPicker(),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            )
          ],
        );
    }
  }
}

class _IPicker {
  _IPicker({
    required this.name,
    required this.picker,
    required this.builder,
  });

  String name;
  Picker picker;
  WidgetBuilder builder;
}
