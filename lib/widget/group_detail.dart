import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/delete_group.dart';
import 'package:khotmil/fetch/round_member.dart';
import 'package:khotmil/widget/add_edit_group.dart';

import 'group_item.dart';

class GroupDetail extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String progress;
  final String round;
  final String deadline;
  final String yourJuz;
  final String yourProgress;
  final String groupColor;
  final String loginKey;
  final bool owner;
  final Function reloadList;

  GroupDetail(
      {Key key,
      this.groupId,
      this.groupName,
      this.progress,
      this.round,
      this.deadline,
      this.yourJuz,
      this.yourProgress,
      this.groupColor,
      this.loginKey,
      this.owner,
      this.reloadList})
      : super(key: key);
  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  String _messageText = '';
  String _detailName = '';
  String _detailDeadline = '';
  String _detailColor = '';
  bool _loadingOverlay = false;
  bool _invitedMember = false;

  void _apiDeleteGroup() async {
    Navigator.pop(context);
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchDeleteGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        Navigator.pop(context);
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

  Widget _memberItem(juz, name, progress) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(width: 32.0, child: Text(juz)),
          Expanded(child: Container(padding: EdgeInsets.only(right: 8.0), width: 32.0, child: Text(name))),
          Container(
              padding: EdgeInsets.only(right: 8.0),
              width: 110.0,
              child: Stack(children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.blue[100], Colors.blue[300]])),
                    width: (int.parse(progress) / 100) * 110,
                    child: Text('')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Container(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0), child: Text(progress + '%'))],
                )
              ])),
          Container(
              width: 50.0,
              child: RaisedButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(0.0),
                  color: progress == '100' ? Colors.redAccent : Colors.green,
                  onPressed: () => {},
                  child: Text(progress == '100' ? ButtonOut : ButtonJoin))),
        ],
      ),
    );
  }

  Widget _memberState(context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Container(
          padding: sidePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _memberItem('1', 'zuli', '20'),
              _memberItem('2', 'zulu', '50'),
              _memberItem('3', 'zule, subekhi, anton, toni', '80'),
              _memberItem('4', 'zula', '100'),
              _memberItem('5', 'zulo', '0'),
              _memberItem('6', 'zuli', '50'),
              _memberItem('7', 'zuli', '50'),
              _memberItem('8', 'zulu', '50'),
              _memberItem('9', 'zule', '50'),
              _memberItem('10', 'zula', '100'),
              _memberItem('11', 'zulo', '50'),
              _memberItem('12', 'zuli', '50'),
              _memberItem('13', 'zule, subekhi, anton, toni', '80'),
              _memberItem('14', 'zula', '100'),
              _memberItem('15', 'zulo', '0'),
              _memberItem('16', 'zuli', '50'),
              _memberItem('17', 'zuli', '50'),
              _memberItem('18', 'zulu', '50'),
              _memberItem('19', 'zule', '50'),
              _memberItem('20', 'zula', '100'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _invitedMemberItem(juz, name) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(width: 32.0, child: Text(juz)),
          Expanded(child: Container(padding: EdgeInsets.only(right: 8.0), width: 32.0, child: Text(name))),
        ],
      ),
    );
  }

  Widget _invitedMemberList(context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Container(
          padding: sidePadding,
          child: FutureBuilder(
            future: fetchRoundMember(widget.loginKey, widget.groupId),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Column(
                  children: [Container(padding: mainPadding, child: Text(LoadingMember)), SizedBox(height: 16.0), Center(child: CircularProgressIndicator())],
                );
              }

              if (snapshot.hasData) {
                List<Widget> members = new List<Widget>();
                var i = 1;
                (snapshot.data['users']).values.forEach((user) {
                  members.add(_invitedMemberItem((i).toString(), user['name']));
                  i += 1;
                });

                return Column(
                  children: members,
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return Column(
                children: [Container(padding: mainPadding, child: Text(LoadingMember)), SizedBox(height: 16.0), Center(child: CircularProgressIndicator())],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _detailName = widget.groupName;
      _detailDeadline = widget.deadline;
      _detailColor = widget.groupColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(AppTitle),
            actions: <Widget>[
              if (widget.owner && _invitedMember)
                IconButton(
                  icon: const Icon(Icons.menu_book),
                  tooltip: JuzMember,
                  onPressed: () {
                    setState(() {
                      _invitedMember = false;
                    });
                  },
                ),
              if (widget.owner && !_invitedMember)
                IconButton(
                  icon: const Icon(Icons.group_add),
                  tooltip: GroupMember,
                  onPressed: () {
                    setState(() {
                      _invitedMember = true;
                    });
                  },
                ),
              if (widget.owner)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: EditGroup,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return AddEditGroup(
                        loginKey: widget.loginKey,
                        title: EditGroup,
                        reloadList: () => widget.reloadList(),
                        groupId: widget.groupId,
                        deadline: widget.deadline,
                        reloadDetail: (name, deadline, color) {
                          setState(() {
                            _detailName = name;
                            _detailDeadline = deadline;
                            _detailColor = color;
                          });
                        },
                      );
                    }));
                  },
                ),
              if (widget.owner)
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: DeleteGroup,
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
                                _apiDeleteGroup();
                              },
                              child: Text(DeleteGroupConfirm),
                            ),
                          ],
                        ));
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              if (_messageText != '') Container(padding: verticalPadding, child: Text(_messageText)),
              GroupItem(
                groupName: _detailName,
                progress: widget.progress,
                round: widget.round,
                deadline: _detailDeadline,
                yourJuz: widget.yourJuz,
                yourProgress: widget.yourProgress,
                groupColor: _detailColor,
              ),
              if (_invitedMember) Center(child: Text(MemberDidNotJoinJuz)),
              if (_invitedMember)
                Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                  padding: sidePadding,
                  child: Row(
                    children: [
                      Container(padding: verticalPadding, width: 32.0, child: Text('No')),
                      Expanded(
                        child: Container(padding: verticalPadding, child: Text(LabelName)),
                      ),
                      Container(padding: verticalPadding, width: 50.0, child: Text('')),
                    ],
                  ),
                ),
              if (_invitedMember) Expanded(child: _invitedMemberList(context)),
              if (!_invitedMember)
                Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                  padding: sidePadding,
                  child: Row(
                    children: [
                      Container(padding: verticalPadding, width: 32.0, child: Text(LabelJuz)),
                      Expanded(
                        child: Container(padding: verticalPadding, child: Text(LabelName)),
                      ),
                      Container(padding: verticalPadding, width: 110.0, child: Text(LabelProgress)),
                      Container(padding: verticalPadding, width: 50.0, child: Text('')),
                    ],
                  ),
                ),
              if (!_invitedMember) Expanded(child: _memberState(context)),
              Container(
                padding: mainPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(CurrentProgress, style: TextStyle(fontSize: 16.0)),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                    margin: EdgeInsets.only(bottom: 8.0, right: 16.0),
                                    decoration: BoxDecoration(color: Colors.lightBlue),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text('Juz 8', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                radio(true, '20%'),
                                radio(true, '50%'),
                                radio(false, '80%'),
                                radio(false, '100%'),
                              ],
                            )
                          ],
                        )),
                        RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          onPressed: () => {},
                          child: Text(SubmitText),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                  ],
                ),
              )
            ],
          ),
        ),
        if (_loadingOverlay) loadingOverlay(context)
      ],
    );
  }
}
