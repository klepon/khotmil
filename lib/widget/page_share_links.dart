import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/share_link.dart';
import 'package:share/share.dart';

class ShareLinksPage extends StatefulWidget {
  @override
  _ShareLinksPageState createState() => _ShareLinksPageState();
}

class _ShareLinksPageState extends State<ShareLinksPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingOverlay = false;
  Map _links;

  _apiGetShareLink() async {
    setState(() {
      _loadingOverlay = true;
    });

    await fetchShareLink().then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _loadingOverlay = false;
          _links = data['links'];
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, e.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    _apiGetShareLink();
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
            decoration: pageBg,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(ShareLinksTitle, style: bold),
                  if (_links != null)
                    for (var i in _links.entries
                        .where((i) => i.value != '')
                        .map<Widget>(
                          (i) => Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: MaterialButton(
                                child: Text(i.key, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                onPressed: () => Share.share(i.value),
                                height: 50.0,
                                color: Color(int.parse('0xff2DA310')),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              )),
                        )
                        .toList())
                      i,
                ],
              ),
            ),
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
          if (_loadingOverlay) loadingOverlay(context)
        ]));
  }
}
