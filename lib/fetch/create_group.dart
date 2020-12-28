import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khotmil/constant/text.dart';

Future fetchCreateGroup(String key, name, address, latlong, color) async {
  final response = await http.post(
    ApiDomain + 'klepon/v1/create-group',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'user_key': key,
      'name': name,
      'address': address,
      'latlong': latlong,
      'color': color,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data[DataStatus] == StatusSuccess || data[DataStatus] == StatusError) {
      return data;
    } else {
      throw Exception(FailValidateUser);
    }
  } else {
    throw Exception(FailValidateUser);
  }
}
