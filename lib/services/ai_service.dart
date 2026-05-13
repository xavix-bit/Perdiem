import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ExtractedItemInfo {
  final String? name;
  final String? brand;
  final double? price;
  final String? category;

  ExtractedItemInfo({this.name, this.brand, this.price, this.category});

  factory ExtractedItemInfo.fromJson(Map<String, dynamic> json) {
    return ExtractedItemInfo(
      name: json['name'] as String?,
      brand: json['brand'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String?,
    );
  }
}

class AiService {
  static Future<ExtractedItemInfo> extractItemInfo(
    File imageFile, {
    required String apiKey,
    required String baseUrl,
    required String model,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = _mimeType(imageFile.path);

    // 根据 URL 判断格式：包含 /anthropic 用 Anthropic 格式，否则用 OpenAI 格式
    final isAnthropic = baseUrl.contains('/anthropic');

    final http.Response response;
    if (isAnthropic) {
      // Anthropic 格式
      final anthropicUrl = baseUrl.endsWith('/messages')
          ? baseUrl
          : '$baseUrl/v1/messages';
      response = await http.post(
        Uri.parse(anthropicUrl),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': 512,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': mimeType,
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text': _extractionPrompt,
                },
              ],
            },
          ],
        }),
      );
    } else {
      // OpenAI 格式
      final chatUrl = baseUrl.endsWith('/chat/completions')
          ? baseUrl
          : '$baseUrl/chat/completions';
      response = await http.post(
        Uri.parse(chatUrl),
        headers: {
          'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                  },
                },
                {
                  'type': 'text',
                  'text': _extractionPrompt,
                },
              ],
            },
          ],
          'max_tokens': 512,
          'temperature': 0.1,
        }),
      );
    }

    if (response.statusCode != 200) {
      final msg = response.body.length > 300
          ? response.body.substring(0, 300)
          : response.body;
      throw Exception('AI 服务请求失败 (${response.statusCode}): $msg');
    }

    final body = jsonDecode(response.body);
    String content;

    if (isAnthropic) {
      // Anthropic 格式: {"content": [{"type": "text", "text": "..."}]}
      content = body['content'][0]['text'] as String;
    } else {
      // OpenAI 格式: {"choices": [{"message": {"content": "..."}}]}
      content = body['choices'][0]['message']['content'] as String;
    }

    return _parseResponse(content);
  }

  static const _extractionPrompt = '''
你是一个物品信息提取助手。请从这张图片中提取物品信息，返回纯 JSON 格式（不要 markdown 代码块）。

需要提取的字段：
- name: 物品名称（必填，尽可能具体）
- brand: 品牌名（如果能看到）
- price: 价格数字（如果能看到，单位为人民币元）
- category: 分类，必须为以下之一：数码、家居、服饰、运动、其他

如果某个字段无法识别，设为 null。

示例输出：
{"name":"MacBook Pro 14寸","brand":"Apple","price":14999,"category":"数码"}

请只返回 JSON，不要附加任何其他文字。''';

  static ExtractedItemInfo _parseResponse(String content) {
    var cleaned = content.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*\n?'), '')
          .replaceFirst(RegExp(r'\n?```\s*$'), '');
    }
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    return ExtractedItemInfo.fromJson(json);
  }

  static String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
