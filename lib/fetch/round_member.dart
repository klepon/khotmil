import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khotmil/constant/text.dart';

Future fetchRoundMember(String key, String gid) async {
  final response = await http.post(
    ApiDomain + 'klepon/v1/get-round-member',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'user_key': key,
      'gid': gid,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data[DataStatus] == StatusSuccess || data[DataStatus] == StatusError) {
      return data;
    } else {
      throw Exception(FailDeleteGroup);
    }
  } else {
    throw Exception(FailDeleteGroup);
  }
}
