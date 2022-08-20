import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class Douyu {
  late String roomId;

  Douyu(this.roomId);

  String _generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<Map> _getRoomStreamInfo() async {
    Map data = {'rid': roomId, 'did': '10000000000000000000000000001501'};
    String time = ((DateTime.now().millisecondsSinceEpoch) * 1000).toString();
    String sign = _generateMd5('$roomId$time');
    Map<String, String> headers = {'rid': roomId, 'time': time, 'auth': sign};
    var resp = await http.post(
        Uri.parse('https://playweb.douyucdn.cn/lapi/live/hlsH5Preview/$roomId'),
        headers: headers,
        body: data);
    var body = json.decode(resp.body);
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
    return {'error': 102, 'msg': '房间未开播'};
  }

  Future<Map> _getRoomBasicInfo() async {
    var resp = await http
        .get(Uri.parse('https://open.douyucdn.cn/api/RoomApi/room/$roomId'));
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

  Future<String> fixErrorRoomId(String wrongRoomId) async {
    var resp =
        await http.get(Uri.parse('https://m.douyu.com/$wrongRoomId'), headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    });
    String body = resp.body;
    if (resp.body.contains('不存在')) {
      throw Exception(
          '不能修复信息，因为房间信息不存在\nThe room number cannot be fixed because the room information does not exist.');
    } else {
      RegExpMatch? match = RegExp(r'rid":(\d{1,8}),"vipId').firstMatch(body);
      String? rightRoomId = match?.group(1);
      roomId = rightRoomId!;
      return roomId;
    }
  }

  Future<Map> _getRoomUrl() async {
    Map info = await _getRoomStreamInfo();
    Map<String, dynamic> realUrl = {'hw': {}, 'ws': {}};
    if (info['error'] == 0) {
      String key = info['key'];
      for (String cdn in realUrl.keys) {
        realUrl[cdn]['原画'] = 'http://$cdn-tct.douyucdn.cn/live/$key.flv?uuid=';
        realUrl[cdn]['流畅'] =
            'http://$cdn-tct.douyucdn.cn/live/${key}_900.flv?uuid=';
      }
    }
    return realUrl;
  }

  Future<String> verifyLink() async {
    return fixErrorRoomId(roomId);
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
  Future<Map<String, dynamic>> getRoomFullInfo() async {
    //try to get room basic info, if error, try to fix the room id
    Map roomBasicInfo = await _getRoomBasicInfo();
    dynamic liveStatus = roomBasicInfo['room_status'];
    Map<String, dynamic> data = {
      'name': roomBasicInfo['owner_name'],
      'avatar': roomBasicInfo['avatar'],
      'title': roomBasicInfo['room_name'],
      'cover': roomBasicInfo['room_thumb'],
      'id': roomBasicInfo['room_id'],
      'startTime': roomBasicInfo['start_time'],
    };
    //print('liveStatus:$liveStatus');
    if (liveStatus == '1') {
      Map links = await _getRoomUrl();
      data['liveStatus'] = 1;
      data['linkList'] = links;
    } else {
      data['liveStatus'] = 0;
    }
    return data;
  }
}



/* void main() {
  Douyu douyuRoom = Douyu('101');
  douyuRoom._fixErrorRoomId(douyuRoom.roomId).then((value) {
    douyuRoom.getRoomFullInfo().then((value) => print(value));
    douyuRoom._getRoomStreamInfo().then((value) => print(value));
  });
  douyuRoom._getRoomBasicInfo().then((value) => print(value));
  douyuRoom.getRoomFullInfo().then((value) => print(value));
} */



/*{"error":104,"msg":"房间未开播","data":""}*/

/*{"error":0,"msg":"success","data":{"room_id":1863767,"rtmp_cdn":"tct","rtmp_url":"https://hlstct.douyucdn2.cn/dyliveflv1a","rtmp_live":"1863767rkpl_900.m3u8?txSecret=8f2a4379ae06731f19eae8329d869357\u0026txTime=62ff4c76\u0026token=web-douyu-0-1863767-f679ed3b4023d4a7becf0618c0a380a8\u0026did=10000000000000000000000000001501\u0026ver=2018061203\u0026st=0\u0026preview=1\u0026pt=3\u0026origin=tct","client_ip":"139.180.215.7","cdnsWithName":[],"multirates":[],"is_pass_player":0,"rate":0,"is_mixed":false,"mixed_url":"","rateSwitch":0,"p2p":0,"streamStatus":0,"mixed_live":"","inNA":0,"smt":0,"mixedCDN":"","eticket":null,"online":0}}*/

