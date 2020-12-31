import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/my_group_list.dart';
import 'package:khotmil/widget/add_group.dart';
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

  Future _futureGetGroupList;
  String _screenState = StateGroupList;
  String _messageText = '';

  void _apiGroupList() {
    setState(() {
      _futureGetGroupList = fetchMyGroupList(widget.loginKey);
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
          _screenState = '';
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
                      if (_screenState == '') Text(''),
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
                          return AddGroup(loginKey: widget.loginKey, reloadList: _reloadGroupList);
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
