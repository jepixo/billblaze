import 'dart:convert';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/providers/box_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<String>> getLayoutFileNames() async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  // Filter assets under assets/layouts/ and remove folder prefix & extension
  final files = manifestMap.keys
      .where((path) => path.startsWith('assets/layouts/') && path.endsWith('.json'))
      .map((path) => path.split('/').last.replaceAll('.json', ''))
      .toList();

  return files;
}
Future<void> syncLayoutsWithAssets() async {
  final layoutsBox = Boxes.getLayouts();
  print('Hello from assets.');

  // 1️⃣ get asset layout names
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  final assetLayoutPaths = manifestMap.keys
      .where((path) => path.startsWith('assets/layouts/') && path.endsWith('.json'))
      .toList();

  for (final path in assetLayoutPaths) {
    final layoutId = path.split('/').last.replaceAll('.json', '');

    // 2️⃣ check if already exists
    if (!layoutsBox.containsKey(layoutId)) {
      try {
        // 3️⃣ load JSON string
        final jsonStr = await rootBundle.loadString(path);

        // 4️⃣ parse into LayoutModel
        final layout = LayoutModel.fromJson(jsonStr);

        // 5️⃣ store in box
        layoutsBox.put(layoutId, layout);
        print('Loaded layout $layoutId from assets.');
      } catch (e) {
        print('Error loading layout $layoutId: $e');
      }
    }
  }
}