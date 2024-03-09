import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:flutter/material.dart';

// Definimos funcion para realizar la busqueda
typedef SearchMoviesCallBack = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {
  final SearchMoviesCallBack searchMovies;
  List<Movie> initialMovies;

  // broadcast = controlador donde se puede escuchar la transmisión más de una vez
  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  SearchMovieDelegate(
      {required this.searchMovies, required this.initialMovies});

  // Los streams quedan guardados en memoria por lo tanto a traves de esta funcion los cerramos
  void clearStreams() {
    debouncedMovies.close();
  }

  void _onQueryChanged(String query) {
    // Si el query cambia aparece el logo de cargando
    isLoadingStream.add(true);

    // Si el Timer ya esta activo lo cancelamos
    // Si no está activo ejecutamos el Timer y el llamado a la api
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final movies = await searchMovies(query);
      initialMovies = movies;
      debouncedMovies.add(movies);
      isLoadingStream.add(false);
    });
  }

  @override
  String get searchFieldLabel => 'Buscar película';

  Widget buildResultAndSuggestions() {
    return StreamBuilder(
      initialData: initialMovies,
      stream: debouncedMovies.stream,
      builder: (context, snapshot) {
        final movies = snapshot.data ??
            []; // Si todavia no hay data devolvemos arreglo vacio
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _MovieItem(
                movie: movie,
                functionClose: (context, movie) {
                  clearStreams();
                  close(context, movie);
                });
          },
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 10),
              spins: 10,
              infinite: true,
              child: IconButton(
                onPressed: () => query = '',
                icon: const Icon(Icons.refresh),
                color: colors.primary,
                iconSize: 20,
              ),
            );
          }
          return FadeIn(
            child: IconButton(
              onPressed: () => query = '',
              icon: const Icon(Icons.clear),
              color: colors.primary,
              iconSize: 20,
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
        onPressed: () {
          // clearStreams();
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios),
        color: colors.primary,
        iconSize: 15);
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Funcion que demora la peticion http
    _onQueryChanged(query);
    return buildResultAndSuggestions();
  }
}

class _MovieItem extends StatelessWidget {
  final Movie movie;
  final Function functionClose;
  const _MovieItem({required this.movie, required this.functionClose});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: GestureDetector(
        onTap: () {
          functionClose(context, movie);
        },
        child: Row(
          children: [
            // Imagen
            SizedBox(
              width: size.width * 0.25,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage(
                    height: 130,
                    fit: BoxFit.cover,
                    image: NetworkImage(movie.posterPath),
                    placeholder:
                        const AssetImage('assets/loaders/bottle-loader.gif'),
                  )),
            ),
            const SizedBox(width: 10),

            // Titulo + descripcion
            SizedBox(
              width: size.width * 0.65,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: textStyle.labelLarge),
                    (movie.overview.length > 100)
                        ? Text(
                            '${movie.overview.substring(0, 100)}...',
                          )
                        : Text(movie.overview),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade800,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          HumanFormats.number(movie.voteAverage, 1),
                          style: textStyle.labelSmall,
                        ),
                        const Spacer(),
                        Text(
                          'Views ${HumanFormats.number(movie.popularity)}',
                          style: textStyle.labelSmall,
                        ),
                      ],
                    )
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
