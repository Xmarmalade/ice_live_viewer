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
        children: const <Widget>[
          SectionTitle(
            title: '如何使用',
          ),
          TextTile(text: '你可以使用本应用程序追踪虎牙和哔哩哔哩的主播'),
          SectionTitle(title: '可解析的链接'),
          TextTile(
              text:
                  '虎牙 https://*.huya.com/<房间号>\nBilibili https://*.bilibili.com/<房间号>\n虎牙的部分主播的房间号是字母，无需手动操作，字母会被自动转换'),
          SectionTitle(title: '部分链接无法播放'),
          TextTile(text: '你可以尝试在其它播放器播放')
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
        style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 16,
            fontWeight: FontWeight.normal),
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
