import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyApiKey = 'ai_api_key';
const _keyBaseUrl = 'ai_base_url';
const _keyModel = 'ai_model';

const kDefaultBaseUrl = 'https://api.xiaomimimo.com/v1';
const kDefaultModel = 'mimo-v2.5-pro';

// Anthropic 格式备选地址
const kAnthropicBaseUrl = 'https://api.xiaomimimo.com/anthropic';

final aiConfigProvider = StateNotifierProvider<AiConfigNotifier, AiConfig>((ref) {
  return AiConfigNotifier();
});

class AiConfig {
  final String? apiKey;
  final String baseUrl;
  final String model;

  const AiConfig({
    this.apiKey,
    this.baseUrl = kDefaultBaseUrl,
    this.model = kDefaultModel,
  });

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  /// 判断是否使用 Anthropic 格式
  bool get isAnthropic => baseUrl.contains('/anthropic');
}

class AiConfigNotifier extends StateNotifier<AiConfig> {
  AiConfigNotifier() : super(const AiConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AiConfig(
      apiKey: prefs.getString(_keyApiKey),
      baseUrl: prefs.getString(_keyBaseUrl) ?? kDefaultBaseUrl,
      model: prefs.getString(_keyModel) ?? kDefaultModel,
    );
  }

  Future<void> save({
    required String apiKey,
    required String baseUrl,
    required String model,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, apiKey);
    await prefs.setString(_keyBaseUrl, baseUrl);
    await prefs.setString(_keyModel, model);
    state = AiConfig(apiKey: apiKey, baseUrl: baseUrl, model: model);
  }
}
