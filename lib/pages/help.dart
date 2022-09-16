import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Help'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const <Widget>[
          SectionTitle(
            title: '如何使用',
          ),
          TextTile(text: '你可以使用本应用程序追踪虎牙，斗鱼和哔哩哔哩的主播'),
          SectionTitle(title: '可解析的链接'),
          TextTile(text: '''
虎牙 https://*.huya.com/<房间号>
虎牙的部分主播的房间号是字母，无需手动操作，字母会被自动转换\n
Bilibili https://*.bilibili.com/<房间号>\n
斗鱼 https://*.douyu.com/<房间号>  https://www.douyu.com/topic/<话题>?rid=<房间号>
斗鱼的部分房间是虚假号码，也可以被转换
'''),
          SectionTitle(title: '部分链接无法播放'),
          TextTile(text: '''
虎牙一起看，斗鱼轮播无法播放\n
对于部分IP，哔哩哔哩的`.flv`格式的直播流无法播放,尝试使用`.m3u8`格式的直播流你可以尝试在其它播放器播放\n
在Windows版本上使用的是VLC，在Android上使用的是系统播放组件，如果存在问题请提issue''')
        ],
      ),
    );
  }
}

class TextTile extends StatelessWidget {
  const TextTile({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    Key? key,
  }) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.headline1),
    );
  }
}
