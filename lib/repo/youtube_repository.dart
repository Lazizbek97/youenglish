import 'dart:convert';
import 'package:http/http.dart' as http;

const clientId =
    '1053280612155-0mvaatocuto8ekb1olueb79pg9m1a8oj.apps.googleusercontent.com';
const clientSecret = 'YOUR_CLIENT_SECRET';
// final scopes = [auth.YouTubeApi.youtubeReadonlyScope];

class YouTubeRepository {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  final String _apiKey;

  YouTubeRepository(this._apiKey);

  Future<List<String>> _searchVideoIds(String query) async {
    final searchUrl =
        '$_baseUrl/search?part=id&q=$query&type=video&key=$_apiKey';
    final searchResponse = await http.get(Uri.parse(searchUrl));

    print(searchResponse.body);

    if (searchResponse.statusCode != 200) {
      throw Exception('Failed to search videos.');
    }

    final searchJson = jsonDecode(searchResponse.body);

    final videoIds = List<Map<String, dynamic>>.from(searchJson['items'])
        .map((item) => item['id']['videoId'].toString())
        .toList();

    return videoIds;
  }

  // Future<List<Map<String, dynamic>>> _getVideoDetails(
  //     List<String> videoIds) async {
  //   final videoUrl =
  //       '$_baseUrl/videos?part=snippet,contentDetails&id=${videoIds.join(',')}&key=$_apiKey';
  //   final videoResponse = await http.get(Uri.parse(videoUrl));

  //   if (videoResponse.statusCode != 200) {
  //     throw Exception('Failed to get videos.');
  //   }

  //   final videoJson = jsonDecode(videoResponse.body);
  //   print('------------');

  //   print(videoJson);
  //   print('------------');
  //   List<Map<String, dynamic>> data =
  //       List<Map<String, dynamic>>.from(videoJson['items']);

  //   final List<Map<String, dynamic>> videoDetails = data
  //       .map((item) => {
  //             'id': item['id'],
  //             'title': item['snippet']['title'],
  //             'description': item['snippet']['description'],
  //             'duration': item['contentDetails']['duration']
  //           })
  //       .toList();

  //   return videoDetails;
  // }

  // Future<List<Map<String, dynamic>>?> _getVideoCaptions(
  //     List<String> videoIds) async {
  //   final client = await auth.clientViaUserConsent(auth.ClientId(clientId),
  //       [youtube.YouTubeApi.youtubeReadonlyScope], (prompt) {});

  //   final accessToken = client.credentials.accessToken;

  //   final transcriptionUrl = '$_baseUrl/captions/{VIDEO_ID}&key=$_apiKey';
  //   final transcriptionHeaders = {
  //     'Accept': 'application/json',
  //     'Authorization': 'Bearer $accessToken',
  //   };
  //   final List<Map<String, dynamic>> transcriptionResults = [];
  //   print('(((((((((((((');

  //   for (final videoId in videoIds) {
  //     final url = transcriptionUrl.replaceAll('{VIDEO_ID}', videoId);
  //     try {
  //       final transcriptionResponse =
  //           await http.get(Uri.parse(url), headers: transcriptionHeaders);
  //       print(transcriptionResponse.body);

  //       if (transcriptionResponse.statusCode == 200) {
  //         final transcriptionJson = jsonDecode(transcriptionResponse.body);
  //         final captions = transcriptionJson['items']
  //             .map((item) => item['textDetails']['transcript'])
  //             .join('\n');
  //         transcriptionResults
  //             .add({'id': videoId, 'captions': captions.trim()});
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   }

  //   return transcriptionResults;
  // }

  Future<List<String>> searchVideos(String query) async {
    final videoIds = await _searchVideoIds(query);
    // final videoDetails = await _getVideoDetails(videoIds);
    // final videoCaptions = await _getVideoCaptions(videoIds);
    // videoIds.forEach((element) async {
    // });
    print(videoIds);
    // await getCaptions(videoIds.first);

    // print(videoCaptions);

    // final results = videoDetails.map((video) {
    //   final captions = videoCaptions
    //       ?.firstWhere((caption) => caption['id'] == video['id'])['captions'];
    //   return {...video, 'captions': captions};
    // }).toList();

    return videoIds;
  }

  // Future<void> getCaptions(String videoId) async {
  //   var url = Uri.parse('http://localhost:8000/getCaptions?videoId=$videoId');
  //   var response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     print('Captions saved to file');
  //     // do something with the captions file here
  //   } else {
  //     print('Captions not found for video ID');
  //   }
  // }
}
