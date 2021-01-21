import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/text.dart';

final EdgeInsets mainPadding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
final EdgeInsets sidePadding = EdgeInsets.symmetric(horizontal: 16.0);
final EdgeInsets sidePaddingWide = EdgeInsets.symmetric(horizontal: 30.0);
final EdgeInsets sidePaddingNarrow = EdgeInsets.symmetric(horizontal: 8.0);
final EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 8.0);
final BoxDecoration mainShadow = BoxDecoration(color: Colors.white, boxShadow: [
  BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 2,
    blurRadius: 3,
    // offset: Offset(0, 3), // changes position of shadow
  ),
]);
final TextStyle bold = TextStyle(fontWeight: FontWeight.bold);
final TextStyle boldLink = TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline);
TextStyle errorTextStyle = TextStyle(color: Colors.white);

Text textSmall(text) {
  return Text(
    text,
    style: TextStyle(color: Colors.black, fontSize: 12.0),
  );
}

Text textExtraSmall(text) {
  return Text(
    text,
    style: TextStyle(color: Colors.black, fontSize: 10.0),
  );
}

Row radio(checked, label) {
  return Row(
    children: [
      Container(
          width: 20.0,
          height: 20.0,
          margin: EdgeInsets.only(right: 4.0),
          decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: const Color(0xFFFFFFFF)), borderRadius: BorderRadius.circular(100.0), color: checked ? Colors.white : Colors.transparent)),
      Text(label, style: TextStyle(fontSize: 12.0)),
      SizedBox(width: 4.0)
    ],
  );
}

Container loadingOverlay(context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
      color: Color(0xbb000000),
    ),
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

BaseOptions dioOptions = new BaseOptions(
  baseUrl: ApiDomain,
  connectTimeout: 5000,
  receiveTimeout: 3000,
);

Decoration pageBg = BoxDecoration(
  image: DecorationImage(
    image: AssetImage(HeaderImage),
    fit: BoxFit.none,
    alignment: Alignment.bottomRight,
    colorFilter: ColorFilter.mode(Color(int.parse('0xff092128')).withOpacity(0.7), BlendMode.dstATop),
  ),
);

// double meters = 50;
// double lat = -8.705877;
// double long = 115.219421;
// // number of km per degree = ~111km (111.32 in google maps, but range varies
// // 1km in degree = 1 / 111.32km = 0.0089
// // 1m in degree = 0.0089 / 1000 = 0.0000089
// // pi / 180 = 0.018
// double coef = meters * 0.0000089;
// double newLat = lat + coef; // + move up to north, - move donw to south
// double newLong = long + coef / Math.cos(lat * 0.018); // + move right to east, - move left to west
