import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchUpdateProgress(String key, String id, String juz, String progress) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/update-progress',
      data: {
        'user_key': key,
        'id': id,
        'juz': juz,
        'progress': progress,
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
