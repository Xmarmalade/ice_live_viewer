import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ice_live_viewer/utils/bilibiliparser.dart';
import 'package:web_socket_channel/io.dart';

/// https://github.com/Ha2ryZhang/alltv_flutter/blob/master/lib/model/bilibili_host_server.dart
/// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/live/message_stream.md
class BilibiliDanmakuListView extends StatefulWidget {
  const BilibiliDanmakuListView({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  final int roomId;

  @override
  _BilibiliDanmakuListViewState createState() =>
      _BilibiliDanmakuListViewState();
}

class _BilibiliDanmakuListViewState extends State<BilibiliDanmakuListView>
    with AutomaticKeepAliveClientMixin<BilibiliDanmakuListView> {
  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;
  final List _messageList = [];
  final ScrollController _scrollController = ScrollController();
  BiliBiliHostServerConfig? config;
  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 60), (callback) {
      totleTime += 60;
      //sendXinTiaoBao();
      debugPrint("时间: $totleTime s");
      _channel!.sink.close();
      initLive();
    });
    initLive();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  //初始化
  Future<void> initLive() async {
    config = await getBServerHost(widget.roomId.toString());
    _channel = IOWebSocketChannel.connect("wss://" +
        config!.hostServerList![2].host! +
        ":" +
        config!.hostServerList![2].wssPort.toString() +
        "/sub");
    joinRoom(widget.roomId);
    setListener();
  }

  void sendHeartBeat() {
    List<int> code = [0, 0, 0, 0, 0, 16, 0, 1, 0, 0, 0, 2, 0, 0, 0, 1];
    _channel!.sink.add(Uint8List.fromList(code));
  }

  //加入房间
  void joinRoom(int id) {
    String msg = "{"
            "\"roomid\":$id,"
            "\"uId\":0,"
            "\"protover\":2,"
            "\"platform\":\"web\","
            "\"clientver\":\"1.10.6\","
            "\"type\":2,"
            "\"key\":\"" +
        config!.token! +
        "\"}";
    debugPrint(msg);
    _channel!.sink.add(encode(7, msg: msg));
    sendHeartBeat();
  }

  //设置监听
  void setListener() {
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
  }

  //对消息编码
  Uint8List encode(int op, {String? msg}) {
    List<int> header = [0, 0, 0, 0, 0, 16, 0, 1, 0, 0, 0, op, 0, 0, 0, 1];
    if (msg != null) {
      List<int> msgCode = utf8.encode(msg);
      header.addAll(msgCode);
    }
    Uint8List uint8list = Uint8List.fromList(header);
    uint8list = writeInt(uint8list, 0, 4, header.length);
    return uint8list;
  }

  //对消息进行解码
  decode(Uint8List list) {
    int headerLen = readInt(list, 4, 2);
    int ver = readInt(list, 6, 2);
    int op = readInt(list, 8, 4);

    switch (op) {
      case 8:
        debugPrint("进入房间");
        break;
      case 5:
        int offset = 0;
        while (offset < list.length) {
          int packLen = readInt(list, offset + 0, 4);
          int headerLen = readInt(list, offset + 4, 2);
          Uint8List body;
          if (ver == 2) {
            body = list.sublist(offset + headerLen, offset + packLen);
            decode(ZLibDecoder().convert(body) as Uint8List);
            offset += packLen;
            continue;
          } else {
            body = list.sublist(offset + headerLen, offset + packLen);
          }
          String data = utf8.decode(body);
          offset += packLen;
          Map<String, dynamic> jd = json.decode(data);
          switch (jd["cmd"]) {
            case "DANMU_MSG":
              String msg = jd["info"][1].toString();
              String name = jd["info"][2][1].toString();
              addDanmaku(LiveDanmakuItem(name, msg));
              break;
            default:
          }
        }
        break;
      case 3:
        int people = readInt(list, headerLen, 4);
        debugPrint("人气: $people");
        break;
      default:
    }
  }

  //写入编码
  Uint8List writeInt(Uint8List src, int start, int len, int value) {
    int i = 0;
    while (i < len) {
      src[start + i] = value ~/ pow(256, len - i - 1);
      i++;
    }
    return src;
  }

  //从编码读出数字
  int readInt(Uint8List src, int start, int len) {
    int res = 0;
    for (int i = len - 1; i >= 0; i--) {
      res += pow(256, len - i - 1) * src[start + i] as int;
    }
    return res;
  }

  void addDanmaku(LiveDanmakuItem item) {
    if (mounted) {
      setState(() {
        _messageList.add(item);
      });
    }
  }

  void addGift(GiftItem item) {
    if (mounted) {
      setState(() {
        _messageList.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return ListView.builder(
        controller: _scrollController,
        itemCount: _messageList.length,
        padding: const EdgeInsets.only(left: 5, top: 2, right: 5),
        // reverse: true,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          late Widget item;
          if (_messageList[i] is LiveDanmakuItem) {
            LiveDanmakuItem liveDanmakuItem = _messageList[i];
            item = Container(
              padding: const EdgeInsets.all(5),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: " ${liveDanmakuItem.name} :",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: " ${liveDanmakuItem.msg}",
                    ),
                  ],
                ),
              ),
            );
          } else if (_messageList[i] is GiftItem) {
            GiftItem giftItem = _messageList[i];
            item = Container(
              padding: const EdgeInsets.all(5),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: " ${giftItem.name} :",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text:
                          " ${giftItem.action} ${giftItem.count} 个 ${giftItem.msg}",
                    ),
                  ],
                ),
              ),
            );
          }
          return item;
        });
  }
}

class DanmakuPackage {
  int? op;
  dynamic body;
}

class LiveDanmakuItem {
  String name;
  String msg;
  LiveDanmakuItem(this.name, this.msg);
}

class GiftItem {
  String name;
  String msg;
  String action;
  int count;
  GiftItem(
    this.name,
    this.action,
    this.count,
    this.msg,
  );
}
