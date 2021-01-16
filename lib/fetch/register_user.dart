import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchRegisterUser(String name, String fullname, String email, String password, String phone) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/register-user',
      data: {
        'name': name,
        'fullname': fullname,
        'email': email,
        'password': password,
        'phone': phone,
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
