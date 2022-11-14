import 'package:flutter/material.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/v2/httpapi.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';

class RoomsProvider with ChangeNotifier {
  RoomsProvider() {
    _getRoomsFromPrefs(PrefsHelper.getLinksOfRoomsPrefList());
    getRoomsInfoFromApi();
  }

  final List<SingleRoom> _roomsList = [];
  final List<SingleRoom> _tempRoomsList = [];
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

  void getRoomsInfoFromApi() async {
    for (var item in _roomsList) {
      SingleRoom singleRoom = await HttpApi.getLiveInfo(item);
      _roomsList[_roomsList.indexOf(item)] = singleRoom;
      notifyListeners();
      print(singleRoom);
    }
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

  void changeRoomInfo(int index, SingleRoom singleRoom) {
    if (index != -1) {
      _roomsList[index] = singleRoom;
      //notifyListeners();
    }
  }

  void hideOfflineRooms() {
    for (var element in _roomsList) {
      _tempRoomsList.add(element);
    }
    for (var item in _tempRoomsList) {
      if (item.liveStatus.name != 'live') {
        print(
            'offline: ${item.roomId}, platform: ${item.platform}, liveStatus: ${item.liveStatus}');
        _roomsList.removeWhere((element) => element.roomId == item.roomId);
      }
    }
    notifyListeners();
    _isHideOffline = true;
  }

  void showOfflineRooms() {
    _roomsList.clear();
    for (var item in _tempRoomsList) {
      _roomsList.add(item);
    }
    _tempRoomsList.clear();
    _isHideOffline = false;
    notifyListeners();
  }
}
