import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/group_list.dart';
import 'package:khotmil/widget/group_detail.dart';
import 'package:khotmil/widget/group_item.dart';
import 'package:sprintf/sprintf.dart';

class GroupListInvitation extends StatefulWidget {
  final String name;
  final String loginKey;
  GroupListInvitation({Key key, this.name, this.loginKey}) : super(key: key);

  @override
  _GroupListInvitationState createState() => _GroupListInvitationState();
}

class _GroupListInvitationState extends State<GroupListInvitation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loadingOverlay = false;

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
        ),
      ));
    }

    return Column(
      children: buttons,
    );
  }

  Widget _myGroupList(context) {
    return FutureBuilder(
      future: fetchMyGroupList(widget.loginKey, 1),
      builder: (context, snapshot) {
        String _responseMessage = '';
        String _dataMessage = '';
        bool _isLoading = true;
        bool _showRefreshButton = false;
        bool _hasData = false;

        if (snapshot.connectionState != ConnectionState.done) {
          _responseMessage = LoadingGroups;
        } else if (snapshot.hasData) {
          if (snapshot.data['message_no_invitation'] != null) {
            _dataMessage = snapshot.data['message_no_invitation'];
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

        return SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: Column(
            children: [
              if (_hasData)
                Container(
                    width: double.infinity,
                    padding: mainPadding,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(sprintf(WelcomeMessage, [widget.name])),
                      Text(ThisGroupInviteYou),
                      SizedBox(height: 8.0)
                    ])),
              if (_hasData) _loopGroups(snapshot.data['groups'], context),
              if (_showRefreshButton) RaisedButton(onPressed: () => setState(() {}), child: Text(ButtonRefresh)),
            ],
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(AppTitle)),
        body: SafeArea(
            child: Stack(
          children: [
            Container(decoration: pageBg, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _myGroupList(context))])),
            if (_loadingOverlay) loadingOverlay(context)
          ],
        )));
  }
}
