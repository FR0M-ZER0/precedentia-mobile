import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:precedentia_mobile/core/network/dio_client.dart';

abstract class PetitionRemoteDatasource {
  Stream<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
    required int userId,
  });
}

class PetitionRemoteDatasourceImpl implements PetitionRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Stream<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
    required int userId,
  }) async* {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$baseUrl/analysis/send-petition');

    final body = json.encode({
      'user_id': userId,
      'type': type,
      'facts': facts,
      'tribunal': tribunal,
      'requests': requests,
    });

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = body;

    final dioHeaders = _dio.options.headers;
    if (dioHeaders['Authorization'] != null) {
      request.headers['Authorization'] = dioHeaders['Authorization'] as String;
    }

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw Exception('Erro ${streamedResponse.statusCode}: $body');
    }

    String eventName = 'message';

    final lineStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      final trimmed = line.trim();

      if (trimmed.isEmpty || trimmed.startsWith(':')) continue;

      if (trimmed.startsWith('event:')) {
        eventName = trimmed.replaceFirst('event:', '').trim();
        continue;
      }

      if (trimmed.startsWith('data:')) {
        final raw = trimmed.replaceFirst('data:', '').trim();
        try {
          final payload = json.decode(raw) as Map<String, dynamic>;
          yield {'event': eventName, ...payload};
          eventName = 'message';
        } catch (_) {
          continue;
        }
      }
    }
  }
}