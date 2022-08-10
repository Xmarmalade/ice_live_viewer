import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ice_live_viewer/utils/storage.dart';

/// 获取网页json数据 由于bilibili的编码utf-8 所以需要转换
Future<dynamic> _getJson(String url) async {
  var resp = await http.get(
    Uri.parse(url),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    },
  );
  return await jsonDecode(const Utf8Codec().decode(resp.bodyBytes));
}

///接收房间号 返回直播信息
///
///liveStatus:直播状态 0未开播 1直播 2轮播
///title:直播标题
///uname:主播名字
///avatar:主播头像
///cover:直播封面
///keyframe:视频关键帧
Future<Map<String, String>> getLiveInfo(String roomId) async {
  String initUrl =
      'https://api.live.bilibili.com/room/v1/Room/room_init?id=$roomId';
  dynamic initJson = await _getJson(initUrl);
  String uid = initJson['data']['uid'].toString();
  String uidUrl =
      'https://api.live.bilibili.com/room/v1/Room/get_status_info_by_uids?uids[]=$uid';
  dynamic uidJson = await _getJson(uidUrl);
  String liveStatus = uidJson['data'][uid]['live_status'].toString();
  String title = uidJson['data'][uid]['title'].toString();
  String uname = uidJson['data'][uid]['uname'].toString();
  String avatar = uidJson['data'][uid]['face'].toString();
  if (liveStatus == '1') {
    String cover = uidJson['data'][uid]['cover_from_user'].toString();
    String keyframe = uidJson['data'][uid]['keyframe'].toString();
    return {
      'liveStatus': liveStatus,
      'title': title,
      'uname': uname,
      'avatar': avatar,
      'cover': cover,
      'keyframe': keyframe,
    };
  } else {
    return {
      'liveStatus': liveStatus,
      'title': title,
      'uname': uname,
      'avatar': avatar,
    };
  }
}

/// 获取对应房间号的直播链接
///
/// 返回画质-链接列表{'4': [主线，备线，备线，备线],'3': [主线，备线，备线，备线]}
Future<Map<String, List>> getStreamLink(String roomId) async {
  bool useM3u8 = await getSwitchPref('use_m3u8');
  String platform = useM3u8 ? 'h5' : 'web';
  String defaultStreamUrl =
      'https://api.live.bilibili.com/room/v1/Room/playUrl?cid=$roomId&platform=$platform&otype=json&quality=4';
  dynamic streamJson = await _getJson(defaultStreamUrl);
  List<dynamic> acceptQuality = streamJson['data']['accept_quality'];
  Map<String, List> streamMap = {};
  List<dynamic> streamList = streamJson['data']['durl'];
  List<String> streamListUrl = [];
  for (Map stream in streamList) {
    if (stream['url'] != null) {
      streamListUrl.add(stream['url']);
    }
  }
  streamMap['4'] = streamListUrl;
  if (acceptQuality.length != 1) {
    for (String qualityOption in acceptQuality) {
      if (qualityOption != '4') {
        String candidateStreamUrl =
            'https://api.live.bilibili.com/room/v1/Room/playUrl?cid=$roomId&platform=$platform&otype=json&quality=$qualityOption';
        dynamic otherStreamJson = await _getJson(candidateStreamUrl);
        List<dynamic> otherStreamList = otherStreamJson['data']['durl'];
        List<String> otherStreamListUrl = [];
        for (Map stream in otherStreamList) {
          if (stream['url'] != null) {
            otherStreamListUrl.add(stream['url']);
          }
        }
        streamMap[qualityOption] = otherStreamListUrl;
      }
    }
  }
  return streamMap;
}

///接收房间号 返回map
///
///liveStatus:直播状态 0未开播 1直播 2轮播
///title:直播标题
///uname:主播名字
///avatar:主播头像
///cover:直播封面
///keyframe:视频关键帧
///
///和画质-链接列表{'4': [主线，备线，备线，备线],'3': [主线，备线，备线，备线]}
Future<Map<String, Map<String, dynamic>>> getLiveInfoAndStreamLink(
    String roomId) async {
  Map<String, String> liveInfo = await getLiveInfo(roomId);
  if (liveInfo['liveStatus'] == '1') {
    Map<String, List> streamLink = await getStreamLink(roomId);
    return {
      'liveInfo': liveInfo,
      'streamLink': streamLink,
    };
  } else {
    return {
      'liveInfo': liveInfo,
    };
  }
}

Future<BiliBiliHostServerConfig?> getBServerHost(String roomId) async {
  String url = "https://api.live.bilibili.com/room/v1/Danmu/getConf?id=$roomId";
  try {
    var resp = await http.get(
      Uri.parse(url),
    );
    var respData = jsonDecode(const Utf8Codec().decode(resp.bodyBytes));
    if (respData["data"] != null) {
      return BiliBiliHostServerConfig.fromJson(respData["data"]);
    }
    return null;
  } catch (e) {
    return null;
  }
}

class BiliBiliHostServerConfig {
  double? refreshRowFactor;
  int? refreshRate;
  int? maxDelay;
  int? port;
  String? host;
  List<HostServerList>? hostServerList;
  List<ServerList>? serverList;
  String? token;

  BiliBiliHostServerConfig(
      {this.refreshRowFactor,
      this.refreshRate,
      this.maxDelay,
      this.port,
      this.host,
      this.hostServerList,
      this.serverList,
      this.token});

  BiliBiliHostServerConfig.fromJson(Map<String, dynamic> json) {
    refreshRowFactor = json['refresh_row_factor'];
    refreshRate = json['refresh_rate'];
    maxDelay = json['max_delay'];
    port = json['port'];
    host = json['host'];
    if (json['host_server_list'] != null) {
      hostServerList = [];
      json['host_server_list'].forEach((v) {
        hostServerList!.add(HostServerList.fromJson(v));
      });
    }
    if (json['server_list'] != null) {
      serverList = [];
      json['server_list'].forEach((v) {
        serverList!.add(ServerList.fromJson(v));
      });
    }
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refresh_row_factor'] = refreshRowFactor;
    data['refresh_rate'] = refreshRate;
    data['max_delay'] = maxDelay;
    data['port'] = port;
    data['host'] = host;
    if (hostServerList != null) {
      data['host_server_list'] =
          hostServerList!.map((v) => v.toJson()).toList();
    }
    if (serverList != null) {
      data['server_list'] = serverList!.map((v) => v.toJson()).toList();
    }
    data['token'] = token;
    return data;
  }
}

class HostServerList {
  String? host;
  int? port;
  int? wssPort;
  int? wsPort;

  HostServerList({this.host, this.port, this.wssPort, this.wsPort});

  HostServerList.fromJson(Map<String, dynamic> json) {
    host = json['host'];
    port = json['port'];
    wssPort = json['wss_port'];
    wsPort = json['ws_port'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['host'] = host;
    data['port'] = port;
    data['wss_port'] = wssPort;
    data['ws_port'] = wsPort;
    return data;
  }
}

class ServerList {
  String? host;
  int? port;

  ServerList({this.host, this.port});

  ServerList.fromJson(Map<String, dynamic> json) {
    host = json['host'];
    port = json['port'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['host'] = host;
    data['port'] = port;
    return data;
  }
}
