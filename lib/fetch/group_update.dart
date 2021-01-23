import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchUpdateGroup(String key, String name, String address, String latlong, String date, String gid, List uids, File file) async {
  try {
    Map<String, dynamic> data = {
      'user_key': key,
      'name': name,
      'address': address,
      'latlong': latlong,
      'round_end_date': date,
      'member_ids': uids,
      'gid': gid,
    };

    if (file != null) {
      File resized = File(file.path)..writeAsBytesSync(img.encodeJpg(img.copyResize(img.decodeImage(File(file.path).readAsBytesSync()), width: ProfilePhotoWidth)));
      data['file'] = await MultipartFile.fromFile(resized.path, filename: resized.path.split('/').last);
    }

    Response response = await Dio(dioOptions).post(
      'klepon/v1/update-group',
      data: FormData.fromMap(data),
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
