import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:cinemapedia/domain/entities/video.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/mappers/video_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_videos.dart';
import 'package:dio/dio.dart';

// extends de la clase de domain/datasource
class MovieDbDataSource extends MoviesDataSource {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      'api_key': Environment.theMovieDbKey,
      'language': 'es-MX'
    },
  ));

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response =
        await dio.get('/movie/now_playing', queryParameters: {'page': page});

    final movieDbResponse = MovieDbResponse.fromJson(response.data);

    final List<Movie> movies = movieDbResponse.results
        .where((moviedb) =>
            moviedb.posterPath !=
            'no-poster') // Si se cumple pasa, sino corta (ref. a movie_mapper)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final response =
        await dio.get('/movie/popular', queryParameters: {'page': page});

    final movieDbResponse = MovieDbResponse.fromJson(response.data);

    final List<Movie> movies = movieDbResponse.results
        .where((moviedb) =>
            moviedb.posterPath !=
            'no-poster') // Si se cumple pasa, sino corta (ref. a movie_mapper)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<List<Movie>> getUpComing({int page = 1}) async {
    final response =
        await dio.get('/movie/upcoming', queryParameters: {'page': page});

    final movieDbResponse = MovieDbResponse.fromJson(response.data);

    final List<Movie> movies = movieDbResponse.results
        .where((moviedb) =>
            moviedb.posterPath !=
            'no-poster') // Si se cumple pasa, sino corta (ref. a movie_mapper)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    final response =
        await dio.get('/movie/top_rated', queryParameters: {'page': page});

    final movieDbResponse = MovieDbResponse.fromJson(response.data);

    final List<Movie> movies = movieDbResponse.results
        .where((moviedb) =>
            moviedb.posterPath !=
            'no-poster') // Si se cumple pasa, sino corta (ref. a movie_mapper)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<Movie> getMovieById(String id) async {
    final response = await dio.get('/movie/$id');
    if (response.statusCode != 200) {
      throw Exception('Movie with id: $id not found');
    }

    final movieDetails = MovieDetails.fromJson(response.data);

    final Movie movie = MovieMapper.movieDetailsToEntity(movieDetails);

    return movie;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final response =
        await dio.get('/search/movie', queryParameters: {'query': query});

    final movieDbResponse = MovieDbResponse.fromJson(response.data);

    final List<Movie> movies = movieDbResponse.results
        .where((moviedb) =>
            moviedb.posterPath !=
            'no-poster') // Si se cumple pasa, sino corta (ref. a movie_mapper)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<List<Movie>> getSimiliarMovies(int movieId) async {
    final response = await dio.get('/movie/$movieId/similar');

    final movieDbResponse = MovieDbResponse.fromJson(response.data);

    final List<Movie> movies = movieDbResponse.results
        .where((moviedb) =>
            moviedb.posterPath !=
            'no-poster') // Si se cumple pasa, sino corta (ref. a movie_mapper)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final response = await dio.get('/movie/$movieId/videos');
    // Nos traemos la data del modelo
    final moviedbVideosResponse = MoviedbVideosResponse.fromJson(response.data);
    final videos = <Video>[];

    for (final moviedbVideo in moviedbVideosResponse.results) {
      if (moviedbVideo.site == 'YouTube') {
        // Pasamos el video que nos llega de la api por la entidad
        final video = VideoMapper.moviedbVideoToEntity(moviedbVideo);
        videos.add(video);
      }
    }

    return videos;
  }
}
