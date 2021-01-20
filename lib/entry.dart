import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/login_user.dart';
import 'package:khotmil/fetch/recovery_pasword.dart';
import 'package:khotmil/fetch/register_user.dart';
import 'package:khotmil/fetch/validate_email.dart';
import 'package:khotmil/fetch/validate_recovery_pasword.dart';
import 'package:khotmil/widget/user_change_password.dart';
import 'package:khotmil/widget/user_edit_account.dart';
import 'package:khotmil/widget/page_full_screen_image.dart';
import 'package:khotmil/widget/group_list.dart';
import 'package:khotmil/widget/user_login_form.dart';
import 'package:khotmil/widget/user_login_page.dart';
import 'package:khotmil/widget/user_recovery_password_form.dart';
import 'package:khotmil/widget/user_recovery_password_validation_form.dart';
import 'package:khotmil/widget/user_register_form.dart';
import 'package:khotmil/widget/user_email_validation_form.dart';
import 'package:khotmil/widget/page_single_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String _futureMessage = '';
  String _currentForm = LoginText;
  String _loginKey = '';
  String _name = '';
  String _email = '';
  String _password = '';
  String _photo = '';

  bool _loadingOverlay = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _getLoginKey() async {
    setState(() {
      _loadingOverlay = true;
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loadingOverlay = false;
      _loginKey = prefs.getString(LoginKeyPref) ?? '';
      _name = prefs.getString(DisplayNamePref) ?? '';
      _photo = prefs.getString(UserPhotoPref) ?? '';
    });
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(LoginKeyPref, '');
    Navigator.pop(context);

    setState(() {
      _loginKey = '';
      _currentForm = FormLogin;
      _futureMessage = '';
    });
  }

  _changeForm(text) {
    setState(() {
      _currentForm = text;
      _futureMessage = '';
    });
  }

  _loginApi(String email, String password) async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
    });

    await fetchLoginUser(email, password).then((data) async {
      if (data[DataMessage] != null && data[DataMessage] != '') {
        setState(() {
          _loadingOverlay = false;
          _futureMessage = data[DataMessage];
        });
        return;
      }

      if (data['key'] != null && data['key'] != '') {
        await SharedPreferences.getInstance().then((prefs) async {
          prefs.setString(LoginKeyPref, data['key']);
          prefs.setString(DisplayNamePref, data['display_name']);
          prefs.setString(UserPhotoPref, data['photo']);
          return true;
        }).then((rs) {
          setState(() {
            _loadingOverlay = false;
          });
          _getLoginKey();
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  _registerApi(String name, String fullname, String email, String password, String phone, File photo) async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
      _name = name;
      _email = email;
      _password = password;
    });

    await fetchRegisterUser(name, fullname, email, password, phone, photo).then((data) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = data[DataMessage];
        if (data[DataStatus] == StatusSuccess) {
          _currentForm = FormEmailValidation;
        }
      });
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  _validationApi(String email, String password, String code) async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
      if ('' == _email || '' == _password) {
        _email = email;
        _password = password;
      }
    });

    await fetchValidateEmail('' == _email ? email : _email, '' == _password ? password : _password, code).then((data) async {
      if (data[DataMessage] != null && data[DataMessage] != '') {
        setState(() {
          _loadingOverlay = false;
          _futureMessage = data[DataMessage];
        });
        return;
      }

      if (data['key'] != null && data['key'] != '') {
        await SharedPreferences.getInstance().then((prefs) async {
          prefs.setString(LoginKeyPref, data['key']);
          prefs.setString(DisplayNamePref, data['display_name']);
          prefs.setString(UserPhotoPref, data['photo']);
          return true;
        }).then((rs) {
          setState(() {
            _loadingOverlay = false;
          });
          _getLoginKey();
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  _recoveryPasswordApi(String email) async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
      _email = email;
    });

    await fetchRecoveryPassword(email).then((data) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = data[DataMessage];
        if (data[DataStatus] == StatusSuccess) {
          _currentForm = FormRecoveryPasswordValidation;
        }
      });
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  _validationRecoveryPasswordApi(String email, String password, String code) async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
      if ('' == _email || '' == _password) {
        _email = email;
        _password = password;
      }
    });

    await fetchRecoveryPasword('' == _email ? email : _email, '' == _password ? password : _password, code).then((data) async {
      if (data[DataMessage] != null && data[DataMessage] != '') {
        setState(() {
          _loadingOverlay = false;
          _futureMessage = data[DataMessage];
        });
        return;
      }

      if (data['key'] != null && data['key'] != '') {
        await SharedPreferences.getInstance().then((prefs) async {
          prefs.setString(LoginKeyPref, data['key']);
          prefs.setString(DisplayNamePref, data['display_name']);
          prefs.setString(UserPhotoPref, data['photo']);
          return true;
        }).then((rs) {
          setState(() {
            _loadingOverlay = false;
          });
          _getLoginKey();
        });
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = e.toString();
      });
    });
  }

  _getForm() {
    switch (_currentForm) {
      case FormEmailValidation:
        return ValidationForm(
          futureMessage: _futureMessage,
          changeForm: _changeForm,
          validationApi: _validationApi,
          requiredUserPass: '' == _email || '' == _password,
        );

      case FormRegisterEmail:
        return RegisterForm(futureMessage: _futureMessage, changeForm: _changeForm, registerApi: _registerApi);

      case FormRecoveryPasswordValidation:
        return RecoveryEmailValidationForm(
          futureMessage: _futureMessage,
          changeForm: _changeForm,
          validationRecoveryPasswordApi: _validationRecoveryPasswordApi,
          requiredEmail: '' == _email,
        );

      case FormRecoveryPassword:
        return RecoveryPasswordForm(
          futureMessage: _futureMessage,
          changeForm: _changeForm,
          recoveryPasswordApi: _recoveryPasswordApi,
          newPassword: false,
        );

      default:
        return LoginForm(futureMessage: _futureMessage, changeForm: _changeForm, loginApi: _loginApi);
    }
  }

  _useLogo() {
    switch (_currentForm) {
      case FormEmailValidation:
        return false;

      case FormRegisterEmail:
        return false;

      case FormRecoveryPasswordValidation:
        return false;

      case FormRecoveryPassword:
        return false;

      default:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _getLoginKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Stack(
        children: [
          _loginKey == ''
              ? LoginRegister(currentForm: _getForm(), showLogo: _useLogo())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      FlatButton(
                          padding: mainPadding,
                          onPressed: () => _scaffoldKey.currentState.openDrawer(),
                          child: Row(children: [
                            CircleAvatar(backgroundImage: _photo != '' ? NetworkImage(_photo) : AssetImage(AnonImage)),
                            SizedBox(width: 8.0),
                            Text(_name, style: TextStyle(fontSize: 20.0)),
                          ])),
                      FlatButton(
                          padding: mainPadding,
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SingleApiPage(apiUrl: ApiDonation))),
                          child: Text(DonateText)),
                    ])),
                    Expanded(
                      child: GroupList(name: _name, loginKey: _loginKey),
                    ),
                  ],
                  // This trailing comma makes auto-formatting nicer for build methods.
                ),
          if (_loadingOverlay) loadingOverlay(context)
        ],
      )),
      drawer: Drawer(
        child: SafeArea(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FlatButton(
                padding: mainPadding,
                onPressed: () => Navigator.of(context).pop(),
                child: Row(children: [
                  CircleAvatar(backgroundImage: _photo != '' ? NetworkImage(_photo) : AssetImage(AnonImage)),
                  SizedBox(width: 8.0),
                  Text(_name, style: TextStyle(fontSize: 20.0))
                ])),
            ListTile(
                title: Text(EditAccount),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage(loginKey: _loginKey, reloadAuth: _getLoginKey)))),
            ListTile(
                title: Text(ChangePassword),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage(loginKey: _loginKey, logout: _logout)))),
            ListTile(title: Text(DoaKhatamanQuran), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImagePage(image: DoaKhatam)))),
            ListTile(title: Text(AboutAplication), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SingleApiPage(apiUrl: ApiAboutApp)))),
            ListTile(title: Text(ShareAplikastion), onTap: () {}),
            ListTile(title: Text(LogoutText), onTap: () => _logout()),
          ],
        )),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
