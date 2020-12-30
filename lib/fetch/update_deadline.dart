import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khotmil/constant/text.dart';

Future fetchUpdateDeadline(String key, String gid, String deadLine) async {
  final response = await http.post(
    ApiDomain + 'klepon/v1/edit-round',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'user_key': key,
      'gid': gid,
      'dead_line': deadLine,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data[DataStatus] == StatusSuccess || data[DataStatus] == StatusError) {
      return data;
    } else {
      throw Exception(FailUpdateDeadline);
    }
  } else {
    throw Exception(FailUpdateDeadline);
  }
}
