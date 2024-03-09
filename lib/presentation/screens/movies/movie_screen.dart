import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/movies/similar_movies.dart';
import 'package:cinemapedia/presentation/widgets/videos/videos_from_movie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';
  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if (movie == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics:
            const ClampingScrollPhysics(), // para que no haga el rebote de IOS
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie),
            childCount: 1,
          )),
        ],
      ),
    );
  }
}

final isFavoriteProvider =
    FutureProvider.family.autoDispose((ref, int movieId) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);

  return localStorageRepository.isMovieFavorite(movieId);
});

//* Imagen
class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, ref) {
    final size = MediaQuery.of(context).size;

    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));

    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
            onPressed: () async {
              // ref.read(localStorageRepositoryProvider).toggleFavorite(movie);
              await ref
                  .read(favoriteMoviesProvider.notifier)
                  .toggleFavorite(movie);
              // Invalidamos para que realice de nuevo la peticion y el icono del favorite cambie en tiempo real
              ref.invalidate(isFavoriteProvider(movie.id));
            },
            icon: isFavoriteFuture.when(
              loading: () => const Icon(Icons.favorite_border),
              data: (isFavorite) => isFavorite
                  ? const Icon(Icons.favorite_rounded, color: Colors.red)
                  : const Icon(Icons.favorite_border),
              error: (_, __) => throw UnimplementedError(),
            )
            // const Icon(Icons.favorite_border),
            // icon: const Icon(Icons.favorite_border),
            // color: const Color.fromARGB(255, 248, 129, 121),
            )
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 0),
        title: _CustomGradient(
            begin: Alignment.center,
            stops: const [0.7, 1.0],
            colors: [Colors.transparent, scaffoldBackgroundColor],
            end: Alignment.bottomCenter),
        background: Stack(
          children: [
            //* Imagen
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.fill,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            //* Gradiente Icon favorite
            const _CustomGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.0, 0.2],
              colors: [Colors.black87, Colors.transparent],
            ),

            //* Gradiente Icon arrow-back
            const _CustomGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.2],
              colors: [Colors.black87, Colors.transparent],
            )
          ],
        ),
      ),
    );
  }
}

//* Titulo, descripción, y géneros
class _MovieDetails extends StatelessWidget {
  final Movie movie;
  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Rank, Views, Play
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(children: [
              Icon(
                Icons.star,
                color: Colors.yellow.shade800,
                size: 15,
              ),
              const SizedBox(width: 3),
              Text(HumanFormats.number(movie.voteAverage, 1),
                  style: textStyle.labelSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              const Icon(Icons.remove_red_eye, size: 15),
              const SizedBox(width: 3),
              Text(
                HumanFormats.number(movie.popularity),
                style:
                    textStyle.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 15),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_circle_outline_outlined),
                iconSize: 30,
              ),
            ]),
          ),

          //* Título
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              movie.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          //* Descripción
          // Text(movie.overview, style: textStyle.labelLarge),
          if (movie.overview != '')
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(movie.overview, style: textStyle.labelLarge))
          else
            const SizedBox(height: 1),

          const SizedBox(height: 10),

          //* Genéros
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Wrap(
              children: [
                ...movie.genreIds.map(
                  (gender) => Container(
                    margin: const EdgeInsets.only(right: 7),
                    child: Chip(
                      label: Text(
                        gender,
                        style: const TextStyle(fontSize: 10),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          //* Actores
          _ActorsByMovie(movieId: movie.id.toString()),

          const SizedBox(height: 10),

          //* Trailer de las peliculas (si tiene)
          // VideosFromMovie(movieId: movie.id),

          // const SizedBox(height: 10),

          //* Peliculas similares
          SimilarMovies(movieId: movie.id),
        ],
      ),
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;
  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final actorsByMovie = ref.watch(actorsByMovieProvider);

    if (actorsByMovie[movieId] == null) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final actors = actorsByMovie[movieId]!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: SizedBox(
          height: 250, // 260
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actors.length,
            itemBuilder: (context, index) {
              final actor = actors[index];

              return Container(
                  padding: const EdgeInsets.only(right: 15),
                  width: 135,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto del actor
                      FadeInRight(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            actor.profilePath,
                            height: 180,
                            width: 135,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Nombre
                      Text(actor.name, maxLines: 2),
                      Text(
                        actor.character ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 2,
                      ),
                    ],
                  ));
            },
          )),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;
  const _CustomGradient({
    required this.begin,
    required this.stops,
    required this.colors,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, end: end, stops: stops, colors: colors))),
    );
  }
}
