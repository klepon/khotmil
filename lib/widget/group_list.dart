import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/group_list.dart';
import 'package:khotmil/widget/group_add_edit.dart';
import 'package:khotmil/widget/group_detail.dart';
import 'package:khotmil/widget/group_list_item.dart';
import 'package:khotmil/widget/group_list_invitation.dart';
import 'package:khotmil/widget/search_group.dart';
import 'package:sprintf/sprintf.dart';

class GroupList extends StatefulWidget {
  final String name;
  final String loginKey;
  GroupList({Key key, this.name, this.loginKey}) : super(key: key);

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  void _reloadGroupList() {
    setState(() {});
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
                yourProgress: group['my_progress'].toString(),
                photo: group['photo'],
                owner: group['owner'],
                isInvitation: false,
                loginKey: widget.loginKey,
                reloadList: _reloadGroupList);
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

    return Column(
      children: buttons,
    );
  }

  Widget _myGroupList(context) {
    return FutureBuilder(
      future: fetchMyGroupList(widget.loginKey, 0),
      builder: (context, snapshot) {
        String _responseMessage = '';
        String _dataMessage = '';
        bool _isLoading = true;
        bool _showRefreshButton = false;
        bool _hasData = false;

        if (snapshot.connectionState != ConnectionState.done) {
          _responseMessage = LoadingGroups;
        } else if (snapshot.hasData) {
          if (snapshot.data['message'] != null) {
            _dataMessage = snapshot.data['message'];
          } else {
            _hasData = true;
          }
          _isLoading = false;
        } else if (snapshot.hasError) {
          _responseMessage = snapshot.error.toString();
          _showRefreshButton = true;
          _isLoading = false;
        }

        if (_isLoading || _dataMessage != '' || _responseMessage != '') {
          return Container(
              width: double.infinity,
              padding: mainPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_responseMessage != '') Text(_responseMessage),
                  if (_isLoading) SizedBox(height: 16.0),
                  if (_isLoading) Center(child: CircularProgressIndicator()),
                  if (_dataMessage != '') Text(sprintf(WelcomeMessage, [widget.name]), textAlign: TextAlign.center),
                  if (_dataMessage != '') SizedBox(height: 20.0),
                  if (_dataMessage != '') Text(_dataMessage, textAlign: TextAlign.center),
                ],
              ));
        }

        return Column(
          children: [
            if (_hasData)
              Container(
                  width: double.infinity,
                  padding: mainPadding,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sprintf(WelcomeMessage, [widget.name])),
                    Text(SelectGroupToSeeProgress),
                    if (snapshot.data['invitation'] > 0)
                      FlatButton(
                          child: Text(sprintf(GroupInvitation, [snapshot.data['invitation']]), style: boldLink),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return GroupListInvitation(
                                  name: widget.name,
                                  loginKey: widget.loginKey,
                                  reloadGroupList: _reloadGroupList,
                                );
                              }))),
                    if (snapshot.data['invitation'] == 0) SizedBox(height: 8.0),
                  ])),
            if (_hasData)
              Expanded(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        child: Column(children: [
                          _loopGroups(snapshot.data['groups'], context),
                        ]))),
              ),
            if (_showRefreshButton) RaisedButton(onPressed: () => setState(() {}), child: Text(ButtonRefresh)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: pageBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _myGroupList(context),
            ),
            Container(
              padding: mainPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    child: Text(CreateGroup, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
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
                    height: 50.0,
                    color: Color(int.parse('0xffF30F0F')),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                  MaterialButton(
                    child: Text(JoinGroup, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return SearchGroup(loginKey: widget.loginKey, reloadList: _reloadGroupList);
                      }));
                    },
                    height: 50.0,
                    color: Color(int.parse('0xff2DA310')),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                ],
              ),
            )
          ],
          // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
