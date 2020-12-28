import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khotmil/constant/text.dart';

Future fetchRegisterUser(String name, String email, String password) async {
  final response = await http.post(
    ApiDomain + 'klepon/v1/register-user',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data[DataStatus] == StatusSuccess || data[DataStatus] == StatusError) {
      return data;
    } else {
      throw Exception(FailRegisterUser);
    }
  } else {
    throw Exception(FailRegisterUser);
  }
}
