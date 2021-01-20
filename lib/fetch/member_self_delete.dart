import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchDeleteMyMember(String key, String mid) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/delete-my-member',
      data: {
        'user_key': key,
        'mid': mid,
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
