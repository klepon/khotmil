import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchCreateGroup(String key, String name, String address, String latlong, String color, String date, uids) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/create-group',
      data: {
        'user_key': key,
        'name': name,
        'address': address,
        'latlong': latlong,
        'color': color,
        'round_end_date': date,
        'member_ids': uids,
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
