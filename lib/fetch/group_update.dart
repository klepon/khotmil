import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchUpdateGroup(String key, String name, String address, String latlong, String round, String date, String id) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/update-group',
      data: {
        'user_key': key,
        'name': name,
        'address': address,
        'latlong': latlong,
        'round': round,
        'round_end_date': date,
        'id': id,
      },
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailUpdateGroup);
      }
    } else {
      throw Exception(FailUpdateGroup);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
