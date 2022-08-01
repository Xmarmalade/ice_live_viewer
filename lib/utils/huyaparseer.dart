import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

Future<String> _getLiveHtml(String url) async {
  var resp = await http.get(
    Uri.parse(url),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    },
  );
  return resp.body;
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
  Map<String, dynamic> liveInfo = {};
  List<String> returnLinkList = [];
  String value = await _getLiveHtml(url);
  var dataLive = parse(value);
  var body = dataLive.getElementsByTagName('body')[0];
  var script = body.getElementsByTagName('script')[3];
  String json = script.text.replaceAll('window.HNF_GLOBAL_INIT = ', '');
  var data = jsonDecode(json);
  int eLiveStatus = data['roomInfo']['eLiveStatus'];
  String sNick = data['roomInfo']['tProfileInfo']['sNick'];

  if (eLiveStatus == 2) {
    var roomValue = data['roomInfo']['tLiveInfo']['tLiveStreamInfo']
        ['vStreamInfo']['value'];
    var roomIntroduction = data['roomInfo']['tLiveInfo']['sIntroduction'];
    var sAvatar180 = data['roomInfo']['tLiveInfo']['sAvatar180'];
    var sScreenshot = data['roomInfo']['tLiveInfo']['sScreenshot'];
    sScreenshot = sScreenshot.replaceAll('http', 'https');
    sScreenshot = sScreenshot.replaceAll('httpss', 'https');
    var lUid = data["roomInfo"]["tProfileInfo"]["lUid"];
    //add basic info
    liveInfo['liveStatus'] = 1;
    liveInfo['name'] = sNick;
    liveInfo['avatar'] = sAvatar180;
    liveInfo['title'] = roomIntroduction;
    liveInfo['cover'] = sScreenshot;
    liveInfo['luid'] = lUid;
    liveInfo['cdnCount'] = roomValue.length;
    //add cdn info
    for (var i = 0, len = roomValue.length; i < len; i++) {
      var cdnType = (roomValue[i]['sCdnType']);
      var cdnHttpUrl = data['roomInfo']['tLiveInfo']["tLiveStreamInfo"]
          ["vStreamInfo"]["value"][i]["sFlvUrl"];
      var cdnHttpsUrl = cdnHttpUrl.replaceAll('http', 'https');
      returnLinkList.add(cdnType);
      returnLinkList.add(cdnHttpsUrl +
          '/' +
          data['roomInfo']['tLiveInfo']["tLiveStreamInfo"]["vStreamInfo"]
              ["value"][i]['sStreamName'] +
          '.flv?' +
          data['roomInfo']['tLiveInfo']["tLiveStreamInfo"]["vStreamInfo"]
              ["value"][i]['sFlvAntiCode']);
    }
    liveInfo['linkList'] = returnLinkList;
  } else {
    //if not online
    liveInfo['liveStatus'] = 0;
    liveInfo['name'] = sNick;
  }

  return liveInfo;
}
