import 'dart:typed_data';

import 'package:ice_live_viewer/dart_tars_protocol/tars_output_stream.dart';
import 'package:ice_live_viewer/dart_tars_protocol/tars_input_stream.dart';
import 'package:ice_live_viewer/dart_tars_protocol/tars_struct.dart';

// credit https://github.com/xiaoyaocz/dart_tars_protocol

/*void main() {
  var testUid = 1354740567;
  //[0, 1, 29, 0, 0, 23, 2, 80, 191, 179, 87, 16, 1, 38, 0, 54, 0, 66, 80, 191, 179, 87, 82, 80, 191, 179, 87, 108, 124]
  print(regDataEncode(testUid));
}
*/

class User extends TarsStruct {
  String user;

  User({this.user = ''});

  @override
  void readFrom(TarsInputStream _is) {
    user = _is.readString(2, false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Uint8List huyaWsHeartbeat() {
  var huyaHeartbeat = <int>[
    0x00,
    0x03,
    0x1d,
    0x00,
    0x00,
    0x69,
    0x00,
    0x00,
    0x00,
    0x69,
    0x10,
    0x03,
    0x2c,
    0x3c,
    0x4c,
    0x56,
    0x08,
    0x6f,
    0x6e,
    0x6c,
    0x69,
    0x6e,
    0x65,
    0x75,
    0x69,
    0x66,
    0x0f,
    0x4f,
    0x6e,
    0x55,
    0x73,
    0x65,
    0x72,
    0x48,
    0x65,
    0x61,
    0x72,
    0x74,
    0x42,
    0x65,
    0x61,
    0x74,
    0x7d,
    0x00,
    0x00,
    0x3c,
    0x08,
    0x00,
    0x01,
    0x06,
    0x04,
    0x74,
    0x52,
    0x65,
    0x71,
    0x1d,
    0x00,
    0x00,
    0x2f,
    0x0a,
    0x0a,
    0x0c,
    0x16,
    0x00,
    0x26,
    0x00,
    0x36,
    0x07,
    0x61,
    0x64,
    0x72,
    0x5f,
    0x77,
    0x61,
    0x70,
    0x46,
    0x00,
    0x0b,
    0x12,
    0x03,
    0xae,
    0xf0,
    0x0f,
    0x22,
    0x03,
    0xae,
    0xf0,
    0x0f,
    0x3c,
    0x42,
    0x6d,
    0x52,
    0x02,
    0x60,
    0x5c,
    0x60,
    0x01,
    0x7c,
    0x82,
    0x00,
    0x0b,
    0xb0,
    0x1f,
    0x9c,
    0xac,
    0x0b,
    0x8c,
    0x98,
    0x0c,
    0xa8,
    0x0c
  ];
  var u8l = Uint8List.fromList(huyaHeartbeat);
  return u8l;
}

List danmakuDecode(Uint8List bytes) {
  //解码弹幕数据
  var ios = TarsInputStream(bytes);
  var type = ios.readInt(0, false);

  if (type == 7) {
    var stream = TarsInputStream(ios.readBytes(1, false));
    if (stream.readInt(1, false) == 1400) {
      var content = TarsInputStream(stream.readBytes(2, false));
      var rawUser = content.read(User(), 0, false);
      var user = rawUser.user;
      var msg = content.readString(3, false);
      return [user, msg];
    } else {
      return ['', ''];
    }
  } else {
    return ['', ''];
  }
}

Uint8List regDataEncode(lUid) {
  var tid = lUid;
  var sid = lUid;

  //encode
  var oos = TarsOutputStream();
  oos.write(lUid, 0);
  oos.write(true, 1);
  oos.write('', 2);
  oos.write('', 3);
  oos.write(tid, 4);
  oos.write(sid, 5);
  oos.write(0, 6);
  oos.write(0, 7);

  var wscmd = TarsOutputStream();
  wscmd.write(1, 0);
  wscmd.write(oos.toUint8List(), 1);
  var res = wscmd.toUint8List();
  return res;
}
