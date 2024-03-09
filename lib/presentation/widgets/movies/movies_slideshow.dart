import 'package:animate_do/animate_do.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoviesSlideShow extends StatelessWidget {
  final List<Movie> movies;

  const MoviesSlideShow({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Swiper(
          viewportFraction: 0.8,
          scale: 0.9,
          autoplay: false,
          pagination: SwiperPagination(
              margin: const EdgeInsets.only(top: 0),
              builder: DotSwiperPaginationBuilder(
                activeColor: colors.primary,
                color: colors.secondary,
              )),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _Slide(movie: movie);
          },
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black45, blurRadius: 5, offset: Offset(0, 8))
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () => context.push('/home/0/movie/${movie.id}'),
            child: FadeIn(
              child: Image.network(
                movie.backdropPath,
                fit: BoxFit.cover,
                // loadingBuilder: (context, child, loadingProgress) {
                //   if (loadingProgress != null) {
                //     return const DecoratedBox(
                //         decoration: BoxDecoration(color: Colors.black12));
                //   }
                //   return FadeIn(child: child);
                // },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
