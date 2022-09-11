import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:ice_live_viewer/model/liveroom.dart';

class NewHome extends StatelessWidget {
  const NewHome({Key? key}) : super(key: key);
  //homepage
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomsNotifier(),
      child: const HomePageRouter(),
    );
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
    final counter = Provider.of<RoomsNotifier>(context);
    TextEditingController controller = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.star_rate_rounded),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Recommend',
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
        Scaffold(
          appBar: AppBar(title: const Text("Favorites"), actions: [
            IconButton(
                onPressed: () => counter.hideOfflineRooms(),
                tooltip: 'Hide Offline Rooms',
                icon: const Icon(Icons.remove_circle_outline_rounded))
          ]),
          body:
              HomePageGridView(screenWidth: screenWidth, roomNotifier: counter),
          floatingActionButton:
              HomePageAddButton(controller: controller, counter: counter),
        ),
        Scaffold(
            appBar: AppBar(title: const Text("Recommend")),
            body: const Center(child: Text('recommend')) //RecommendPages(),
            ),
        Scaffold(
            appBar: AppBar(title: const Text("Settings")),
            body: const Center(child: Text('Settings')) //RecommendPages(),
            ),
      ][_selectedIndex],
    );
  }
}

class HomePageGridView extends StatelessWidget {
  const HomePageGridView(
      {Key? key, required this.screenWidth, required this.roomNotifier})
      : super(key: key);

  final double screenWidth;
  final RoomsNotifier roomNotifier;

  @override
  Widget build(BuildContext context) {
    if (roomNotifier.singleRoomsList.isNotEmpty) {
      return MasonryGridView.count(
          crossAxisCount: screenWidth > 1280
              ? 4
              : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1)),
          itemCount: roomNotifier.singleRoomsList.length,
          itemBuilder: (context, index) {
            SingleRoom room = roomNotifier.singleRoomsList[index];
            return RoomCard(room: room, counter: roomNotifier, index: index);
          });
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
    required this.counter,
    required this.index,
  }) : super(key: key);

  final SingleRoom room;
  final RoomsNotifier counter;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  content: Text(room.roomId),
                  actions: [
                    TextButton(
                      onPressed: () {
                        counter.removeSingleRooms(index);
                        return Navigator.pop(context);
                      },
                      child: const Text("Remove"),
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
                  child: room.liveStatus == 'ON'
                      ? Image.network(
                          room.cover,
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
                      : const Center(
                          child: Text(
                            "Offline",
                            style: TextStyle(fontSize: 32),
                          ),
                        )),
            ),
            ListTile(
              leading: CircleAvatar(
                foregroundImage: NetworkImage(room.avatar),
                radius: 20,
                backgroundColor: Theme.of(context).errorColor,
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
    );
  }
}

class HomePageAddButton extends StatelessWidget {
  const HomePageAddButton({
    Key? key,
    required this.controller,
    required this.counter,
  }) : super(key: key);

  final TextEditingController controller;
  final RoomsNotifier counter;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Add"),
              content: TextField(
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    counter.addSingleRoom(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class RoomsNotifier with ChangeNotifier {
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
        "links": {},
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

/*   Future<void> getRoomsFromLocalStorage() {

  } */
}
