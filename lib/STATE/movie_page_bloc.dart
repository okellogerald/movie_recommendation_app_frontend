import 'dart:async';
import 'package:recommendation/DATA/movie.dart';
import '../source.dart';

enum Events { fetch, fetching, done }

abstract class MoviePage {
  void dispose();
}

class MoviePageBloc {
  StreamController<Events> _eventsStreamController =
      StreamController<Events>.broadcast();

  Stream<Events> get eventsStream => _eventsStreamController.stream;
  StreamSink<Events> get eventsSink => _eventsStreamController.sink;

  StreamController<Movie> _movieStreamController =
      StreamController<Movie>.broadcast();

  Stream<Movie> get movieStream => _movieStreamController.stream;
  StreamSink<Movie> get movieSink => _movieStreamController.sink;

  StreamController<int> _idStreamController = StreamController<int>.broadcast();

  Stream<int> get idStream => _idStreamController.stream;
  StreamSink<int> get idSink => _idStreamController.sink;

  MoviePageBloc() {
    eventsStream.listen((event) async {
      switch (event) {
        case Events.fetch:
          eventsSink.add(Events.fetching);
          break;
        case Events.fetching:
          int id = 342473;
          Movie movie = await tmdb.getMovieById(id);
          movieBloc.movieSink.add(movie);
          eventsSink.add(Events.done);
          break;
        default:
      }
    });
  }

  dispose() {
    _eventsStreamController.close();
    _movieStreamController.close();
    _idStreamController.close();
  }
}
