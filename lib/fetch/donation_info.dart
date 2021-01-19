import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchApiPage(apiUrl) async {
  try {
    Response response = await Dio(dioOptions).post(apiUrl, data: {});

    if (response.statusCode == 200) {
      if (response.data[DataStatus] == StatusSuccess || response.data[DataStatus] == StatusError) {
        return response.data;
      } else {
        throw Exception(FailValidateUser);
      }
    } else {
      throw Exception(FailValidateUser);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
