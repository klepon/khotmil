import 'package:flutter/material.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/widget/page_single_api.dart';

class LoginRegister extends StatefulWidget {
  final Widget currentForm;
  final bool showLogo;
  LoginRegister({Key key, this.showLogo, this.currentForm}) : super(key: key);

  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: widget.showLogo ? null : pageBg,
        child: SingleChildScrollView(
          padding: sidePaddingWide,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
            ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 16.0),
                  if (widget.showLogo)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 80 / 100,
                      child: Image(image: AssetImage(HeaderImage)),
                    ),
                  widget.currentForm,
                  // Expanded(child: widget.currentForm),
                  Column(
                    children: [
                      Text(
                        CopyRight,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 16.0),
                      RaisedButton(
                        child: Text(DonateText),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return SingleApiPage(apiUrl: ApiDonation);
                        })),
                        color: Color(int.parse('0xffFDAC0E')),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
