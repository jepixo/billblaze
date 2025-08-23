import 'dart:convert';

import 'package:billblaze/auth/user_auth.dart';
import 'package:billblaze/home.dart';
import 'package:billblaze/models/bill/bill_type.dart';
import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:billblaze/providers/box_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart'
    as gap;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<bool> authenticateAndSyncLayoutModels(
    Box<LayoutModel> layoutBox, WidgetRef ref, OverlayEntry? overlay) async {
  try {
    final googleSignIn = ref.read(gapSignInProvider);
    ref.read(processMessageProvider.notifier).state = "Signing in to Google...";
    overlay?.markNeedsBuild();
    final authManager = ref.read(authTokenManagerProvider.notifier);
    gap.GoogleSignInCredentials? creds;
    // 🔁 Check and refresh token if needed
    if (!authManager.state.isValid) {
      print("🔐 Token expired or missing. Signing in again...");
      ref.read(processMessageProvider.notifier).state =
          "🔐 Token expired or missing. Signing in again...";
      overlay?.markNeedsBuild();
      creds = await googleSignIn.signInOnline();
      if (creds == null) {
        print("❌ Google Sign-In failed or was canceled.");
        ref.read(processMessageProvider.notifier).state =
            "❌ Google Sign-In failed or was canceled.";
        overlay?.markNeedsBuild();
        overlay?.remove();
        return false;
      }
      authManager.state = AuthTokenManager(
        credentials: creds,
        expiryTime: DateTime.now()
            .add(Duration(hours: 1)), // adjust if you know exact expiry
      );
    } else {
      creds = authManager.state.credentials;
    }
    final authClient = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', creds!.accessToken,
            DateTime.now().toUtc().add(Duration(hours: 1))),
        creds.refreshToken,
        [
          'https://www.googleapis.com/auth/drive',
          'https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/documents',
        ],
      ),
    );
    final driveApi = drive.DriveApi(authClient);
    final sheetsApi = sheets.SheetsApi(authClient);
    // 1️⃣ Locate or create LayoutModelBox sheet
    final fileList = await driveApi.files.list(
      q: "name='LayoutModelBox' and mimeType='application/vnd.google-apps.spreadsheet'",
    );
    String sheetId;
    if (fileList.files != null && fileList.files!.isNotEmpty) {
      sheetId = fileList.files!.first.id!;
      print("📄 Found existing sheet with ID: $sheetId");
      ref.read(processMessageProvider.notifier).state =
          "📄 Found existing storage with ID: $sheetId";
      overlay?.markNeedsBuild();
    } else {
      final newFile = await driveApi.files.create(drive.File()
        ..name = "LayoutModelBox"
        ..mimeType = "application/vnd.google-apps.spreadsheet");
      sheetId = newFile.id!;
      print("✅ Created new sheet with ID: $sheetId");
      ref.read(processMessageProvider.notifier).state =
          "✅ Created new storage with ID: $sheetId";
      overlay?.markNeedsBuild();
    }
    // 2️⃣ Clear sheet
    await sheetsApi.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      sheetId,
      "Sheet1",
    );
    // 3️⃣ Header row
    final headers = [
      "id",
      "name",
      "createdAt",
      "modifiedAt",
      "type",
      "spreadsheetDocId",
      "docPropsList",
      "labelList",
      "hasPdf"
    ];
    List<List<dynamic>> allRows = [headers];
    for (final layout in layoutBox.values) {
      // 🔍 Delete old doc if exists
      final existingDocSearch = await driveApi.files.list(
        q: "name='${layout.id}' and mimeType='application/vnd.google-apps.document'",
      );
      String docId;
      if (existingDocSearch.files != null &&
          existingDocSearch.files!.isNotEmpty) {
        final oldDocId = existingDocSearch.files!.first.id!;
        try {
          await driveApi.files.delete(oldDocId);
          print("🗑️ Deleted existing doc for ${layout.id} (ID: $oldDocId)");
          ref.read(processMessageProvider.notifier).state =
              "🗑️ Deleted existing spreadsheet for ${layout.name}";
          overlay?.markNeedsBuild();
        } catch (e) {
          print("⚠️ Couldn't delete old doc for ${layout.id}: $e");
          ref.read(processMessageProvider.notifier).state =
              "⚠️ Couldn't delete old spreadsheet for ${layout.name}: $e";
          overlay?.markNeedsBuild();
        }
      }
      // 🆕 Create new doc
      final docResponse = await http.post(
        Uri.parse('https://docs.googleapis.com/v1/documents'),
        headers: {
          'Authorization': 'Bearer ${creds.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'title': layout.id}),
      );
      if (docResponse.statusCode != 200) {
        print("❌ Failed to create doc for layout ${layout.id}");
        ref.read(processMessageProvider.notifier).state =
            "❌ Failed to create spreadsheet for ${layout.name}";
        overlay?.markNeedsBuild();
        continue;
      }
      docId = jsonDecode(docResponse.body)['documentId'];
      print("🆕 Created new doc with ID: $docId");
      ref.read(processMessageProvider.notifier).state =
          "🆕 Created new spreadsheet for ${layout.name}";
      overlay?.markNeedsBuild();
      // ✍️ Insert spreadsheetList JSON
      await http.post(
        Uri.parse(
            'https://docs.googleapis.com/v1/documents/$docId:batchUpdate'),
        headers: {
          'Authorization': 'Bearer ${creds.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requests': [
            {
              'insertText': {
                'location': {'index': 1},
                'text': jsonEncode(
                    layout.spreadSheetList.map((e) => e.toMap()).toList()),
              }
            }
          ]
        }),
      );
      // ➕ Add to sheet
      allRows.add([
        layout.id,
        layout.name,
        layout.createdAt.toIso8601String(),
        layout.modifiedAt.toIso8601String(),
        layout.type,
        docId,
        jsonEncode(layout.docPropsList.map((e) => e.toJson()).toList()),
        jsonEncode(layout.labelList.map((e) => e.toMap()).toList()),
        layout.pdf != null && layout.pdf!.isNotEmpty ? "yes" : "no"
      ]);
    }
    // 6️⃣ Push to Sheet
    await sheetsApi.spreadsheets.values.update(
      sheets.ValueRange.fromJson({'values': allRows}),
      sheetId,
      "Sheet1!A1",
      valueInputOption: "RAW",
    );

    ///SHEETDECORATIONS
    ///
    ///
    // 🔹 Convert decorations to JSON string
    final decorationsJson = jsonEncode(
      Boxes.getDecorations().values.map((d) => d.toMap()).toList(),
    );

    // 🔎 Search for existing JSON file "SheetDecorationBox.json"
    final decoFileSearch = await driveApi.files.list(
      q: "name='SheetDecorationBox.json' and mimeType='application/json'",
    );

    if (decoFileSearch.files != null && decoFileSearch.files!.isNotEmpty) {
      // If exists, update content
      final existingFileId = decoFileSearch.files!.first.id!;
      final media = drive.Media(
        Stream.value(utf8.encode(decorationsJson)),
        decorationsJson.length,
      );
      await driveApi.files
          .update(drive.File(), existingFileId, uploadMedia: media);
      print("✅ Updated existing SheetDecorationBox.json");
    } else {
      // Create new JSON file
      final newFile = drive.File()
        ..name = 'SheetDecorationBox.json'
        ..mimeType = 'application/json';
      final media = drive.Media(
        Stream.value(utf8.encode(decorationsJson)),
        decorationsJson.length,
      );
      await driveApi.files.create(newFile, uploadMedia: media);
      print("✅ Created new SheetDecorationBox.json");
    }
    // print("✅ Created new doc with ID: $decorationDocId");
    // ref.read(processMessageProvider.notifier).state = "✅ Created new decoration storage with ID: $decorationDocId";

    print(
        "✅ Synced all LayoutModels and Decorations to Google Sheet and Docs.");
    ref.read(processMessageProvider.notifier).state =
        "✅ Synced all Layouts&Bills to Google Drive.";
    overlay?.markNeedsBuild();
    authClient.close();
  } catch (e) {
    print("❌ Error during authentication or data sync: $e");
    ref.read(processMessageProvider.notifier).state =
        "❌ Error during authentication or data sync: $e";
    overlay?.markNeedsBuild();
    overlay?.remove();
    return false;
  }
  return true; // Indicate success
}
//
//

Future<Map<String, SheetDecoration>> fetchDecorationsFromDrive(
    WidgetRef ref, OverlayEntry? overlay) async {
  final googleSignIn = ref.read(gapSignInProvider);
  try {
    final authManager = ref.read(authTokenManagerProvider.notifier);
    ref.read(processMessageProvider.notifier).state =
        "Signing in to Google for decorations...";
    overlay?.markNeedsBuild();

    gap.GoogleSignInCredentials? creds;
    if (!authManager.state.isValid) {
      creds = await googleSignIn.signInOnline();
      if (creds == null) {
        ref.read(processMessageProvider.notifier).state =
            "❌ Google Sign-In failed for decorations.";
        overlay?.markNeedsBuild();
        overlay?.remove();
        return {};
      }
      authManager.state = AuthTokenManager(
        credentials: creds,
        expiryTime: DateTime.now().add(Duration(hours: 1)),
      );
    } else {
      creds = authManager.state.credentials;
    }

    final authClient = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', creds!.accessToken,
            DateTime.now().toUtc().add(Duration(hours: 1))),
        creds.refreshToken,
        ['https://www.googleapis.com/auth/drive'],
      ),
    );
    final driveApi = drive.DriveApi(authClient);

    // 🔍 Search for the JSON file
    final fileList = await driveApi.files.list(
      q: "name='SheetDecorationBox.json' and mimeType='application/json'",
    );

    if (fileList.files == null || fileList.files!.isEmpty) {
      ref.read(processMessageProvider.notifier).state =
          "❌ SheetDecorationBox.json not found.";
      overlay?.markNeedsBuild();
      overlay?.remove();
      return {};
    }

    final fileId = fileList.files!.first.id!;
    ref.read(processMessageProvider.notifier).state =
        "📥 Fetching SheetDecorationBox.json from Drive...";
    overlay?.markNeedsBuild();

    final media = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    // Collect the stream into a single string
    final chunks = await media.stream.toList();
    final allBytes = chunks.expand((chunk) => chunk).toList();
    final jsonString = utf8.decode(allBytes);

    final List<dynamic> jsonList = jsonDecode(jsonString);
    final Map<String, SheetDecoration> decorations = {};

    for (final item in jsonList) {
      final deco =
          SheetDecoration.fromMap(item); // implement fromMap in your class
      decorations[deco.id] = deco;
    }

    ref.read(processMessageProvider.notifier).state =
        "✅ Decorations loaded from Drive.";

    return decorations;
  } catch (e) {
    print("❌ Failed to fetch decorations: $e");
    ref.read(processMessageProvider.notifier).state =
        "❌ Failed to fetch decorations: $e";
    overlay?.markNeedsBuild();
    overlay?.remove();
    return {};
  }
}

//
//
Future<Map<String, dynamic>> fetchAndReconstructLayoutModels(
    WidgetRef ref, OverlayEntry? overlay) async {
  final googleSignIn = ref.read(gapSignInProvider);
  try {
    final authManager = ref.read(authTokenManagerProvider.notifier);
    ref.read(processMessageProvider.notifier).state = "Signing in to Google...";
    overlay?.markNeedsBuild();
    gap.GoogleSignInCredentials? creds;
    // 🔁 Check and refresh token if needed
    if (!authManager.state.isValid) {
      print("🔐 Token expired or missing. Signing in again...");
      ref.read(processMessageProvider.notifier).state =
          "🔐 Token expired or missing. Signing in again...";
      overlay?.markNeedsBuild();
      creds = await googleSignIn.signInOnline();
      if (creds == null) {
        print("❌ Google Sign-In failed.");
        ref.read(processMessageProvider.notifier).state =
            "❌ Google Sign-In failed.";
        overlay?.markNeedsBuild();
        overlay?.remove();
      }
      authManager.state = AuthTokenManager(
        credentials: creds,
        expiryTime: DateTime.now().add(Duration(hours: 1)),
      );
    } else {
      creds = authManager.state.credentials;
    }
    final authClient = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', creds!.accessToken,
            DateTime.now().toUtc().add(Duration(hours: 1))),
        creds.refreshToken,
        [
          'https://www.googleapis.com/auth/drive',
          'https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/documents',
        ],
      ),
    );
    final driveApi = drive.DriveApi(authClient);
    final sheetsApi = sheets.SheetsApi(authClient);
    // 🔍 Find the sheet
    final fileList = await driveApi.files.list(
      q: "name='LayoutModelBox' and mimeType='application/vnd.google-apps.spreadsheet'",
    );
    if (fileList.files == null || fileList.files!.isEmpty) {
      print("❌ LayoutModelBox spreadsheet not found.");
      ref.read(processMessageProvider.notifier).state =
          "❌ Storage not found in drive.";
      overlay?.markNeedsBuild();
      overlay?.remove();
      return {};
    }

    final sheetId = fileList.files!.first.id!;
    ref.read(processMessageProvider.notifier).state =
        "📄 Found existing storage with ID: ${sheetId}";
    print("📄 Found existing sheet with ID: $sheetId");
    overlay?.markNeedsBuild();
    final sheetData =
        await sheetsApi.spreadsheets.values.get(sheetId, "Sheet1");
    final rows = sheetData.values;
    if (rows == null || rows.length < 2) {
      print("❌ No layout data found in sheet.");
      ref.read(processMessageProvider.notifier).state =
          "❌ No data found in storage.";
      overlay?.markNeedsBuild();
      overlay?.remove();
      return {};
    }
    final headers = rows.first;
    final Map<String, dynamic> box = {};
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final headerStrings = headers.map((e) => e.toString()).toList();
      final data = Map<String, dynamic>.fromIterables(
        headerStrings,
        row + List.filled(headerStrings.length - row.length, ''),
      );
      // 📥 Fetch spreadsheetList JSON from Google Doc
      final docId = data['spreadsheetDocId'];
      final docResponse = await http.get(
        Uri.parse('https://docs.googleapis.com/v1/documents/$docId'),
        headers: {
          'Authorization': 'Bearer ${creds.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      if (docResponse.statusCode != 200) {
        print("❌ Failed to fetch Google Doc $docId");
        ref.read(processMessageProvider.notifier).state =
            "❌ Failed to fetch spreadSheetList for ${data['name']}";
        overlay?.markNeedsBuild();
        continue;
      }
      ref.read(processMessageProvider.notifier).state =
          "📥 Fetched spreadsheetList from Google Doc for ${data['name']}";
      overlay?.markNeedsBuild();
      final docBody = jsonDecode(docResponse.body);
      final content = docBody['body']['content'] as List? ?? [];
      final textRuns = content
          .expand((e) => (e['paragraph']?['elements'] as List?) ?? [])
          .map((e) => e['textRun']?['content'])
          .whereType<String>();
      final firstTextElement = textRuns.join();
      // 🧱 Rebuild spreadsheetList
      ref.read(processMessageProvider.notifier).state =
          "🧱 Decoding spreadsheetList for ${data['name']}";
      final spreadsheetListRaw = jsonDecode(firstTextElement.trim());
      final List<SheetListBox> spreadsheetList = (spreadsheetListRaw as List)
          .map((e) => SheetListBox.fromMap(e))
          .toList();
      // 🧱 Build LayoutModel
      final model = LayoutModel(
        id: data['id'],
        name: data['name'],
        createdAt: DateTime.parse(data['createdAt']),
        modifiedAt: DateTime.parse(data['modifiedAt']),
        type: int.tryParse(data['type'].toString()) ?? 0,
        spreadSheetList: spreadsheetList,
        docPropsList: (jsonDecode(data['docPropsList']) as List)
            .map((e) => DocumentPropertiesBox.fromJson(e))
            .toList(),
        labelList: (jsonDecode(data['labelList']) as List)
            .map((e) => RequiredText.fromMap(e))
            .toList(),
        pdf: (data['hasPdf'] == 'yes') ? [] : null,
      );
      box.addAll({model.id: model});
    }
    var decorationsMap = await fetchDecorationsFromDrive(ref, overlay);

    for (var dcEntry in decorationsMap.entries) {
      var decorationsBox = Boxes.getDecorations();
      var existing = decorationsBox.get(dcEntry.key);
      if (existing!=null) {
        decorationsBox.put(dcEntry.key,dcEntry.value);
      }
    }

    print("✅ LayoutModelBox and SheetDecorations loaded from Google Sheet and Docs");
    ref.read(processMessageProvider.notifier).state =
        "✅ Layouts&Bills and SheetDecorations loaded from Google Drive.";
    overlay?.markNeedsBuild();
    overlay?.remove();
    return box;
  } catch (e) {
    print("❌ Failed to fetch LayoutModels: $e");
    ref.read(processMessageProvider.notifier).state =
        "❌ Failed to fetch Layouts&Bills: $e";
    overlay?.markNeedsBuild();
    overlay?.remove();
    return {};
  }
}
