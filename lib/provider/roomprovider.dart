import 'package:flutter/material.dart';

class RoomsNotifier with ChangeNotifier {
  List<String> rooms = [];

  void addRooms(String room) {
    rooms.add(room);
    notifyListeners();
  }

  void removeRooms(String room) {
    rooms.remove(room);
    notifyListeners();
  }
}
