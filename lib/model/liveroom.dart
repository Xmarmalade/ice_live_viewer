class LiveRooom {
  String? id;
  String? name;
  String? platform;
  String? cover;
  String? title;
  bool? isLive = false;

  LiveRooom({
    required this.id,
    required this.platform,
    this.cover,
    this.name,
    this.title,
    this.isLive,
  });
}
