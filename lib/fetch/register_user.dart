import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchRegisterUser(String name, String email, String password) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/register-user',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailRegisterUser);
      }
    } else {
      throw Exception(FailRegisterUser);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
