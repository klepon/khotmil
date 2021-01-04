import 'package:flutter/material.dart';
import 'package:khotmil/fetch/delete_my_member.dart';
import 'package:khotmil/fetch/get_single_group.dart';
import 'package:khotmil/fetch/update_progress.dart';
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
  String _detailProgress = '';
  String _detailMyJuz = '';
  String _detailMyProgress = '';

  bool _loadingOverlay = false;
  bool _invitedMember = false;
  List _activeJuz = ['-', '0', '0'];

  Future _getMemberAPI;

  void _apiGetDetail() async {
    await fetchGetSingleGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _loadingOverlay = false;
          _detailProgress = data['group']['progress'].toString();
          _detailMyJuz = data['group']['my_juz'].toString();
          _detailMyProgress = data['group']['my_progress'].toString();
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

  void _apiJoinRound(String juz) async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchJoinRound(widget.loginKey, widget.groupId, juz).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadList();

        setState(() {
          _apiGetDetail();
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

  void _apiLeaveRound(String mid) async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchDeleteMyMember(widget.loginKey, mid).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadList();

        setState(() {
          _apiGetDetail();
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

  void _apiUpdateProgress(String juz, String progress, String id) async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchUpdateProgress(widget.loginKey, id, juz, progress).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadList();

        setState(() {
          _apiGetDetail();
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
    return Scaffold(
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
      body: FutureBuilder(
          future: _getMemberAPI,
          builder: (context, snapshot) {
            List<Widget> members = new List<Widget>();
            bool snapShootLoading = false;
            String snapShootMessage = '';
            Map<int, dynamic> joinedUsers = Map();
            List unjoinedUsers = [];
            List activeJuz = [_activeJuz[0], _activeJuz[1], _activeJuz[2]];

            if (snapshot.connectionState != ConnectionState.done) {
              snapShootLoading = true;
            }

            if (snapshot.hasData) {
              for (var user in snapshot.data['users']) {
                if (user['juz'] == '0') {
                  unjoinedUsers.add(user);
                } else {
                  joinedUsers[int.parse(user['juz'])] = user;
                }
              }
            }

            if (snapshot.hasData && !_invitedMember) {
              for (int i = 1; i < 31; i += 1) {
                List names = [];
                String mid = '';
                String progress = '0';
                bool isMe = false;
                bool disableButton = false;

                if (joinedUsers[i] != null) {
                  names.add(joinedUsers[i]['name']);
                  progress = joinedUsers[i]['progress'];
                  disableButton = joinedUsers[i]['progress'] != '100';
                  if (joinedUsers[i]['isMe'] == true) {
                    isMe = true;
                    mid = joinedUsers[i]['id'];
                    if (activeJuz[0] == '-') {
                      activeJuz[0] = i;
                      activeJuz[2] = joinedUsers[i]['id'];
                    }
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
                                decoration:
                                    BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.blue[100], Colors.blue[300]])),
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
                                if (progress == '100' && isMe)
                                  showDialog(
                                      context: context,
                                      child: AlertDialog(
                                        title: Text(sprintf(ConfirmLeaveJuzTitle, [i])),
                                        content: Text(sprintf(ConfirmLeaveJuzDesc, [i])),
                                        actions: [
                                          FlatButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(CancelText),
                                          ),
                                          RaisedButton(
                                            color: Colors.redAccent,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _apiLeaveRound(mid);
                                            },
                                            child: Text(ConfirmLeaveJuzButton),
                                          ),
                                        ],
                                      ));

                                if (progress != '100' && !isMe)
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
                                              _apiJoinRound(i.toString());
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
            } else if (snapshot.hasData && _invitedMember) {
              var i = 1;
              for (var user in unjoinedUsers) {
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
            } else if (snapshot.hasError) {
              snapShootMessage = snapshot.error.toString();
            }

            return Stack(children: [
              Column(
                children: [
                  GroupItem(
                    groupName: _detailName,
                    progress: _detailProgress != '' ? _detailProgress : widget.progress,
                    round: widget.round,
                    deadline: _detailDeadline,
                    yourJuz: _detailMyJuz != '' ? _detailMyJuz : widget.yourJuz,
                    yourProgress: _detailMyProgress != '' ? _detailMyProgress : widget.yourProgress,
                    groupColor: _detailColor,
                  ),
                  SizedBox(height: 16.0),
                  if (_messageText != '') Container(padding: mainPadding, child: Text(_messageText)),
                  if (snapShootMessage != '') Container(padding: mainPadding, child: Text(snapShootMessage)),
                  if (members.length == 0)
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (!_invitedMember) Container(padding: mainPadding, child: Text(LoadingMember)),
                      if (_invitedMember) Container(padding: mainPadding, child: Text(AllMemberJoinJuz)),
                    ])),
                  if (_messageText != '' || snapShootMessage != '' || members.length == 0) SizedBox(height: 16.0),
                  if (members.length > 0 && _invitedMember) Center(child: Text(MemberDidNotJoinJuz)),
                  if (members.length > 0 && _invitedMember) SizedBox(height: 16.0),
                  if (members.length > 0 && _invitedMember)
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
                  if (members.length > 0 && _invitedMember)
                    Expanded(
                        child: SingleChildScrollView(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                                child: Container(padding: sidePadding, child: Column(children: members))))),
                  if (members.length > 0 && !_invitedMember)
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
                  if (members.length > 0 && !_invitedMember)
                    Expanded(
                        child: SingleChildScrollView(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                                child: Container(padding: sidePadding, child: Column(children: members))))),
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
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                        margin: EdgeInsets.only(bottom: 8.0, right: 16.0),
                                        decoration: BoxDecoration(color: Colors.lightBlue),
                                        child: GestureDetector(
                                          child: Center(
                                            child: Text(sprintf(CurrentJuz, [activeJuz[0]]), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                          ),
                                          onTap: () {
                                            List keys = joinedUsers.keys.toList();
                                            keys.sort();

                                            if (keys.length == 1) return;

                                            showDialog(
                                                context: context,
                                                child: SimpleDialog(
                                                  title: const Text(SelectEditedJuz),
                                                  children: keys.map((juz) {
                                                    if (joinedUsers[juz]['isMe']) {
                                                      return SimpleDialogOption(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          setState(() {
                                                            _activeJuz[0] = juz;
                                                            _activeJuz[1] = joinedUsers[juz]['progress'];
                                                            _activeJuz[2] = joinedUsers[juz]['id'];
                                                          });
                                                        },
                                                        child: Text(sprintf(OptionJuz, [juz, joinedUsers[juz]['progress']])),
                                                      );
                                                    }
                                                  }).toList(),
                                                ));
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [20, 40, 80, 100]
                                      .map((progress) => GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _activeJuz[1] = _activeJuz[1] == '20' && progress == 20 ? '0' : progress.toString();
                                              });
                                            },
                                            child: radio(int.parse(activeJuz[1]) >= progress, progress.toString() + '%'),
                                          ))
                                      .toList(),
                                )
                              ],
                            )),
                            RaisedButton(
                              padding: EdgeInsets.symmetric(vertical: 25.0),
                              onPressed: () {
                                _apiUpdateProgress(
                                  activeJuz[0].toString(),
                                  activeJuz[1].toString(),
                                  activeJuz[2].toString(),
                                );
                              },
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
              if (snapShootLoading || _loadingOverlay) loadingOverlay(context)
            ]);
          }),
    );
  }
}
