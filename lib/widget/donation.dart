import 'package:flutter/material.dart';
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
  String _title = '';
  String _body = '';

  _getDonateINfoApi() async {
    setState(() {
      _loadingOverlay = true;
      _title = '';
      _body = '';
    });

    await fetchDonationInfo().then((data) async {
      if (data['title'] != null || data['body'] != null) {
        setState(() {
          _loadingOverlay = false;
          _title = data['title'];
          _body = data['body'];
        });
        return;
      } else {
        print(data);

        setState(() {
          _loadingOverlay = false;
          _body = 'error';
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
      Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(AppTitle),
        ),
        body: Container(
          padding: mainPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_title != '') SizedBox(height: 16.0),
              if (_title != '') Text(_title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              if (_title != '') SizedBox(height: 16.0),
              if (_body != '') Text(_body),
            ],
          ),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
      if (_loadingOverlay) loadingOverlay(context)
    ]);
  }
}
