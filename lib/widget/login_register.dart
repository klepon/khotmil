import 'package:flutter/material.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/widget/donation.dart';

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
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: 16.0),
              if (widget.showLogo)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 80 / 100,
                  child: Image(image: AssetImage(HeaderImage)),
                ),
              widget.currentForm,
              Column(
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    CopyRight,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 16.0),
                  RaisedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return Donation();
                    })),
                    child: Text(DonateText),
                    color: Color(int.parse('0xffFDAC0E')),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ],
          ),
        ),
      )),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
