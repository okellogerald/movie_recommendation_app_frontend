import 'package:recommendation/STUDY%20UI/study_ratingpage.dart';
import 'package:recommendation/source.dart';

class StudyHomepage extends StatelessWidget {
  const StudyHomepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202024),
      body: Column(
        children: [_buildMoviesPoster(), _buildGetStartedTexts(context)],
      ),
    );
  }

  _buildMoviesPoster() {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Expanded(
              child: GridView.count(
            crossAxisCount: 2,
            scrollDirection: Axis.vertical,
            childAspectRatio: 0.7,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Image.network(
                  'https://upload.wikimedia.org/wikipedia/en/thumb/a/af/Wrath-of-man.jpg/220px-Wrath-of-man.jpg',
                  fit: BoxFit.cover),
              Image.network(
                  'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/qBxMhcmNnFniuDAZTKEHcSgKtsn.jpg',
                  fit: BoxFit.cover)
            ],
          )),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        'https://occ-0-1068-1723.1.nflxso.net/dnm/api/v6/E8vDc_W8CLv7-yMQu8KMEC7Rrr8/AAAABXRFIistmofJNQDn72a00coyhMezij0AxxnCVYbVh6ZwaeTdrmFhbuIJTMviKuFEbO0kaB56PFcJJgTKdidg8ZRlJMkX.jpg?r=689'))),
          ))
        ],
      ),
    );
  }

  _buildGetStartedTexts(BuildContext context) {
    return Expanded(
        child: Container(
            alignment: Alignment.bottomLeft,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text('Movies Recommender System',
                    size: 22, color: Colors.white),
                SizedBox(height: 10),
                text(
                    'A study on the effectiveness of Collaborative Filtering technique on providing recommendations to users based on the latent features shared with other users.',
                    size: 20,
                    family: 'Regular',
                    color: Colors.white70),
                Expanded(
                    child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 20),
                  child: MaterialButton(
                    minWidth: 350,
                    height: 45,
                    onPressed: () async {
                      /*     Recommendations recommendation = Recommendations(
                          releasedYear: 2016,
                          title: 'Ballerina',
                          tmdbId: 342473,
                          image:
                              'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/qBxMhcmNnFniuDAZTKEHcSgKtsn.jpg',
                          trailerLink:
                              'https://www.youtube.com/watch?v=a166o4om9OA'); */
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudyRatingpage()));
                    },
                    color: Color(0xffECD5BB),
                    child: text('Get Started', color: Colors.black),
                  ),
                ))
              ],
            )));
  }
}
