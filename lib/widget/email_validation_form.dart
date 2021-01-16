import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';

// ini harusya hanya display page dan form saja, prosess di auth
class ValidationForm extends StatefulWidget {
  final String futureMessage;
  final Function changeForm;
  final Function validationApi;
  final bool requiredUserPass;
  ValidationForm({Key key, this.futureMessage, this.changeForm, this.validationApi, this.requiredUserPass}) : super(key: key);

  @override
  _ValidationFormState createState() => _ValidationFormState();
}

class _ValidationFormState extends State<ValidationForm> {
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
              Center(child: Text(ValidatedEmailFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
              if (widget.requiredUserPass)
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
              if (widget.requiredUserPass) SizedBox(height: 8.0),
              if (widget.requiredUserPass)
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
              if (widget.requiredUserPass) SizedBox(height: 16.0),
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
              SizedBox(height: 16.0),
              if (widget.futureMessage != '') Text(widget.futureMessage),
              if (widget.futureMessage != '') SizedBox(height: 8.0),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    widget.validationApi(emailController.text, passwordController.text, codeController.text);
                  }
                },
                child: Text(EmailValidationText),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(NoAccountYet),
                  TextButton(
                      onPressed: () => widget.changeForm(FormRegisterEmail),
                      child: Text(RegisterWithEmailNow, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline))),
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
