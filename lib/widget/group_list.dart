import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoder/geocoder.dart';
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
  String _messageText = '';

  Color _currentColor = Color(0xfff6d55c);
  bool _showColorPicker = false;

  bool _searchLatlong = false;
  bool _hasAddressData = false;
  String _addressSeacrhError = '';
  String _addressLatlong = '';
  Address _addressSuggestion;

  TextEditingController _nameFormController = TextEditingController();
  TextEditingController _addressFormController = TextEditingController();
  TextEditingController _colorFormController = TextEditingController();
  TextEditingController _endDateFormController = TextEditingController();
  TextEditingController _uidsFormController = TextEditingController();
  FocusNode _focusAddressNode = FocusNode();

  Future<void> _renderSelectDate(BuildContext context) async {
    DateTime date = DateTime.now();
    final DateTime picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: date, lastDate: DateTime(date.year, date.month + 3));
    if (picked != null) _endDateFormController.text = (picked.toString()).split(' ')[0];
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
      _nameFormController.text,
      _addressFormController.text,
      _addressLatlong,
      _currentColor.value.toRadixString(16).substring(2).toUpperCase(),
      _endDateFormController.text,
      _uidsFormController.text.split(','),
    ).then((data) {
      widget.toggleLoading();
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _futureGetGroupList = fetchMyGroupList(widget.loginKey);
          _screenState = StateGroupList;
          _nameFormController.text = '';
          _addressFormController.text = '';
          _addressLatlong = '';
          _colorFormController.text = '';
          _endDateFormController.text = (DateTime.now().toString()).split(' ')[0];
          _uidsFormController.text = '';
        });
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _messageText = data[DataMessage];
        });
      }
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

  void _reloadGroupList(int action) {
    // tricky here, first change the state before await, then change it back tolist after await
    setState(() {
      switch (action) {
        case 1:
          _screenState = StateJoinGroup;
          break;
        case 2:
          _screenState = StateGroupList;
          _futureGetGroupList = fetchMyGroupList(widget.loginKey);
          break;
        case 3:
          _screenState = StateGroupList;
          break;
      }
    });
  }

  void _changeColor(Color color) {
    setState(() {
      _currentColor = color;
      _colorFormController.text = '#' + _currentColor.value.toRadixString(16).substring(2).toUpperCase();
      _showColorPicker = false;
    });
  }

  void _getLatLong() async {
    setState(() {
      _hasAddressData = false;
      _addressSeacrhError = '';
      _searchLatlong = true;
      _addressLatlong = '';
    });
    await Geocoder.local.findAddressesFromQuery(_addressFormController.text).then((data) {
      setState(() {
        _addressSuggestion = data.first;
        _hasAddressData = true;
        _searchLatlong = false;
        _addressLatlong = data.first.coordinates.latitude.toString() + ',' + data.first.coordinates.longitude.toString();
      });
    }).catchError((onError) {
      setState(() {
        _addressSeacrhError = AddressSuggestionErrorText;
        _searchLatlong = false;
      });
    });
  }

  String _getTimeStamp() {
    String ts = DateTime.parse(_endDateFormController.text + ' 00:00:00.000').millisecondsSinceEpoch.toString();
    return ts.substring(0, ts.length - 3);
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
                groupId: group['id'],
                groupName: group['name'],
                progress: group['progress'].toString(),
                round: group['round'].toString(),
                deadline: group['end_date'].toString(),
                yourJuz: group['my_juz'].toString(),
                yourProgress: group['my_progress'].toString(),
                groupColor: group['color'],
                owner: group['owner'],
                loginKey: widget.loginKey,
                reloadList: _reloadGroupList);
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
            return Text(snapshot.data['message']);
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

  Widget _createGroupForm() {
    return Form(
      key: _formKey,
      child: Container(
          padding: mainPadding,
          child: Column(
            children: [
              SizedBox(height: 16.0),
              Text(CreateGroup, style: bold),
              SizedBox(height: 16.0),
              if (_nameFormController.text != '')
                GroupItem(
                  groupName: _nameFormController.text,
                  progress: '95',
                  round: '1',
                  deadline: _getTimeStamp(),
                  yourJuz: '25',
                  yourProgress: '50',
                  groupColor: _currentColor.value.toRadixString(16).substring(2).toUpperCase(),
                ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameFormController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
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
                controller: _addressFormController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  hintText: FormCreateGroupAddress,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return FormCreateGroupAddressError;
                  }
                  return null;
                },
                focusNode: _focusAddressNode,
              ),
              if (_searchLatlong)
                Container(
                    padding: verticalPadding,
                    child: Column(children: [
                      Text(AddressValidateTitle, style: bold),
                      SizedBox(height: 16.0),
                      Center(child: CircularProgressIndicator()),
                    ])),
              if (_addressSeacrhError != '')
                Container(
                    padding: verticalPadding,
                    child: Column(children: [
                      Text(_addressSeacrhError, style: bold),
                      SizedBox(height: 16.0),
                      Text(ClosedAddressFoundDesc),
                    ])),
              if (_hasAddressData)
                Container(
                    padding: verticalPadding,
                    child: Column(
                      children: [
                        Text(ClosedAddressFoundTitle, style: bold),
                        SizedBox(height: 16.0),
                        Text(_addressSuggestion.featureName),
                        SizedBox(height: 8.0),
                        Text(FormCreateGroupLatlong + _addressLatlong),
                        SizedBox(height: 8.0),
                        RaisedButton(
                          onPressed: () {
                            setState(() {
                              _hasAddressData = false;
                            });
                          },
                          child: Text(OkButtonText),
                        ),
                        SizedBox(height: 16.0),
                        Text(ClosedAddressFoundDesc),
                      ],
                    )),
              Container(
                decoration: BoxDecoration(color: _currentColor),
                child: TextFormField(
                  controller: _colorFormController,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () {
                    setState(() {
                      _showColorPicker = !_showColorPicker;
                    });
                  },
                  style: TextStyle(color: _currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    hintText: FormCreateGroupColor,
                  ),
                ),
              ),
              if (_showColorPicker)
                Container(
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: MaterialPicker(
                    pickerColor: _currentColor,
                    onColorChanged: _changeColor,
                    enableLabel: true,
                  ),
                ),
              TextFormField(
                controller: _endDateFormController,
                keyboardType: TextInputType.text,
                readOnly: true,
                onTap: () => _renderSelectDate(context),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ),
              TextFormField(
                controller: _uidsFormController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  hintText: FormCreateGroupUids,
                ),
              ),
            ],
          )),
    );
  }

  Widget _joinGroupForm() {
    return Container(
      padding: mainPadding,
      child: Text('join group form here'),
    );
  }

  @override
  void initState() {
    super.initState();
    _apiGroupList();
    _endDateFormController.text = (DateTime.now().toString()).split(' ')[0];
    _colorFormController.text = '#' + _currentColor.value.toRadixString(16).substring(2).toUpperCase();

    // handle search address coordinate
    _focusAddressNode.addListener(() {
      if (_addressFormController.text != '' && !_focusAddressNode.hasFocus) {
        _getLatLong();
      }
    });
  }

  @override
  void dispose() {
    _nameFormController.dispose();
    _addressFormController.dispose();
    _colorFormController.dispose();
    _endDateFormController.dispose();
    _uidsFormController.dispose();
    _focusAddressNode.dispose();
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
          if (_messageText != '') Container(padding: verticalPadding, child: Center(child: Text(_messageText))),
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
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (_screenState == StateGroupList) _myGroupList(context),
                      if (_screenState == StateCreateGroup) _createGroupForm(),
                      if (_screenState == StateJoinGroup) _joinGroupForm(),
                    ]))),
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
