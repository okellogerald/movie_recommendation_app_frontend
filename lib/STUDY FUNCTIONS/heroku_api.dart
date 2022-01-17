import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:recommendation/DATA/recommendations.dart';
import 'package:recommendation/source.dart';

class RecommendationsFunctions {
  List<Recommendations> recommendationList = [];

  Future<List<Recommendations>> fetchRecommendations() async {
    var firestore = FirebaseFirestore.instance.collection('Demo Movies');
    var response = await http.get(
      Uri.parse('https://recommender-system-study.herokuapp.com/'),
    );

    var jsonResponse = jsonDecode(response.body);
    String userId = await studyFunction.getUserId();
    int id = int.parse(userId) - 1000 + 1;
    String _index = id.toString();
    Map results = jsonResponse['results'][_index];
    List movieIds = results['MovieIds'];
    List recommendations = results['Recommendations'];

    for (int index = 0; index < recommendations.length; index++) {
      if (recommendations[index] >= 3.0) {
        String docName = (movieIds[index] + 2220).toString();
        DocumentSnapshot doc = await firestore.doc(docName).get();
        recommendationList.add(Recommendations(
          movieId: doc['movieId'],
            image: doc['image'],
            releasedYear: doc['releasedYear'],
            title: doc['title'],
            tmdbId: doc['tmdbId'],
            trailerLink: doc['trailerLink']));
      }
    }
    return recommendationList;
  }
}
