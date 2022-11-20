import 'dart:convert';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:ice_live_viewer/utils/linkparser.dart';

class DouyuApi {
  static String _generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static Future<Map> _getRoomStreamInfo(SingleRoom douyuRoom) async {
    Map data = {
      'rid': douyuRoom.roomId,
      'did': '10000000000000000000000000001501'
    };
    String time = ((DateTime.now().millisecondsSinceEpoch) * 1000).toString();
    String sign = _generateMd5('${douyuRoom.roomId}$time');
    Map<String, String> headers = {
      'rid': douyuRoom.roomId,
      'time': time,
      'auth': sign
    };
    var resp = await http.post(
        Uri.parse(
            'https://playweb.douyucdn.cn/lapi/live/hlsH5Preview/${douyuRoom.roomId}'),
        headers: headers,
        body: data);
    var body = json.decode(resp.body);
    //print(body);
    if (body['error'] == 0) {
      String rtmpLive = body['data']['rtmp_live'];
      RegExpMatch? match =
          RegExp(r'(\d{1,8}[0-9a-zA-Z]+)_?\d{0,4}(/playlist|.m3u8)')
              .firstMatch(rtmpLive);
      String? key = match?.group(1);
      return {'error': 0, 'key': key, 'msg': rtmpLive, 'data': body['data']};
    } else if (body['error'] == 104) {
      return {'error': 104, 'msg': '房间不存在'};
    }
    //return {'error': 102, 'msg': '房间未开播'};
    throw Exception(body);
  }

  static Future<Map> _getRoomBasicInfo(SingleRoom douyuRoom) async {
    var resp = await http.get(Uri.parse(
        'https://open.douyucdn.cn/api/RoomApi/room/${douyuRoom.roomId}'));
    var body = json.decode(resp.body);
    if (resp.statusCode == 200) {
      if (body['error'] == 0) {
        Map data = body['data'];
        data['gift'] = [];
        return data;
      } else if (body['error'] == 101) {
        throw Exception([body['data'], body['error'], resp.statusCode]);
      } else {
        //return {'error': body};
        throw Exception([body, resp.statusCode]);
      }
    } else {
      //return {'error': body};
      throw Exception([body, resp.statusCode]);
    }
  }

  Future<String> fixErrorroomId(String wrongroomId) async {
    var resp =
        await http.get(Uri.parse('https://m.douyu.com/$wrongroomId'), headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    });
    String body = resp.body;
    if (resp.body.contains('不存在')) {
      throw Exception(
          '不能修复信息，因为房间信息不存在\nThe room number cannot be fixed because the room information does not exist.');
    } else {
      RegExpMatch? match = RegExp(r'rid":(\d{1,8}),"vipId').firstMatch(body);
      String? rightroomId = match?.group(1);
      return rightroomId!;
    }
  }

  static Future<Map> _getRoomStreamLink(SingleRoom douyuRoom) async {
    Map info = await _getRoomStreamInfo(douyuRoom);
    //print(info);
    Map<String, dynamic> realUrl = {'hw': {}, 'ws': {}, 'akm': {}};
    if (info['error'] == 0 || info['error'] == 104) {
      String key = info['key'];
      for (String cdn in realUrl.keys) {
        realUrl[cdn]['原画'] = 'https://$cdn-tct.douyucdn.cn/live/$key.flv?uuid=';
        realUrl[cdn]['流畅'] =
            'https://$cdn-tct.douyucdn.cn/live/${key}_900.flv?uuid=';
      }
    }
    //print(realUrl);
    return realUrl;
  }

  Future<String> verifyLink(String link) async {
    return fixErrorroomId(LinkParser.getRoomId(link));
  }

  ///接收url 返回直播信息
  ///
  ///liveStatus:直播状态 0未开播 1直播
  ///name:名字
  ///avatar:头像
  ///title:直播标题
  ///cover:直播封面
  ///id:直播id
  ///startTime:直播开始时间
  ///linkList:直播链接列表[CDN-链接]
  static Future<SingleRoom> getRoomFullInfo(SingleRoom douyuRoom) async {
    //try to get room basic info, if error, try to fix the room id
    Map roomBasicInfo = await _getRoomBasicInfo(douyuRoom);
    //print(roomBasicInfo);
    dynamic liveStatus = roomBasicInfo['room_status'];
    Map<String, dynamic> data = {
      'name': roomBasicInfo['owner_name'],
      'avatar': roomBasicInfo['avatar'],
      'title': roomBasicInfo['room_name'],
      'cover': roomBasicInfo['room_thumb'],
      'id': roomBasicInfo['room_id'],
      'startTime': roomBasicInfo['start_time'],
    };
    douyuRoom.nick = data['name'];
    douyuRoom.title = data['title'];
    douyuRoom.avatar = data['avatar'];
    douyuRoom.cover = data['cover'];

    if (liveStatus == '1') {
      Map links = await _getRoomStreamLink(douyuRoom);
      douyuRoom.liveStatus = LiveStatus.live;
      douyuRoom.cdnMultiLink = links;
    } else {
      douyuRoom.liveStatus = LiveStatus.offline;
    }
    return douyuRoom;
  }
}
