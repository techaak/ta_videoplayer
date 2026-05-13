enum TaVideoSourceType { network, youtube, asset, file }

class TaVideoSource {
  final String url;
  final TaVideoSourceType type;
  final String? id;
  final Map<String, String>? headers;

  TaVideoSource._({
    required this.url,
    required this.type,
    this.id,
    this.headers,
  });

  factory TaVideoSource.network(String url, {Map<String, String>? headers}) {
    return TaVideoSource._(
        url: url, type: TaVideoSourceType.network, headers: headers);
  }

  factory TaVideoSource.youtubeId(String id) {
    return TaVideoSource._(
        url: 'https://www.youtube.com/watch?v=$id',
        type: TaVideoSourceType.youtube,
        id: id);
  }

  factory TaVideoSource.asset(String path) {
    return TaVideoSource._(url: path, type: TaVideoSourceType.asset);
  }

  factory TaVideoSource.file(String path) {
    return TaVideoSource._(url: path, type: TaVideoSourceType.file);
  }
}
