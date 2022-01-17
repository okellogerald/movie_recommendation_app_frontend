import 'package:recommendation/DATA/movie.dart';
import 'package:recommendation/DATA/recommendations.dart';
import 'package:recommendation/source.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class StudyMoviePage extends StatefulWidget {
  late final Recommendations movie;
   StudyMoviePage({required Recommendations recommendation}) {
    movie = recommendation;
  }

  @override
  _StudyMoviePageState createState() => _StudyMoviePageState();
}

class _StudyMoviePageState extends State<StudyMoviePage> {
  ValueNotifier<bool> showTrailer = ValueNotifier<bool>(false);
  ValueNotifier<bool> applyOpacity = ValueNotifier<bool>(false);
  ValueNotifier<int> optionIndex = ValueNotifier<int>(0);

  late YoutubePlayerController _controller, _inactiveController;

  late PlayerState playerState;
  late YoutubeMetaData videoMetaData;
  double volume = 100;
  bool muted = false;
  bool isPlayerReady = false;

  String convertYoutubeUrlToId(String link) {
    String id = link.replaceAll("https://www.youtube.com/watch?v=", "");
    return id;
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: convertYoutubeUrlToId(widget.movie.trailerLink),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: true,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;

    _inactiveController = YoutubePlayerController(
      initialVideoId: convertYoutubeUrlToId(widget.movie.trailerLink),
      flags: const YoutubePlayerFlags(
        mute: true,
        autoPlay: false,
        disableDragSeek: false,
        loop: true,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  void listener() {
    if (isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        playerState = _controller.value.playerState;
        videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Recommendations movie = widget.movie;
    return WillPopScope(
      onWillPop: () async {
        //    _controller.dispose();
        return true;
      },
      child: Scaffold(
          backgroundColor: Color(0xFF202024),
          appBar: _buildAppBar(),
          body: _buildBody(movie, context)),
    );
  }

  _buildBody(Recommendations movie, BuildContext) {
    return FutureBuilder<Movie>(
        future: tmdb.getMovieById(widget.movie.tmdbId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            late Movie? movieDetails;
            movieDetails = snapshot.data;
            return Stack(
              children: [
                ValueListenableBuilder<bool>(
                    valueListenable: applyOpacity,
                    builder: (context, child, snapshot) {
                      return Opacity(
                        opacity: applyOpacity.value ? .5 : 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: ListView(
                            children: [
                              SizedBox(height: 20),
                              _buildMovieTrailer(),
                              _buildMovieDetails(movie: movieDetails),
                              Padding(
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  child: text(movieDetails?.tagline,
                                      size: 16,
                                      family: 'Akaya',
                                      color: Colors.white)),
                              _buildMovieGenres(movie: movieDetails),
                              _buildOverview(movie: movieDetails),
                              _buildCast(movie: movieDetails)
                            ],
                          ),
                        ),
                      );
                    }),
                _buildBottomButton(context, movie)
              ],
            );
          } else {
            _buildTopDetails(movie);
          }
          return sharedWidget.indicator('loading');
        });
  }

  _buildBottomButton(BuildContext context, Recommendations movie) {
    return Positioned(
        bottom: 0,
        child: GestureDetector(
          onTap: () {
            applyOpacity.value = !applyOpacity.value;
            _showRatingOptions(context, movie);
          },
          child: Container(
              height: 50,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              color: Color(0xffECD5BB),
              child: text('Rate this movie')),
        ));
  }

  _buildMovieGenres({required Movie? movie}) {
    List<Widget> list = [text('hello')];
    return Wrap(
        children: movie?.genresIds
                .map((e) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    margin: EdgeInsets.only(top: 10, right: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                            width: 0.5, color: Colors.grey.withOpacity(.4))),
                    child: text(e['name'],
                        family: 'Light', size: 16, color: Colors.white70)))
                .toList()
                .cast<Widget>() ??
            list);
  }

  _buildOverview({required Movie? movie}) {
    print(movie?.languages);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Column(children: [
            text('Official Language', color: Colors.white, size: 20),
            SizedBox(height: 5),
            text(movie?.languages[0]['name'],
                color: Colors.white70, size: 18, family: 'Light')
          ]),
          Column(children: [
            text('Duration', color: Colors.white, size: 20),
            SizedBox(height: 5),
            text(movie?.runtime.toString(),
                color: Colors.white70, size: 18, family: 'Light')
          ])
        ]),
        SizedBox(height: 30),
        text('Overview', color: Colors.white, size: 22),
        SizedBox(height: 10),
        text(movie?.description,
            size: 18, family: 'Regular', color: Colors.grey),
        SizedBox(height: 20),
      ],
    );
  }

  _buildMovieTrailer() {
    return ValueListenableBuilder(
      valueListenable: showTrailer,
      builder: (context, snapshot, child) {
        if (showTrailer.value) {
          return Container(
            height: 200,
            margin: EdgeInsets.only(bottom: 20),
            child: Stack(
              children: [
                Container(
                  constraints: BoxConstraints.expand(),
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    onReady: () {
                      _controller.addListener(listener);
                    },
                  ),
                ),
                Positioned(
                    right: 5,
                    child: ButtonTheme(
                      minWidth: 40,
                      child: MaterialButton(
                          onPressed: () {
                            _controller.pause();
                            showTrailer.value = !showTrailer.value;
                          },
                          color: Colors.white70,
                          child: Icon(
                            EvaIcons.close,
                            color: Colors.black,
                          )),
                    )),
              ],
            ),
          );
        } else {
          return Container(
              height: 200,
              margin: EdgeInsets.only(bottom: 20),
              child: Stack(
                children: [
                  YoutubePlayer(
                    controller: _inactiveController,
                    showVideoProgressIndicator: false,
                    onReady: () {},
                  ),
                  /*   Image.network(
                      'http://prod-upp-image-read.ft.com/886ee184-c838-11e6-9043-7e34c07b46ef',
                      width: double.infinity,
                      fit: BoxFit.cover), */
                  Container(
                      constraints: BoxConstraints.expand(),
                      color: Colors.black.withOpacity(.35),
                      alignment: Alignment.center,
                      child: MaterialButton(
                          color: Colors.white,
                          onPressed: () {
                            showTrailer.value = true;
                          },
                          child: text('View Trailer')))
                ],
              ));
        }
      },
    );
  }

  _buildAppBar() {
    return AppBar(
      leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(EvaIcons.arrowBack)),
      backgroundColor: Color(0xFF405775),
      elevation: 0,
      actions: [Icon(EvaIcons.bookmarkOutline), SizedBox(width: 20)],
    );
  }

  _buildTopDetails(Recommendations movie) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Image.network(movie.image, height: 250, fit: BoxFit.contain)),
      Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(movie.title,
                  family: 'Medium', size: 30, color: Colors.white),
              text(movie.releasedYear.toString(),
                  family: 'Regular', size: 18, color: Colors.white70)
            ],
          ),
        ),
      )
    ]);
  }

  _buildCast({required Movie? movie}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text('Cast', color: Colors.white, size: 22),
            IconButton(
                color: Colors.grey.withOpacity(.2),
                onPressed: () {},
                icon: Icon(EvaIcons.arrowForward, color: Colors.white70))
          ],
        ),
        SizedBox(
          height: 285,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                Map<String, dynamic> cast = movie?.cast[index];
                String castName = cast['name'];

                String male =
                    'https://i.pinimg.com/236x/95/77/83/957783cdb9cb73ef4ebac7916fbd6b03.jpg';
                String female =
                    'https://i.pinimg.com/236x/a0/59/a3/a059a37b6fb47d9526486669497e10cd.jpg';
                return Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      cast['profile_path'] == null
                          ? FutureBuilder<Map<String, dynamic>>(
                              future: tmdb.detectGender(
                                  name: castName.substring(
                                      0, castName.indexOf(' '))),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  String gender = snapshot.data?['gender'];
                                  return Container(
                                    height: 215,
                                    alignment: Alignment.bottomLeft,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(gender == 'male'
                                                ? male
                                                : female))),
                                    child: Container(
                                      color: Colors.black,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      margin:
                                          EdgeInsets.only(bottom: 5, left: 5),
                                      child: text('Image Unavailable',
                                          family: 'Regular',
                                          size: 18,
                                          color: Colors.white70),
                                    ),
                                  );
                                } else {
                                  return Container(
                                      height: 215,
                                      width: 180,
                                      alignment: Alignment.center,
                                      color: Colors.black.withOpacity(.5),
                                      child: text('Image Unavailable',
                                          family: 'Medium',
                                          size: 18,
                                          color: Colors.white));
                                }
                              })
                          : Image.network(
                              'http://image.tmdb.org/t/p/w500/' +
                                  cast['profile_path'],
                              height: 215,
                              width: 180,
                              fit: BoxFit.fill),
                      text(cast['name'],
                          color: Colors.white, size: 18, family: 'Regular'),
                      text('As ' + cast['character'],
                          color: Colors.white70, size: 16, family: 'Akaya'),
                    ],
                  ),
                );
              }),
        ),
        SizedBox(height: 60),
      ],
    );
  }

  _buildMovieDetails({required Movie? movie}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Container(
        height: 180,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: NetworkImage(widget.movie.image))),
      )),
      Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(movie?.title,
                  family: 'Medium', size: 30, color: Colors.white),
              text(movie?.releaseDate,
                  family: 'Regular', size: 18, color: Colors.white70)
            ],
          ),
        ),
      )
    ]);
  }

  _showRatingOptions(BuildContext context, Recommendations movie) {
    List<String> rates = ['Nah', 'Average', 'Good', 'Awesome'];
    List<int> ratings = [1, 2, 3, 4];
    Scaffold.of(context).showBottomSheet((context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: rates
            .map((rate) => GestureDetector(
                  onTap: () async {
                    optionIndex.value = ratings[rates.indexOf(rate)];
                    await studyFunction
                        .rateMovieFromRecommendation(
                            movieId: widget.movie.movieId,
                            rate: ratings[rates.indexOf(rate)])
                        .then((value) {
                      Navigator.pop(context);
                      applyOpacity.value = !applyOpacity.value;
                    });
                  },
                  child: ValueListenableBuilder<int>(
                      valueListenable: optionIndex,
                      builder: (context, child, snapshot) {
                        return Container(
                          decoration: BoxDecoration(
                              border: Border.fromBorderSide(
                                  BorderSide(color: Colors.grey, width: .05))),
                          child: ListTile(
                            title: text(rate, color: Colors.black),
                            tileColor: optionIndex.value !=
                                    ratings[rates.indexOf(rate)]
                                ? Colors.white
                                : Color(0xffF88379),
                          ),
                        );
                      }),
                ))
            .toList()));
  }
}
