import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/group_list.dart';
import 'package:khotmil/widget/group_create_group.dart';
import 'package:khotmil/widget/group_detail.dart';
import 'package:khotmil/widget/group_list_item.dart';
import 'package:khotmil/widget/group_list_invitation.dart';
import 'package:khotmil/widget/group_search_group.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class WidgetGroupList extends StatefulWidget {
  final String name;
  final String loginKey;
  WidgetGroupList({Key key, this.name, this.loginKey}) : super(key: key);

  @override
  _WidgetGroupListState createState() => _WidgetGroupListState();
}

class _WidgetGroupListState extends State<WidgetGroupList> {
  void _reloadGroupList() {
    setState(() {});
  }

  Widget _createOrJoinGroup() {
    return Container(
      padding: mainPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MaterialButton(
            child: Text(CreateGroup, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WidgetCreateGroup(
                  loginKey: widget.loginKey,
                  reloadList: _reloadGroupList,
                );
              }));
            },
            height: 40.0,
            color: Color(int.parse('0xffF30F0F')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
          MaterialButton(
            child: Text(JoinGroup, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WidgetSearchGroup(loginKey: widget.loginKey, reloadList: _reloadGroupList);
              }));
            },
            height: 40.0,
            color: Color(int.parse('0xff2DA310')),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
        ],
      ),
    );
  }

  Widget _loopGroups(groups, context) {
    List<Widget> buttons = new List<Widget>();
    for (var i = 0; i < groups.length; i += 1) {
      var group = groups[i];
      buttons.add(FlatButton(
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
                reloadList: _reloadGroupList);
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

    return Column(
      children: buttons,
    );
  }

  Widget _myGroupList(context) {
    return FutureBuilder(
      future: fetchMyGroupList(widget.loginKey, 0),
      builder: (context, snapshot) {
        String _versionMessage = '';
        String _currentAppVersion = '';
        String _versionMessageCtaText = '';
        String _versionMessageCtaLink = '';
        String _responseMessage = '';
        String _dataMessage = '';
        bool _isLoading = true;
        bool _showRefreshButton = false;
        bool _hasData = false;

        if (snapshot.connectionState != ConnectionState.done) {
          _responseMessage = LoadingGroups;
        } else if (snapshot.hasData) {
          _currentAppVersion = snapshot.data['khotmil_app_version'];
          _versionMessageCtaText = snapshot.data['app_version_cta_text'];
          _versionMessageCtaLink = snapshot.data['app_version_cta_link'];

          if (snapshot.data['app_version_message'] != '0') {
            _versionMessage = snapshot.data['app_version_message'];
          }

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

        // response message, loading indicator, data message
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
                  SizedBox(height: 24.0),
                  _createOrJoinGroup(),
                  SizedBox(height: 24.0),
                  MaterialButton(
                    child: Text(ButtonRefresh, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                    onPressed: () => setState(() {}),
                    height: 40.0,
                    color: Color(int.parse('0xffC4C4C4')),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                ],
              ));
        }

        // update warning blocking
        if (_versionMessage != '' && _currentAppVersion != ApiVersion)
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                margin: mainPadding,
                padding: mainPadding,
                color: Colors.deepOrange,
                child: Html(
                  data: sprintf(_versionMessage, [_currentAppVersion]),
                  style: {"*": Style(textAlign: TextAlign.center, fontSize: FontSize(14.0)), "strong": Style(fontSize: FontSize(20.0))},
                ),
              ),
              SizedBox(height: 8.0),
              MaterialButton(
                child: Text(_versionMessageCtaText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: () => launch(_versionMessageCtaLink),
                height: 50.0,
                color: Color(int.parse('0xff2DA310')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
              SizedBox(height: 24.0),
              MaterialButton(
                child: Text(ButtonRefresh, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: () => _reloadGroupList(),
                height: 50.0,
                color: Color(int.parse('0xff2DA310')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
            ],
          );

        // notification message, listing
        return Column(
          children: [
            if (_versionMessage != '' && _currentAppVersion == ApiVersion)
              Container(
                width: double.infinity,
                margin: mainPadding,
                padding: mainPadding,
                color: Colors.deepOrange,
                child: Html(
                  data: sprintf(_versionMessage, [_currentAppVersion]),
                  style: {"*": Style(textAlign: TextAlign.center, fontSize: FontSize(14.0)), "strong": Style(fontSize: FontSize(20.0))},
                ),
              ),

            // welcome/intro message
            if (_hasData)
              Container(
                  width: double.infinity,
                  padding: mainPadding,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (snapshot.data['invitation'] > 0)
                      Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        width: double.infinity,
                        child: FlatButton(
                            color: Colors.deepOrange,
                            child: Text(sprintf(GroupInvitation, [snapshot.data['invitation']]), style: boldLink),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return WidgetGroupListInvitation(
                                    name: widget.name,
                                    loginKey: widget.loginKey,
                                    reloadGroupList: _reloadGroupList,
                                  );
                                }))),
                      ),
                    Text(sprintf(WelcomeMessage, [widget.name])),
                    Text(SelectGroupToSeeProgress),
                    if (snapshot.data['invitation'] == 0) SizedBox(height: 8.0),
                  ])),

            // list group render only
            if (_hasData)
              Expanded(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        child: Column(children: [
                          _loopGroups(snapshot.data['groups'], context),
                        ]))),
              ),
            if (_showRefreshButton)
              MaterialButton(
                child: Text(ButtonRefresh, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                onPressed: () => setState(() {}),
                height: 40.0,
                color: Color(int.parse('0xffC4C4C4')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
            _createOrJoinGroup(),
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
          ],
        ));
  }
}
