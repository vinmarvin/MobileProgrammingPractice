import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/theme.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const YoutubePlayerScreen({super.key, required this.videoId, required this.title});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primaryDark,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primaryDark,
          handleColor: AppColors.primary,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            backgroundColor: AppColors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.white),
            title: Text(widget.title, style: const TextStyle(color: AppColors.white, fontSize: 16)),
          ),
          body: Center(
            child: player,
          ),
        );
      },
    );
  }
}
