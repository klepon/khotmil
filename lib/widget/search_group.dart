import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/group_search_group.dart';
import 'package:sprintf/sprintf.dart';

import 'group_detail.dart';
import 'group_list_item.dart';

class SearchGroup extends StatefulWidget {
  final String loginKey;
  final Function reloadList;
  SearchGroup({Key key, this.loginKey, this.reloadList}) : super(key: key);

  @override
  _SearchGroupState createState() => _SearchGroupState();
}

class _SearchGroupState extends State<SearchGroup> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchGroupByKeywordFormController = TextEditingController();
  TextEditingController _searchAddressFormController = TextEditingController();
  final GlobalKey<FormState> _formKeyAddress = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKeyword = GlobalKey<FormState>();

  int _radius = 1;
  String _keyword = '';
  String _searchBy = SearchGroupByPhoneLocation;
  bool _editSearch = false;

  bool _searchAddressLoading = false;
  String _searchAddressErrorMessage = '';
  Address _closedValidAddress;

  Future<Position> _getPhoneLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(LocationServicesDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(LocationServicesDisabledPermanently);
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return Future.error(sprintf(LocationServicesDenied, [permission]));
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future _getGroup() async {
    String addressLine = '';
    String latlong = '';

    try {
      switch (_searchBy) {
        case SearchGroupByCustomLocation:
          addressLine = _closedValidAddress.addressLine;
          latlong = _closedValidAddress.coordinates.latitude.toString() + ',' + _closedValidAddress.coordinates.longitude.toString();
          break;
        case SearchGroupByKeyword:
          break;
        default:
          Position position = await _getPhoneLocation();
          List<Address> address = await Geocoder.local.findAddressesFromCoordinates(Coordinates(position.latitude, position.longitude));
          latlong = position.latitude.toString() + ',' + position.longitude.toString();
          addressLine = address[0].addressLine;
      }

      Map<String, dynamic> data = await fetchSearchGroup(widget.loginKey, _radius, latlong, _keyword);
      if (data[DataStatus] == StatusSuccess) {
        return {'latlong': latlong, 'address': addressLine, 'groups': data['groups']};
      } else if (data[DataStatus] == StatusError) {
        throw data[DataMessage];
      }
      throw SearchGroupError;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future _getLatLong(context) async {
    setState(() {
      _closedValidAddress = null;
      _searchAddressErrorMessage = '';
      _searchAddressLoading = true;
    });

    await Geocoder.local.findAddressesFromQuery(_searchAddressFormController.text).then((data) {
      setState(() {
        _closedValidAddress = data.first;
        _searchAddressLoading = false;
      });
      _showAddress(context);
    }).catchError((onError) {
      setState(() {
        _searchAddressErrorMessage = AddressSuggestionErrorText;
        _searchAddressLoading = false;
      });
    });
  }

  void _showAddress(context) {
    showDialog(
        context: context,
        child: Dialog(
          child: Container(
              padding: mainPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ClosedAddressFoundTitle, style: bold),
                  SizedBox(height: 16.0),
                  Text(_closedValidAddress.addressLine),
                  SizedBox(height: 8.0),
                  RaisedButton(
                    child: Text(SearchByMyLocationContinueButton),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _searchBy = SearchGroupByCustomLocation;
                        _editSearch = false;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(ClosedAddressFoundDesc),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [RaisedButton(child: Text(CancelText), color: Colors.blueGrey, onPressed: () => Navigator.pop(context))],
                  )
                ],
              )),
        ));
  }

  @override
  void dispose() {
    _searchGroupByKeywordFormController.dispose();
    _searchAddressFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text(AppTitle)),
      body: FutureBuilder(
          future: _getGroup(),
          builder: (context, snapshot) {
            bool snapLoading = false;
            String snapMessage = '';
            List<Widget> groups = [];

            if (snapshot.connectionState != ConnectionState.done) {
              snapLoading = true;
              snapMessage = '';
            } else if (snapshot.hasData) {
              for (var group in snapshot.data['groups']) {
                groups.add(FlatButton(
                  padding: EdgeInsets.all(0.00),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return GroupDetail(
                          groupId: group['id'],
                          groupName: group['name'],
                          progress: group['progress'].toString(),
                          round: group['round'].toString(),
                          deadline: group['end_date'].toString(),
                          yourProgress: group['my_progress'].toString(),
                          photo: group['photo'],
                          owner: group['owner'],
                          isInvitation: false,
                          loginKey: widget.loginKey,
                          reloadList: () {
                            widget.reloadList();
                            setState(() {});
                          });
                    }));
                  },
                  child: GroupItem(
                    groupName: group['name'],
                    progress: group['progress'].toString(),
                    round: group['round'].toString(),
                    deadline: group['end_date'].toString(),
                    photo: group['photo'],
                    yourProgress: group['my_progress'].toString(),
                    asHeader: false,
                  ),
                ));
              }
            } else if (snapshot.hasError) {
              snapMessage = snapshot.error.toString();
            }

            return Container(
              decoration: pageBg,
              child: Column(
                children: [
                  // edit search title
                  if (_editSearch)
                    Container(
                      padding: mainPadding,
                      child: Text(EditSearch, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    ),
                  // edit search form
                  if (_editSearch)
                    Expanded(
                        child: SingleChildScrollView(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                                child: Container(
                                    padding: mainPadding,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // expand radius
                                        Text(ExpandRadiusTitle, style: bold),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [1, 'spacer', 5, 'spacer', 10]
                                              .map((km) => km == 'spacer'
                                                  ? SizedBox(width: 4.0)
                                                  : TextButton(
                                                      child: Text(sprintf(XKilometer, [km]), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white12)),
                                                      onPressed: () {
                                                        setState(() {
                                                          _keyword = '';
                                                          _radius = km;
                                                          _searchBy = _searchBy == SearchGroupByKeyword ? SearchGroupByPhoneLocation : _searchBy;
                                                          _editSearch = false;
                                                        });
                                                      },
                                                    ))
                                              .toList(),
                                        ),
                                        SizedBox(height: 32.0),
                                        // custom location
                                        Text(FindAroundTitle, style: bold),
                                        Form(
                                            key: _formKeyAddress,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: TextFormField(
                                                  controller: _searchAddressFormController,
                                                  keyboardType: TextInputType.text,
                                                  decoration: InputDecoration(hintText: FindAroundLabel, errorStyle: errorTextStyle),
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return FindAroundErrorEmpty;
                                                    }

                                                    if (value.length < 10) {
                                                      return FindAroundErrorShort;
                                                    }

                                                    return null;
                                                  },
                                                )),
                                                if (_searchAddressLoading) CircularProgressIndicator(),
                                                RaisedButton(
                                                  onPressed: () {
                                                    if (_formKeyAddress.currentState.validate()) {
                                                      _getLatLong(context);
                                                    }
                                                  },
                                                  child: Text(FindButton),
                                                )
                                              ],
                                            )),
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
                                        SizedBox(height: 32.0),
                                        // search by keyword
                                        Text(SearchByKeywordTitle, style: bold),
                                        Form(
                                            key: _formKeyKeyword,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: TextFormField(
                                                  controller: _searchGroupByKeywordFormController,
                                                  keyboardType: TextInputType.text,
                                                  decoration: InputDecoration(hintText: FindAroundLabel, errorStyle: errorTextStyle),
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return SearchGroupByKeywordErrorEmpty;
                                                    }

                                                    if (value.length < 3) {
                                                      return SearchGroupByKeywordErrorShort;
                                                    }

                                                    return null;
                                                  },
                                                )),
                                                RaisedButton(
                                                  onPressed: () {
                                                    if (_formKeyKeyword.currentState.validate()) {
                                                      setState(() {
                                                        _searchBy = SearchGroupByKeyword;
                                                        _keyword = _searchGroupByKeywordFormController.text;
                                                        _editSearch = false;
                                                      });
                                                    }
                                                  },
                                                  child: Text(FindButton),
                                                )
                                              ],
                                            )),
                                        // search by phone location
                                        if (_keyword != '' || _closedValidAddress != null)
                                          RaisedButton(
                                              child: Text(SearchByMyLocationTitle),
                                              onPressed: () {
                                                setState(() {
                                                  _searchBy = SearchGroupByPhoneLocation;
                                                  _editSearch = false;
                                                });
                                              })
                                      ],
                                    ))))),
                  // cancel edit search button
                  if (_editSearch)
                    RaisedButton(
                        child: Text(CancelText),
                        color: Colors.blueGrey,
                        onPressed: () {
                          setState(() {
                            _editSearch = false;
                          });
                        }),
                  // search group title, message
                  if (!_editSearch)
                    Container(
                      padding: mainPadding,
                      child: Column(
                        children: [
                          Text(SearchGroupTitle, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16.0),
                          if (snapMessage != '') Container(padding: EdgeInsets.only(bottom: 16.0), child: Text(snapMessage, textAlign: TextAlign.center)),
                          if (snapMessage != '')
                            RaisedButton(
                                child: Text(EditSearch),
                                onPressed: () {
                                  setState(() {
                                    _editSearch = true;
                                  });
                                }),
                          if (snapLoading)
                            Column(
                              children: [
                                Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                                SizedBox(height: 16.0),
                                Text(LocatingDevice, textAlign: TextAlign.center),
                              ],
                            ),
                          if (groups.length > 0)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(_searchBy == SearchGroupByKeyword
                                      ? sprintf(SearchByKeywordLead, [_keyword])
                                      : sprintf(SearchByRadiusLead, [_radius, snapshot.data['address'] ?? '...'])),
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    tooltip: 'Edit',
                                    onPressed: () {
                                      setState(() {
                                        _editSearch = true;
                                      });
                                    }),
                              ],
                            ),
                        ],
                      ),
                    ),
                  if (!_editSearch) SizedBox(height: 16.0),
                  if (!_editSearch)
                    Expanded(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                          child: Column(children: groups),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
    );
  }
}
