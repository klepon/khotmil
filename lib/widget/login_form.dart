import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';

// ini harusya hanya display page dan form saja, prosess di auth
class LoginForm extends StatefulWidget {
  final String futureMessage;
  final Function changeForm;
  final Function loginApi;
  LoginForm({Key key, this.futureMessage, this.changeForm, this.loginApi}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
              Center(child: Text(LoginFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
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
                decoration: InputDecoration(hintText: EnterPassword, errorStyle: errorTextStyle),
                validator: (value) {
                  if (value.isEmpty) {
                    return PasswordRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              if (widget.futureMessage != '') Text(widget.futureMessage),
              RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      widget.loginApi(emailController.text, passwordController.text);
                    }
                  },
                  child: Text(LoginText)),
              SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(NoAccountYet),
                    TextButton(onPressed: () => widget.changeForm(FormRegisterEmail), child: Text(RegisterWithEmailNow, style: TextStyle(fontWeight: FontWeight.bold)))
                  ]),
                  TextButton(onPressed: () => widget.changeForm(FormRecoveryPassword), child: Text(RecoveryPassword, style: TextStyle(fontWeight: FontWeight.bold))),
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
