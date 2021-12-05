import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

_fetchRemote() async {
  Logger logger = Logger("remoteFetcher");
  const String updateURL =
      "https://gist.githubusercontent.com/Hu1buerger/3a92d33965db9e299f8077fe6feb5f97/raw/pharmaceuticals.json";
  logger.fine("starting remote pharmaceutical load");
  var updateURI = Uri.parse(updateURL);
  http.get(updateURI).then((response) {
    if (response.statusCode != 200) {
      return;
    }
    var remoteUpdate = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    var pharmaceuticals = remoteUpdate["pharmaceuticals"] as List;

    List<Pharmaceutical> pharms = [];
    for (var pJson in pharmaceuticals) {
      var p = Pharmaceutical.fromJson(pJson);
      assert(p.documentState != DocumentState.user_created);
      pharms.add(p);
    }

    logger.fine("recieved ${pharmaceuticals.length} pharmaceuticals from $updateURL");
    //TODO: return them and integrate to the repo
  });
}
