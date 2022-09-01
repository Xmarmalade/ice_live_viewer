import 'dart:convert';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:ice_live_viewer/utils/storage.dart';

Future<Map<String, dynamic>> _getFromHuyaApi(String roomId) async {
  var resp = await http.get(
    Uri.parse(
        'https://mp.huya.com/cache.php?m=Live&do=profileRoom&roomid=$roomId'),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    },
  );
  var json = jsonDecode(resp.body);
  return json['data'];
}

Future<Map<String, dynamic>> getFromUnofficialApi(
    String liveApiUrl, String roomId) async {
  var resp = await http.get(Uri.parse('https://$liveApiUrl/huya/$roomId'));
  if (resp.statusCode == 200) {
    return jsonDecode(resp.body)['data'];
  } else {
    throw Exception(resp.body);
  }
}

///接收url 返回直播信息
///
///liveStatus:直播状态 0未开播 1直播
///name:名字
///avatar:头像
///title:直播标题
///cover:直播封面
///luid:主播id 弹幕
///cdnCount:cdn数量
///linkList:直播链接列表[CDN-链接]
Future<Map<String, dynamic>> getLiveInfo(String url) async {
  String roomId = getRoomId(url);
  if (int.tryParse(roomId) == null) {
    roomId = await fixRoomId(roomId);
  }
  Map roomInfo = await _getFromHuyaApi(roomId);
  bool useCustomResolution =
      await getSwitchPref('use_custom_resolution_for_huya');
  String liveStatus = roomInfo['liveStatus'];
  String name = roomInfo['profileInfo']['nick'];
  String avatar = roomInfo['profileInfo']['avatar180'];
  String title = roomInfo['liveData']['introduction'];

  if (liveStatus == 'OFF') {
    return {
      'liveStatus': '0',
      'name': name,
      'avatar': avatar,
      'title': title,
    };
  } else if (liveStatus == 'REPLAY') {
    return {
      'liveStatus': '2',
      'name': name,
      'avatar': avatar,
      'title': title,
    };
  } else {
    int lUid = roomInfo['profileInfo']['uid'];
    String cover = roomInfo['liveData']['screenshot'];
    //TODO fix cover 403
    Map streamDict = roomInfo['stream']['flv'];
    List multiLine = streamDict['multiLine'];
    List rateArray = streamDict['rateArray'];
    Map supportedResolutions = {};
    Map finalLinks = {};
    for (Map resolutions in rateArray) {
      String bitrate = resolutions['iBitRate'].toString();
      supportedResolutions[resolutions['sDisplayName']] = '_$bitrate';
    }
    Map reso = useCustomResolution
        ? {'1080P': '_4000', '720P': '_2000', '540P': '_1500'}
        : supportedResolutions;

    for (Map item in multiLine) {
      String url = item['url'];
      url = url.replaceAll('http://', 'https://');
      String cdnType = item['cdnType'];
      Map cdnLinks = {};
      cdnLinks['原画'] = url;
      for (String resolution in reso.keys) {
        String key = reso[resolution];
        String tempUrl = url.replaceAll('imgplus.flv', 'imgplus$key.flv');
        cdnLinks[resolution] = tempUrl;
      }
      finalLinks[cdnType] = cdnLinks;
    }
    return {
      'name': name,
      'title': title,
      'liveStatus': '1',
      'avatar': avatar,
      'cover': cover,
      'luid': lUid,
      'cdnCount': finalLinks.length,
      'linkList': finalLinks,
    };
  }
}

Future<String> fixRoomId(String notDigitRoomId) async {
  var resp = await http.get(
    Uri.parse('https://m.huya.com/$notDigitRoomId'),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    },
  );
  String value = resp.body;
  var dataLive = parse(value);
  var body = dataLive.getElementsByTagName('body')[0];
  var script = body.getElementsByTagName('script')[3];
  String json = script.text.replaceAll('window.HNF_GLOBAL_INIT = ', '');
  return jsonDecode(json)['roomInfo']['tProfileInfo']['lProfileRoom']
      .toString();
}

String getRoomId(String url) {
  String path = url.split("/").last;
  for (var i = 0; i < path.length; i++) {
    if (path[i] == "?") {
      return path.substring(0, i);
    }
  }
  return path;
}
