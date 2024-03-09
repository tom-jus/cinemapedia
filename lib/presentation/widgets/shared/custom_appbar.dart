import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:cinemapedia/presentation/delegates/search_movie_delegate.dart';
import 'package:cinemapedia/presentation/providers/search/search_movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Icon(Icons.movie_creation_outlined, color: colors.primary),
            const SizedBox(width: 5),
            Text('Cinemapedia',
                // style: titleStyle,
                style: titleStyle),
            const Spacer(), // Ocupa el espacio disponible
            IconButton(
              onPressed: () {
                final searchedMovies = ref.read(searchedMoviesProvider);
                final searchQuery = ref.read(searchQueryProvider);
                showSearch<Movie?>(
                        // la propiedad query: texto predeterminado que comienza al buscar
                        // Con la funcion de abajo lo actualizamos
                        query: searchQuery,
                        context: context,
                        delegate: SearchMovieDelegate(
                            initialMovies: searchedMovies,
                            searchMovies: ref
                                .read(searchedMoviesProvider.notifier)
                                .searchMoviesbyQuery))
                    .then((movie) {
                  // Metodo para una vez realizada la busqueda poder acceder al id de la pelicula
                  if (movie == null) return;
                  context.push('/home/0/movie/${movie.id}');
                });
              },
              icon: const Icon(Icons.search),
              color: colors.primary,
            ),
          ],
        ),
      ),
    ));
  }
}
