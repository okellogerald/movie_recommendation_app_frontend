import 'package:recommendation/DATA/recommendations.dart';
import 'package:recommendation/STATE/rating_bloc.dart';
import 'package:recommendation/STUDY%20UI/study_moviepage.dart';
import 'package:recommendation/source.dart';

class RecommendationsUI extends StatefulWidget {
  RecommendationsUI({Key? key}) : super(key: key);

  @override
  _RecommendationsUIState createState() => _RecommendationsUIState();
}

class _RecommendationsUIState extends State<RecommendationsUI> {
  MoviesRecommendationsBloc _recommendationBloc = MoviesRecommendationsBloc();
  ValueNotifier<List<String>> repeatedMovieCheck =
      ValueNotifier<List<String>>([]);

  @override
  void initState() {
    _recommendationBloc.recommendationEventsSink
        .add(RecommendationEvents.fetch);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  _buildAppBar() {
    return AppBar(
        backgroundColor: Color(0xFF405775),
        automaticallyImplyLeading: false,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(EvaIcons.arrowBack, color: Colors.white)),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: text('Recommendations',
            color: Colors.white, family: 'Regular', size: 20),
        actions: [
          Icon(EvaIcons.flip2Outline, color: Colors.white),
          SizedBox(width: 20)
        ]);
  }

  _buildBody() {
    return FutureBuilder(
        future: recommendationsFunctions.fetchRecommendations(),
        builder: (context, AsyncSnapshot<List<Recommendations>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Recommendations> allRecommendations = snapshot.data!;
//done so to remove the duplicates that would be found when the screen was popped and pushed again
            return FutureBuilder<List<Recommendations>>(
                future: studyFunction.getUniqueCombinations(allRecommendations),
                builder: (context, secondSnapshot) {
                  List<Recommendations> uniqueRecommendations =
                      secondSnapshot.data!;
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                        constraints: BoxConstraints.expand(),
                        color: Colors.black87,
                        child: GridView.builder(
                            itemCount: uniqueRecommendations.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: .57, crossAxisCount: 2),
                            itemBuilder: (context, index) {
                              Recommendations recommendation =
                                  uniqueRecommendations[index];
                              repeatedMovieCheck.value
                                  .add(recommendation.title);
                              return Container(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      StudyMoviePage(
                                                        recommendation:
                                                            recommendation,
                                                      )));
                                        },
                                        child: Image.network(
                                            recommendation.image)),
                                    text(
                                        recommendation.title.length > 20
                                            ? recommendation.title
                                                    .substring(0, 18) +
                                                '...'
                                            : recommendation.title,
                                        family: 'Regular',
                                        color: Colors.white),
                                    text(recommendation.releasedYear.toString(),
                                        family: 'Regular',
                                        color: Colors.white70),
                                  ],
                                ),
                              );
                            }));
                  } else {
                    return sharedWidget.indicator('loading ...');
                  }
                });
          } else {
            return Container(
                constraints: BoxConstraints.expand(),
                color: Colors.black87,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Color(0xffFB3A3D)),
                    ),
                    SizedBox(height: 40),
                    Text("loading ...",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            fontFamily: 'Medium',
                            fontSize: 20,
                            color: Colors.white70)),
                  ],
                ));
          }
        });
  }
}
