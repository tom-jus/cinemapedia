import 'package:cinemapedia/domain/entities/video.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_videos.dart';

class VideoMapper {
  // El argumento Result hace referencia a la class del archivo correspondiente en Models
  static moviedbVideoToEntity(Result moviedbVideo) => Video(
      id: moviedbVideo.id,
      name: moviedbVideo.name,
      youtubeKey: moviedbVideo.key,
      publishedAt: moviedbVideo.publishedAt);
}
