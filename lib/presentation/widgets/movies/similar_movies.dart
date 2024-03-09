import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_horizontal_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final similarMoviesProvider = FutureProvider.family((ref, int movieId) {
  final movieRepository = ref.watch(movieRepositoryProvider);
  return movieRepository.getSimiliarMovies(movieId);
});

class SimilarMovies extends ConsumerWidget {
  final int movieId;

  const SimilarMovies({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final similarMoviesFuture = ref.watch(similarMoviesProvider(movieId));

    return similarMoviesFuture.when(
        data: (movies) => _Recomendations(movies: movies),
        error: (_, __) => const Center(
            child: Text('No se pudieron cargar películas similares')),
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}

class _Recomendations extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final List<Movie> movies;
  const _Recomendations({required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox();

    return Container(
        margin: const EdgeInsetsDirectional.only(bottom: 50),
        child: MovieHorizontalListViewTwo(
            movies: movies, title: 'Recomendaciones'));
  }
}

class MovieHorizontalListViewTwo extends StatefulWidget {
  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListViewTwo(
      {super.key,
      required this.movies,
      this.title,
      this.subTitle,
      this.loadNextPage});

  @override
  State<MovieHorizontalListViewTwo> createState() =>
      _MovieHorizontalListViewTwoState();
}

class _MovieHorizontalListViewTwoState
    extends State<MovieHorizontalListViewTwo> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (widget.loadNextPage == null) return;

      if ((scrollController.position.pixels + 230) >=
          scrollController.position.maxScrollExtent) {
        widget.loadNextPage!();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 320, // 320
        child: Column(
          children: [
            if (widget.title != null || widget.subTitle != null)
              _Title(
                title: widget.title,
                subTitle: widget.subTitle,
              ),
            const SizedBox(height: 10),
            Expanded(
                child: ListView.builder(
              controller: scrollController,
              itemCount: widget.movies.length,
              scrollDirection: Axis.horizontal,
              physics:
                  const BouncingScrollPhysics(), // mismo rebote tanto android como ios
              itemBuilder: (context, index) {
                return FadeInRight(child: _Slide(movie: widget.movies[index]));
              },
            )),
          ],
        ));
  }
}

class _Title extends StatelessWidget {
  final String? title;
  final String? subTitle;

  const _Title({this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    // final textStyle = Theme.of(context).textTheme.titleMedium;
    final textStyle2 = Theme.of(context).textTheme.labelSmall;

    return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            if (title != null)
              Text(title!, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (subTitle != null)
              FilledButton.tonal(
                  style:
                      const ButtonStyle(visualDensity: VisualDensity.compact),
                  onPressed: () {},
                  child: Text(subTitle!, style: textStyle2)),
          ],
        ));
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: SizedBox(
        height: 260,
        child: Container(
          margin: const EdgeInsets.only(right: 5),
          // padding: const EdgeInsets.only(right: 15),
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto del actor
              FadeInRight(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    movie.posterPath,
                    height: 180,
                    width: 135,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // return Padding(
              //   padding: const EdgeInsets.only(left: 10),
              //   child: SizedBox(
              //     height: 300,
              //     child: Container(
              //       padding: const EdgeInsets.only(right: 15),
              //       child: Column(
              //         children: [
              //           //* Imagen
              //           SizedBox(
              //               width: 130,
              //               height: 192, // 192
              //               child: ClipRRect(
              //                 borderRadius: BorderRadius.circular(20),
              //                 child: GestureDetector(
              //                   onTap: () => context.push('/home/0/movie/${movie.id}'),
              //                   child: FadeInRight(
              //                       child: Image.network(
              //                     movie.posterPath,
              //                     width: 130,
              //                     fit: BoxFit.cover,
              //                   )),
              //                 ),
              //               )),
              const SizedBox(height: 10),
              //* Title
              SizedBox(
                width: 120,
                // height: double.infinity,
                child: Text(
                  movie.title,
                  maxLines: 2,
                  textAlign: TextAlign.start,
                ),
              ),
              const Spacer(),

              //* Rating
              // SizedBox(
              //   width: 120,
              //   height: 35,
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              // Icon(
              //   Icons.star,
              //   color: Colors.yellow.shade800,
              //   size: 15,
              // ),
              // const SizedBox(width: 2),
              // Text(
              //   '${movie.voteAverage}',
              //   style: textStyle.labelSmall
              //       ?.copyWith(color: Colors.yellow.shade800),
              // ),
              // const Spacer(),
              // Text(
              //   HumanFormats.number(movie.popularity),
              //   style: textStyle.labelSmall,
              // )
            ],
          ),
        ),
        // ],
        // ),
        // ),
      ),
    );
  }
}
