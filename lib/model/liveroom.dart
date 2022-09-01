class SingleRoom {
  final String roomId;
  final String title;
  final String nick;
  final String avatar;
  final String liveStatus;

  SingleRoom(this.roomId, this.title, this.nick, this.avatar, this.liveStatus);

  SingleRoom.fromJson(Map<String, dynamic> json)
      : roomId = json['roomId'],
        title = json['title'],
        nick = json['nick'],
        avatar = json['avatar'],
        liveStatus = json['liveStatus'];
  Map<String, dynamic> toJson() => <String, dynamic>{
        'roomId': roomId,
        'title': title,
        'nick': nick,
        'avatar': avatar,
        'liveStatus': liveStatus,
      };
}
