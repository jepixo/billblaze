import 'dart:convert';

import 'package:billblaze/auth/user_auth.dart';
import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart' as gap;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<void> authenticateAndSyncLayoutModels(Box<LayoutModel> layoutBox, WidgetRef ref) async {
  final googleSignIn = ref.read(gapSignInProvider);
  try {
    final authManager = ref.read(authTokenManagerProvider.notifier);
    gap.GoogleSignInCredentials? creds;
    // 🔁 Check and refresh token if needed
    if (!authManager.state.isValid) {
      print("🔐 Token expired or missing. Signing in again...");
      creds = await googleSignIn.signInOnline();
      if (creds == null) {
        print("❌ Google Sign-In failed or was canceled.");
        return;
      }
      authManager.state = AuthTokenManager(
        credentials: creds,
        expiryTime: DateTime.now().add(Duration(hours: 1)), // adjust if you know exact expiry
      );
    } else {
      creds = authManager.state.credentials;
    }
    final authClient = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', creds!.accessToken, DateTime.now().toUtc().add(Duration(hours: 1))),
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
    } else {
      final newFile = await driveApi.files.create(drive.File()
        ..name = "LayoutModelBox"
        ..mimeType = "application/vnd.google-apps.spreadsheet");
      sheetId = newFile.id!;
      print("✅ Created new sheet with ID: $sheetId");
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
      if (existingDocSearch.files != null && existingDocSearch.files!.isNotEmpty) {
        final oldDocId = existingDocSearch.files!.first.id!;
        try {
          await driveApi.files.delete(oldDocId);
          print("🗑️ Deleted existing doc for ${layout.id} (ID: $oldDocId)");
        } catch (e) {
          print("⚠️ Couldn't delete old doc for ${layout.id}: $e");
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
        continue;
      }
      docId = jsonDecode(docResponse.body)['documentId'];
      print("🆕 Created new doc with ID: $docId");
      // ✍️ Insert spreadsheetList JSON
      await http.post(
        Uri.parse('https://docs.googleapis.com/v1/documents/$docId:batchUpdate'),
        headers: {
          'Authorization': 'Bearer ${creds.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requests': [
            {
              'insertText': {
                'location': {'index': 1},
                'text': jsonEncode(layout.spreadSheetList.map((e) => e.toMap()).toList()),
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
        jsonEncode(layout.labelList.map((e) => e.toJson()).toList()),
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
    print("✅ Synced all LayoutModels to Google Sheet and Docs.");
    authClient.close();
  } catch (e) {
    print("❌ Error during authentication or data sync: $e");
  }
}
//
//
//
//
Future<Map<String, dynamic>> fetchAndReconstructLayoutModels(WidgetRef ref) async {
  final googleSignIn = ref.read(gapSignInProvider);
  try {
    final authManager = ref.read(authTokenManagerProvider.notifier);
    gap.GoogleSignInCredentials? creds;
    // 🔁 Check and refresh token if needed
    if (!authManager.state.isValid) {
      print("🔐 Token expired or missing. Signing in again...");
      creds = await googleSignIn.signInOnline();
      if (creds == null) {
        print("❌ Google Sign-In failed.");
        throw Exception("Sign-in failed");
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
        AccessToken('Bearer', creds!.accessToken, DateTime.now().toUtc().add(Duration(hours: 1))),
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
      throw Exception("LayoutModelBox spreadsheet not found");
    }
    final sheetId = fileList.files!.first.id!;
    final sheetData = await sheetsApi.spreadsheets.values.get(sheetId, "Sheet1");
    final rows = sheetData.values;
    if (rows == null || rows.length < 2) {
      throw Exception("No layout data in sheet");
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
        continue;
      }
      final docBody = jsonDecode(docResponse.body);
      final content = docBody['body']['content'] as List? ?? [];
      final textRuns = content
          .expand((e) => (e['paragraph']?['elements'] as List?) ?? [])
          .map((e) => e['textRun']?['content'])
          .whereType<String>();
      final firstTextElement = textRuns.join();
      // 🧱 Rebuild spreadsheetList
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
            .map((e) => RequiredText.fromJson(e))
            .toList(),
        pdf: (data['hasPdf'] == 'yes') ? [] : null,
      );
      box.addAll({model.id: model});
    }
    print("✅ LayoutModelBox loaded from Google Sheet and Docs");
    return box;
  } catch (e) {
    print("❌ Failed to fetch LayoutModels: $e");
    rethrow;
  }
}
            