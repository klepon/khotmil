import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/create_group.dart';
import 'package:khotmil/fetch/my_group_list.dart';
import 'package:khotmil/widget/group_detail.dart';

import 'group_item.dart';

class GroupList extends StatefulWidget {
  final String name;
  final String loginKey;
  final Function logout;
  final Function toggleLoading;
  GroupList({Key key, this.name, this.loginKey, this.logout, this.toggleLoading}) : super(key: key);

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future _futureGetGroupList;
  String _screenState = StateGroupList;
  String _defaultColor = 'f6d55c';
  String _messageText = '';

  TextEditingController nameFormController = TextEditingController();
  TextEditingController addressFormController = TextEditingController();
  TextEditingController latlongFormController = TextEditingController();
  TextEditingController colorFormController = TextEditingController();
  TextEditingController endDateFormController = TextEditingController();
  TextEditingController uidsFormController = TextEditingController();

  DateTime selectedRoundEndDateForm = DateTime.now();

  Future<void> _renderSelectDate(BuildContext context) async {
    DateTime date = DateTime.now();
    final DateTime picked = await showDatePicker(context: context, initialDate: selectedRoundEndDateForm, firstDate: date, lastDate: DateTime(date.year, date.month + 3));
    if (picked != null && picked != selectedRoundEndDateForm) endDateFormController.text = (picked.toString()).split(' ')[0];
    // setState(() {
    //   selectedRoundEndDateForm = picked;
    // });
  }

  void _apiGroupList() {
    setState(() {
      _futureGetGroupList = fetchMyGroupList(widget.loginKey);
    });
  }

  void _apiCreateGroup() async {
    widget.toggleLoading();
    setState(() {
      _messageText = '';
    });

    await fetchCreateGroup(
      widget.loginKey,
      nameFormController.text,
      addressFormController.text,
      latlongFormController.text,
      colorFormController.text != '' ? colorFormController.text : _defaultColor,
      endDateFormController.text,
      uidsFormController.text.split(','),
    ).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _futureGetGroupList = fetchMyGroupList(widget.loginKey);
          _screenState = StateGroupList;
          nameFormController.text = '';
          addressFormController.text = '';
          latlongFormController.text = '';
          colorFormController.text = '';
          endDateFormController.text = '';
          uidsFormController.text = '';
        });
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _messageText = data[DataMessage];
        });
      }

      widget.toggleLoading();
    }).catchError((onError) {
      widget.toggleLoading();
      setState(() {
        _messageText = onError.toString();
      });
    });
  }

  void _toggleScreenState(state) {
    setState(() {
      _screenState = state;
    });
  }

  Widget _loopGroups(groups, context) {
    List<Widget> buttons = new List<Widget>();
    for (var i = 0; i < groups.length; i += 1) {
      var group = groups[i];
      buttons.add(FlatButton(
        padding: EdgeInsets.all(0.00),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return GroupDetail(
              groupName: group['name'],
              progress: group['progress'].toString(),
              round: group['round'].toString(),
              deadline: group['end_date'].toString(),
              yourJuz: group['my_juz'].toString(),
              yourProgress: group['my_progress'].toString(),
              groupColor: group['color'],
            );
          }));
        },
        child: GroupItem(
          groupName: group['name'],
          progress: group['progress'].toString(),
          round: group['round'].toString(),
          deadline: group['end_date'].toString(),
          yourJuz: group['my_juz'].toString(),
          yourProgress: group['my_progress'].toString(),
          groupColor: group['color'],
        ),
      ));
    }

    return Column(
      children: buttons,
    );
  }

  Widget _myGroupList(context) {
    return FutureBuilder(
      future: _futureGetGroupList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['message'] != null) {
            return Text(TextCode[snapshot.data['message']]);
          }

          return _loopGroups(snapshot.data['groups'], context);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return Column(
          children: [Container(padding: mainPadding, child: Text(LoadingGroups)), SizedBox(height: 16.0), Center(child: CircularProgressIndicator())],
        );
      },
    );
  }

  _getTimeStamp() {
    String ts = DateTime.parse(endDateFormController.text + ' 00:00:00.000').millisecondsSinceEpoch.toString();
    return ts.substring(0, ts.length - 3);
  }

  Widget _createGroupForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 16.0),
          Text(CreateGroup, style: bold),
          SizedBox(height: 16.0),
          if (nameFormController.text != '')
            GroupItem(
              groupName: nameFormController.text,
              progress: '95',
              round: '1',
              deadline: _getTimeStamp(),
              yourJuz: '25',
              yourProgress: '50',
              groupColor: colorFormController.text != '' ? colorFormController.text : _defaultColor,
            ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: nameFormController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: FormCreateGroupName,
            ),
            validator: (value) {
              if (value.isEmpty) {
                return FormCreateGroupNameError;
              }
              return null;
            },
          ),
          TextFormField(
            controller: addressFormController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: FormCreateGroupAddress,
            ),
            validator: (value) {
              if (value.isEmpty) {
                return FormCreateGroupAddressError;
              }
              return null;
            },
          ),
          TextFormField(
            controller: latlongFormController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: FormCreateGroupLatlong,
            ),
            validator: (value) {
              if (value.isEmpty) {
                return FormCreateGroupLatlongError;
              }
              return null;
            },
          ),
          TextFormField(
            controller: colorFormController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: FormCreateGroupColor,
            ),
          ),
          TextFormField(
            controller: endDateFormController,
            keyboardType: TextInputType.text,
            readOnly: true,
            onTap: () => _renderSelectDate(context),
          ),
          // Text((selectedRoundEndDateForm.toString()).split(' ')[0]),
          // IconButton(icon: Icon(Icons.calendar_today), onPressed: () => _renderSelectDate(context)),
          TextFormField(
            controller: uidsFormController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: FormCreateGroupUids,
            ),
          ),
        ],
      ),
    );
  }

  Widget _joinGroupForm() {
    return Text('join group form here');
  }

  @override
  void initState() {
    super.initState();
    _apiGroupList();
    endDateFormController.text = (DateTime.now().toString()).split(' ')[0];
  }

  @override
  void dispose() {
    nameFormController.dispose();
    addressFormController.dispose();
    latlongFormController.dispose();
    colorFormController.dispose();
    endDateFormController.dispose();
    uidsFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(AppTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: LogoutText,
            onPressed: () => widget.logout(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_screenState == StateGroupList)
            Container(
                padding: mainPadding,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(WelcomeMessage), Text(widget.name)]),
                  SizedBox(height: 8.0),
                  Text(YourGroup, style: bold),
                ])),
          Expanded(
            child: SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: Container(
                        padding: mainPadding,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (_messageText != '') Container(padding: verticalPadding, child: Center(child: Text(_messageText))),
                          if (_screenState == StateGroupList) _myGroupList(context),
                          if (_screenState == StateCreateGroup) _createGroupForm(),
                          if (_screenState == StateJoinGroup) _joinGroupForm(),
                        ])))),
          ),

          // Expanded(child: _groupList(context)),
          Container(
            padding: mainPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_screenState == StateCreateGroup)
                  RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _apiCreateGroup();
                        }
                      },
                      child: Text(SubmitText)),
                if (_screenState == StateCreateGroup)
                  RaisedButton(onPressed: () => _toggleScreenState(StateCreateGroup), child: Text(FormCreateGroupPreview), color: Color(0xfff6d55c)),
                if (_screenState == StateCreateGroup || _screenState == StateJoinGroup)
                  RaisedButton(onPressed: () => _toggleScreenState(StateGroupList), child: Text(CancelText), color: Colors.blueGrey),
                if (_screenState != StateCreateGroup && _screenState != StateJoinGroup)
                  RaisedButton(onPressed: () => _toggleScreenState(StateCreateGroup), child: Text(CreateGroup), color: Colors.redAccent),
                if (_screenState != StateCreateGroup && _screenState != StateJoinGroup) RaisedButton(onPressed: () => _toggleScreenState(StateJoinGroup), child: Text(JoinGroup)),
              ],
            ),
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Widget _groupList(context) {
//   return SingleChildScrollView(
//     child: ConstrainedBox(
//       constraints: BoxConstraints(
//         minWidth: MediaQuery.of(context).size.width,
//       ),
//       child: Container(
//         padding: mainPadding,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FlatButton(
//               padding: EdgeInsets.all(0.00),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return GroupDetail(groupName: 'Nurul Hikmah', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '1', yourProgress: '50%', groupColor: 'ff0000');
//                 }));
//               },
//               child: GroupItem(groupName: 'Nurul Hikmah', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '1', yourProgress: '50%', groupColor: 'ff0000'),
//             ),
//             FlatButton(
//               padding: EdgeInsets.all(0.00),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return GroupDetail(
//                       groupName: 'Nurul Hikmah dengan nama panajang',
//                       progress: '60%',
//                       round: '1',
//                       deadline: '21 Feb 2021',
//                       yourJuz: '29',
//                       yourProgress: '80%',
//                       groupColor: 'ffffff');
//                 }));
//               },
//               child: GroupItem(
//                   groupName: 'Nurul Hikmah dengan nama panajang', progress: '60%', round: '1', deadline: '21 Feb 2021', yourJuz: '29', yourProgress: '80%', groupColor: 'ffffff'),
//             ),
//             FlatButton(
//               padding: EdgeInsets.all(0.00),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return GroupDetail(groupName: 'Nurul Hikmah', progress: '75%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: '66dd33');
//                 }));
//               },
//               child: GroupItem(groupName: 'Nurul Hikmah', progress: '75%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: '66dd33'),
//             ),
//             GroupItem(groupName: 'not link', progress: '50%', round: '2', deadline: '21 jan 2021', yourJuz: '28', yourProgress: '50%', groupColor: '666666'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: '66dd33'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//             GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
//           ],
//         ),
//       ),
//     ),
//   );
// }
