import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchValidateEmail(String email, String password, String code) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/create-key',
      data: {
        'verification_code': code.substring(0, 3) + ' ' + code.substring(3),
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailValidateUser);
      }
    } else {
      throw Exception(FailValidateUser);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
