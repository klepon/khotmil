import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/get_user_data.dart';
import 'package:khotmil/fetch/update_user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAccountPage extends StatefulWidget {
  final String loginKey;
  final Function reloadAuth;
  EditAccountPage({Key key, this.loginKey, this.reloadAuth}) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  TextEditingController nickNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingOverlay = false;
  String _futureMessage = '';
  String _photo = '';

  File _image;
  final picker = ImagePicker();

  Future _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photo = '';
        _image = File(pickedFile.path);
      });
    }
  }

  _getUserData() async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
    });

    await fetchGetUserData(widget.loginKey).then((data) async {
      if (data['email'] != null && data['email'] != '') {
        setState(() {
          _loadingOverlay = false;
          fullNameController.text = data['fullname'];
          nickNameController.text = data['name'];
          emailController.text = data['email'];
          phoneController.text = data['phone'];
          _photo = data['photo'];
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  _updateUserData() async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
    });

    await fetchUpdateUserData(widget.loginKey, nickNameController.text, fullNameController.text, emailController.text, phoneController.text, _image).then((data) async {
      if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
          _futureMessage = data[DataMessage];
        });
      }

      if (data[DataStatus] == StatusSuccess) {
        await SharedPreferences.getInstance().then((prefs) async {
          prefs.setString(DisplayNamePref, data['name']);
          prefs.setString(UserPhotoPref, data['photo']);
          return true;
        }).then((rs) {
          setState(() {
            _loadingOverlay = false;
            fullNameController.text = data['fullname'];
            nickNameController.text = data['name'];
            emailController.text = data['email'];
            phoneController.text = data['phone'];
            _photo = data['photo'];
          });

          widget.reloadAuth();
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    nickNameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
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
                    Center(child: Text(EditAccountFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
                    SizedBox(height: 16.0),
                    FlatButton(
                        onPressed: () => _getImage(),
                        child: Stack(
                          alignment: const Alignment(0.0, 0.8),
                          children: [
                            CircleAvatar(backgroundImage: _photo != '' ? NetworkImage(_photo) : AssetImage(_image != null ? _image.path : AnonImage), radius: 79),
                            if (_image == null) Text(UploadPhoto),
                          ],
                        )),
                    SizedBox(height: 8.0),
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
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(hintText: EnterPhone, errorStyle: errorTextStyle),
                    ),
                    SizedBox(height: 8.0),
                    // Text('list admin group disini'),
                    SizedBox(height: 16.0),
                    if (_futureMessage != '') Text(_futureMessage),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          child: Text(SaveText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          onPressed: () => _updateUserData(),
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
