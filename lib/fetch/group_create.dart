import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchCreateGroup(String key, String name, String address, String latlong, String round, String date, List uids, File file) async {
  try {
    File resized = File(file.path)..writeAsBytesSync(img.encodeJpg(img.copyResize(img.decodeImage(File(file.path).readAsBytesSync()), width: ProfilePhotoWidth)));

    Map<String, dynamic> data = {
      'user_key': key,
      'name': name,
      'address': address,
      'latlong': latlong,
      'round': round,
      'round_end_date': date,
      'member_ids': uids,
    };

    if (file != null) {
      data['file'] = await MultipartFile.fromFile(resized.path, filename: resized.path.split('/').last);
    }

    Response response = await Dio(dioOptions).post(
      'klepon/v1/create-group',
      data: FormData.fromMap(data),
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
