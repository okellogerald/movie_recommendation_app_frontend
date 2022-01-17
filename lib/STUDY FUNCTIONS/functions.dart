import 'dart:io';
import 'package:path/path.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recommendation/DATA/movie.dart';
import 'package:recommendation/DATA/recommendations.dart';
import 'package:recommendation/STATE/rating_bloc.dart';
import 'package:recommendation/source.dart';
import 'package:sqflite/sqflite.dart';

//Firebase functions
class StudyFunctions {
  var _instance = FirebaseFirestore.instance;

  Future<List<DemoMovie>> getDemoMovies() async {
    List<DemoMovie> moviesListFromFirebase;

    List<DemoMovie> moviesList =
        await _instance.collection('Demo Movies').get().then((value) {
      List<DemoMovie> moviesList = [];
      value.docs.forEach((element) {
        Map<String, dynamic> movieDetails = element.data();

        moviesList.add(DemoMovie(
            image: movieDetails['image'],
            movieId: movieDetails['movieId'],
            releasedYear: movieDetails['releasedYear'],
            title: movieDetails['title'],
            tmdbId: movieDetails['tmdbId'],
            trailerLink: movieDetails['trailerLink']));
      });

      return moviesList;
    });

    moviesListFromFirebase = moviesList;
    return moviesListFromFirebase;
  }

  Future<int> getNumberOfDocs(collection) async {
    int totalNumberofDocs = 0;
    await _instance.collection(collection).get().then((value) {
      totalNumberofDocs = value.size;
    });

    return totalNumberofDocs;
  }

  addDemoMovies(
      {required String trailerLink,
      required String image,
      required String title,
      required int tmdbId,
      required int releasedYear}) async {
    int totalNumberofDocs = await getNumberOfDocs('Demo Movies');

    int docName = 2220 + totalNumberofDocs;
    String textDocName = docName.toString();
    await _instance.collection('Demo Movies').doc(textDocName).set({
      'image': image,
      'trailerLink': trailerLink,
      'title': title,
      'tmdbId': tmdbId,
      'movieId': docName,
      'releasedYear': releasedYear,
    });
  }

  Future rateMovieFromRecommendation(
      {required int movieId, required int rate}) async {
    int ratingDocName = movieId - 2220 + 1000;
    int ratingIndex = movieId - 2220;

    var ratingDoc = await _instance
        .collection('Ratings')
        .doc(ratingDocName.toString())
        .get();
    List ratings = ratingDoc['ratings'];
    ratings[ratingIndex] = rate;
    await _instance
        .collection('Ratings')
        .doc(ratingDocName.toString())
        .set({'ratings': ratings});
  }

  Future<List<Recommendations>> getUniqueCombinations(
      List<Recommendations> recommendations) async {
    List<Recommendations> uniqueRecommendations = [];
    List<String> titles = [];
    recommendations.forEach((element) {
      if (titles.contains(element.title)) {
      } else {
        uniqueRecommendations.add(element);
        titles.add(element.title);
      }
    });

    return uniqueRecommendations;
  }

  Future<String> addUserDetails(
      {required String name, required String phoneNumber}) async {
    late String report;
    int totalNumberofUsers = await getNumberOfDocs('Users');
    int userId = totalNumberofUsers;
    var user = await _instance.collection('Users').doc(phoneNumber).get();
    if (user.exists) {
      report = 'User Existis';
    } else {
      _instance.collection('Users').doc(phoneNumber).set(
          {'Phone Number': phoneNumber, 'Username': name, 'User Id': userId});
      report = 'Gone Well';
    }
    return report;
  }

  Future<String> getUserId() async {
    late String userId;
    String phoneNumber = await sql.getValueFromDatabase('PhoneNumber');
    var userDoc = await _instance.collection('Users').doc(phoneNumber).get();
    userId = userDoc['User Id'].toString();
    return userId;
  }

  addDemoMovieRating({required int rating}) async {
    String docName = await getUserId();
    var ratingDoc =
        await _instance.collection('Ratings').doc(docName.toString()).get();
    if (ratingDoc.exists) {
      List ratings = ratingDoc.data()?['ratings'];
      ratings.add(rating);
      await _instance
          .collection('Ratings')
          .doc(docName.toString())
          .update({'ratings': ratings});
    } else {
      await _instance.collection('Ratings').doc(docName.toString()).set({
        'ratings': [rating],
      });
    }
  }
}

//AuthenticationFunctions
class AuthFunctions {
  FirebaseAuth _auth = FirebaseAuth.instance;
  registerByPhone() async {
    String phoneNumber = await sql.getValueFromDatabase('PhoneNumber');
    //callbacks in the code below are called when the specified event has occurred and what we receive is
    //placed in the brackets, how we decide to use it for in the curly braces.

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          print(credential);
        },
        verificationFailed: (error) async {
          print(error);
        },
        timeout: Duration(seconds: 60),
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (id) {});
  }

  codeSent(String verificationId, int? forceResendToken) {
    sql.updateDataInDatabase('VerificationId',
        verificationId); //we save the id because it is required when signing in the user. they are generated uniquely in every request
    verifyBloc.phoneVerificationReportSink.add(report.codeSent);
  }

  signIn() async {
    verifyBloc.phoneVerificationReportSink.add(report.verifying);
    String id = await sql.getValueFromDatabase('VerificationId');
    String otp = await sql.getValueFromDatabase('Otp');

    print('in the sign in');
    print(id);
    print(otp);

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      verifyBloc.phoneVerificationEventsSink
          .add(PhoneVerificationEvents.verified);
    } catch (e) {
      verifyBloc.phoneVerificationEventsSink
          .add(PhoneVerificationEvents.failed);
      print(e);
    }
  }
}

class SQLiteFunctions {
  String name = 'WhatNextTrialUsers.db';
  createDatabase() async {
    Directory directory = await getApplicationSupportDirectory();
    String path = join(directory.path, name);

    await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          '''CREATE TABLE UserDetails (id INTEGER PRIMARY KEY, Name TEXT, VerificationId TEXT, PhoneNumber TEXT, Otp TEXT)''');
    });
  }

  insertDataIntoDatabase(username, verificationId, phoneNumber, otp) async {
    Directory directory = await getApplicationSupportDirectory();
    String path = join(directory.path, name);
    Database database = await openDatabase(path);

    await database.rawInsert(
        'INSERT Into UserDetails (Name,VerificationId,PhoneNumber,Otp) VALUES(?,?,?,?)',
        [username, verificationId, phoneNumber, otp]);
  }

  updateDataInDatabase(String whatChange, String value) async {
    Directory directory = await getApplicationSupportDirectory();
    String path = join(directory.path, name);
    Database database = await openDatabase(path);

    await database.rawUpdate(
        'UPDATE UserDetails SET $whatChange = ? WHERE id = ?', [value, 1]);
  }

  Future<String> getValueFromDatabase(String whatValue) async {
    Directory directory = await getApplicationSupportDirectory();
    String path = join(directory.path, name);
    Database database = await openDatabase(path);
    String table = 'UserDetails';
    String value = '';

    switch (whatValue) {
      case 'PhoneNumber':
        List<Map<String, dynamic>> data = await database.query(table,
            columns: ['PhoneNumber'], where: 'id = ?', whereArgs: [1]);
        value = data[0]['PhoneNumber'];
        break;

      case 'VerificationId':
        List<Map<String, dynamic>> data = await database.query(table,
            columns: ['VerificationId'], where: 'id = ?', whereArgs: [1]);
        value = data[0]['VerificationId'];
        break;

      case 'Name':
        List<Map<String, dynamic>> data = await database.query(table,
            columns: ['Name'], where: 'id = ?', whereArgs: [1]);
        value = data[0]['Name'];
        break;

      case 'Otp':
        List<Map<String, dynamic>> data = await database.query(table,
            columns: ['Otp'], where: 'id = ?', whereArgs: [1]);
        value = data[0]['Otp'];
        break;
      default:
    }
    return value;
  }
}
