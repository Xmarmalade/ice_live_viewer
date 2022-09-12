# ice_live_viewer

<img width="100" alt="image" src="https://user-images.githubusercontent.com/16839488/159170616-6633b2c9-0b33-4dd1-9de4-b73b9d70eca4.png">

![](https://img.shields.io/badge/language-dart-blue.svg?style=for-the-badge&color=00ACC1)
![](https://img.shields.io/badge/flutter-00B0FF?style=for-the-badge&logo=flutter)
[![](https://img.shields.io/github/downloads/iiijam/ice_live_viewer/total?style=for-the-badge&color=FF2196)](https://github.com/iiijam/ice_live_viewer/releases)
![](https://img.shields.io/github/license/iiijam/ice_live_viewer?style=for-the-badge)
![](https://img.shields.io/github/stars/iiijam/ice_live_viewer?style=for-the-badge)
![](https://img.shields.io/github/issues/iiijam/ice_live_viewer?style=for-the-badge&color=9C27B0)

A Flutter project can make you watch live with ease.

一个Flutter直播应用程序，轻松看直播。

## Features

- Follow many anchors 追踪各平台主播，包括虎牙，斗鱼和哔哩哔哩
- Check the status of the anchor 检查主播开播状态
- View the cover of the anchor's live stream 查看封面
- Get the address of the live room from multiple CDNs and qualities 选择不同的线路和质量
- Check danmaku messages 查看弹幕聊天信息
- Support Android, ~~iOS, Liunx~~ and Windows 支持安卓，~~iOS，Liunx~~ 和 Windows 
## Screenshots
<img width="1040" alt="屏幕截图 2022-08-21 173645" src="https://user-images.githubusercontent.com/16839488/185785310-7a21dc36-fa9c-493a-a06e-149fb577714b.png">
<img width="1280" alt="屏幕截图 2022-08-21 174302" src="https://user-images.githubusercontent.com/16839488/185785381-964cfcf8-716a-432f-8bfe-664ef23d90e6.png">

## Platforms
- [x] BILIBILI

- [x] 虎牙

- [x] 斗鱼

## Problems
### 如何使用
你可以使用本应用程序追踪虎牙，斗鱼和哔哩哔哩的主播
### 可解析的链接
 - 虎牙 `https://*.huya.com/<房间号>` 如：`https://www.huya.com/lpl`

   虎牙的部分主播的房间号是字母，无需手动操作，字母会被自动转换

 - Bilibili `https://*.bilibili.com/<房间号>` 如：`https://live.bilibili.com/21495945`


 - 斗鱼 `https://*.douyu.com/<房间号>` 或 `https://www.douyu.com/topic/<话题>?rid=<房间号>` 如：`https://www.douyu.com/12306`

   斗鱼的部分房间是虚假号码，也可以被转换

如果你发现有房间无法解析，可以在[issue](https://github.com/iiijam/ice_live_viewer/issues/new/choose)反馈



### 部分链接无法播放

- 虎牙一起看，斗鱼轮播无法播放

- 对于部分IP，哔哩哔哩的`.flv`格式的直播流无法播放,尝试使用`.m3u8`格式的直播流

- 你可以尝试在其它播放器里面播放，在Windows版本上使用的是VLC，在Android上使用的是系统播放组件

如果排除了上述的问题，请提[issue](https://github.com/iiijam/ice_live_viewer/issues/new/choose)
