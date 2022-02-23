import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tekium_movies/helpers/debouncer.dart';
import 'package:tekium_movies/models/models.dart';
import 'package:tekium_movies/models/now_playing_response.dart';


class MoviesProvider extends ChangeNotifier{

  String _apiKey   = '1865f43a0549ca50d341ddeab8b29f49';
  String _baseUrl  = 'api.themoviedb.org';
  String _language = 'es-HN';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> topRatedMovies = [];
  List<Movie> upcomingMovies = [];

  Map<int, List<Cast>> movieCast = {};

  int _popularPage = 0;
  int _topRatedPage = 0;
  int _upcomingPage = 0;

  final debouncer = Debouncer(
      duration: Duration(milliseconds: 500),

  );

  final StreamController<List<Movie>> _suggestionsStreamController = new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionsStreamController.stream;


  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
    getTopRatedMovies();
    getUpcomingMovies();
  }


  Future<String> _getJsonData( String endpoint, [int page = 1] ) async {
    try {
      final url = Uri.https(
          _baseUrl,
          endpoint,
          {'api_key': _apiKey, 'language': _language, 'page': '$page'}
      );

      // Await the http get response, then decode the json-formatted response.
      final response = await http.get(url);
      return response.body;
    } on Exception catch (e) {
      print(e.toString());
      return '';
    }
  }


  getOnDisplayMovies() async {

    final jsonData = await this._getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;

    notifyListeners();
  }

  getPopularMovies() async {

    _popularPage++;

    final jsonData = await this._getJsonData('3/movie/popular', _popularPage );
    final popularResponse = PopularResponse.fromJson( jsonData );

    popularMovies = [ ...popularMovies, ...popularResponse.results ];

    notifyListeners();
  }


  getTopRatedMovies() async {

    _topRatedPage++;

    final jsonData = await this._getJsonData('3/movie/top_rated', _topRatedPage);
    final topRatedResponse  = TopRatedResponse.fromJson(jsonData);

    topRatedMovies = [ ...topRatedMovies, ...topRatedResponse.results ];

    notifyListeners();
  }

  getUpcomingMovies() async {

    _upcomingPage++;

    final jsonData = await this._getJsonData('3/movie/upcoming', _upcomingPage);
    final upcomingResponse  = TopRatedResponse.fromJson(jsonData);

    upcomingMovies = [ ...upcomingMovies, ...upcomingResponse.results ];

    notifyListeners();
  }

  Future<List<Cast>> getMovieCast( int movieId ) async {

    if( movieCast.containsKey(movieId) ) return movieCast[movieId]!;

    //print('Pidiendo info al servidor - Cast');

    final jsonData = await this._getJsonData('3/movie/$movieId/credits');
    final creditsResponse  = CreditsResponse.fromJson(jsonData);

    movieCast[movieId]  = creditsResponse.cast;

    return creditsResponse.cast;

  }

  Future<List<Movie>> searchMovies( String query ) async {

    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query
    });

    final response = await http.get(url);
    final searchResponse =  SearchResponse.fromJson(response.body);

    return searchResponse.results;

  }

  void getSuggestionsByQuery( String searchTerm ) {

    debouncer.value = '';
    debouncer.onValue = ( value ) async {
      // print('Tenemos valor a buscar: $value');
      final results = await this.searchMovies(value);
      this._suggestionsStreamController.add( results );
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), ( _ ) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration( milliseconds: 301 )).then(( _ ) => timer.cancel());

  }

}
