import 'package:flutter_dotenv/flutter_dotenv.dart';

// final gdriveClientId = dotenv.env['GDRIVE_CLIENT_ID'];
// final gdriveClientSecret = dotenv.env['GDRIVE_CLIENT_SECRET'];
// final googleFontsApiKey = dotenv.env['GFONTS_API_KEY'];
// final gSignInClientId = dotenv.env['GSIGN_IN_CLIENT_ID'];
// final gSignInClientSecret = dotenv.env['GSIGN_IN_CLIENT_SECRET'];

// NEW
const gdriveClientId = String.fromEnvironment('GDRIVE_CLIENT_ID');
const gdriveClientSecret = String.fromEnvironment('GDRIVE_CLIENT_SECRET');
const googleFontsApiKey = String.fromEnvironment('GFONTS_API_KEY');
const gSignInClientId = String.fromEnvironment('GSIGN_IN_CLIENT_ID');
const gSignInClientSecret = String.fromEnvironment('GSIGN_IN_CLIENT_SECRET');
