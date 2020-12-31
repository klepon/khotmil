import 'package:flutter/material.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/text.dart';

class LoginRegister extends StatefulWidget {
  final Widget currentForm;
  LoginRegister({Key key, this.currentForm}) : super(key: key);

  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: 16.0),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 80 / 100,
                child: Image(image: AssetImage(HeaderImage)),
              ),
              widget.currentForm,
              Column(
                children: [
                  Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.width * 20 / 100, child: Image(image: AssetImage(FooterLogo))),
                  SizedBox(height: 16.0),
                  Text(CopyRight),
                  SizedBox(height: 16.0),
                ],
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
