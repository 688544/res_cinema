class Movie {
  final String imdbId, title, year, type, poster, plot, rating, runtime, genre, director, actors, awards, language, country, votes;

  Movie({
    this.imdbId = '', this.title = '', this.year = '', this.type = '',
    this.poster = '', this.plot = '', this.rating = '', this.runtime = '',
    this.genre = '', this.director = '', this.actors = '', this.awards = '',
    this.language = '', this.country = '', this.votes = '',
  });

  factory Movie.fromJson(Map<String, dynamic> j) => Movie(
    imdbId: j['imdbID'] ?? '',
    title: j['Title'] ?? '',
    year: j['Year'] ?? '',
    type: j['Type'] ?? '',
    poster: j['Poster'] ?? '',
    plot: j['Plot'] ?? '',
    rating: j['imdbRating'] ?? 'N/A',
    runtime: j['Runtime'] ?? '',
    genre: j['Genre'] ?? '',
    director: j['Director'] ?? '',
    actors: j['Actors'] ?? '',
    awards: j['Awards'] ?? '',
    language: j['Language'] ?? '',
    country: j['Country'] ?? '',
    votes: j['imdbVotes'] ?? '',
  );

  String toStorageString() => '$imdbId|$title|$year|$rating|$poster';

  static Movie fromStorageString(String s) {
    final p = s.split('|');
    return Movie(
      imdbId: p.length > 0 ? p[0] : '',
      title:  p.length > 1 ? p[1] : '',
      year:   p.length > 2 ? p[2] : '',
      rating: p.length > 3 ? p[3] : '',
      poster: p.length > 4 ? p[4] : '',
    );
  }
}
