import 'package:dio/dio.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

Future fetchShareLink() async {
  try {
    Response response = await Dio(dioOptions).post(
      'klepon/v1/get-share-links',
      data: {},
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
