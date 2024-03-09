import 'package:cinemapedia/infrastructure/datasources/actors_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/actor_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este repositorio es Inmutable
// Su objetivo es proporcionar a todos los demas providers la informacion necesaria

final actorsRepositoryProvider = Provider((ref) {
  return ActorRepositoryImpl(ActorMovieDbDatasource());
});
