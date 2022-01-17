class Recommendations {
  late String title, trailerLink, image;
  late int releasedYear, tmdbId, movieId;

  Recommendations(
      {required this.image,
      required this.releasedYear,
      required this.title,
      required this.movieId,
      required this.tmdbId,
      required this.trailerLink});
}
