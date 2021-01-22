import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchUpdateUserData(String key, String name, String fullname, String email, String phone, File file) async {
  try {
    Map<String, dynamic> data = {
      'user_key': key,
      'name': name,
      'fullname': fullname,
      'email': email,
      'phone': phone,
    };

    if (file != null) {
      File(file.path)..writeAsBytesSync(img.encodeJpg(img.copyResize(img.decodeImage(File(file.path).readAsBytesSync()), width: ProfilePhotoWidth)));
      data['file'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
    }

    Response response = await Dio(dioOptions).post(
      'klepon/v1/update-user-data',
      data: FormData.fromMap(data),
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailLoadingUser);
      }
    } else {
      throw Exception(FailLoadingUser);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
