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
  TextEditingController nameController = TextEditingController();
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
              Center(child: Text(RegisterFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: EnterName,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return NameRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: EnterEmail,
                ),
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
                decoration: const InputDecoration(
                  hintText: EnterPassword,
                ),
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
                    widget.registerApi(nameController.text, emailController.text, passwordController.text);
                  }
                },
                child: Text(RegisterText),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(HasAccountYet),
                  TextButton(onPressed: () => widget.changeForm(LoginText), child: Text(LoginText, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
