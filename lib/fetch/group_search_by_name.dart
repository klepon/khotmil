import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchSearchGroupByName(String keyword, String latlong) async {
  try {
    Response response = await Dio(dioOptions).post('klepon/v1/search-name', data: {
      'keyword': keyword,
      'type': latlong,
    });

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
