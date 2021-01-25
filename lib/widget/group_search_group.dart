import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/group_search_group.dart';
import 'package:sprintf/sprintf.dart';

import 'group_detail.dart';
import 'group_list_item.dart';

class WidgetSearchGroup extends StatefulWidget {
  final String loginKey;
  final Function reloadList;
  WidgetSearchGroup({Key key, this.loginKey, this.reloadList}) : super(key: key);

  @override
  _WidgetSearchGroupState createState() => _WidgetSearchGroupState();
}

class _WidgetSearchGroupState extends State<WidgetSearchGroup> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchGroupByKeywordFormController = TextEditingController();
  TextEditingController _searchAddressFormController = TextEditingController();
  final GlobalKey<FormState> _formKeyAddress = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyKeyword = GlobalKey<FormState>();

  int _radius = 5;
  String _keyword = '';
  String _searchBy = SearchGroupByMyAddress;

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
        case SearchGroupByAddress:
          if (_closedValidAddress == null) return;
          addressLine = _closedValidAddress.addressLine;
          latlong = _closedValidAddress.coordinates.latitude.toString() + ',' + _closedValidAddress.coordinates.longitude.toString();
          break;
        case SearchGroupByTitle: // just emptying latlong
          if (_keyword == '') return;
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
        _searchAddressLoading = false;
      });
      _showAddress(context, data.first);
    }).catchError((onError) {
      setState(() {
        _searchAddressErrorMessage = AddressSuggestionErrorText;
        _searchAddressLoading = false;
      });
    });
  }

  void _showAddress(context, address) {
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
                  Text(address.addressLine),
                  SizedBox(height: 8.0),
                  RaisedButton(
                    child: Text(SearchByMyLocationContinueButton),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _closedValidAddress = address;
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

  void _resetKeywordAddress(String tab) {
    setState(() {
      _keyword = '';
      _searchAddressErrorMessage = '';
      _closedValidAddress = null;
      _searchGroupByKeywordFormController.text = '';
      _searchAddressFormController.text = '';
      _searchBy = tab;
    });
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
              snapLoading = (_searchBy == SearchGroupByTitle && _keyword != '') ||
                  (_searchBy == SearchGroupByAddress && _closedValidAddress != null) ||
                  (_searchBy == SearchGroupByMyAddress);
              snapMessage = '';
            } else if (snapshot.hasData) {
              for (var group in snapshot.data['groups']) {
                groups.add(FlatButton(
                  padding: EdgeInsets.all(0.00),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return WidgetGroupDetail(
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
                  child: WidgetGroupItem(
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
                  // title
                  Container(padding: mainPadding, child: Text(SearchGroupTitle, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))),

                  // tab search option
                  Container(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: (_searchBy != SearchGroupByMyAddress)
                              ? FlatButton(
                                  onPressed: () => _resetKeywordAddress(SearchGroupByMyAddress),
                                  child: Text(SearchGroupByMyAddress,
                                      textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)))
                              : Container(
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))),
                                  padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                                  child: Text(SearchGroupByMyAddress, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87))),
                        ),
                        Expanded(
                          flex: 1,
                          child: (_searchBy != SearchGroupByTitle)
                              ? FlatButton(
                                  onPressed: () => _resetKeywordAddress(SearchGroupByTitle),
                                  child: Text(SearchGroupByTitle, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)))
                              : Container(
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))),
                                  padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                                  child: Text(SearchGroupByTitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87))),
                        ),
                        Expanded(
                          flex: 1,
                          child: (_searchBy != SearchGroupByAddress)
                              ? FlatButton(
                                  onPressed: () => _resetKeywordAddress(SearchGroupByAddress),
                                  child:
                                      Text(SearchGroupByAddress, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)))
                              : Container(
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))),
                                  padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                                  child: Text(SearchGroupByAddress, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87))),
                        ),
                      ],
                    ),
                  ),

                  // tab content aka search form
                  Container(
                    color: Colors.white,
                    padding: mainPadding,
                    width: double.infinity,
                    child: Column(
                      children: [
                        if (_searchBy == SearchGroupByMyAddress)
                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(sprintf(GroupNearMeInRadiusXLead, [_radius, !snapLoading ? snapshot.data['address'] : '...']), style: TextStyle(color: Colors.black87)),
                            Text(ExpandRadiusTitle, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [5, 'spacer', 10, 'spacer', 20]
                                  .map((km) => km == 'spacer'
                                      ? SizedBox(width: 4.0)
                                      : TextButton(
                                          child: Text(sprintf(XKilometer, [km]), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => km == _radius ? Colors.black26 : Colors.black12)),
                                          onPressed: () {
                                            setState(() {
                                              _radius = km;
                                            });
                                          },
                                        ))
                                  .toList(),
                            ),
                          ]),
                        if (_searchBy == SearchGroupByTitle)
                          Column(
                            children: [
                              if (_keyword != '') Text(sprintf(SearchByKeywordLead, [_keyword]), style: TextStyle(color: Colors.black87)),
                              if (_keyword != '') SizedBox(height: 8.0),
                              Form(
                                  key: _formKeyKeyword,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: TextFormField(
                                        controller: _searchGroupByKeywordFormController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          hintText: SearchByKeywordlabel,
                                          hintStyle: TextStyle(color: Color(int.parse('0xff747070'))),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                                          errorStyle: TextStyle(color: Colors.redAccent),
                                          filled: true,
                                          fillColor: Color(int.parse('0xffC4C4C4')),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(width: 0, style: BorderStyle.none)),
                                        ),
                                        style: TextStyle(color: Color(int.parse('0xff747070'))),
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
                                      SizedBox(width: 8.0),
                                      MaterialButton(
                                        child: Text(FindButton, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          if (_formKeyKeyword.currentState.validate()) {
                                            FocusScope.of(context).unfocus();

                                            setState(() {
                                              _keyword = _searchGroupByKeywordFormController.text;
                                            });
                                          }
                                        },
                                        height: 46.0,
                                        color: Color(int.parse('0xff2DA310')),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        if (_searchBy == SearchGroupByAddress)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_closedValidAddress != null)
                                Text(sprintf(SearchGroupByAddressLead, [_radius, _closedValidAddress.addressLine]), style: TextStyle(color: Colors.black87)),
                              if (_closedValidAddress != null) SizedBox(height: 8.0),
                              Form(
                                  key: _formKeyAddress,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: TextFormField(
                                        controller: _searchAddressFormController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            hintText: FindAroundLabel,
                                            hintStyle: TextStyle(color: Color(int.parse('0xff747070'))),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                                            errorStyle: TextStyle(color: Colors.redAccent),
                                            filled: true,
                                            fillColor: Color(int.parse('0xffC4C4C4')),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(width: 0, style: BorderStyle.none))),
                                        style: TextStyle(color: Color(int.parse('0xff747070'))),
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
                                      SizedBox(width: 8.0),
                                      MaterialButton(
                                        child: Text(FindButton, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          if (_formKeyAddress.currentState.validate()) {
                                            FocusScope.of(context).unfocus();
                                            _getLatLong(context);
                                          }
                                        },
                                        height: 46.0,
                                        color: Color(int.parse('0xff2DA310')),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                      ),
                                    ],
                                  )),
                              if (_searchAddressErrorMessage != '')
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: verticalPadding,
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(_searchAddressErrorMessage, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                      Text(ClosedAddressFoundDesc, style: TextStyle(color: Colors.black87)),
                                    ])),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // loading
                  if (snapLoading)
                    Container(
                        padding: mainPadding,
                        child: Column(children: [
                          Column(children: [
                            Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                            SizedBox(height: 16.0),
                            if (_searchBy == SearchGroupByMyAddress) Text(LocatingDevice, textAlign: TextAlign.center),
                            if (_searchBy == SearchGroupByTitle) Text(sprintf(LoadingSearchByKeyword, [_keyword]), textAlign: TextAlign.center),
                            if (_searchBy == SearchGroupByAddress) Text(sprintf(LoadingGroupByAddress, [_closedValidAddress.addressLine]), textAlign: TextAlign.center),
                          ])
                        ])),

                  // if message
                  if (snapMessage != '') Container(padding: EdgeInsets.symmetric(vertical: 16.0), child: Text(snapMessage, textAlign: TextAlign.center)),

                  // result groups
                  if (groups.length > 0)
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
