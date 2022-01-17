import 'dart:async';

import 'package:recommendation/DATA/movie.dart';
import 'package:recommendation/DATA/recommendations.dart';
import 'package:recommendation/STUDY%20FUNCTIONS/functions.dart';
import 'package:recommendation/STUDY%20FUNCTIONS/heroku_api.dart';

import '../source.dart';

abstract class RatingBloc {
  void dispose();
}

enum RatingEvents { initialState, fetch, fetching, moviesLoaded }
enum RecommendationEvents {
  initialState,
  fetch,
  fetching,
  recommendationLoaded
}
RecommendationsFunctions _recommendationFunctions = RecommendationsFunctions();
StudyFunctions _studyFunctions = StudyFunctions();

class MoviesRating extends RatingBloc {
  StreamController<RatingEvents> ratingEventsController =
      StreamController<RatingEvents>.broadcast();
  StreamSink<RatingEvents> get ratingEventsSink => ratingEventsController.sink;
  Stream<RatingEvents> get ratingEventsStream => ratingEventsController.stream;

  StreamController<List<DemoMovie>> demoMoviesController =
      StreamController<List<DemoMovie>>.broadcast();
  StreamSink<List<DemoMovie>> get demoMoviesSink => demoMoviesController.sink;
  Stream<List<DemoMovie>> get demoMoviesStream => demoMoviesController.stream;

  MoviesRating() {
    ratingEventsStream.listen((event) async {
      if (event == RatingEvents.fetch) {
        ratingEventsSink.add(RatingEvents.fetching);
        List<DemoMovie> demoMoviesList = await _studyFunctions.getDemoMovies();
        demoMoviesSink.add(demoMoviesList);
        ratingEventsSink.add(RatingEvents.moviesLoaded);
      }
    });
  }

  @override
  void dispose() {
    ratingEventsController.close();
    demoMoviesController.close();
  }
}

abstract class MovieRecommendationsState {
  void dispose();
}

class MoviesRecommendationsBloc extends MovieRecommendationsState {
  StreamController<RecommendationEvents> _recommendationEventsStreamController =
      StreamController<RecommendationEvents>.broadcast();
  Stream<RecommendationEvents> get recommendationEventsStream =>
      _recommendationEventsStreamController.stream;
  StreamSink<RecommendationEvents> get recommendationEventsSink =>
      _recommendationEventsStreamController.sink;

  StreamController<List<Recommendations>> _recommendationStreamController =
      StreamController<List<Recommendations>>.broadcast();
  Stream<List<Recommendations>> get recommendationStream =>
      _recommendationStreamController.stream;
  StreamSink<List<Recommendations>> get _recommendationSink =>
      _recommendationStreamController.sink;

  MoviesRecommendationsBloc() {
    recommendationEventsStream.listen((event) async {
      switch (event) {
        case RecommendationEvents.fetch:
          recommendationEventsSink.add(RecommendationEvents.fetching);
          break;
        case RecommendationEvents.fetching:
          List<Recommendations> movieRecommendations =
              await _recommendationFunctions.fetchRecommendations();
          _recommendationSink.add(movieRecommendations);
          recommendationEventsSink
              .add(RecommendationEvents.recommendationLoaded);
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    _recommendationEventsStreamController.close();
    _recommendationStreamController.close();
  }
}

abstract class PhoneVerifyingState {
  void dispose();
}

enum PhoneVerificationEvents {
  start,
  sendingCode,
  CodeSent,
  verifying,
  verified,
  failed
}

class VerificationReports {
  String sendingCode = 'SendingCode';
  String codeSent = 'CodeSent';
  String verifying = 'Verifying';
  String verified = 'Verified';
  String verify = "NowVerify";
  String codeSendingFailed = 'CodeSendingFailed';
  String verificationFailed = 'VerificationFailed';
}

class PhoneVerifyingBloc extends PhoneVerifyingState {
  StreamController<PhoneVerificationEvents> _phoneVerificationEventsController =
      StreamController<PhoneVerificationEvents>.broadcast();
  Stream<PhoneVerificationEvents> get phoneVerificationEventsStream =>
      _phoneVerificationEventsController.stream;
  StreamSink<PhoneVerificationEvents> get phoneVerificationEventsSink =>
      _phoneVerificationEventsController.sink;

  StreamController<String> _phoneVerificationReportController =
      StreamController<String>.broadcast();
  Stream<String> get phoneVerificationReportStream =>
      _phoneVerificationReportController.stream;
  StreamSink<String> get phoneVerificationReportSink =>
      _phoneVerificationReportController.sink;

  PhoneVerifyingBloc() {
    phoneVerificationEventsStream.listen((event) {
      switch (event) {
        case PhoneVerificationEvents.start:
          phoneVerificationEventsSink.add(PhoneVerificationEvents.sendingCode);
          break;
        case PhoneVerificationEvents.sendingCode:
          authFunction.registerByPhone();
          break;
        case PhoneVerificationEvents.CodeSent:
          authFunction.signIn();
          break;
        case PhoneVerificationEvents.failed:
          verifyBloc.phoneVerificationReportSink.add(report.verificationFailed);
          break;
        case PhoneVerificationEvents.verified:
          verifyBloc.phoneVerificationReportSink.add(report.verified);
          break;
        default:
      }
    });
  }
  @override
  void dispose() {
    _phoneVerificationEventsController.close();
    _phoneVerificationReportController.close();
  }
}
