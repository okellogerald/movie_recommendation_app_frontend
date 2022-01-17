class Movie {
  late String title, description, releaseDate, image, tagline, runtime;
  late int id;
  late List genresIds, languages, cast;

  Movie(
      {required this.description,
      required this.genresIds,
      required this.id,
      required this.image,
      required this.runtime,
      required this.cast,
      required this.tagline,
      required this.languages,
      required this.releaseDate,
      required this.title});
}

class DemoMovie {
  late String title, trailerLink, image;
  late int releasedYear, movieId, tmdbId;

  DemoMovie(
      {required this.image,
      required this.movieId,
      required this.releasedYear,
      required this.title,
      required this.tmdbId,
      required this.trailerLink});
}
