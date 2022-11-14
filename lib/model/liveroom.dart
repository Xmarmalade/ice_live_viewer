import 'package:ice_live_viewer/utils/linkparser.dart';

enum LiveStatus { live, offline, replay, unknown }

enum Platform { huya, bilibili, douyu, unknown }

class SingleRoom {
  String roomId;
  String link;
  bool isInit = true;
  String title = '';
  String nick = '';
  String avatar = '';
  LiveStatus liveStatus = LiveStatus.unknown;
  String cover = '';
  String platform = '';
  int huyaDanmakuId = 0;
  Map cdnMultiLink = {};

  SingleRoom(this.roomId,
      {this.link = '',
      this.liveStatus = LiveStatus.unknown,
      this.platform = 'UNKNOWN'});

  SingleRoom.fromJson(Map<String, dynamic> json)
      : roomId = json['roomId'],
        title = json['title'],
        link = json['link'],
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

  SingleRoom.fromLink(String rawLink)
      : link = rawLink,
        platform = LinkParser.checkType(rawLink),
        roomId = LinkParser.getRoomId(rawLink);

  @override
  String toString() =>
      'roomId: $roomId, link: $link, title: $title, nick: $nick, liveStatus: $liveStatus, platform: $platform,';
}
