import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchMyGroupList(String key) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/group-list',
      data: {
        'user_key': key,
      },
    );

    if (response.statusCode == 200) {
      var data = response.data;

      if (data[DataStatus] == StatusSuccess || data[DataStatus] == StatusError) {
        return data;
      } else {
        throw Exception(FailListingGroup);
      }
    } else {
      throw Exception(FailListingGroup);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
