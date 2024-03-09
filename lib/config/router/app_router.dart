import 'package:go_router/go_router.dart';

import '../../presentation/screens/screens.dart';

final appRouter = GoRouter(initialLocation: '/home/0', routes: [
  GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = state.pathParameters['page'] ?? '0';
        return HomeScreen(pageIndex: int.parse(pageIndex));
      },
      routes: [
        GoRoute(
            path: 'movie/:id',
            name: MovieScreen.name,
            builder: (context, state) {
              final movieId = state.pathParameters['id'] ?? 'no-id';
              return MovieScreen(movieId: movieId);
            }),
      ]),

// * Redireccionar al home
// Se coloca el _ cuando no necesitas el argumento y debes proporcionarlo a la fuerza
  GoRoute(
    path: '/',
    redirect: (_, __) => '/home/0',
  )
]);

// Colocamos las siguientes rutas dentro del route [] de nuestra pantalla principal (HOME SCREEN)

/* Esto se realiza para que cuando compartamos el enlace de una pelicula (deep linking) 
al recargar la pagina en la web, el usuario que recibio el link pueda volver atras 
a la pagina principal */

/* Al hacerlo debemos tener en cuenta que no se coloca el slash (/) inicial ya que lo aporta esta
ruta principal */

/* Si creamos la ruta por fuera de nuestra principal pantalla, debemos colocar el slash inicial
ej : /movie/:id */
