import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchStartNewRound(String key, String gid, String newEndDate) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/start-new-round',
      data: {
        'user_key': key,
        'gid': gid,
        'date_done': (DateTime.now().toString()).split(' ')[0],
        'new_end_date': newEndDate,
      },
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailCreateGroup);
      }
    } else {
      throw Exception(FailCreateGroup);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
