import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/delete_group.dart';
import 'package:khotmil/fetch/join_round.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _messageText = '';
  String _detailName = '';
  String _detailDeadline = '';
  String _detailColor = '';
  bool _loadingOverlay = false;
  bool _invitedMember = false;

  Future _getMemberAPI;

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

  void _apiJoinRound(String mid, String juz) async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchJoinRound(widget.loginKey, mid, juz).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _loadingOverlay = false;
          _getMemberAPI = fetchRoundMember(widget.loginKey, widget.groupId);
        });
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

  Widget _joiningMemberList(context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Container(
          padding: sidePadding,
          child: FutureBuilder(
            future: _getMemberAPI,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Column(
                  children: [Container(padding: mainPadding, child: Text(LoadingMember)), SizedBox(height: 16.0), Center(child: CircularProgressIndicator())],
                );
              }

              if (snapshot.hasData) {
                var gid = '0';
                for (var user in snapshot.data['users']) {
                  if (user['isMe'] == true) {
                    gid = (user['gid']).toString();
                    break;
                  }
                }

                List<Widget> members = new List<Widget>();
                for (int i = 1; i < 31; i += 1) {
                  var names = [];
                  var isMe = false;
                  var progress = '0';
                  bool disableButton = false;

                  for (var user in snapshot.data['users']) {
                    if (user['juz'].toString() == i.toString()) {
                      names.add(user['name']);
                      progress = user['progress'];
                      disableButton = user['progress'] != '100';
                      if (user['isMe'] == true) isMe = true;
                    }
                  }

                  members.add(Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Container(width: 32.0, child: Text(i.toString())),
                        Expanded(child: Container(padding: EdgeInsets.only(right: 8.0), width: 32.0, child: Text(names.join(', ')))),
                        Container(
                            padding: EdgeInsets.only(right: 8.0),
                            width: 110.0,
                            child: Stack(children: [
                              Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.blue[100], Colors.blue[300]])),
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
                                color: progress == '100' && isMe ? Colors.redAccent : (disableButton ? Colors.grey : Colors.green),
                                onPressed: () {
                                  if (disableButton) return;

                                  showDialog(
                                      context: context,
                                      child: AlertDialog(
                                        title: Text(sprintf(ConfirmTakingJuzTitle, [i])),
                                        content: Text(sprintf(ConfirmTakingJuzDesc, [i])),
                                        actions: [
                                          FlatButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(CancelText),
                                          ),
                                          RaisedButton(
                                            color: Colors.redAccent,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _apiJoinRound(gid, i.toString());
                                            },
                                            child: Text(ConfirmTakingJuzButton),
                                          ),
                                        ],
                                      ));
                                },
                                child: Text(progress == '100' ? ButtonOut : ButtonJoin))),
                      ],
                    ),
                  ));
                }

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

  Widget _invitedMemberList(context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Container(
          padding: sidePadding,
          child: FutureBuilder(
            future: _getMemberAPI,
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
                  if (user['juz'] == '0') {
                    members.add(Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      padding: EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(width: 32.0, child: Text(i.toString())),
                          Expanded(child: Container(padding: EdgeInsets.only(right: 8.0), width: 32.0, child: Text(user['name']))),
                        ],
                      ),
                    ));
                    i += 1;
                  }
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

    _getMemberAPI = fetchRoundMember(widget.loginKey, widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
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
              GroupItem(
                groupName: _detailName,
                progress: widget.progress,
                round: widget.round,
                deadline: _detailDeadline,
                yourJuz: widget.yourJuz,
                yourProgress: widget.yourProgress,
                groupColor: _detailColor,
              ),
              if (_messageText != '') SizedBox(height: 8.0),
              if (_messageText != '') Container(child: Text(_messageText)),
              if (_messageText != '') SizedBox(height: 8.0),
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
              if (!_invitedMember) Expanded(child: _joiningMemberList(context)),
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
