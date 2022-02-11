import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekium_movies/screens/screens.dart';
import 'package:tekium_movies/providers/movies_provider.dart';

void main() => runApp(AppState());


class AppState extends StatelessWidget {
  const AppState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: ( _ ) => MoviesProvider(), lazy: false )
        ],
      child: MyApp(),
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movies',
      initialRoute: 'home',
      routes: {
        'home' : ( _ ) => const HomeScreen(),
        'details' : ( _ ) => DetailsScreen(),
      },
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          color: Colors.grey[800]
        )
      ),
    );
  }
}
