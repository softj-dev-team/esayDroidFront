
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GlobalConfig {
  static late final String apiHost;
  static late final String wsHost;
  static void initialize() {
    apiHost = dotenv.get('api_host');
    wsHost =  dotenv.get('ws_host');
  }
}