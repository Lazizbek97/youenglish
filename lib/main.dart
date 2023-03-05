import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youenglish/repo/caption_repo.dart';
import 'package:youenglish/repo/video_repo.dart';
import 'package:youenglish/repo/youtube_repository.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'core/constants.dart';
import 'core/debouncer.dart';
import 'models/caption.dart';

enum VidoPlayingStatus { onSearch, onPlaying, notPlayedYet }

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
          // primaryColorDark: AppColors.blueGray800
          ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final apiKey = dotenv.env['YOUTUBE_API_KEY'];
  YouTubeRepository? youTubeRepository;
  final repository = VideoRepository(baseUrl: 'http://localhost:8000');
  final captionRepository = CaptionRepository(baseUrl: 'http://localhost:8000');
  late YoutubePlayerController _ytbPlayerController;

  TextEditingController controller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);

  List<String> videoIds = [];
  List<Caption> videosCaption = [];
  Caption? curCaption;
  int currentVideoIndex = 0;
  VidoPlayingStatus status = VidoPlayingStatus.notPlayedYet;

  @override
  void initState() {
    youTubeRepository = YouTubeRepository(apiKey ?? '');
    _ytbPlayerController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 38,
                child: CupertinoSearchTextField(
                    controller: controller,
                    placeholder: 'search terms',
                    onChanged: (String text) async {
                      status = VidoPlayingStatus.onSearch;
                      setState(() {});
                      await _debouncer.run(() async {
                        videoIds =
                            await youTubeRepository?.searchVideos(text) ?? [];
                        videosCaption =
                            await captionRepository.getCaption(videoIds.first);
                        if (videosCaption.isNotEmpty) {
                          for (var caption in videosCaption) {
                            if (caption.text.toLowerCase().contains(
                                  text.toLowerCase(),
                                )) {
                              curCaption = caption;
                            }
                          }
                        }
                      });
                      status = VidoPlayingStatus.onPlaying;

                      setState(() {});
                      if (videoIds.isNotEmpty) {
                        await _ytbPlayerController.loadVideoById(
                          videoId: videoIds[currentVideoIndex],
                          startSeconds: curCaption?.start,
                        );
                      }
                    }),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        status = VidoPlayingStatus.onPlaying;
                        setState(() {});

                        if (curCaption != null) {
                          await _ytbPlayerController.loadVideoById(
                            videoId: videoIds[currentVideoIndex],
                            startSeconds: curCaption?.start,
                          );
                        }
                      },
                      child: controller.text.isEmpty
                          ? const Align(
                              alignment: Alignment.center,
                              child: Text('Search any Terms'),
                            )
                          : status == VidoPlayingStatus.onPlaying
                              ? Column(
                                  children: [
                                    YoutubePlayer(
                                        controller: _ytbPlayerController),
                                    const SizedBox(height: 16),
                                    Text(curCaption?.text ?? ""),
                                  ],
                                )
                              : status == VidoPlayingStatus.onSearch
                                  ? const Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 15,
                                      ),
                                    )
                                  : videoIds.isEmpty || controller.text.isEmpty
                                      ? const Align(
                                          alignment: Alignment.center,
                                          child: Text('Search any Terms'),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 250,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: AppColors.blueGray200,
                                              ),
                                              BoxShadow(
                                                color: AppColors.blueGray200,
                                              )
                                            ],
                                            image: videoIds.isEmpty
                                                ? null
                                                : DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                      "https://img.youtube.com/vi/${videoIds[currentVideoIndex]}/0.jpg",
                                                    ),
                                                  ),
                                          ),
                                        ),
                    ),
                    Expanded(
                        child: SizedBox(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                        itemCount: videosCaption.length,
                        itemBuilder: (context, index) => Text(
                          videosCaption[index].text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: curCaption?.start ==
                                      videosCaption[index].start
                                  ? Colors.blue
                                  : null),
                        ),
                      ),
                    )),
                    CupertinoButton.filled(
                      onPressed: currentVideoIndex < videoIds.length &&
                              controller.text.isNotEmpty
                          ? () async {
                              videosCaption = await captionRepository
                                  .getCaption(videoIds[currentVideoIndex]);
                              if (videosCaption.isNotEmpty) {
                                for (var caption in videosCaption) {
                                  if (caption.text.toLowerCase().contains(
                                        controller.text.toLowerCase(),
                                      )) {
                                    curCaption = caption;
                                  }
                                }
                              }
                              setState(() {});
                              await _ytbPlayerController.loadVideoById(
                                videoId: videoIds[currentVideoIndex],
                                startSeconds: curCaption?.start,
                              );
                            }
                          : null,
                      child: const Text('Next Example'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
