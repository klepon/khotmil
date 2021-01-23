import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';

// ini harusya hanya display page dan form saja, prosess di auth
class WidgetRegisterForm extends StatefulWidget {
  final String futureMessage;
  final Function changeForm;
  final Function registerApi;
  WidgetRegisterForm({Key key, this.futureMessage, this.changeForm, this.registerApi}) : super(key: key);

  @override
  _WidgetRegisterFormState createState() => _WidgetRegisterFormState();
}

class _WidgetRegisterFormState extends State<WidgetRegisterForm> {
  TextEditingController nickNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File _image;
  final picker = ImagePicker();

  Future _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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
              FlatButton(
                  onPressed: () => _getImage(),
                  child: Stack(
                    alignment: const Alignment(0.0, 0.8),
                    children: [
                      CircleAvatar(backgroundImage: AssetImage(_image != null ? _image.path : AnonImage), radius: 79),
                      if (_image == null) Text(UploadPhoto),
                    ],
                  )),
              SizedBox(height: 16.0),
              if (widget.futureMessage != '') Text(widget.futureMessage),
              MaterialButton(
                child: Text(RegisterText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    widget.registerApi(nickNameController.text, fullNameController.text, emailController.text, passwordController.text, phoneController.text, _image);
                  }
                },
                minWidth: double.infinity,
                height: 50.0,
                color: Color(int.parse('0xff0E5BF0')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
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
