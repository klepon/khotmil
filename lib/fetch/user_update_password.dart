import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchUpdatePassword(String key, String email, String password, String newPassword) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/update-password',
      data: {
        'user_key': key,
        'email': email,
        'password': password,
        'new-password': newPassword,
      },
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailLoadingUser);
      }
    } else {
      throw Exception(FailLoadingUser);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
