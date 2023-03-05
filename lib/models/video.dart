class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String description;
  final Duration duration;
  final DateTime publishedAt;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.description,
    required this.duration,
    required this.publishedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final duration = Duration(seconds: int.parse(json['duration']));
    final publishedAt = DateTime.parse(json['published_at']);

    return Video(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnail_url'],
      channelTitle: json['channel_title'],
      description: json['description'],
      duration: duration,
      publishedAt: publishedAt,
    );
  }
}
