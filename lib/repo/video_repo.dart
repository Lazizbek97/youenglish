import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';

class VideoRepository {
  final String baseUrl;

  VideoRepository({required this.baseUrl});

  Future<List<Video>> searchVideosByKeyword(String keyword) async {
    final url = Uri.parse('$baseUrl/searchVideos?query=$keyword');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final videosJson = json.decode(response.body);
      print(videosJson);
      // final videos = (videosJson['videoIds'] as List).map((json) => Video.fromJson(json)).toList();
      return [];
    } else {
      throw Exception('Failed to search videos');
    }
  }

  Future<Video> getVideo(String videoId) async {
    final url = Uri.parse('$baseUrl/getVideo?videoId=$videoId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final videoJson = json.decode(response.body);
      final video = Video.fromJson(videoJson);
      return video;
    } else {
      throw Exception('Failed to get video');
    }
  }
}
