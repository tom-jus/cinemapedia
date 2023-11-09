import 'package:cinemapedia/domain/entities/movies.dart';

abstract class MovieDataSource {
  Future<List<Movie>> getNowPlaying({int page = 1});
}
