import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khotmil/constant/text.dart';

Future fetchValidateEmail(String email, String password, String code) async {
  final response = await http.post(
    ApiDomain + 'klepon/v1/create-key',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'verification_code': code.substring(0, 3) + ' ' + code.substring(3),
      'email': email,
      'password': password,
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

// class ResponseRegisterUser {
//   final String status;
//   final String message;

//   ResponseRegisterUser({this.status, this.message});

//   factory ResponseRegisterUser.fromJson(Map<String, dynamic> json) {
//     return ResponseRegisterUser(
//       status: json['status'],
//       message: TextCode[json['message']],
//     );
//   }
// }
