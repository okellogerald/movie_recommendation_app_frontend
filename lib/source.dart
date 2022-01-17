export 'package:flutter/material.dart';
export 'package:provider/provider.dart';
export 'package:eva_icons_flutter/eva_icons_flutter.dart';
export 'package:ionicons/ionicons.dart';

import 'package:recommendation/STATE/movie_page_bloc.dart';
import 'package:recommendation/STATE/rating_bloc.dart';
import 'package:recommendation/STUDY%20FUNCTIONS/heroku_api.dart';
import 'package:recommendation/STUDY%20FUNCTIONS/shared_widget.dart';
import 'package:recommendation/STUDY%20FUNCTIONS/tmdb_api.dart';
import 'STUDY FUNCTIONS/functions.dart';

SQLiteFunctions sql = SQLiteFunctions();
PhoneVerifyingBloc verifyBloc = PhoneVerifyingBloc();
VerificationReports report = VerificationReports();
AuthFunctions authFunction = AuthFunctions();
TmdbApiFunctions tmdb = TmdbApiFunctions();
StudyFunctions studyFunction = StudyFunctions();
MoviePageBloc movieBloc = MoviePageBloc();
SharedWidgets sharedWidget = SharedWidgets();
RecommendationsFunctions recommendationsFunctions = RecommendationsFunctions();
Function text = SharedWidgets().myCustomizedText;
