import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/user_update_password.dart';

class WidgetChangePassword extends StatefulWidget {
  final String loginKey;
  final Function logout;
  WidgetChangePassword({Key key, this.loginKey, this.logout}) : super(key: key);

  @override
  _WidgetChangePasswordState createState() => _WidgetChangePasswordState();
}

class _WidgetChangePasswordState extends State<WidgetChangePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingOverlay = false;
  String _futureMessage = '';

  _updatePassword() async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
    });

    await fetchUpdatePassword(widget.loginKey, emailController.text, passwordController.text, newPasswordController.text).then((data) async {
      if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
          _futureMessage = data[DataMessage];
        });
      }

      if (data[DataStatus] == StatusSuccess) {
        Navigator.of(context).pop();
        widget.logout();
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(AppTitle)),
      body: Stack(children: [
        SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Container(
                padding: mainPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(child: Text(ChangePassword, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: EnterEmail, errorStyle: errorTextStyle),
                      validator: (value) {
                        if (value.isEmpty || !EmailValidator.validate(value)) {
                          return EmailRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      decoration: InputDecoration(hintText: EnterOldPassword, errorStyle: errorTextStyle),
                      validator: (value) {
                        if (value.isEmpty) {
                          return PasswordRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      controller: newPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      decoration: InputDecoration(hintText: EnterNewPassword, errorStyle: errorTextStyle),
                      validator: (value) {
                        if (value.isEmpty) {
                          return PasswordRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    if (_futureMessage != '') Text(_futureMessage),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          child: Text(SaveText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          onPressed: () => _updatePassword(),
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          height: 50.0,
                          color: Color(int.parse('0xff2DA310')),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                        ),
                        MaterialButton(
                          child: Text(CancelText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          height: 50.0,
                          color: Color(int.parse('0xffC4C4C4')),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                        ),
                      ],
                    )
                  ],
                ),
              )),
        ),
        if (_loadingOverlay) loadingOverlay(context)
      ]),
    );
  }
}
