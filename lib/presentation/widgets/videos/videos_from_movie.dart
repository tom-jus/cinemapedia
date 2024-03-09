import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinemapedia/domain/entities/video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final FutureProviderFamily<List<Video>, int> videosFromMovieProvider =
    FutureProvider.family((ref, int movieId) {
  final movieRepository =
      ref.watch(movieRepositoryProvider).getYoutubeVideosById(movieId);
  return movieRepository;
});

class VideosFromMovie extends ConsumerWidget {
  final int movieId;

  const VideosFromMovie({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // En esta variable está el metodo getYoutubeVideosById
    final moviesFromVideo = ref.watch(videosFromMovieProvider(movieId));

    return moviesFromVideo.when(
        data: (videos) => _VideosList(videos: videos),
        error: (_, __) => const Center(
            child: Text('No se pudieron cargar peliculas similares')),
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}

class _VideosList extends StatelessWidget {
  final List<Video> videos;
  const _VideosList({required this.videos});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall;

    //* Si no hay nada que mostrar
    if (videos.isEmpty) {
      return const SizedBox();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Trailer',
          style:
              textStyle!.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),

      //* Aunque tenga disponible varios videos, solo quiero mostrar el primero
      _YoutubeVideoPlayer(
        youtubeId: videos.first.youtubeKey,
        name: videos.first.name,
      ),
    ]);
  }
}

class _YoutubeVideoPlayer extends StatefulWidget {
  final String youtubeId;
  final String name;
  const _YoutubeVideoPlayer({required this.youtubeId, required this.name});

  @override
  State<_YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<_YoutubeVideoPlayer> {
  // plugin
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
        initialVideoId: widget.youtubeId,
        flags: const YoutubePlayerFlags(
          // hideThumbnail: true,
          // showLiveFullscreenButton: false,
          mute: false,
          autoPlay: false,
          // disableDragSeek: true,
          loop: false,
          // isLive: false,
          // forceHD: false,
          // enableCaption: false,
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final textStyle = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.name, style: textStyle.labelSmall!.copyWith(fontSize: 13)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
        )
      ],
    );
  }
}
