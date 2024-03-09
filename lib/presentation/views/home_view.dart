import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/widgets.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  // Colocamos nombre de la clase con estado
  HomeViewState createState() => HomeViewState();
}

// State<_HomeView> lo cambiamos por ConsumerState<_HomeView>
class HomeViewState extends ConsumerState<HomeView>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
    ref.read(popularMoviesProvider.notifier).loadNextPage();
    ref.read(upComingMoviesProvider.notifier).loadNextPage();
    ref.read(topRatedMoviesProvider.notifier).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final initialLoading = ref.watch(initialLoadingProvider);
    if (initialLoading) return FullScreenLoader();

    final moviesSlowShow = ref.watch(moviesSlideShowProvider);
    final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final upComingMovies = ref.watch(upComingMoviesProvider);
    final topRatedMovies = ref.watch(topRatedMoviesProvider);

    return CustomScrollView(slivers: [
      const SliverAppBar(
        floating: true,
        flexibleSpace: FlexibleSpaceBar(
            title: CustomAppBar(),
            // Colocamos en 0, porque por defecto le otorga un padding
            titlePadding: EdgeInsets.all(0)),
      ),
      SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Column(
            children: [
              // const CustomAppBar(),
              MoviesSlideShow(movies: moviesSlowShow),
              MovieHorizontalListView(
                movies: nowPlayingMovies,
                title: 'En cines',
                subTitle: 'Hoy',
                loadNextPage: () =>
                    ref.read(nowPlayingMoviesProvider.notifier).loadNextPage(),
              ),
              MovieHorizontalListView(
                movies: upComingMovies,
                title: 'Próximamente',
                subTitle: 'En Cines',
                loadNextPage: () =>
                    ref.read(upComingMoviesProvider.notifier).loadNextPage(),
              ),
              // MovieHorizontalListView(
              //   movies: popularMovies,
              //   title: 'Populares',
              //   subTitle: 'Este mes',
              //   loadNextPage: () =>
              //       ref.read(popularMoviesProvider.notifier).loadNextPage(),
              // ),
              MovieHorizontalListView(
                movies: topRatedMovies,
                title: 'Mejor calificadas',
                subTitle: 'General',
                loadNextPage: () =>
                    ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
        childCount: 1,
      ))
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
