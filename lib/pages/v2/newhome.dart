import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/pages/settings.dart';
import 'package:ice_live_viewer/utils/http/v2/httpapi.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';
import 'package:provider/provider.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/provider/roomprovider.dart';

class NewHome extends StatelessWidget {
  const NewHome({Key? key}) : super(key: key);
  //homepage
  @override
  Widget build(BuildContext context) {
    return const HomePageRouter();
  }
}

class HomePageRouter extends StatefulWidget {
  const HomePageRouter({Key? key}) : super(key: key);

  @override
  State<HomePageRouter> createState() => _HomePageRouterState();
}

class _HomePageRouterState extends State<HomePageRouter> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    RoomsProvider provider = Provider.of<RoomsProvider>(context);
    TextEditingController addLinkController = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;
    //provider.getRoomsInfo();
    return Scaffold(
      bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.star_rate_rounded),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_rounded),
              label: 'Popular',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
      body: [
        //Favorites
        Scaffold(
          appBar: AppBar(title: const Text("Favorites"), actions: [
            provider.isHideOffline == false
                ? IconButton(
                    onPressed: () => provider.hideOfflineRooms(),
                    tooltip: 'Hide Offline Rooms',
                    icon: const Icon(Icons.remove_circle_outline_rounded))
                : IconButton(
                    onPressed: () => provider.showOfflineRooms(),
                    tooltip: 'Show Offline Rooms',
                    icon: const Icon(Icons.add_circle_outline_rounded)),
          ]),
          body: HomePageGridView(
              screenWidth: screenWidth, roomsProvider: provider),
          floatingActionButton: HomePageAddButton(
              controller: addLinkController, roomsProvider: provider),
        ),
        //Popular
        Scaffold(
            appBar: AppBar(title: const Text("Recommend")),
            body:
                const Center(child: Text('Recommend Page')) //RecommendPages(),
            ),
        //Settings
        const SettingsPage(), //RecommendPages(),
      ][_selectedIndex],
    );
  }
}

class HomePageGridView extends StatelessWidget {
  const HomePageGridView(
      {Key? key, required this.screenWidth, required this.roomsProvider})
      : super(key: key);

  final double screenWidth;
  final RoomsProvider roomsProvider;

  @override
  Widget build(BuildContext context) {
    if (roomsProvider.roomsList.isNotEmpty) {
      return KeepAliveWrapper(
        child: EasyRefresh(
          onLoad: () async {
            return IndicatorResult.success;
          },
          onRefresh: () => roomsProvider.getRoomsInfoFromApi(),
          child: MasonryGridView.count(
              padding: const EdgeInsets.all(5),
              controller: ScrollController(),
              crossAxisCount: screenWidth > 1280
                  ? 4
                  : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1)),
              itemCount: roomsProvider.roomsList.length,
              physics: (const BouncingScrollPhysics()),
              itemBuilder: (context, index) {
                SingleRoom room = roomsProvider.roomsList[index];
                return RoomCard(
                    room: room, roomsProvider: roomsProvider, index: index);
              }),
        ),
      );
    } else {
      return const HomeEmptyScreen();
    }
  }
}

class HomeEmptyScreen extends StatelessWidget {
  const HomeEmptyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Icon(
              Icons.post_add_rounded,
              size: 144,
              color: Theme.of(context).disabledColor,
            ),
          ),
          Expanded(
            child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: "No data! 没有数据\n\n",
                      style: Theme.of(context).textTheme.headlineLarge),
                  TextSpan(
                      text: "Click the button below\nto add your first link",
                      style: Theme.of(context).textTheme.headline3),
                ]),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  const RoomCard({
    Key? key,
    required this.room,
    required this.roomsProvider,
    required this.index,
  }) : super(key: key);

  final SingleRoom room;
  final RoomsProvider roomsProvider;
  final int index;

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
        child: Card(
      elevation: 5,
      margin: const EdgeInsets.fromLTRB(7.5, 7.5, 7.5, 7.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(room.title),
                  content: Text('RoomId' +
                      room.roomId +
                      '\nLiveStatus: ' +
                      room.liveStatus.name +
                      '\ncover' +
                      room.cover +
                      '\n' +
                      room.cdnMultiLink.toString()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        roomsProvider.removeRoom(index);
                        return Navigator.pop(context);
                      },
                      child: const Text("Remove"),
                    ),
                    TextButton(
                      onPressed: () {
                        roomsProvider.moveToTop(index);
                        return Navigator.pop(context);
                      },
                      child: const Text("Move to top"),
                    ),
                  ],
                )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).focusColor,
                  elevation: 0,
                  child: room.liveStatus.name == 'live'
                      ? Image.network(
                          room.cover,
                          fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                              child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '${error.toString()}\n',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 10)),
                            TextSpan(text: stackTrace.toString())
                          ]))),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.tv_off_rounded, size: 48),
                              Text("Offline", style: TextStyle(fontSize: 28))
                            ],
                          ),
                        )),
            ),
            ListTile(
              leading: CircleAvatar(
                foregroundImage:
                    (room.avatar == '') ? null : NetworkImage(room.avatar),
                radius: 20,
                backgroundColor: Theme.of(context).disabledColor,
              ),
              title: Text(
                room.title,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                room.nick,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                room.platform,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            )
          ],
        ),
      ),
    ));
  }
}

class HomePageAddButton extends StatelessWidget {
  const HomePageAddButton({
    Key? key,
    required this.controller,
    required this.roomsProvider,
  }) : super(key: key);

  final TextEditingController controller;
  final RoomsProvider roomsProvider;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Add your link"),
              content: TextField(controller: controller),
              actions: [
                TextButton(
                    onPressed: () {
                      roomsProvider.addRoom(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Add")),
              ],
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

/* class RoomsNotifier with ChangeNotifier {
  List<SingleRoom> singleRoomsList = [
    SingleRoom.fromJson({
      "avatar":
          "https://huyaimg.msstatic.com/avatar/1010/66/6aba6b4323ab3c52960e7bf169d08e_180_135.jpg?1653400276",
      "cover":
          "https://anchorpost.msstatic.com/cdnimage/anchorpost/1010/66/6aba6b4323ab3c52960e7bf169d08e_2336_1662655848.jpg",
      "liveStatus": "ON",
      "nick": "KPL职业联赛",
      "roomId": "660002",
      "title": "【重播】9.10 17:00 重庆狼队 vs 广州TTG"
    }),
    SingleRoom.fromJson(
      {
        "avatar":
            "https://huyaimg.msstatic.com/avatar/1034/77/a4286776aa02881faa959bbb2a94d5_180_135.jpg?1598180690",
        "liveStatus": "OFF",
        "cover": "",
        "nick": "久爱-预见【吕德华】",
        "roomId": "243547",
        "title": "儒雅少年 血洗巅峰冲2500"
      },
    ),
    SingleRoom.fromJson(
      {
        "avatar":
            "https://huyaimg.msstatic.com/avatar/1087/cb/ab41300582958653660b6620e05fd1_180_135.jpg?1577343415",
        "cover":
            "https://live-cover.msstatic.com/huyalive/1610145122-1610145122-6915520640803930112-3220413700-10057-A-0-1-imgplus/20220910155139.jpg?streamName=1610145122-1610145122-6915520640803930112-3220413700-10057-A-0-1-imgplus&interval=10",
        "liveStatus": "ON",
        "nick": "LING-树叶",
        "roomId": "296191",
        "title": "祝大家中秋团圆"
      },
    ),
    SingleRoom.fromJson(
      {
        "avatar":
            "https://huyaimg.msstatic.com/avatar/1086/bf/fd6f69d69c0015eaface1f6024869e_180_135.jpg?1619540458",
        "cover":
            "https://live-cover.msstatic.com/huyalive/294636272-294636272-1265453152455360512-589396000-10057-A-0-1-imgplus/20220910152837.jpg?streamName=294636272-294636272-1265453152455360512-589396000-10057-A-0-1-imgplus&interval=10",
        "liveStatus": "ON",
        "nick": "狂鸟丶楚河-90327",
        "roomId": "998",
        "title": "新主播，第一天直播，什么游戏都播"
      },
    ),
    SingleRoom.fromJson(
      {
        "avatar":
            "https://apic.douyucdn.cn/upload/avatar_v3/202209/f71f86fa2cc1474b9914452379fdcfc1_big.jpg",
        "cover":
            "https://rpic.douyucdn.cn/live-cover/roomCove_coverUpdate_2022-09-10_84f3e2e4019598aad12bf33c3fa00167.jpg/dy1",
        "liveStatus": "ON",
        "nick": "王者荣耀官方赛事",
        "roomId": "1863767",
        "title": "预告丨13日 EMC vs GOG"
      },
    ),
    SingleRoom.fromJson(
      {
        "avatar":
            "https://apic.douyucdn.cn/upload/avatar_v3/202206/c7084e1e66ed4195a379cddd4b2bce1b_big.jpg",
        "cover": "https://rpic.douyucdn.cn/asrpic/220820/6_1901.png/dy1",
        "liveStatus": "OFF",
        "nick": "斗鱼官方直播",
        "roomId": "6",
        "title": "20日16点 比亚迪汽车王者荣耀高校赛"
      },
    )
  ];

  void addSingleRoom(String roomId) {
    SingleRoom sgroom = SingleRoom(roomId);
    singleRoomsList.add(sgroom);
    notifyListeners();
  }

  void removeSingleRooms(int index) {
    singleRoomsList.removeAt(index);
    notifyListeners();
  }

  void hideOfflineRooms() {
    for (int i = 0; i < singleRoomsList.length; i++) {
      if (singleRoomsList[i].liveStatus != 'ON') {
        singleRoomsList.removeAt(i);
      }
    }
    notifyListeners();
  }


}
 */