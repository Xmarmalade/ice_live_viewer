class SingleRoom {
  String roomId;
  String title;
  String nick;
  String avatar;
  String liveStatus;
  String cover;
  String platform = 'HUYA';

  SingleRoom(this.roomId,
      {this.title = '',
      this.nick = '',
      this.avatar = '',
      this.liveStatus = '',
      this.cover = '',
      this.platform = 'Unknown'});

  SingleRoom.fromJson(Map<String, dynamic> json)
      : roomId = json['roomId'],
        title = json['title'],
        nick = json['nick'],
        avatar = json['avatar'],
        cover = json['cover'],
        liveStatus = json['liveStatus'];
  Map<String, dynamic> toJson() => <String, dynamic>{
        'roomId': roomId,
        'title': title,
        'nick': nick,
        'avatar': avatar,
        'cover': cover,
        'liveStatus': liveStatus
      };
}
