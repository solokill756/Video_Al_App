import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static setup() async {
    await dotenv.load(fileName: ".env");
  }

  static final apiUrl = dotenv.env['API_URL'] ?? '';
  static final appStoreId = dotenv.env['APP_STORE_ID'] ?? '';
  static final googlePlayId = dotenv.env['GOOGLE_PLAY_ID'] ?? '';
  static final mastraApiUrl = dotenv.env['MASTRA_API_URL'] ?? '';
  static final videoServer = dotenv.env['MASTRA_VIDEO_BASE_URL'] ?? '';
  static final googleGenerativeAiApiKey =
      dotenv.env['GOOGLE_GENERATIVE_AI_API_KEY'] ?? '';
  static final searchApiUrl = dotenv.env['SEARCH_API_URL'] ?? '';
  static final imageBaseUrl = dotenv.env['IMAGE_BASE_URL'] ?? '';
  static final videoBaseUrl = dotenv.env['VIDEO_BASE_URL'] ?? '';
  static final triggerPrivateSearchUrl =
      dotenv.env['TRIGGER_PRIVATE_SEARCH_URL'] ?? '';
  static final privateSearchApiUrl =
      dotenv.env['VIDEO_PRIVATE_SEARCH_API_URL'] ?? '';
}
