import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:khotmil/fetch/search_name.dart';

// ini harusya hanya display page dan form saja, prosess di auth
class WidgetRegisterForm extends StatefulWidget {
  final Function changeForm;
  final Function registerApi;
  WidgetRegisterForm({Key key, this.changeForm, this.registerApi}) : super(key: key);

  @override
  _WidgetRegisterFormState createState() => _WidgetRegisterFormState();
}

class _WidgetRegisterFormState extends State<WidgetRegisterForm> {
  TextEditingController _nickNameController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode _focusNameNode = FocusNode();

  bool _searchNameLoading = false;
  bool _nameExist = false;
  String _searchNameMessage = '';
  String _lastCheckedName = '';

  File _image;
  final picker = ImagePicker();

  _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  _getGroupName() async {
    if (_lastCheckedName == _nickNameController.text) {
      if (_searchNameMessage != '') {
        setState(() {
          _searchNameMessage = '';
          _nameExist = false;
        });
      }

      return;
    }

    setState(() {
      _nameExist = false;
      _searchNameLoading = true;
      _searchNameMessage = '';
      _lastCheckedName = _nickNameController.text;
    });

    await fetchSearchName(_nickNameController.text, 'user').then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _nameExist = data['data'];
          _searchNameMessage = data['data'] ? NickNameExistMessage : '';
          _searchNameLoading = false;
        });
      }
      if (data[DataStatus] == StatusError) {
        setState(() {
          _searchNameLoading = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        _searchNameLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _nickNameController.addListener(() {
      if (_nickNameController.text != '' && !_focusNameNode.hasFocus) {
        _getGroupName();
      }
    });
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();

    _focusNameNode.dispose();

    super.dispose();
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
                controller: _nickNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: EnterNickName, errorStyle: errorTextStyle),
                focusNode: _focusNameNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return NameRequired;
                  }

                  if (value.isNotEmpty && _nameExist == true) {
                    return NickNameExistShort;
                  }
                  return null;
                },
              ),
              if (_searchNameLoading)
                Container(
                    padding: verticalPadding,
                    child: Column(children: [
                      Center(child: LinearProgressIndicator()),
                      Text(NickNameChecking),
                    ])),
              if (_searchNameMessage != '') Text(_searchNameMessage),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _fullNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: EnterFullName, errorStyle: errorTextStyle),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _emailController,
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
                controller: _passwordController,
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
                controller: _phoneController,
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
              MaterialButton(
                child: Text(RegisterText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  await _getGroupName();

                  if (_formKey.currentState.validate()) {
                    widget.registerApi(_nickNameController.text, _fullNameController.text, _emailController.text, _passwordController.text, _phoneController.text, _image);
                  } else {
                    modalMessage(context, FormErrorMessage);
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
}
