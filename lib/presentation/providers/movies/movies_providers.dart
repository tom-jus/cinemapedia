import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifierProvider = Proovedor de informacion que notifica cuando cambia el estado
// PROVIDER DE PETICION A TODAS LAS PELICULAS
final nowPlayingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final movieRepository = ref.watch(movieRepositoryProvider).getNowPlaying;
  return MoviesNotifier(fetchMoreMovies: movieRepository);
});

// PROVIDER DE PETICION A PELICULAS POPULARES
final popularMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final movieRepository = ref.watch(movieRepositoryProvider).getPopular;
  return MoviesNotifier(fetchMoreMovies: movieRepository);
});

// PROVIDER DE PETICION A PROXIMAS PELICULAS
final upComingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final movieRepository = ref.watch(movieRepositoryProvider).getUpComing;
  return MoviesNotifier(fetchMoreMovies: movieRepository);
});

// PROVIDER DE PETICION A PELICULAS MEJOR CALIFICADAS
final topRatedMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final movieRepository = ref.watch(movieRepositoryProvider).getTopRated;
  return MoviesNotifier(fetchMoreMovies: movieRepository);
});

// Definimos como queremos que sea la funcion
typedef MovieCallback = Future<List<Movie>> Function({int page});

class MoviesNotifier extends StateNotifier<List<Movie>> {
  int currentPage = 0;
  bool isLoading = false;
  MovieCallback fetchMoreMovies;

  MoviesNotifier({required this.fetchMoreMovies}) : super([]);

  Future<void> loadNextPage() async {
    if (isLoading) return;

    isLoading = true;
    currentPage++;
    final List<Movie> movies = await fetchMoreMovies(page: currentPage);
    state = [...state, ...movies];
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading = false;
  }
}
