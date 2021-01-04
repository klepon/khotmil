// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
// import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
// import 'package:sms/sms.dart';

class RegisterPhoneForm extends StatefulWidget {
  final String futureMessage;
  final Function changeForm;
  final Function registerApi;
  RegisterPhoneForm({Key key, this.futureMessage, this.changeForm, this.registerApi}) : super(key: key);

  @override
  _RegisterPhoneFormState createState() => _RegisterPhoneFormState();
}

class _RegisterPhoneFormState extends State<RegisterPhoneForm> {
  // TextEditingController nameController = TextEditingController();
  // TextEditingController phoneController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // String phoneNumber = "82144032624";
  // String validationCode = (1000 + Random().nextInt(9999 - 1000)).toString();

  // @override
  // void initState() {
  //   super.initState();

  //   // SmsSender sender = new SmsSender();
  //   // sender.sendSms(new SmsMessage('+62' + phoneNumber, 'Kode validasi : ' + validationCode));
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: mainPadding,
      child: Column(
        children: [
          Text('Pendaftaran dengan nomor telpon sementara belum tersedia'),
          TextButton(onPressed: () => widget.changeForm(LoginText), child: Text(LoginText, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Form(
  //       key: _formKey,
  //       child: Container(
  //         padding: mainPadding,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Center(child: Text(RegisterWithPhoneFormTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
  //             TextFormField(
  //               controller: nameController,
  //               keyboardType: TextInputType.text,
  //               decoration:  InputDecoration(
  //                 hintText: EnterName, errorStyle: errorTextStyle
  //               ),
  //               validator: (value) {
  //                 if (value.isEmpty) {
  //                   return NameRequired;
  //                 }
  //                 return null;
  //               },
  //             ),
  //             SizedBox(height: 8.0),
  //             TextFormField(
  //               controller: phoneController,
  //               keyboardType: TextInputType.number,
  //               decoration:  InputDecoration(
  //                 hintText: EnterPhone, errorStyle: errorTextStyle
  //               ),
  //               validator: (value) {
  //                 if (value.isEmpty || value.length < 10) {
  //                   return PhoneRequired;
  //                 }
  //                 return null;
  //               },
  //             ),
  //             SizedBox(height: 8.0),
  //             TextFormField(
  //               controller: passwordController,
  //               keyboardType: TextInputType.visiblePassword,
  //               enableSuggestions: false,
  //               autocorrect: false,
  //               obscureText: true,
  //               decoration:  InputDecoration(
  //                 hintText: EnterPassword, errorStyle: errorTextStyle
  //               ),
  //               validator: (value) {
  //                 if (value.isEmpty) {
  //                   return PasswordRequired;
  //                 }
  //                 return null;
  //               },
  //             ),
  //             SizedBox(height: 16.0),
  //             if (widget.futureMessage != '') Text(widget.futureMessage),
  //             RaisedButton(
  //               onPressed: () async {
  //                 if (_formKey.currentState.validate()) {
  //                   widget.registerApi(nameController.text, phoneController.text, passwordController.text);
  //                 }
  //               },
  //               child: Text(RegisterText),
  //             ),
  //             SizedBox(height: 16.0),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(AlreadyHasAccount),
  //                 TextButton(onPressed: () => widget.changeForm(LoginText), child: Text(LoginText, style: TextStyle(fontWeight: FontWeight.bold))),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ));
  // }

  // @override
  // void dispose() {
  //   nameController.dispose();
  //   phoneController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }

}
