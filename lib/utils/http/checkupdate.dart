import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> judgeVersion(String version) async {
  var resp = await http.get(Uri.parse(
      'https://api.github.com/repos/iiijam/ice_live_viewer/releases'));
  var body = await jsonDecode(resp.body);
  String networkVersion = body[0]['tag_name'].replaceAll('v', '');
  List networkVersions = networkVersion.split('-')[0].split('.');
  List versions = version.split('-')[0].split('.');
  for (int i = 0; i < networkVersions.length; i++) {
    if (int.parse(networkVersions[i]) > int.parse(versions[i])) {
      return '1-$networkVersion';
    } else if (int.parse(networkVersions[i]) < int.parse(versions[i])) {
      return '0-$networkVersion';
    }
  }
  if (version == networkVersion) {
    return '0-$networkVersion';
  } else {
    throw Exception('版本号不正确:$version$networkVersion');
  }
}
