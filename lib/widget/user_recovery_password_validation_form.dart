import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';

// ini harusya hanya display page dan form saja, prosess di auth
class WidgetRecoveryEmailValidation extends StatefulWidget {
  final Function changeForm;
  final Function validationRecoveryPasswordApi;
  final bool requiredEmail;
  WidgetRecoveryEmailValidation({Key key, this.changeForm, this.validationRecoveryPasswordApi, this.requiredEmail}) : super(key: key);

  @override
  _WidgetRecoveryEmailValidationState createState() => _WidgetRecoveryEmailValidationState();
}

class _WidgetRecoveryEmailValidationState extends State<WidgetRecoveryEmailValidation> {
  TextEditingController codeController = TextEditingController();
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
              TextFormField(
                controller: codeController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: ValidationCode, errorStyle: errorTextStyle),
                validator: (value) {
                  if (value.isEmpty) {
                    return ValidationCodeRequired;
                  }
                  return null;
                },
              ),
              if (widget.requiredEmail)
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
              if (widget.requiredEmail) SizedBox(height: 8.0),
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
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    widget.validationRecoveryPasswordApi(emailController.text, passwordController.text, codeController.text);
                  }
                },
                child: Text(SubmitText),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
    codeController.dispose();
    super.dispose();
  }
}
