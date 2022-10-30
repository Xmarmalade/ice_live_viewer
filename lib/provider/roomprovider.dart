import 'package:flutter/material.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';

class RoomsProvider with ChangeNotifier {
  RoomsProvider() {
    _getRoomsFromPrefs(PrefsHelper.getLinksOfRoomsPrefList());
  }

  List<SingleRoom> _roomsList = [];
  List<SingleRoom> _offlineRoomsList = [];
  bool _isHideOffline = false;
  get roomsList => _roomsList;
  get isHideOffline => _isHideOffline;

  void _getRoomsFromPrefs(List<String> prefs) {
    for (var item in prefs) {
      SingleRoom singleRoom = SingleRoom.fromLink(item);
      _roomsList.add(singleRoom);
    }
    notifyListeners();
  }

  void _saveRoomsToPrefs() {
    List<String> links = [];
    for (var item in _roomsList) {
      links.add(item.link);
    }
    PrefsHelper.setLinksOfRoomsPrefList(links);
  }

  void addRoom(String link) {
    _roomsList.add(SingleRoom.fromLink(link));
    notifyListeners();
    _saveRoomsToPrefs();
  }

  void removeRoom(int index) {
    _roomsList.removeAt(index);
    notifyListeners();
    _saveRoomsToPrefs();
  }

  void moveToTop(int index) {
    _roomsList.insert(0, _roomsList[index]);
    _roomsList.removeAt(index + 1);
    notifyListeners();
    _saveRoomsToPrefs();
  }

  void hideOfflineRooms() {
    for (var item in _roomsList) {
      if (item.liveStatus == 'OFF') {
        _offlineRoomsList.add(item);
      }
    }
    for (var item in _offlineRoomsList) {
      _roomsList.remove(item);
    }
    notifyListeners();
    _isHideOffline = true;
  }

  void showOfflineRooms() {
    for (var item in _offlineRoomsList) {
      _roomsList.add(item);
      notifyListeners();
    }
    _offlineRoomsList.clear();
    _isHideOffline = false;
  }
}
