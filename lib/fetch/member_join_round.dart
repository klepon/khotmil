import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchJoinRound(String key, String gid, String juz) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/join-round',
      data: {
        'user_key': key,
        'gid': gid,
        'juz': juz,
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
