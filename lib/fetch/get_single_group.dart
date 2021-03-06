import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchGetSingleGroup(String key, String gid) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/single-group',
      data: {
        'user_key': key,
        'gid': gid,
      },
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailLoadingGroup);
      }
    } else {
      throw Exception(FailLoadingGroup);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
