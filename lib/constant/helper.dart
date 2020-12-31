import 'package:flutter/material.dart';

final EdgeInsets mainPadding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
final EdgeInsets sidePadding = EdgeInsets.symmetric(horizontal: 16.0);
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
