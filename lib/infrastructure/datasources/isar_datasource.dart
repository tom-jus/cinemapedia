import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movies.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatasource extends LocalStorageDatasource {
  // SINGLETON = Patron de diseño que asegura que una clase tenga solo una instancia en todas las aplicaciones y proporciona un punto de acceso global.
  // static IsarDatasource? _instance;
  // static IsarDatasource get instance {
  //   _instance ??= IsarDatasource();
  //   return _instance!;
  // }

  // Apertura db
  late Future<Isar> db;

  IsarDatasource() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();

    if (Isar.instanceNames.isEmpty) {
      return await Isar.open([MovieSchema],
          inspector: true, directory: dir.path);
    }
    return Future.value(Isar.getInstance());
  }

  @override
  Future<bool> isMovieFavorite(int movieId) async {
    // Esperamos a la db
    final isar = await db;

    final Movie? isFavoriteMovie =
        await isar.movies.filter().idEqualTo(movieId).findFirst();

    // Si isFavoriteMovie encuentra algo, regresa true, si no encuentra nada regresa false
    return isFavoriteMovie != null;
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    final isar = await db;

    final favoriteMovie =
        await isar.movies.filter().idEqualTo(movie.id).findFirst();

    if (favoriteMovie != null) {
      // Borrar movie
      isar.writeTxnSync(() => isar.movies.deleteSync(favoriteMovie.isarId!));
      return;
    }

    // Agregar movie
    isar.writeTxnSync(() => isar.movies.putSync(movie));
  }

  @override
  Future<List<Movie>> loadMovies({int limit = 10, offset = 0}) async {
    final isar = await db;

    return isar.movies.where().offset(offset).limit(limit).findAll();
  }
}
