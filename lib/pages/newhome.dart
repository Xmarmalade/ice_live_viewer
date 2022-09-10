import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class NewHome extends StatelessWidget {
  const NewHome({Key? key}) : super(key: key);
  //homepage
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomsNotifier(),
      child: const HomePageScaffold(),
    );
  }
}

class HomePageScaffold extends StatefulWidget {
  const HomePageScaffold({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePageScaffold> createState() => _HomePageScaffoldState();
}

class _HomePageScaffoldState extends State<HomePageScaffold> {
  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<RoomsNotifier>(context);
    TextEditingController controller = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Home Preview"),
      ),
      floatingActionButton:
          HomePageAddButton(controller: controller, counter: counter),
      body: HomePageGridView(screenWidth: screenWidth, counter: counter),
    );
  }
}

class HomePageGridView extends StatelessWidget {
  const HomePageGridView({
    Key? key,
    required this.screenWidth,
    required this.counter,
  }) : super(key: key);

  final double screenWidth;
  final RoomsNotifier counter;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: screenWidth > 1280
          ? 4
          : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1)),
      itemCount: counter.rooms.length,
      itemBuilder: (context, index) {
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
                      title: Text("Item $index"),
                      content: Text(counter.rooms[index]),
                      actions: [
                        TextButton(
                          onPressed: () {
                            counter.removeRooms(counter.rooms[index]);
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
                    color: Theme.of(context).highlightColor,
                    child: const Center(
                      child: Text("Image"),
                    ),
                  ),
                ),
                ListTile(
                  leading: CircleAvatar(
                    //radius: 24,
                    backgroundColor: Theme.of(context).highlightColor,
                  ),
                  title: const Text(
                    "Title",
                    //style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: Text(
                    counter.rooms[index],
                    //style: Theme.of(context).textTheme.subtitle1,
                  ),
                  trailing: Text(
                    "Live",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                    counter.addRooms(controller.text);
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
  List<String> rooms = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

  void addRooms(String room) {
    rooms.add(room);
    print('huyaRooms: $rooms');
    notifyListeners();
  }

  void removeRooms(String room) {
    rooms.remove(room);
    notifyListeners();
  }
}
