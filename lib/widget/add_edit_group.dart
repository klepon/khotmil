import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/create_group.dart';
import 'package:khotmil/fetch/get_group.dart';
import 'package:khotmil/fetch/update_deadline.dart';

import 'group_item.dart';

class AddGroup extends StatefulWidget {
  final String loginKey;
  final String title;
  final String groupId;
  final String deadline;
  final Function reloadList;
  final Function reloadDetail;
  AddGroup({Key key, this.loginKey, this.title, this.groupId, this.deadline, this.reloadList, this.reloadDetail}) : super(key: key);

  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _messageText = '';
  bool _renderPreview = false;
  bool _loadingOverlay = false;

  Color _currentColor = Color(0xfff6d55c);
  bool _showColorPicker = false;

  bool _searchLatlong = false;
  bool _hasAddressData = false;
  String _addressSeacrhError = '';
  String _lastCheckedAddress = '';
  String _latlongOri = '';
  Address _addressSuggestion;

  TextEditingController _nameFormController = TextEditingController();
  TextEditingController _addressFormController = TextEditingController();
  TextEditingController _colorFormController = TextEditingController();
  TextEditingController _endDateFormController = TextEditingController();
  TextEditingController _uidsFormController = TextEditingController();
  FocusNode _focusAddressNode = FocusNode();

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

  void _apiUpdateGroup() async {
    widget.reloadList(1);

    setState(() {
      _messageText = '';
      _loadingOverlay = true;
    });

    await fetchUpdateGroup(
            widget.loginKey,
            _nameFormController.text,
            _addressFormController.text,
            _latlongOri == '' ? _addressSuggestion.coordinates.latitude.toString() + ',' + _addressSuggestion.coordinates.longitude.toString() : _latlongOri,
            _currentColor.value.toRadixString(16).substring(2).toUpperCase(),
            _endDateFormController.text,
            widget.groupId)
        .then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadList(2);
        widget.reloadDetail(_nameFormController.text, _getTimeStamp(), _currentColor.value.toRadixString(16).substring(2).toUpperCase());
        Navigator.pop(context);
      } else if (data[DataStatus] == StatusError) {
        widget.reloadList(3);

        setState(() {
          _messageText = data[DataMessage];
          _loadingOverlay = false;
        });
      }
    }).catchError((onError) {
      widget.reloadList(3);

      setState(() {
        _messageText = onError.toString();
        _loadingOverlay = false;
      });
    });
  }

  void _apiCreateGroup() async {
    widget.reloadList(1);

    setState(() {
      _messageText = '';
      _loadingOverlay = true;
    });

    await fetchCreateGroup(
      widget.loginKey,
      _nameFormController.text,
      _addressFormController.text,
      _addressSuggestion.coordinates.latitude.toString() + ',' + _addressSuggestion.coordinates.longitude.toString(),
      _currentColor.value.toRadixString(16).substring(2).toUpperCase(),
      _endDateFormController.text,
      _uidsFormController.text.split(','),
    ).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadList(2);
        Navigator.pop(context);
      } else if (data[DataStatus] == StatusError) {
        widget.reloadList(3);

        setState(() {
          _messageText = data[DataMessage];
          _loadingOverlay = false;
        });
      }
    }).catchError((onError) {
      widget.reloadList(3);

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
          _colorFormController.text = "#" + data['group']['color'];
          _currentColor = Color(int.parse("0xff" + data['group']['color']));

          _endDateFormController.text = (DateTime.fromMillisecondsSinceEpoch(int.parse(widget.deadline) * 1000).toString()).split(' ')[0];
          _latlongOri = data['group']['latlong'];
        });
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

  void _changeColor(Color color) {
    setState(() {
      _currentColor = color;
      _colorFormController.text = '#' + _currentColor.value.toRadixString(16).substring(2).toUpperCase();
      _showColorPicker = false;
    });
  }

  void _getLatLong() async {
    if (_lastCheckedAddress == _addressFormController.text) return;

    setState(() {
      _hasAddressData = false;
      _addressSeacrhError = '';
      _searchLatlong = true;
      _lastCheckedAddress = _addressFormController.text;
    });
    await Geocoder.local.findAddressesFromQuery(_addressFormController.text).then((data) {
      setState(() {
        _addressSuggestion = data.first;
        _hasAddressData = true;
        _searchLatlong = false;
      });
    }).catchError((onError) {
      setState(() {
        _addressSeacrhError = AddressSuggestionErrorText;
        _searchLatlong = false;
      });
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
    _colorFormController.text = '#' + _currentColor.value.toRadixString(16).substring(2).toUpperCase();

    // handle search address coordinate
    _focusAddressNode.addListener(() {
      if (_addressFormController.text != '' && !_focusAddressNode.hasFocus) {
        _getLatLong();
      }
    });

    if (widget.groupId != '') {
      _apiGetGroup();
    }
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
        appBar: AppBar(title: Text(AppTitle)),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        child: Container(
                            padding: sidePadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16.0),
                                Center(
                                  child: Text(widget.title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 16.0),
                                if (_messageText != '') Text(_messageText),
                                if (_messageText != '') SizedBox(height: 16.0),
                                if (_renderPreview || '' != widget.groupId)
                                  GroupItem(
                                    groupName: _nameFormController.text != '' ? _nameFormController.text : FormCreateGroupName,
                                    progress: '95',
                                    round: '1',
                                    deadline: _getTimeStamp(),
                                    yourJuz: '25',
                                    yourProgress: '50',
                                    groupColor: _currentColor.value.toRadixString(16).substring(2).toUpperCase(),
                                  ),
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
                                SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    Expanded(
                                        child: TextFormField(
                                      controller: _addressFormController,
                                      keyboardType: TextInputType.multiline,
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
                                SizedBox(height: 16.0),
                                if (_searchLatlong)
                                  Container(
                                      padding: verticalPadding,
                                      child: Column(children: [
                                        Text(AddressValidateTitle, style: bold),
                                        SizedBox(height: 16.0),
                                        Center(child: CircularProgressIndicator()),
                                        SizedBox(height: 16.0),
                                      ])),
                                if (_addressSeacrhError != '')
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: verticalPadding,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(_addressSeacrhError, style: bold),
                                        SizedBox(height: 16.0),
                                        Text(ClosedAddressFoundDesc),
                                        SizedBox(height: 16.0),
                                      ])),
                                if (_hasAddressData)
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: verticalPadding,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ClosedAddressFoundTitle, style: bold),
                                          SizedBox(height: 16.0),
                                          Text(_addressSuggestion.addressLine),
                                          SizedBox(height: 8.0),
                                          Text(FormCreateGroupLatlong +
                                              _addressSuggestion.coordinates.latitude.toString() +
                                              ',' +
                                              _addressSuggestion.coordinates.longitude.toString()),
                                          SizedBox(height: 8.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: RaisedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _lastCheckedAddress = _addressSuggestion.addressLine;
                                                    _hasAddressData = false;
                                                    _latlongOri = '';
                                                  });
                                                },
                                                child: Text(UseCoordinateButtonText),
                                              )),
                                              SizedBox(width: 8.0),
                                              Expanded(
                                                  child: RaisedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _addressFormController.text = _addressSuggestion.addressLine;
                                                    _lastCheckedAddress = _addressSuggestion.addressLine;
                                                    _hasAddressData = false;
                                                    _latlongOri = '';
                                                  });
                                                },
                                                child: Text(UseAddressButtonText),
                                              )),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(ClosedAddressFoundDesc),
                                          SizedBox(height: 16.0),
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
                                if (!_showColorPicker) SizedBox(height: 16.0),
                                if (_showColorPicker)
                                  Container(
                                    height: MediaQuery.of(context).size.width * 0.8,
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    child: MaterialPicker(
                                      pickerColor: _currentColor,
                                      onColorChanged: _changeColor,
                                      enableLabel: true,
                                    ),
                                  ),
                                if (_showColorPicker) SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _endDateFormController,
                                  keyboardType: TextInputType.text,
                                  readOnly: true,
                                  onTap: () => _renderSelectDate(context),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                                    hintText: FormCreateGroupEndDate,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return FormCreateGroupEndDateError;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.0),
                                if ('' == widget.groupId)
                                  TextFormField(
                                    controller: _uidsFormController,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                                      hintText: FormCreateGroupUids,
                                    ),
                                  ),
                                if ('' == widget.groupId) SizedBox(height: 16.0),
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
                        RaisedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (widget.groupId == '') {
                                  _apiCreateGroup();
                                } else {
                                  _apiUpdateGroup();
                                }
                              }
                            },
                            child: Text(SubmitText)),
                        RaisedButton(
                            onPressed: () => setState(() {
                                  _renderPreview = true;
                                }),
                            child: Text(FormCreateGroupPreview),
                            color: Color(0xfff6d55c)),
                        RaisedButton(onPressed: () => Navigator.pop(context), child: Text(CancelText), color: Colors.blueGrey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_loadingOverlay) loadingOverlay(context)
          ],
        ));
  }
}
