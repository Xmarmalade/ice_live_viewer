import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ice_live_viewer/utils/tarscodec.dart';
import 'package:web_socket_channel/io.dart';

class HuyaDanmakuListView extends StatefulWidget {
  const HuyaDanmakuListView({Key? key, required this.danmakuId})
      : super(key: key);
  final int danmakuId;
  @override
  State<HuyaDanmakuListView> createState() => _HuyaDanmakuListViewState();
}

class _HuyaDanmakuListViewState extends State<HuyaDanmakuListView>
    with AutomaticKeepAliveClientMixin<HuyaDanmakuListView> {
  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;
  final List _messageList = [];
  final ScrollController _scrollController = ScrollController();
  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
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
  void initLive() {
    _channel = IOWebSocketChannel.connect("wss://cdnws.api.huya.com");
    login();
    setListener();
    timer = Timer.periodic(const Duration(seconds: 30), (callback) {
      totleTime += 30;
      heartBeat();
      //print("时间: $totleTime s");
    });
  }

  //发送心跳包
  void heartBeat() {
    Uint8List heartbeat = huyaWsHeartbeat();
    _channel!.sink.add(heartbeat);
  }

  //设置监听
  void setListener() {
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
  }

  void login() {
    Uint8List regData = regDataEncode(widget.danmakuId);
    _channel!.sink.add(regData);
    //print("login");
    Uint8List heartbeat = huyaWsHeartbeat();
    //print("heartbeat");
    _channel!.sink.add(heartbeat);
  }

  //对消息进行解码
  decode(Uint8List list) {
    List danmaku = danmakuDecode(list);
    String nickname = danmaku[0];
    String message = danmaku[1];
    //TODO: 屏蔽词功能
    if (message != '') {
      addDanmaku(LiveDanmakuItem(nickname, message));
    }
  }

  void addDanmaku(LiveDanmakuItem item) {
    if (_messageList.length > 100) {
      int leng = _messageList.length;
      for (int i = 0; i < leng - 100; i++) {
        _messageList.removeAt(0);
      }
    }
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    " ${liveDanmakuItem.name} :",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: Text(
                      " ${liveDanmakuItem.msg}",
                    ),
                  )
                ],
              ),
            );
          }
          return item;
        });
  }
}

class LiveDanmakuItem {
  String name;
  String msg;
  LiveDanmakuItem(this.name, this.msg);
}
