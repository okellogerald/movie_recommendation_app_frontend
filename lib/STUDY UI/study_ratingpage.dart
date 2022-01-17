import 'package:recommendation/DATA/movie.dart';
import 'package:recommendation/STATE/rating_bloc.dart';
import 'package:recommendation/STUDY%20UI/study_recommendations.dart';
import 'package:recommendation/source.dart';

class StudyRatingpage extends StatefulWidget {
  const StudyRatingpage({Key? key}) : super(key: key);

  @override
  _StudyRatingpageState createState() => _StudyRatingpageState();
}

class _StudyRatingpageState extends State<StudyRatingpage> {
  final ValueNotifier<int> rateIndex = ValueNotifier<int>(-1);
  final ValueNotifier<int> percentIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> indexValue = ValueNotifier<int>(-66);
  final moviesRating = MoviesRating();
  int totalNumberofMovies = 0;

  @override
  void initState() {
    moviesRating.ratingEventsSink.add(RatingEvents.fetch);
    getTotalNumberofDemoMovies();
    super.initState();
  }

  getTotalNumberofDemoMovies() async {
    int totalNumberofDocs = await studyFunction.getNumberOfDocs('Demo Movies');
    setState(() {
      totalNumberofMovies = totalNumberofDocs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: percentIndex,
        builder: (context, child, snapshot) {
          return Scaffold(
              backgroundColor: Color(0xFF202024),
              appBar: percentIndex.value == totalNumberofMovies
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(0),
                      child: Container(),
                    )
                  : _buildPercentIndicator(),
              body: percentIndex.value < totalNumberofMovies
                  ? Padding(
                      padding: EdgeInsets.only(left: 10, right: 20, top: 20),
                      child: Column(
                        children: [
                          _buildMoviesDetails(),
                          _anotherRatingScale(),
                          _buildBottomPrevNext()
                        ],
                      ),
                    )
                  : _buildFinishedRatingBody());
        });
  }

  _buildPercentIndicator() {
    return AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Color(0xFF405775),
        centerTitle: true,
        title: ValueListenableBuilder<int>(
            valueListenable: percentIndex,
            builder: (context, child, snapshot) {
              return text(
                  '${((percentIndex.value / totalNumberofMovies) * 100).toStringAsFixed(0)} %',
                  size: 22,
                  color: Colors.white);
            }));
  }

  _buildMoviesDetails() {
    return StreamBuilder<RatingEvents>(
        stream: moviesRating.ratingEventsStream,
        builder: (context, eventsSnapshot) {
          return StreamBuilder<List<DemoMovie>>(
              stream: moviesRating.demoMoviesStream,
              builder: (context, moviesSapshot) {
                if (eventsSnapshot.data == RatingEvents.fetching ||
                    eventsSnapshot.data == RatingEvents.fetch) {
                  return Container(
                    height: 700,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFFEDEDED)),
                          ),
                          SizedBox(height: 40),
                          text('fetching movies...', color: Colors.white)
                        ]),
                  );
                } else if (eventsSnapshot.data == RatingEvents.moviesLoaded) {
                  print('MOVIES LOADED');
                  List<DemoMovie>? demoMovie = moviesSapshot.data;
                  return ValueListenableBuilder<int>(
                      valueListenable: percentIndex,
                      builder: (context, child, snapshot) {
                        return SizedBox(
                          height: 440,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              itemCount:
                                  demoMovie?.length ?? totalNumberofMovies,
                              scrollDirection: Axis.horizontal,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 340,
                                        width: 224,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.white54)),
                                        child: Image.network(
                                            demoMovie?[percentIndex.value]
                                                    .image ??
                                                '',
                                            fit: BoxFit.cover),
                                      ),
                                      SizedBox(height: 20),
                                      text(
                                          demoMovie?[percentIndex.value]
                                                  .title ??
                                              '',
                                          alignment: TextAlign.center,
                                          family: 'Medium',
                                          color: Colors.white,
                                          size: 26),
                                      text(
                                          'Released: ${demoMovie?[percentIndex.value].releasedYear ?? ''}',
                                          family: 'Light',
                                          color: Colors.white70,
                                          size: 20)
                                    ],
                                  ),
                                );
                              }),
                        );
                      });
                }
                return CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xffFB3A3D)),
                );
              });
        });
  }

  _anotherRatingScale() {
    return Expanded(
        child: StreamBuilder<RatingEvents>(
            stream: moviesRating.ratingEventsStream,
            builder: (context, snapshot) {
              if (snapshot.data == RatingEvents.moviesLoaded) {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 50,
                          child: ListView.builder(
                              itemCount: 3,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    rateIndex.value = index + 1;
                                    indexValue.value = index;
                                  },
                                  child: ValueListenableBuilder<int>(
                                      valueListenable: indexValue,
                                      builder: (context, child, snapshot) {
                                        return _buildOptionTile(
                                          index == 0
                                              ? 0
                                              : index == 1
                                                  ? 1
                                                  : 2,
                                          index == indexValue.value,
                                          index == 0
                                              ? 'Nah'
                                              : index == 1
                                                  ? 'Average'
                                                  : 'Good',
                                        );
                                      }),
                                );
                              })),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          rateIndex.value = 4;
                          indexValue.value = 3;
                        },
                        child: ValueListenableBuilder(
                          valueListenable: indexValue,
                          builder: (BuildContext context, dynamic value,
                              Widget? child) {
                            return _buildOptionTile(
                                3, indexValue.value == 3, 'Awesome');
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      ValueListenableBuilder<int>(
                          valueListenable: indexValue,
                          builder: (context, child, snapshot) {
                            return Container(
                              alignment: Alignment.centerRight,
                              child: MaterialButton(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  onPressed: () {
                                    indexValue.value = 100;
                                    rateIndex.value = 0;
                                  },
                                  color: indexValue.value == 100
                                      ? Color(0xffF88379)
                                      : Colors.grey.withOpacity(.8),
                                  child: text('skip')),
                            );
                          }),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            }));
  }

  _buildOptionTile(int number, bool check, String option) {
    Color selectedColor = Color(0xffF88379);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: check ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
              width: 1, color: check ? selectedColor : Colors.white30)),
      child: text(option, color: Colors.white70, family: 'Akaya'),
    );
  }

  _buildRatingScale() {
    return Expanded(
      child: StreamBuilder<RatingEvents>(
          stream: moviesRating.ratingEventsStream,
          builder: (context, snapshot) {
            if (snapshot.data == RatingEvents.moviesLoaded) {
              return ValueListenableBuilder<int>(
                  valueListenable: rateIndex,
                  builder: (context, child, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            text(
                                '${rateIndex.value == -1 ? '-' : rateIndex.value + 1} /5',
                                size: 22,
                                color: Colors.white),
                          ],
                        ),
                        Container(
                          height: 50,
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5),
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return IconButton(
                                    onPressed: () {
                                      rateIndex.value = index;
                                    },
                                    icon: Icon(
                                      rateIndex.value == -1
                                          ? EvaIcons.starOutline
                                          : rateIndex.value >= index
                                              ? EvaIcons.star
                                              : EvaIcons.starOutline,
                                    ),
                                    color: rateIndex.value == -1 ||
                                            rateIndex.value < index
                                        ? Colors.grey
                                        : Colors.orange);
                              }),
                        ),
                        SizedBox(height: 30),
                        Center(
                          child: MaterialButton(
                              elevation: 0,
                              onPressed: () {
                                /*    StudyFunctions().addDemoMovieRating(
                                  userId: 12,
                                  rating: 0,
                                ); */
                                rateIndex.value = -1;
                                percentIndex.value += 1;
                              },
                              color: Color(0xff444348),
                              child: text('I haven\'t watched this',
                                  color: Colors.white70, family: 'Regular')),
                        ),
                      ],
                    );
                  });
            } else {
              return Container();
            }
          }),
    );
  }

  _buildBottomPrevNext() {
    return StreamBuilder<RatingEvents>(
        stream: moviesRating.ratingEventsStream,
        builder: (context, snapshot) {
          if (snapshot.data == RatingEvents.moviesLoaded) {
            return Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: ButtonTheme(
                height: 45,
                minWidth: double.infinity,
                child: ValueListenableBuilder<int>(
                    valueListenable: rateIndex,
                    builder: (context, child, snapshot) {
                      if (rateIndex.value < 0) {
                        return Container();
                      } else {
                        return MaterialButton(
                          color: Color(0xffECD5BB),
                          onPressed: () {
                            if (rateIndex.value == -1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.white,
                                      content: text(
                                          'Only skipping or rating allowed.',
                                          color: Colors.black54)));
                            } else {
                              studyFunction.addDemoMovieRating(
                                rating: rateIndex.value,
                              );
                              rateIndex.value = -1;
                              percentIndex.value += 1;
                              indexValue.value = -66;
                            }
                          },
                          child: text('Next'),
                        );
                      }
                    }),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  _buildFinishedRatingBody() {
    String backgroundImage =
        'https://firebasestorage.googleapis.com/v0/b/movie-recommendation-126.appspot.com/o/bcff60b0813436b46db30c54f23d7c90%20(3).jpg?alt=media&token=548cd3c2-cc2d-4630-a420-11775016a79a';
    return Container(
      padding: EdgeInsets.only(left: 10, right: 20, top: 20),
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover, image: NetworkImage(backgroundImage)),
      ),
      child: FutureBuilder(
          future: Future.delayed(Duration(seconds: 5)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /* CircularPercentIndicator(
                            radius: 90.0,
                            lineWidth: 2.0,
                            percent: .5,
                            center: Text(
                                "${'nah'}%",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                    fontFamily: 'Regular',
                                    fontSize: 16,
                                    color: Colors.white)),
                            progressColor: Colors.white,
                          ), */
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xffFB3A3D)),
                          ),
                          SizedBox(height: 40),
                          Text("sending data ...",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  fontFamily: 'Medium',
                                  fontSize: 20,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  text('Thanks for your participation in this study.',
                      size: 30,
                      color: Colors.white.withOpacity(.9),
                      family: 'Medium'),
                  SizedBox(height: 20),
                  text(
                      'Would you like see your movie recommendations from the results of this study?',
                      family: 'Regular',
                      color: Colors.white70),
                  SizedBox(height: 30),
                  ButtonTheme(
                    height: 45,
                    minWidth: double.infinity,
                    child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecommendationsUI()));
                        },
                        color: Colors.white,
                        child: text('Go to Recommendations',
                            color: Colors.black87)),
                  ),
                  SizedBox(height: 10)
                ],
              );
            }
          }),
    );
  }
}
