import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:switch_theme/core/models/movie_list_model.dart';

import 'package:switch_theme/core/models/movie_model.dart';
import 'package:http/http.dart' as http;
import 'package:switch_theme/shared/exceptions.dart';

import 'constants.dart';

abstract class MoviesRepo {
  Future<MovieDetails> getMovieById(int id);
  Future<MovieList> getNextMoviesPage(String criteria, int page);
  Future<MovieList> getTrending(String dw);
  Future<MovieList> getSimilarMovies(int id);
  Future<List<Genre>> getGenres();
}

class MoviesApi implements MoviesRepo {
  final logger = Logger();

  String url(dynamic uri, {String language, int page}) =>
      "https://api.themoviedb.org/3/movie/$uri?api_key=$api_key&language=${language ?? "en-US"}&page=${page ?? 1}";

  @override
  Future<MovieDetails> getMovieById(int id) async {
    try {
      http.Response response = await http.get("${url(id)}");
      logger.i(response.statusCode);
      if (response.statusCode == 200) {
        return MovieDetails.fromJson(response.body);
      }
      throw Exception("Failed to Load $id movies");
    } catch (e) {
      logger.e(e.toString());
      throw Exception("Faled to load $id movies");
    }
  }

  @override
  Future<List<Genre>> getGenres() async {
    try {
      http.Response response = await http.get(
          "https://api.themoviedb.org/3/genre/movie/list?api_key=${api_key}&language=en-US");
      logger.i(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["genres"]
            .map<Genre>((res) => Genre.fromMap(res))
            .toList();
      }
      throw Exception("Failed to Load genres");
    } catch (e) {
      logger.e(e.toString());
      throw Exception("Faled to load genres");
    }
  }

  Future<MovieList> getNextMoviesPage(String criteria, int page) async {
    logger.d(page);

    try {
      http.Response response = await http.get("${url(criteria, page: page)}");

      if (response.statusCode == 200) {
        if (page >= jsonDecode(response.body)["total_pages"]) {
          throw NoNextPageException();
        }
        return MovieList.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load $criteria movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load $criteria movies");
    }
  }

  Future<MovieList> getTrending(String dw) async {
    try {
      http.Response response = await http.get(
          "https://api.themoviedb.org/3/trending/movie/${dw}?api_key=${api_key}");

      if (response.statusCode == 200) {
        return MovieList.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load trending movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load trending movies");
    }
  }

  @override
  Future<MovieList> getSimilarMovies(int id) async {
    try {
      http.Response response = await http.get(
          "https://api.themoviedb.org/3/movie/${id}/similar?api_key=${api_key}");

      if (response.statusCode == 200) {
        return MovieList.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load trending movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load trending movies");
    }
  }

  Future<MovieDetails> getLatest() async {
    try {
      http.Response response = await http
          .get("https://api.themoviedb.org/3/movie/latest?api_key=${api_key}");

      if (response.statusCode == 200) {
        return MovieDetails.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load trending movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load trending movies");
    }
  }
}
