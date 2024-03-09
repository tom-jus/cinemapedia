import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView>
    with AutomaticKeepAliveClientMixin {
  bool isLastPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadNextPage();
  }

  void loadNextPage() async {
    // Si esta cargando o es la ultima pagina salimos, no hace falta cargar de nuevo
    if (isLoading || isLastPage) return;
    isLoading = true;

    final movies =
        await ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    isLoading = false;

    if (movies.isEmpty) {
      isLastPage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final textStyle = Theme.of(context).textTheme.labelSmall;

    // El provider devuelve un Map y lo convertimos en List
    final favoriteMovies = ref.watch(favoriteMoviesProvider).values.toList();

    if (favoriteMovies.isEmpty) {
      final colors = Theme.of(context).colorScheme;
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline_sharp,
            size: 60,
            color: colors.primary,
          ),
          const SizedBox(height: 20),
          Text('No hay favoritos', style: textStyle!.copyWith(fontSize: 13)),
          const SizedBox(height: 20),
          FilledButton.tonal(
              onPressed: () => context.go('/home/0'),
              child: const Text('Agregar'))
        ],
      ));
    }

    return MovieMasonry(loadNextPage: loadNextPage, movies: favoriteMovies);
  }

  @override
  bool get wantKeepAlive => true;
}


// Scaffold(
//       body: ListView.builder(
//         itemCount: favoriteMovies.length,
//         itemBuilder: (context, index) {
//           final movie = favoriteMovies[index];
//           return ListTile(
//             title: Text(movie.title),
//           );
//         },
//       ),
//     );