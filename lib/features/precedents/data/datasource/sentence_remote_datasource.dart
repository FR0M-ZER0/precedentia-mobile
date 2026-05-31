import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/dio_client.dart';

abstract class SentenceRemoteDatasource {
  Stream<Map<String, dynamic>> extractSentenceStream(
    PlatformFile file,
    int userId,
  );
}

class SentenceRemoteDatasourceImpl implements SentenceRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Stream<Map<String, dynamic>> extractSentenceStream(
    PlatformFile file,
    int userId,
  ) async* {
    if (file.bytes == null) {
      throw Exception(
        'Os bytes do arquivo estão nulos. Verifique o FilePicker.',
      );
    }

    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$baseUrl/sentences/extract-process');

    debugPrint('[SentenceDatasource] URI: $uri');
    debugPrint('[SentenceDatasource] userId: $userId');
    debugPrint(
      '[SentenceDatasource] file: ${file.name} (${file.bytes!.length} bytes)',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = userId.toString()
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: MediaType('application', 'pdf'),
        ),
      );

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
