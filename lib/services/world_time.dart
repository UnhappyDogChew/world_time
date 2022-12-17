import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime {
  String location; // location name for the UI
  String flag; // url to an asset flag icon
  String url; // location url for api endpoint
  late String time; // the time in that location
  late bool isDaytime; // true or false if daytime or not

  static const int MAX_RETRY_COUNT = 50;

  WorldTime({required this.location, required this.flag, required this.url});

  Future getTime() async {
    int retry_count = 0;
    var client = http.Client();
    while (true) {
      try {
        // make the request
        var uri = Uri.https('worldtimeapi.org', 'api/timezone/$url');
        var response = await client.get(uri);

        Map data = jsonDecode(response.body);

        // get properties from data
        String datetime = data['datetime'];
        String offset = data['utc_offset'].substring(1, 3);

        // create DateTime object
        DateTime now = DateTime.parse(datetime);
        now = now.add(Duration(hours: int.parse(offset)));

        // set the time property
        isDaytime = now.hour > 6 && now.hour < 20 ? true : false;
        time = DateFormat.jm().format(now);
        break;
      } catch (e) {
        if (retry_count >= MAX_RETRY_COUNT) {
          print('caught error: $e');
          time = 'could not get time data';
          isDaytime = false;
          break;
        } else {
          retry_count++;
        }
      }
    }
    client.close();
  }
}

WorldTime instance =
    WorldTime(location: 'Seoul', flag: 'korea.png', url: 'Asia/Seoul');
