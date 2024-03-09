import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:cinemapedia/domain/repositories/local_storage_repository.dart';
import 'package:cinemapedia/presentation/providers/storage/local_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteMoviesProvider =
    StateNotifierProvider<StorageMovieNotifier, Map<int, Movie>>((ref) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return StorageMovieNotifier(localStorageRepository: localStorageRepository);
});

class StorageMovieNotifier extends StateNotifier<Map<int, Movie>> {
  int page = 0;
  final LocalStorageRepository localStorageRepository;

  StorageMovieNotifier({required this.localStorageRepository}) : super({});

  Future<List<Movie>> loadNextPage() async {
    final movies =
        await localStorageRepository.loadMovies(offset: page * 10, limit: 10);
    page++;

    final tempMoviesMap = <int, Movie>{};
    // Creo una movie por cada elemento de movies
    for (final movie in movies) {
      // En la variable tempMoviesMap me guardo cada id de movie
      tempMoviesMap[movie.id] = movie;
    }

    state = {...state, ...tempMoviesMap};

    return movies;
  }

  Future<void> toggleFavorite(Movie movie) async {
    await localStorageRepository.toggleFavorite(movie);
    // Chequeamos si la movie esta en favorites o no
    final bool isMovieInFavorites = state[movie.id] != null;

    if (isMovieInFavorites) {
      state.remove(movie.id);
      state = {...state};
    }
    state = {...state, movie.id: movie};
  }
}
