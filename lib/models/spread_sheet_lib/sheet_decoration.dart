// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:uuid/uuid.dart';

import 'package:billblaze/providers/box_provider.dart';

part 'sheet_decoration.g.dart';

@HiveType(typeId: 5)
enum Access {
  @HiveField(0)
 local,
 @HiveField(1)
 global
}

@HiveType(typeId: 6)
class SheetDecoration extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final Access access;
  SheetDecoration({
    required this.id,
    required this.name,
    this.access = Access.global
  });
  
}

@HiveType(typeId: 7)
class SuperDecorationBox extends SheetDecoration{
  @HiveField(3)
  List<dynamic> itemDecorationList;

  SuperDecorationBox({
    required super.id,
    super.name = 'Untitled',
    this.itemDecorationList = const [],
  });

  SuperDecoration toSuperDecoration() {
    return SuperDecoration(
      id: id,
      name: name,
      itemDecorationList: decodeItemDecorationList(itemDecorationList)
      );
  }
}

@HiveType(typeId: 8)
class ItemDecorationBox extends SheetDecoration {
  @HiveField(3)
  Map<String, dynamic> itemDecoration;
  
  ItemDecorationBox({
    required this.itemDecoration, required super.id, super.name = 'Untitled',
  });
}

 
class ItemDecoration extends SheetDecoration{
  
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxDecoration decoration;
  final Alignment alignment;
  final Matrix4? transform;
  final BoxDecoration foregroundDecoration; 
  final Map<String, dynamic> pinned;

  ItemDecoration({
    required super.id,
    super.name = 'Untitled',
    this.padding = const EdgeInsets.all(0),
    this.margin = const EdgeInsets.all(0),
    this.decoration = const BoxDecoration(),
    this.alignment = const Alignment(0, 0),
    this.foregroundDecoration = const BoxDecoration(),
    this.transform, 
    Map<String, dynamic>? pinned,
  }) : pinned = pinned?? defaultPins() ;

  // ✅ Convert the ItemDecoration to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'padding': [padding.top, padding.bottom, padding.left, padding.right],
      'margin': [margin.top, margin.bottom, margin.left, margin.right],
      'decoration': _boxDecorationToJson(decoration ),
      'alignment': [alignment.x, alignment.y],
      'transform': transform?.storage,
      'foregroundDecoration': _boxDecorationToJson(foregroundDecoration), 
      'pinned': pinned,

    };
  }

  // ✅ Convert the ItemDecoration from JSON
  factory ItemDecoration.fromJson(Map<dynamic, dynamic> json) {
    return ItemDecoration(
      padding: EdgeInsets.fromLTRB(
        json['padding'][2] ?? 0.0, // left
        json['padding'][0] ?? 0.0, // top
        json['padding'][3] ?? 0.0, // right
        json['padding'][1] ?? 0.0, // bottom
      ),
      margin: EdgeInsets.fromLTRB(
        json['margin'][2] ?? 0.0, // left
        json['margin'][0] ?? 0.0, // top
        json['margin'][3] ?? 0.0, // right
        json['margin'][1] ?? 0.0, // bottom
      ),
      decoration: _boxDecorationFromJson(json['decoration'], ),
      alignment: Alignment(
        json['alignment'][0] ?? 0.0,
        json['alignment'][1] ?? 0.0,
      ),
      transform: json['transform'] != null
          ? Matrix4.fromList(List<double>.from(json['transform']))
          : null,
      foregroundDecoration: _boxDecorationFromJson(json['foregroundDecoration'], ), 
      id: json['id'], 
      name: json['name'],
      pinned: Map<String, dynamic>.from(json['pinned'] ?? defaultPins()),
    );
  }

  // ✅ Helper for BoxDecoration to JSON
  static Map<String, dynamic> _boxDecorationToJson(BoxDecoration decoration ) {
    return {
      'color': decoration.color?.value,
      'border': decoration.border != null
          ? (decoration.border! is Border)
          ? {
              'left': _borderSideToJson((decoration.border! as Border).left),
              'right': _borderSideToJson((decoration.border!  as Border).right),
              'top': _borderSideToJson((decoration.border!  as Border).top),
              'bottom': _borderSideToJson((decoration.border!  as Border).bottom),
              
            }
          : {
              'left': _borderSideToJson((decoration.border! as DashedBorder).left),
              'right': _borderSideToJson((decoration.border!  as DashedBorder).right),
              'top': _borderSideToJson((decoration.border!  as DashedBorder).top),
              'bottom': _borderSideToJson((decoration.border!  as DashedBorder).bottom),
              'dashLength':(decoration.border! as DashedBorder).dashLength,
              'spaceLength':(decoration.border! as DashedBorder).spaceLength??0,
              'isOnlyCorners':(decoration.border! as DashedBorder).isOnlyCorner,
              'strokeCap':(decoration.border! as DashedBorder).strokeCap.index

            }
          : null,
      'borderRadius': decoration.borderRadius != null
          ? [
              (decoration.borderRadius!  as BorderRadius).topLeft.x,
              (decoration.borderRadius!  as BorderRadius).topLeft.y,
              (decoration.borderRadius!  as BorderRadius).topRight.x,
              (decoration.borderRadius!  as BorderRadius).topRight.y,
              (decoration.borderRadius!  as BorderRadius).bottomLeft.x,
              (decoration.borderRadius!  as BorderRadius).bottomLeft.y,
              (decoration.borderRadius!  as BorderRadius).bottomRight.x,
              (decoration.borderRadius!  as BorderRadius).bottomRight.y,
            ]
          : null,
      'image': decoration.image != null
          ? {
              'bytes': decoration.image!.image is MemoryImage
                  ? (decoration.image!.image as MemoryImage).bytes
                  : null,
              'fit': decoration.image!.fit?.index,
              'repeat': decoration.image!.repeat.index,
              'alignment': [
                (decoration.image!.alignment as Alignment).x,
                (decoration.image!.alignment as Alignment).y
              ],
              'scale': decoration.image!.scale,
              'opacity': decoration.image!.opacity,
              'filterQuality': decoration.image!.filterQuality.index,
              'invertColors': decoration.image!.invertColors,
            }
          : null,
      'boxShadow': decoration.boxShadow != null
          ? decoration.boxShadow!.map(_boxShadowToJson).toList()
          : null,
      'gradient': _gradientToJson(decoration.gradient),
      'backgroundBlendMode': decoration.backgroundBlendMode?.index,
    };
  }

  //  Helper for JSON to BoxDecoration
  static BoxDecoration _boxDecorationFromJson(Map<dynamic, dynamic>? json, ) {
    if (json == null) return const BoxDecoration();

    return BoxDecoration(
      color: json['color'] != null ? Color(json['color']) : null,
      border: json['border'] != null
    ? json['border']['dashLength'] != null
        ? DashedBorder(
            left: _borderSideFromJson(json['border']['left']),
            right: _borderSideFromJson(json['border']['right']),
            top: _borderSideFromJson(json['border']['top']),
            bottom: _borderSideFromJson(json['border']['bottom']),
            dashLength: json['border']['dashLength'],
            spaceLength: json['border']['spaceLength'] ?? 0,
            isOnlyCorner: json['border']['isOnlyCorners'] ?? false,
            strokeCap: json['border']['strokeCap'] != null
                ? StrokeCap.values[json['border']['strokeCap']]
                : StrokeCap.butt, // Default value
          )
        : Border(
            left: _borderSideFromJson(json['border']['left']),
            right: _borderSideFromJson(json['border']['right']),
            top: _borderSideFromJson(json['border']['top']),
            bottom: _borderSideFromJson(json['border']['bottom']),
          )
    : null,

      borderRadius: json['borderRadius'] != null
          ? BorderRadius.only(
              topLeft: Radius.elliptical(
                json['borderRadius'][0] ?? 0.0,
                json['borderRadius'][1] ?? 0.0,
              ),
              topRight: Radius.elliptical(
                json['borderRadius'][2] ?? 0.0,
                json['borderRadius'][3] ?? 0.0,
              ),
              bottomLeft: Radius.elliptical(
                json['borderRadius'][4] ?? 0.0,
                json['borderRadius'][5] ?? 0.0,
              ),
              bottomRight: Radius.elliptical(
                json['borderRadius'][6] ?? 0.0,
                json['borderRadius'][7] ?? 0.0,
              ),
            )
          : null,
      image: json['image'] != null
          ? DecorationImage(
              image: MemoryImage(Uint8List.fromList(
                  List<int>.from(json['image']['bytes']))),
              fit: BoxFit.values[json['image']['fit']],
              repeat: ImageRepeat.values[json['image']['repeat']],
              alignment: Alignment(
                json['image']['alignment'][0],
                json['image']['alignment'][1],
              ),
              scale: json['image']['scale'],
              opacity: json['image']['opacity'],
              filterQuality:
                  FilterQuality.values[json['image']['filterQuality']],
              invertColors: json['image']['invertColors'],
            )
          : null,
      boxShadow: json['boxShadow'] != null
          ? (json['boxShadow'] as List)
              .map((e) => _boxShadowFromJson(e))
              .toList()
          : null,
      gradient: _gradientFromJson(json['gradient']),
      backgroundBlendMode: json['backgroundBlendMode'] != null
          ? BlendMode.values[json['backgroundBlendMode']]
          : null,
    );
  }

  //  Helper for BoxShadow to JSON
  static Map<String, dynamic> _boxShadowToJson(BoxShadow shadow) {
    return {
      'color': shadow.color.value,
      'offset': [shadow.offset.dx, shadow.offset.dy],
      'blurRadius': shadow.blurRadius,
      'spreadRadius': shadow.spreadRadius,
    };
  }

  static BoxShadow _boxShadowFromJson(Map<String, dynamic> json) {
    return BoxShadow(
      color: Color(json['color']),
      offset: Offset(json['offset'][0], json['offset'][1]),
      blurRadius: json['blurRadius'],
      spreadRadius: json['spreadRadius'],
    );
  }

  // ✅ Helper for Gradient to JSON
  static Map<dynamic, dynamic>? _gradientToJson(Gradient? gradient) {
    if (gradient is LinearGradient) {
      return {
        'type': 'linear',
        'colors': gradient.colors.map((c) => c.value).toList(),
        'begin': [(gradient.begin as Alignment).x, (gradient.begin as Alignment).y],
        'end': [(gradient.end as Alignment).x, (gradient.end as Alignment).y],
      };
    }
    return null;
  }

  static Gradient? _gradientFromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return null;
    if (json['type'] == 'linear') {
      return LinearGradient(
        colors: (json['colors'] as List).map((c) => Color(c)).toList(),
        begin: Alignment(json['begin'][0], json['begin'][1]),
        end: Alignment(json['end'][0], json['end'][1]),
      );
    }
    return null;
  }
    // ✅ Helper for BorderSide to JSON
  static Map<String, dynamic> _borderSideToJson(BorderSide side) {
    return {
      'width': side.width,
      'color': side.color.value,
    };
  }

  // ✅ Helper for JSON to BorderSide
  static BorderSide _borderSideFromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return BorderSide.none;
    return BorderSide(
      width: json['width'] ?? 0.0,
      color: Color(json['color'] ?? 0x00000000),
    );
  }

  ItemDecoration copyWith({
    String? id,
    String? name,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
    Alignment? alignment,
    Matrix4? transform,
    BoxDecoration? foregroundDecoration, 
    Map<String, dynamic>? pinned,
  }) {
    return ItemDecoration(
      id: id ?? this.id,
      name: name ?? this.name,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
      transform: transform ?? this.transform,
      foregroundDecoration: foregroundDecoration ?? this.foregroundDecoration, 
      pinned: pinned ?? this.pinned,
    );
  }
}

Map<String, dynamic> defaultPins() => {
    'padding': {
      'isPinned': true,
      'top': true,
      'bottom': true,
      'left': true,
      'right': true,
    },
    'margin': {
      'isPinned': true,
      'top': true,
      'bottom': true,
      'left': true,
      'right': true,
    },
    'decoration': {
      'isPinned': true,
      'color': true,
      'border': true,
      'borderRadius': {
        'isPinned': true,
      'topLeft': true,
      'topRight': true,
      'bottomLeft': true, 
      'bottomRight': true,
      },
      'boxShadow': true,
      'image': {
        'isPinned': true,
        'bytes': true,
        'fit': false,
        'repeat': false,
        'alignment': false,
        'scale': false,
        'opacity': false,
        'filterQuality': false,
        'invertColors': false,
      }, 
      'backgroundBlendMode': true,
    }, 
    'transform': {
      'isPinned': false,
    },
    'foregroundDecoration': {
      'isPinned': false,
      'color': false,
      'border': false,
      'borderRadius': {
        'isPinned': true,
      'topLeft': true,
      'topRight': true,
      'bottomLeft': true, 
      'bottomRight': true,
      },
      'boxShadow': false,
      'image': {
        'isPinned': false,
        'bytes': false,
        'fit': false,
        'repeat': false,
        'alignment': false,
        'scale': false,
        'opacity': false,
        'filterQuality': false,
        'invertColors': false,
      }, 
      'backgroundBlendMode': false,
    }, 
  };

class SuperDecoration extends SheetDecoration {
  List<SheetDecoration> itemDecorationList;

  SuperDecoration({
    required super.id,
    super.name = 'Untitled',
    this.itemDecorationList = const [],
  });

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemDecorationList': encodeItemDecorationList(itemDecorationList),
    };
  }

  // ✅ Convert from JSON
  factory SuperDecoration.fromJson(Map<dynamic, dynamic> json) {
    return SuperDecoration(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled',
      itemDecorationList: decodeItemDecorationList(json['itemDecorationList']),
    );
  }

  SuperDecoration copyWith({
    List<SheetDecoration>? itemDecorationList,
    String? name,
  }) {
    return SuperDecoration(
      id: id,
      name: name ?? this.name,
      itemDecorationList: itemDecorationList ?? this.itemDecorationList,
    );
  }

  SuperDecorationBox toSuperDecorationBox() {
    return SuperDecorationBox(
      id: id,
      name: name,
      itemDecorationList:encodeItemDecorationList(itemDecorationList)  
      );
  }

}

 
List<dynamic> encodeItemDecorationList(List<SheetDecoration> list) {
  return list.map((item) {
    if (item is ItemDecoration) {
      return {'type': 'ItemDecoration', 'value': item.toJson()};
    } else if (item is SuperDecoration) {
      return {
        'type': 'SuperDecoration',
        'value': item.toJson(),
      };
    }
    throw Exception('Unsupported type');
  }).toList();
}

List<SheetDecoration> decodeItemDecorationList(List<dynamic> list) {
   
  return list.map((item) {
    if (item['type'] == 'ItemDecoration') {
      return ItemDecoration.fromJson(item['value']);
    } else if (item['type'] == 'SuperDecoration') {
      return SuperDecoration.fromJson(item['value']);
    }
    throw Exception('Unsupported type');
  }).toList();
}


