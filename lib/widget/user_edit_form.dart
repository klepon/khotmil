import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/delete_admin.dart';
import 'package:khotmil/fetch/group_search_by_name.dart';
import 'package:khotmil/fetch/user_get_data.dart';
import 'package:khotmil/fetch/user_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class WidgetEditAccount extends StatefulWidget {
  final String loginKey;
  final Function reloadAuth;
  WidgetEditAccount({Key key, this.loginKey, this.reloadAuth}) : super(key: key);

  @override
  _WidgetEditAccountState createState() => _WidgetEditAccountState();
}

class _WidgetEditAccountState extends State<WidgetEditAccount> {
  TextEditingController _nickNameController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FocusNode _focusNameNode = FocusNode();

  bool _searchNameLoading = false;
  bool _nameExist = false;
  String _searchNameMessage = '';
  String _lastCheckedName = '';
  String _originalName = '';

  bool _loadingOverlay = false;
  String _photo = '';
  List<dynamic> _admins = new List<dynamic>();

  File _image;
  final picker = ImagePicker();

  _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photo = '';
        _image = File(pickedFile.path);
      });
    }
  }

  _getGroupName() async {
    if (_lastCheckedName == _nickNameController.text || _originalName == _nickNameController.text) {
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

    await fetchSearchGroupByName(_nickNameController.text, 'user').then((data) {
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

  _apiGetUserData() async {
    setState(() {
      _loadingOverlay = true;
    });

    await fetchGetUserData(widget.loginKey).then((data) async {
      if (data['email'] != null && data['email'] != '') {
        setState(() {
          _originalName = data['name'];
          _loadingOverlay = false;
          _fullNameController.text = data['fullname'];
          _nickNameController.text = data['name'];
          _emailController.text = data['email'];
          _phoneController.text = data['phone'];
          _photo = data['photo'];
          _admins = data['admins'].length == 0 ? new List() : data['admins'].entries.map((entry) => entry.value).toList();
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, e.toString());
    });
  }

  _apiUpdateUserData() async {
    setState(() {
      _loadingOverlay = true;
    });

    await fetchUpdateUserData(widget.loginKey, _nickNameController.text, _fullNameController.text, _emailController.text, _phoneController.text, _image).then((data) async {
      if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      }

      if (data[DataStatus] == StatusSuccess) {
        await SharedPreferences.getInstance().then((prefs) async {
          prefs.setString(DisplayNamePref, data['name']);
          prefs.setString(UserPhotoPref, data['photo']);
          Navigator.pop(context);
          return true;
        }).then((rs) {
          setState(() {
            _loadingOverlay = false;
            _fullNameController.text = data['fullname'];
            _nickNameController.text = data['name'];
            _emailController.text = data['email'];
            _phoneController.text = data['phone'];
            _photo = data['photo'];
          });

          widget.reloadAuth();
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, e.toString());
    });
  }

  void _apiDeleteAdmin(int uid, String gid) async {
    Navigator.pop(context);

    setState(() {
      _loadingOverlay = true;
    });

    await fetchDeleteAdmin(widget.loginKey, uid, gid).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, QuitAdminsGroupsSuccess);
        _apiGetUserData();
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    _apiGetUserData();

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
    _phoneController.dispose();

    _focusNameNode.dispose();

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text(EditAccountFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
                    SizedBox(height: 16.0),
                    Center(
                        child: FlatButton(
                            onPressed: () => _getImage(),
                            child: Stack(
                              alignment: const Alignment(0.0, 0.8),
                              children: [
                                CircleAvatar(backgroundImage: _photo != '' ? NetworkImage(_photo) : AssetImage(_image != null ? _image.path : AnonImage), radius: 79),
                                if (_image == null) Text(UploadPhoto),
                              ],
                            ))),
                    SizedBox(height: 8.0),
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(hintText: EnterPhone, errorStyle: errorTextStyle),
                    ),
                    SizedBox(height: 24.0),
                    if (_admins.length > 0) Text(AdminsGroups, style: bold, textAlign: TextAlign.left),
                    if (_admins.length > 0)
                      for (var admin in _admins)
                        Row(
                          children: [
                            Container(padding: EdgeInsets.symmetric(vertical: 16.0), child: Text(admin['name'])),
                            if (!admin['owner'])
                              IconButton(
                                  icon: Icon(Icons.delete_forever),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                            content: Column(mainAxisSize: MainAxisSize.min, children: [
                                              Text(sprintf(QuitAdminsGroupsWarning, [admin['name']]), textAlign: TextAlign.center),
                                              SizedBox(height: 24.0),
                                              MaterialButton(
                                                child: Text(YesText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                                onPressed: () => _apiDeleteAdmin(admin['uid'], admin['id'].toString()),
                                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                                height: 50.0,
                                                color: Color(int.parse('0xffF30F0F')),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                                              )
                                            ]),
                                            actions: [FlatButton(onPressed: () => Navigator.pop(context), child: Text(CancelText))]));
                                  }),
                          ],
                        ),
                    SizedBox(height: 8.0),
                    SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          child: Text(SaveText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            await _getGroupName();

                            if (_formKey.currentState.validate()) {
                              _apiUpdateUserData();
                            } else {
                              modalMessage(context, FormErrorMessage);
                            }
                          },
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
