import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekium_movies/providers/movies_provider.dart';
import 'package:tekium_movies/search/search_delegate.dart';
import 'package:tekium_movies/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas en Cines'),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () { showSearch(context: context, delegate: MovieSearchDelegate()); },
              icon: const Icon( Icons.search_outlined )
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardSwiper(movies: moviesProvider.onDisplayMovies),
            MovieSlider(movies: moviesProvider.popularMovies, Title: 'Populares', onNextPage: () => moviesProvider.getPopularMovies()),
            const SizedBox(height: 10),
            MovieSlider(movies: moviesProvider.topRatedMovies, Title: 'Mejor Valoradas', onNextPage: () => moviesProvider.getTopRatedMovies()),
            const SizedBox(height: 10),
            MovieSlider(movies: moviesProvider.upcomingMovies, Title: 'Próximas Películas',onNextPage: () => moviesProvider.getUpcomingMovies()),
          ],
        ),
      ),
    );
  }
}
