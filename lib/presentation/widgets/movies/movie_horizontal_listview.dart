import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/helpers/human_formats.dart';

class MovieHorizontalListView extends StatefulWidget {
  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListView(
      {super.key,
      required this.movies,
      this.title,
      this.subTitle,
      this.loadNextPage});

  @override
  State<MovieHorizontalListView> createState() =>
      _MovieHorizontalListViewState();
}

class _MovieHorizontalListViewState extends State<MovieHorizontalListView> {
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
        height: 320,
        child: Column(
          children: [
            if (widget.title != null || widget.subTitle != null)
              _Title(
                title: widget.title,
                subTitle: widget.subTitle,
              ),
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
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 3),
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
    final textStyle = Theme.of(context).textTheme;
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            //* Imagen
            SizedBox(
                width: 130,
                height: 192,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onTap: () => context.push('/home/0/movie/${movie.id}'),
                    child: FadeInRight(
                        child: Image.network(
                      movie.posterPath,
                      width: 130,
                      fit: BoxFit.cover,
                    )),
                  ),
                )),
            const SizedBox(height: 5),
            //* Title
            SizedBox(
              width: 120,
              // height: double.infinity,
              child: Text(
                movie.title,
                maxLines: 2,
                textAlign: TextAlign.start,
                style: textStyle.labelSmall,
              ),
            ),
            const Spacer(),

            //* Rating
            SizedBox(
              width: 120,
              height: 35,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade800,
                    size: 15,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${movie.voteAverage}',
                    style: textStyle.labelSmall
                        ?.copyWith(color: Colors.yellow.shade800),
                  ),
                  const Spacer(),
                  Text(
                    HumanFormats.number(movie.popularity),
                    style: textStyle.labelSmall,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
