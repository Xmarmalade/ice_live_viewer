class LinkParser {
  /// Parses a link and returns its id.
  String getRoomId(String url) {
    String path = url.split("/").last;
    for (var i = 0; i < path.length; i++) {
      if (path[i] == "?") {
        return path.substring(0, i);
      }
    }
    return path;
  }

  /// Parses a link and standardizes it.
  String standardizeUrl(String url) {
    String roomId = getRoomId(url);
    if (url.contains("huya.com")) {
      return "https://m.huya.com/$roomId";
    } else if (url.contains("bilibili.com")) {
      return "https://live.bilibili.com/$roomId";
    } else {
      return '';
    }
  }

  /// Parses a link and checks its type.
  String checkType(String url) {
    if (url.contains("huya.com")) {
      return "huya";
    } else if (url.contains("bilibili.com")) {
      return "bilibili";
    } else {
      return 'Unable to parse type!';
    }
  }
}
