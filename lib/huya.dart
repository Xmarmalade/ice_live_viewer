import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

//This code is used to parse the live address

Future<String> _getLiveHtml(String url) async {
  //get html from url
  var resp = await http.get(
    Uri.parse(url),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    },
  );
  return resp.body;
}

Future<List> getLiveList(String url) async {
  List returnList = [];
  String value;
  value = await _getLiveHtml(url);
  var dataLive = parse(value);
  var body = dataLive.getElementsByTagName('body')[0];
  var script = body.getElementsByTagName('script')[3];
  //replace 'window.HNF_GLOBAL_INIT = ' in script.text
  var json = script.text.replaceAll('window.HNF_GLOBAL_INIT = ', '');
  var data = jsonDecode(json);
  var eLiveStatus = data['roomInfo']['eLiveStatus'];
  var sNick = data['roomInfo']['tProfileInfo']['sNick'];

  //check live status
  if (eLiveStatus == 2) {
    var roomValue = data['roomInfo']['tLiveInfo']['tLiveStreamInfo']
        ['vStreamInfo']['value'];
    var roomIntroduction = data['roomInfo']['tLiveInfo']['sIntroduction'];
    var sAvatar180 = data['roomInfo']['tLiveInfo']['sAvatar180'];
    var sScreenshot = data['roomInfo']['tLiveInfo']['sScreenshot'];
    //add basic info
    returnList.add(1);
    returnList.add(sNick);
    returnList.add(sAvatar180);
    returnList.add(roomIntroduction);
    returnList.add(sScreenshot);
    returnList.add(roomValue.length);
    //add cdn info
    for (var i = 0, len = roomValue.length; i < len; i++) {
      var cdnType = (roomValue[i]['sCdnType']);

      returnList.add(cdnType);
      returnList.add(data['roomInfo']['tLiveInfo']["tLiveStreamInfo"]
              ["vStreamInfo"]["value"][i]["sFlvUrl"] +
          '/' +
          data['roomInfo']['tLiveInfo']["tLiveStreamInfo"]["vStreamInfo"]
              ["value"][i]['sStreamName'] +
          '.flv?' +
          data['roomInfo']['tLiveInfo']["tLiveStreamInfo"]["vStreamInfo"]
              ["value"][i]['sFlvAntiCode']);
    }
  } else {
    //if not online
    returnList.add(0);
    returnList.add(sNick);
  }

  return returnList;
}

/*
[0_0(off)_or_1(on), 
1_name, 
2_avatar,
3_title, 
4_screenshot,
5_length(cdn number), 
6_cdnType,
7_cdnUrl]
*/