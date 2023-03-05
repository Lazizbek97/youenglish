import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/caption.dart';

class CaptionRepository {
  final String baseUrl;

  CaptionRepository({required this.baseUrl});

  Future<List<Caption>> getCaption(String videoId) async {
    final url = Uri.parse('$baseUrl/getTranscript?videoId=$videoId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final captionJson = json.decode(response.body);
      print(captionJson);
      final captions = (captionJson['transcript'] as List)
          .map((e) => Caption.fromJson(e))
          .toList();
      return captions;
    } else {
      throw Exception('Failed to get caption');
    }
  }
}
