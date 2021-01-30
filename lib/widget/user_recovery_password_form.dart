import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';

// ini harusya hanya display page dan form saja, prosess di auth
class WidgetRecoveryPassword extends StatefulWidget {
  final bool newPassword;
  final Function changeForm;
  final Function recoveryPasswordApi;
  WidgetRecoveryPassword({Key key, this.newPassword, this.changeForm, this.recoveryPasswordApi}) : super(key: key);

  @override
  _WidgetRecoveryPasswordState createState() => _WidgetRecoveryPasswordState();
}

class _WidgetRecoveryPasswordState extends State<WidgetRecoveryPassword> {
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
              Center(child: Text(RecoveryPasswordFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
              if (!widget.newPassword)
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
              if (widget.newPassword)
                TextFormField(
                  controller: passwordController,
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
              if (!widget.newPassword)
                RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      widget.recoveryPasswordApi(emailController.text);
                    }
                  },
                  child: Text(SubmitText),
                ),
              if (widget.newPassword)
                RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      widget.recoveryPasswordApi(emailController.text);
                    }
                  },
                  child: Text(SubmitText),
                ),
              SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () => widget.changeForm(FormRecoveryPasswordValidation),
                      child: Text(RecoveryPasswordEmailValidationText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline))),
                  TextButton(
                      onPressed: () => widget.changeForm(FormLogin),
                      child: Text(LoginText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline))),
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
