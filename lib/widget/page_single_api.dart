import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/donation_info.dart';

class SingleApiPage extends StatefulWidget {
  final String apiUrl;
  SingleApiPage({Key key, this.apiUrl}) : super(key: key);

  @override
  _SingleApiPageState createState() => _SingleApiPageState();
}

class _SingleApiPageState extends State<SingleApiPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingOverlay = false;
  String _message = '';

  _getApiPage() async {
    setState(() {
      _loadingOverlay = true;
      _message = '';
    });

    await fetchApiPage(widget.apiUrl).then((data) async {
      if (data['message'] != null && data['message'] != '') {
        setState(() {
          _loadingOverlay = false;
          _message = data['message'];
        });
        return;
      } else {
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

    _getApiPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(AppTitle)),
        body: Stack(children: [
          Container(
            padding: mainPadding,
            width: double.infinity,
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
                  if (_message != '')
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
          if (_loadingOverlay) loadingOverlay(context)
        ]));
  }
}
