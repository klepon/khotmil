import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchRegisterUser(String name, String fullname, String email, String password, String phone, File file) async {
  try {
    FormData formData;
    if (file != null) {
      File resizedFile = File(file.path)..writeAsBytesSync(img.encodeJpg(img.copyResize(img.decodeImage(file.readAsBytesSync()), width: ProfilePhotoWidth)));
      formData = FormData.fromMap({
        'name': name,
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'file': await MultipartFile.fromFile(resizedFile.path, filename: resizedFile.path.split('/').last),
      });
    } else {
      formData = FormData.fromMap({
        'name': name,
        'fullname': fullname,
        'email': email,
        'phone': phone,
      });
    }

    Response response = await Dio(dioOptions).post(
      'klepon/v1/register-user',
      data: formData,
    );

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailRegisterUser);
      }
    } else {
      throw Exception(FailRegisterUser);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
