import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchDeleteAdmin(String key, int adminId, String gid) async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/remove-admin-by-id',
      data: {
        'user_key': key,
        'admin_id': adminId,
        'gid': gid,
      },
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailDeleteGroup);
      }
    } else {
      throw Exception(FailDeleteGroup);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
