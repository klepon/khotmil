import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';

// ini harusya hanya display page dan form saja, prosess di auth
class RegisterForm extends StatefulWidget {
  final String futureMessage;
  final Function changeForm;
  final Function registerApi;
  RegisterForm({Key key, this.futureMessage, this.changeForm, this.registerApi}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  TextEditingController nickNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
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
              Center(child: Text(RegisterWithEmailFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
              TextFormField(
                controller: nickNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: EnterNickName, errorStyle: errorTextStyle),
                validator: (value) {
                  if (value.isEmpty) {
                    return NameRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: fullNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: EnterFullName, errorStyle: errorTextStyle),
              ),
              SizedBox(height: 8.0),
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
              SizedBox(height: 8.0),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: EnterPhone, errorStyle: errorTextStyle),
              ),
              SizedBox(height: 16.0),
              if (widget.futureMessage != '') Text(widget.futureMessage),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    widget.registerApi(nickNameController.text, fullNameController.text, emailController.text, passwordController.text, phoneController.text);
                  }
                },
                child: Text(RegisterText),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AlreadyHasAccount),
                  TextButton(
                      onPressed: () => widget.changeForm(FormLogin),
                      child: Text(LoginText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline))),
                ],
              ),
              TextButton(
                  onPressed: () => widget.changeForm(FormEmailValidation),
                  child: Text(EmailValidationText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline))),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    nickNameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
