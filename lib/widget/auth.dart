import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/login_user.dart';
import 'package:khotmil/fetch/register_user.dart';
import 'package:khotmil/fetch/validate_email.dart';
import 'package:khotmil/widget/group_list.dart';
import 'package:khotmil/widget/login_form.dart';
import 'package:khotmil/widget/login_register.dart';
import 'package:khotmil/widget/register_form.dart';
import 'package:khotmil/widget/register_phone_form.dart';
import 'package:khotmil/widget/email_validation_form.dart';
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

  bool _loadingOverlay = false;

  _toggleLoadingOverlay() {
    setState(() {
      _loadingOverlay = !_loadingOverlay;
    });
  }

  _getLoginKey() async {
    setState(() {
      _loadingOverlay = true;
    });
    final prefs = await SharedPreferences.getInstance();
    // prefs.setString(LoginKeyPref, '');
    setState(() {
      _loadingOverlay = false;
      _loginKey = prefs.getString(LoginKeyPref) ?? '';
      _name = prefs.getString(DisplayNamePref) ?? '';
    });
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(LoginKeyPref, '');
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
          return true;
        }).then((rs) {
          setState(() {
            _loadingOverlay = false;
          });
          _getLoginKey();
        });
      }
    });
  }

  _registerApi(String name, String email, String password) async {
    setState(() {
      _loadingOverlay = true;
      _futureMessage = '';
      _name = name;
      _email = email;
      _password = password;
    });

    await fetchRegisterUser(name, email, password).then((data) {
      setState(() {
        _loadingOverlay = false;
        _futureMessage = data[DataMessage];
        if (data[DataStatus] == StatusSuccess) {
          _currentForm = FormEmailValidation;
        }
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
          return true;
        }).then((rs) {
          setState(() {
            _loadingOverlay = false;
          });
          _getLoginKey();
        });
      }
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

      case FormRegisterPhone:
        return RegisterPhoneForm(futureMessage: _futureMessage, changeForm: _changeForm, registerApi: _registerApi);
      default:
        return LoginForm(futureMessage: _futureMessage, changeForm: _changeForm, loginApi: _loginApi);
    }
  }

  @override
  void initState() {
    super.initState();
    _getLoginKey();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _loginKey == '' ? LoginRegister(currentForm: _getForm()) : GroupList(toggleLoading: _toggleLoadingOverlay, name: _name, loginKey: _loginKey, logout: _logout),
        if (_loadingOverlay) loadingOverlay(context)
      ],
    );
  }
}
