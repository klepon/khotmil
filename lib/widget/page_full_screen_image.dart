import 'package:flutter/material.dart';
import 'package:khotmil/constant/text.dart';

class FullScreenImagePage extends StatelessWidget {
  final String image;
  FullScreenImagePage({Key key, this.image}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(AppTitle)),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Column(
              children: [
                Image(
                  image: AssetImage(image),
                ),
                SizedBox(height: 16.0),
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(OKText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  height: 38.0,
                  color: Color(int.parse('0xffF30F0F')),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                )
              ],
            ),
          ),
        ));
  }
}
