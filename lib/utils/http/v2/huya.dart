import 'dart:convert';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class HuyaApi {
  static String profileUrl =
      'https://mp.huya.com/cache.php?m=Live&do=profileRoom&roomid=';

  //get live info from huya api
  static Future<Map<String, dynamic>> _getFromHuyaApi(String roomId) async {
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

  static Future<SingleRoom> getLiveInfo(String url) async {
    String roomId = getRoomId(url);
    if (int.tryParse(roomId) == null) {
      roomId = await fixRoomId(roomId);
    }
    SingleRoom newEmptyRoom = SingleRoom(roomId);
    Map roomInfo = await _getFromHuyaApi(roomId);
    newEmptyRoom.platform = 'huya';
    newEmptyRoom.link = url;
    String liveStatus = roomInfo['liveStatus'];
    newEmptyRoom.nick = roomInfo['profileInfo']['nick'];
    newEmptyRoom.avatar = roomInfo['profileInfo']['avatar180'];
    newEmptyRoom.title = roomInfo['liveData']['introduction'];
    if (liveStatus == 'OFF') {
      newEmptyRoom.liveStatus = '0';
      return newEmptyRoom;
    } else if (liveStatus == 'REPLAY') {
      newEmptyRoom.liveStatus = '2';
      return newEmptyRoom;
    } else {
      newEmptyRoom.liveStatus = '1';
      bool useCustomResolution = PrefsHelper.getUseCustomResolutionPref();
      newEmptyRoom.huyaDanmakuId = roomInfo['profileInfo']['uid'];
      newEmptyRoom.cover = roomInfo['liveData']['screenshot'];
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
      newEmptyRoom.cdnMultiLink = finalLinks;
      return newEmptyRoom;
    }
  }

  static Future<String> fixRoomId(String notDigitRoomId) async {
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

  static String getRoomId(String url) {
    String path = url.split("/").last;
    for (var i = 0; i < path.length; i++) {
      if (path[i] == "?") {
        return path.substring(0, i);
      }
    }
    return path;
  }
}
