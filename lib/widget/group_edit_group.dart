import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/group_delete.dart';
import 'package:khotmil/fetch/group_get_groups.dart';
import 'package:khotmil/fetch/group_search_user.dart';
import 'package:khotmil/fetch/group_update.dart';

class WidgetEditGroup extends StatefulWidget {
  final String loginKey;
  final String groupId;
  final Function reloadList;
  final Function reloadDetail;
  final Function backToList;
  WidgetEditGroup({Key key, this.loginKey, this.groupId, this.reloadList, this.reloadDetail, this.backToList}) : super(key: key);

  @override
  _WidgetEditGroupState createState() => _WidgetEditGroupState();
}

class _WidgetEditGroupState extends State<WidgetEditGroup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _messageText = '';
  bool _loadingOverlay = false;
  String _photo = '';

  bool _searchAddressLoading = false;
  bool _searchAddressSuccess = false;
  String _searchAddressErrorMessage = '';
  String _lastCheckedAddress = '';
  Address _closedValidAddress;

  List _apiReturnUsers = [];
  List _usersSelectedForInvite = [];
  bool _searchUserLoading = false;

  TextEditingController _nameFormController = TextEditingController();
  TextEditingController _addressFormController = TextEditingController();
  TextEditingController _roundFormController = TextEditingController();
  TextEditingController _endDateFormController = TextEditingController();
  TextEditingController _searchUserFormController = TextEditingController();
  FocusNode _focusAddressNode = FocusNode();

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

  Future<void> _renderSelectDate(BuildContext context) async {
    DateTime date = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: date,
      lastDate: DateTime(date.year, date.month + 3),
      helpText: FormCreateGroupEndDate,
    );
    if (picked != null) _endDateFormController.text = (picked.toString()).split(' ')[0];
  }

  Future _getLatLong() async {
    if (_lastCheckedAddress == _addressFormController.text) return;

    setState(() {
      _closedValidAddress = null;
      _searchAddressSuccess = false;
      _searchAddressErrorMessage = '';
      _searchAddressLoading = true;
      _lastCheckedAddress = _addressFormController.text;
    });
    await Geocoder.local.findAddressesFromQuery(_addressFormController.text).then((data) {
      setState(() {
        _closedValidAddress = data.first;
        _searchAddressSuccess = true;
        _searchAddressLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        _searchAddressErrorMessage = AddressSuggestionErrorText;
        _searchAddressLoading = false;
      });
    });
  }

  Future _getLatLongInBackground() async {
    setState(() {
      _closedValidAddress = null;
      _searchAddressSuccess = false;
      _searchAddressErrorMessage = '';
      _lastCheckedAddress = _addressFormController.text;
    });
    await Geocoder.local.findAddressesFromQuery(_addressFormController.text).then((data) {
      setState(() {
        _closedValidAddress = data.first;
      });
    }).catchError((onError) {});
  }

  void _apiDeleteGroup() async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchDeleteGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        Navigator.pop(context);
        widget.backToList();
        widget.reloadList();
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
          _messageText = data[DataMessage];
        });
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
        _messageText = onError.toString();
      });
    });
  }

  void _apiUpdateGroup() async {
    setState(() {
      _messageText = '';
      _loadingOverlay = true;
    });
    await fetchUpdateGroup(
            widget.loginKey,
            _nameFormController.text,
            _addressFormController.text,
            _closedValidAddress.coordinates.latitude.toString() + ',' + _closedValidAddress.coordinates.longitude.toString(),
            _endDateFormController.text,
            widget.groupId,
            _usersSelectedForInvite,
            _image)
        .then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadDetail(_nameFormController.text, _getTimeStamp(), data['photo']);
        widget.reloadList();
        Navigator.pop(context);
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _messageText = data[DataMessage];
          _loadingOverlay = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        _messageText = onError.toString();
        _loadingOverlay = false;
      });
    });
  }

  void _apiGetGroup() async {
    setState(() {
      _messageText = '';
      _loadingOverlay = true;
    });

    await fetchGetGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _loadingOverlay = false;
          _nameFormController.text = data['group']['name'];
          _addressFormController.text = data['group']['address'];
          _endDateFormController.text = (DateTime.fromMillisecondsSinceEpoch(int.parse(data['group']['deadline']) * 1000).toString()).split(' ')[0];
          _photo = data['group']['photo'];
        });

        // fill api address with current state
        _getLatLongInBackground();
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _messageText = data[DataMessage];
          _loadingOverlay = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        _messageText = onError.toString();
        _loadingOverlay = false;
      });
    });
  }

  void _apiSearchUser(value) async {
    setState(() {
      _searchUserLoading = true;
    });

    await fetchSearchUser(widget.loginKey, value).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _apiReturnUsers = data['users'];
          _searchUserLoading = false;
        });
      }
      if (data[DataStatus] == StatusError) {
        setState(() {
          _apiReturnUsers = [];
          _searchUserLoading = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        _apiReturnUsers = [];
        _searchUserLoading = false;
      });
    });
  }

  void _addUid(userData) {
    _searchUserFormController.text = '';
    _usersSelectedForInvite.add(userData);

    setState(() {
      _apiReturnUsers = [];
      _usersSelectedForInvite = [
        ...{..._usersSelectedForInvite}
      ];
    });
  }

  void _removeUid(userData) {
    _usersSelectedForInvite.removeWhere((user) => user == userData);

    setState(() {
      _usersSelectedForInvite = [
        ...{..._usersSelectedForInvite}
      ];
    });
  }

  String _getTimeStamp() {
    String ts = _endDateFormController.text == ''
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : DateTime.parse(_endDateFormController.text + ' 00:00:00.000').millisecondsSinceEpoch.toString();
    return ts.substring(0, ts.length - 3);
  }

  @override
  void initState() {
    super.initState();

    // handle search address coordinate
    _focusAddressNode.addListener(() {
      if (_addressFormController.text != '' && !_focusAddressNode.hasFocus) {
        _getLatLong();
      }
    });

    _apiGetGroup();
  }

  @override
  void dispose() {
    _nameFormController.dispose();
    _addressFormController.dispose();
    _roundFormController.dispose();
    _endDateFormController.dispose();
    _searchUserFormController.dispose();
    _focusAddressNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(AppTitle)),
        body: Stack(
          children: [
            Container(
              decoration: pageBg,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                          child: Container(
                              padding: sidePaddingWide,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.0),
                                  Center(
                                    child: FlatButton(
                                        onPressed: () => _getImage(),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 79,
                                          child: CircleAvatar(
                                            backgroundImage: _image != null
                                                ? AssetImage(_image.path)
                                                : _photo == ''
                                                    ? null
                                                    : NetworkImage(_photo),
                                            backgroundColor: Colors.white,
                                            radius: 72,
                                            child: Text(_image == null && _photo == '' ? UploadGroupPhoto : '', textAlign: TextAlign.center),
                                          ),
                                        )),
                                  ),
                                  SizedBox(height: 4.0),
                                  Center(child: Text(EditPhotoText, style: TextStyle(color: Color(0xff747070)))),
                                  SizedBox(height: 16.0),
                                  Center(
                                    child: Text(EditGroup, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(height: 16.0),
                                  if (_messageText != '') Text(_messageText),
                                  if (_messageText != '') SizedBox(height: 16.0),

                                  // group name
                                  TextFormField(
                                    controller: _nameFormController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(contentPadding: sidePaddingNarrow, hintText: FormCreateGroupName, errorStyle: errorTextStyle),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return FormCreateGroupNameError;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16.0),

                                  // group address
                                  Row(
                                    children: [
                                      Expanded(
                                          child: TextFormField(
                                        controller: _addressFormController,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(hintText: FormCreateGroupAddress, contentPadding: sidePaddingNarrow, errorStyle: errorTextStyle),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return FormCreateGroupAddressError;
                                          }

                                          if (value.isNotEmpty && _closedValidAddress == null) {
                                            return FormCreateGroupAddressInvalid;
                                          }

                                          return null;
                                        },
                                        maxLines: null,
                                        focusNode: _focusAddressNode,
                                      )),
                                      IconButton(
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                            _getLatLong();
                                          })
                                    ],
                                  ),
                                  if (_searchAddressLoading)
                                    Container(
                                        padding: verticalPadding,
                                        child: Column(children: [
                                          Text(AddressValidateTitle, style: bold),
                                          SizedBox(height: 16.0),
                                          Center(child: CircularProgressIndicator()),
                                          SizedBox(height: 16.0),
                                        ])),
                                  if (_searchAddressErrorMessage != '')
                                    Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: verticalPadding,
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(_searchAddressErrorMessage, style: bold),
                                          SizedBox(height: 16.0),
                                          Text(ClosedAddressFoundDesc),
                                          SizedBox(height: 16.0),
                                        ])),
                                  if (_searchAddressSuccess)
                                    Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: verticalPadding,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(ClosedAddressFoundTitle, style: bold),
                                            SizedBox(height: 16.0),
                                            Text(_closedValidAddress.addressLine),
                                            SizedBox(height: 8.0),
                                            Text(FormCreateGroupLatlong +
                                                _closedValidAddress.coordinates.latitude.toString() +
                                                ',' +
                                                _closedValidAddress.coordinates.longitude.toString()),
                                            SizedBox(height: 8.0),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: RaisedButton(
                                                  child: Text(UseCoordinateButtonText),
                                                  onPressed: () {
                                                    setState(() {
                                                      _lastCheckedAddress = _closedValidAddress.addressLine;
                                                      _searchAddressSuccess = false;
                                                    });
                                                  },
                                                )),
                                                SizedBox(width: 8.0),
                                                Expanded(
                                                    child: RaisedButton(
                                                  child: Text(UseAddressButtonText),
                                                  onPressed: () {
                                                    setState(() {
                                                      _addressFormController.text = _closedValidAddress.addressLine;
                                                      _lastCheckedAddress = _closedValidAddress.addressLine;
                                                      _searchAddressSuccess = false;
                                                    });
                                                  },
                                                )),
                                              ],
                                            ),
                                            SizedBox(height: 16.0),
                                            Text(ClosedAddressFoundDesc),
                                            SizedBox(height: 16.0),
                                          ],
                                        )),
                                  SizedBox(height: 16.0),

                                  // round deadline
                                  TextFormField(
                                    controller: _endDateFormController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(hintText: FormCreateGroupEndDate, contentPadding: sidePaddingNarrow, errorStyle: errorTextStyle),
                                    readOnly: true,
                                    onTap: () => _renderSelectDate(context),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return FormCreateGroupEndDateError;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16.0),

                                  // user search
                                  if (_searchUserLoading) Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                                  if (_apiReturnUsers.length > 0)
                                    Container(
                                      padding: sidePaddingNarrow,
                                      child: Wrap(children: [
                                        for (var user in _apiReturnUsers)
                                          if ((_usersSelectedForInvite.firstWhere((i) => i[0] == user[0], orElse: () => null)) == null)
                                            TextButton(onPressed: () => _addUid(user), child: Text('@' + user[1])),
                                      ]),
                                    ),
                                  TextFormField(
                                    controller: _searchUserFormController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      contentPadding: sidePaddingNarrow,
                                      hintText: UndangAdmin,
                                    ),
                                    onChanged: (value) {
                                      if (value.length >= 3) {
                                        _apiSearchUser(value);
                                      } else if (_apiReturnUsers.length > 0) {
                                        setState(() {
                                          _apiReturnUsers = [];
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(height: 16.0),
                                  if (_usersSelectedForInvite.length > 0)
                                    Container(
                                      padding: sidePaddingNarrow,
                                      child: Column(children: [
                                        for (var user in _usersSelectedForInvite)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('@' + user[1]),
                                              IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => _removeUid(user)),
                                            ],
                                          ),
                                        SizedBox(height: 16.0),
                                      ]),
                                    ),
                                ],
                              )),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MaterialButton(
                            child: Text(SaveText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              await _getLatLong();

                              if (_formKey.currentState.validate()) {
                                _apiUpdateGroup();
                              }
                            },
                            height: 50.0,
                            color: Color(int.parse('0xff2DA310')),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          ),
                          MaterialButton(
                            child: Text(ButtonRemove, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    title: Text(DeleteGroupWarningTitle),
                                    content: Text(DeleteGroupWarning),
                                    actions: [
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(CancelText),
                                      ),
                                      RaisedButton(
                                        color: Colors.redAccent,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _apiDeleteGroup();
                                        },
                                        child: Text(DeleteGroupConfirm),
                                      ),
                                    ],
                                  ));
                            },
                            height: 50.0,
                            color: Color(int.parse('0xffF30F0F')),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          ),
                          MaterialButton(
                            child: Text(CancelText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                            onPressed: () => Navigator.of(context).pop(),
                            height: 50.0,
                            color: Color(int.parse('0xff747070')),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loadingOverlay) loadingOverlay(context)
          ],
        ));
  }
}
