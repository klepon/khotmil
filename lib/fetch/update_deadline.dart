import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khotmil/constant/text.dart';

Future fetchUpdateGroup(String key, String name, String address, String latlong, String color, String date, String id) async {
  final response = await http.post(
    ApiDomain + 'klepon/v1/update-group',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'user_key': key,
      'name': name,
      'address': address,
      'latlong': latlong,
      'color': color,
      'round_end_date': date,
      'id': id,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data[DataStatus] == StatusSuccess || data[DataStatus] == StatusError) {
      return data;
    } else {
      throw Exception(FailCreateGroup);
    }
  } else {
    throw Exception(FailCreateGroup);
  }
}
