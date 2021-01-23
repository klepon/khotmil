import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchSearchUser(String key, String keyword, List<String> uids) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/search-user',
      data: {
        'user_key': key,
        'keyword': keyword,
        'exclude': uids,
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
