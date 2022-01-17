import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recommendation/DATA/movie.dart';

class TmdbApiFunctions {
  final String apiKey = '12d83915c95e7ead1b9ff455aa044b47';
  final String accessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxMmQ4MzkxNWM5NWU3ZWFkMWI5ZmY0NTVhYTA0NGI0NyIsInN1YiI6IjYwY2Y4YTkyNjI5YjJjMDA3OGYzNmRmNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.rKwBZWiggOF-dj7NwOKQQ5dkh6VhMqVP328rRjjdizE';

  Future<Movie> getMovieById(int id) async {
    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json;charset=utf-8',
    };
    var res = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/movie/$id?api_key=$apiKey&language=en-US&append_to_response=credits'),
        headers: headers);

    Map<String, dynamic> response = jsonDecode(res.body);

    late Movie movie;
    movie = Movie(
        description: response['overview'],
        genresIds: response['genres'],
        tagline: response['tagline'],
        cast: response['credits']['cast'],
        runtime: convertMinutesToHoursAndMinutes(response['runtime']),
        languages: response['spoken_languages'],
        id: response['id'],
        image: 'http://image.tmdb.org/t/p/w500/' + response['backdrop_path'],
        releaseDate: response['release_date'],
        title: response['title']);

    return movie;
  }

  String convertMinutesToHoursAndMinutes(int mins) {
    late String runtime;
    int hours = mins ~/ 60;
    if (hours == 0) {
      runtime = 'mins mins';
    } else {
      int minutes = mins - (hours * 60);
      if (minutes == 0) {
        if (hours == 1) {
          runtime = '$hours hr';
        } else {
          runtime = '$hours hrs';
        }
      } else {
        if (hours == 1) {
          runtime = '$hours hr & $minutes mins';
        } else {
          runtime = '$hours hrs & $minutes mins';
        }
      }
    }
    return runtime;
  }

  Future<Map<String, dynamic>> detectGender({required String name}) async {
    String apiKey = '61127416f08e9c6d6d0d4a52';
    var response = await http
        .get(Uri.parse('https://genderapi.io/api/?name=$name&key=$apiKey'));
    return jsonDecode(response.body);
  }

 
}
