import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/v2/huya.dart';

///the api interface
class HttpApi {
  static Future<SingleRoom> getLiveInfo(SingleRoom singleRoom) {
    switch (singleRoom.platform) {
      case 'huya':
        return HuyaApi.getLiveInfo(singleRoom.link);
      default:
        return Future(() => singleRoom);
    }
  }
}
