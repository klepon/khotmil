import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/my_group_list.dart';
import 'package:khotmil/fetch/search_group.dart';
import 'package:khotmil/widget/add_edit_group.dart';
import 'package:khotmil/widget/group_detail.dart';
import 'package:sprintf/sprintf.dart';

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

  TextEditingController _searchGroupFormController = TextEditingController();

  String _screenState = StateGroupList;
  String _messageText = '';
  int _radius = 1;
  String _keyword = '';
  Address _closedValidAddress;
  String _searchBy = SearchGroupByPhoneLocation;

  void _toggleScreenState(state) {
    setState(() {
      _screenState = state;
    });
  }

  void _reloadGroupList() {
    setState(() {});
  }

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
          latlong = position.latitude.toString() + ',' + position.longitude.toString();

          List<Address> address = await Geocoder.local.findAddressesFromCoordinates(Coordinates(position.latitude, position.longitude));
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

  Widget _errorResponse(_errorMessage, [showRefresh = true]) {
    return Column(
      children: [
        Container(padding: mainPadding, child: Text(_errorMessage)),
        SizedBox(
          height: 16.0,
        ),
        if (showRefresh)
          RaisedButton(
              onPressed: () {
                setState(() {});
              },
              child: Text(ButtonRefresh)),
      ],
    );
  }

  Widget _myGroupList(context) {
    return FutureBuilder(
      future: fetchMyGroupList(widget.loginKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            children: [Container(padding: mainPadding, child: Text(LoadingGroups)), SizedBox(height: 16.0), Center(child: CircularProgressIndicator())],
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data['message'] != null) {
            return _errorResponse(snapshot.data['message'], false);
          }

          return _loopGroups(snapshot.data['groups'], context);
        } else if (snapshot.hasError) {
          return _errorResponse("${snapshot.error}");
        }

        return Column(
          children: [Container(padding: mainPadding, child: Text(LoadingGroups)), SizedBox(height: 16.0), Center(child: CircularProgressIndicator())],
        );
      },
    );
  }

  Widget _joinGroupForm() {
    return Container(
      padding: mainPadding,
      child: Column(
        children: [
          Text(SearchGroupTitle, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.0),
          FutureBuilder(
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
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text(JoinGroupConfirmationTitle),
                              content: Text(sprintf(JoinGroupConfirmationDesc, [group['name'], group['round'].toString()])),
                              actions: [
                                FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(CancelText),
                                ),
                                RaisedButton(
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(JoinGroupConfirmButton),
                                ),
                              ],
                            ));
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
                } else if (snapshot.hasError) {
                  snapMessage = snapshot.error.toString();
                }

                return Column(
                  children: [
                    if (snapMessage != '') Container(padding: EdgeInsets.only(bottom: 16.0), child: Text(snapMessage, textAlign: TextAlign.center)),
                    if (snapLoading)
                      Column(
                        children: [
                          Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                          SizedBox(height: 16.0),
                          Text(LocatingDevice, textAlign: TextAlign.center),
                        ],
                      ),
                    if (groups.length > 0)
                      Column(
                        children: [
                          Column(
                            children: [
                              Text(sprintf(GroupInRadius, [_radius, snapshot.data['address'] ?? '...']), textAlign: TextAlign.center),
                              SizedBox(height: 16.0),
                              Column(children: groups),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    onPressed: () {},
                                    child: Text(ExpandRadiusButton),
                                  ),
                                  RaisedButton(
                                    onPressed: () {},
                                    child: Text(ChangeRadiusCenterButton),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: _searchGroupFormController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Cari dengan nama',
                          ),
                        )),
                        RaisedButton(
                          onPressed: () {},
                          child: Text('cari'),
                        )
                      ],
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchGroupFormController.dispose();
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
          if (_messageText != '') Container(padding: mainPadding, child: Center(child: Text(_messageText))),
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
                      if (_screenState == StateJoinGroup) _joinGroupForm(),
                    ]))),
          ),

          // Expanded(child: _groupList(context)),
          Container(
            padding: mainPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_screenState == StateJoinGroup) RaisedButton(onPressed: () => _toggleScreenState(StateGroupList), child: Text(CancelText), color: Colors.blueGrey),
                if (_screenState != StateJoinGroup)
                  RaisedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return AddEditGroup(
                            loginKey: widget.loginKey,
                            title: CreateGroup,
                            groupId: '',
                            reloadList: _reloadGroupList,
                            deadline: '',
                            reloadDetail: () => {},
                          );
                        }));
                      },
                      child: Text(CreateGroup),
                      color: Colors.redAccent),
                if (_screenState != StateJoinGroup) RaisedButton(onPressed: () => _toggleScreenState(StateJoinGroup), child: Text(JoinGroup)),
              ],
            ),
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
