import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:khotmil/constant/assets.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/html_parser.dart';
// import 'package:flutter_html/style.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/donation_info.dart';

class Donation extends StatefulWidget {
  @override
  _DonationState createState() => _DonationState();
}

class _DonationState extends State<Donation> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingOverlay = false;
  String _message = '';

  _getDonateINfoApi() async {
    setState(() {
      _loadingOverlay = true;
      _message = '';
    });

    await fetchDonationInfo().then((data) async {
      if (data['message'] != null && data['message'] != '') {
        setState(() {
          _loadingOverlay = false;
          _message = data['message'];
        });
        return;
      } else {
        print(data);

        setState(() {
          _loadingOverlay = false;
          _message = 'error';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _getDonateINfoApi();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.width * 80 / 100,
      //   child: Image(image: AssetImage(HeaderImage)),
      // ),
      Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(AppTitle),
        ),
        body: Container(
          padding: mainPadding,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(HeaderImage),
              fit: BoxFit.none,
              alignment: Alignment.bottomRight,
              colorFilter: ColorFilter.mode(Color(int.parse('0xff092128')).withOpacity(0.7), BlendMode.dstATop),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_message != '')
                  Html(
                    data: _message,
                    style: {"*": Style(textAlign: TextAlign.center, fontSize: FontSize(14.0)), "strong": Style(fontSize: FontSize(16.0))},
                  ),
                SizedBox(
                  height: 54.0,
                ),
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(OkText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  height: 38.0,
                  color: Color(int.parse('0xffF30F0F')),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                )
              ],
            ),
          ),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
      if (_loadingOverlay) loadingOverlay(context)
    ]);
  }
}
