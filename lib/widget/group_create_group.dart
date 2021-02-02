import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/group_create.dart';
import 'package:khotmil/fetch/search_name.dart';
import 'package:khotmil/fetch/group_search_user.dart';

class WidgetCreateGroup extends StatefulWidget {
  final String loginKey;
  final Function reloadList;
  WidgetCreateGroup({Key key, this.loginKey, this.reloadList}) : super(key: key);

  @override
  _WidgetCreateGroupState createState() => _WidgetCreateGroupState();
}

class _WidgetCreateGroupState extends State<WidgetCreateGroup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loadingOverlay = false;

  bool _searchAddressLoading = false;
  bool _searchAddressSuccess = false;
  String _searchAddressErrorMessage = '';
  String _lastCheckedAddress = '';
  Address _closedValidAddress;

  List _apiReturnUsers = [];
  List _usersSelectedForInvite = [];
  bool _searchUserLoading = false;

  bool _searchNameLoading = false;
  bool _nameExist = false;
  String _searchNameMessage = '';
  String _lastCheckedName = '';

  TextEditingController _nameFormController = TextEditingController();
  TextEditingController _addressFormController = TextEditingController();
  TextEditingController _roundFormController = TextEditingController();
  TextEditingController _endDateFormController = TextEditingController();
  TextEditingController _searchUserFormController = TextEditingController();
  FocusNode _focusAddressNode = FocusNode();
  FocusNode _focusNameNode = FocusNode();

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

  void _apiCreateGroup() async {
    setState(() {
      _loadingOverlay = true;
    });

    List _uids = [];
    for (var user in _usersSelectedForInvite) {
      _uids.add(user[0].toString());
    }

    fetchCreateGroup(
      widget.loginKey,
      _nameFormController.text,
      _addressFormController.text,
      _closedValidAddress.coordinates.latitude.toString() + ',' + _closedValidAddress.coordinates.longitude.toString(),
      _roundFormController.text,
      _endDateFormController.text,
      _uids,
      _image,
    ).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadList();
        Navigator.pop(context);
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

  void _apiSearchUser(String value) async {
    setState(() {
      _searchUserLoading = true;
    });

    await fetchSearchUser(widget.loginKey, value, new List<String>()).then((data) {
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

  Future _getGroupName() async {
    if (_lastCheckedName == _nameFormController.text) {
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
      _lastCheckedName = _nameFormController.text;
    });

    await fetchSearchName(_nameFormController.text, 'group').then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _nameExist = data['data'];
          _searchNameMessage = data['data'] ? FormCreateGroupNameExist : '';
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

    // handle search address coordinate
    _focusAddressNode.addListener(() {
      if (_addressFormController.text != '' && !_focusAddressNode.hasFocus) {
        _getLatLong();
      }
    });

    _nameFormController.addListener(() {
      if (_nameFormController.text != '' && !_focusNameNode.hasFocus) {
        _getGroupName();
      }
    });
  }

  @override
  void dispose() {
    _nameFormController.dispose();
    _addressFormController.dispose();
    _roundFormController.dispose();
    _endDateFormController.dispose();
    _searchUserFormController.dispose();

    _focusAddressNode.dispose();
    _focusNameNode.dispose();

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
                                  SizedBox(height: 16.0),
                                  Center(
                                    child: Text(CreateGroup, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _nameFormController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(contentPadding: sidePaddingNarrow, hintText: FormCreateGroupName, errorStyle: errorTextStyle),
                                    focusNode: _focusNameNode,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return FormCreateGroupNameError;
                                      }

                                      if (value.isNotEmpty && _nameExist == true) {
                                        return FormCreateGroupNameExistShort;
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_searchNameLoading)
                                    Container(
                                        padding: verticalPadding,
                                        child: Column(children: [
                                          Center(child: LinearProgressIndicator()),
                                          Text(FormCreateGroupNameChecking),
                                        ])),
                                  if (_searchNameMessage != '') Text(_searchNameMessage),
                                  SizedBox(height: 16.0),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: TextFormField(
                                        controller: _addressFormController,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(hintText: FormCreateGroupAddress, contentPadding: sidePaddingNarrow, errorStyle: errorTextStyle),
                                        maxLines: null,
                                        focusNode: _focusAddressNode,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return FormCreateGroupAddressError;
                                          }

                                          if (value.isNotEmpty && _closedValidAddress == null) {
                                            return FormCreateGroupAddressInvalid;
                                          }

                                          return null;
                                        },
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
                                          Center(child: LinearProgressIndicator()),
                                          Text(AddressValidateTitle),
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
                                  TextFormField(
                                    controller: _roundFormController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(hintText: FormCreateGroupRound, contentPadding: sidePaddingNarrow, errorStyle: errorTextStyle),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        setState(() {
                                          _roundFormController.text = '1';
                                        });
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16.0),
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
                                      hintText: FormCreateGroupUids,
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
                                  SizedBox(height: 16.0),
                                  Center(
                                    child: FlatButton(
                                        onPressed: () => _getImage(),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 79,
                                          child: CircleAvatar(
                                            backgroundImage: _image == null ? null : AssetImage(_image.path),
                                            backgroundColor: Colors.white,
                                            radius: 72,
                                            child: Text(_image == null ? UploadGroupPhoto : '', textAlign: TextAlign.center),
                                          ),
                                        )),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ),
                    Container(
                      padding: mainPadding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            child: Text(CreateGroup, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              await _getGroupName();
                              await _getLatLong();

                              if (_formKey.currentState.validate()) {
                                _apiCreateGroup();
                              }
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
