import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';

// ini harusya hanya display page dan form saja, prosess di entry.dart
class WidgetUserLogin extends StatefulWidget {
  final Function changeForm;
  final Function loginApi;
  WidgetUserLogin({Key key, this.changeForm, this.loginApi}) : super(key: key);

  @override
  _WidgetUserLoginState createState() => _WidgetUserLoginState();
}

class _WidgetUserLoginState extends State<WidgetUserLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          padding: mainPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: EnterEmail,
                  hintStyle: TextStyle(color: Color(int.parse('0xff747070'))),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                  errorStyle: errorTextStyle,
                  filled: true,
                  fillColor: Color(int.parse('0xffC4C4C4')),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      )),
                ),
                style: TextStyle(color: Color(int.parse('0xff747070'))),
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
                decoration: InputDecoration(
                  hintText: EnterPassword,
                  hintStyle: TextStyle(color: Color(int.parse('0xff747070'))),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                  errorStyle: errorTextStyle,
                  filled: true,
                  fillColor: Color(int.parse('0xffC4C4C4')),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      )),
                ),
                style: TextStyle(color: Color(int.parse('0xff747070'))),
                validator: (value) {
                  if (value.isEmpty) {
                    return PasswordRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              MaterialButton(
                child: Text(LoginText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    widget.loginApi(emailController.text, passwordController.text);
                  }
                },
                minWidth: double.infinity,
                height: 50.0,
                color: Color(int.parse('0xff0E5BF0')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
              ),
              SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(NoAccountYet),
                    TextButton(
                        onPressed: () => widget.changeForm(FormRegisterEmail),
                        child: Text(RegisterWithEmailNow, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline)))
                  ]),
                  TextButton(
                      onPressed: () => widget.changeForm(FormRecoveryPassword),
                      child: Text(RecoveryPassword, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline))),
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
