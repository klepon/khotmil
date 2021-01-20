import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchSearchGroup(String key, int radius, String latlong, String keyword) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/search-group',
      data: (latlong != '')
          ? {
              'user_key': key,
              'radius': radius,
              'coordinate': latlong,
            }
          : {
              'user_key': key,
              'keyword': keyword,
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
