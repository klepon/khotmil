import 'package:flutter/material.dart';
import 'package:khotmil/fetch/delete_my_member.dart';
import 'package:khotmil/fetch/get_single_group.dart';
import 'package:khotmil/fetch/invite_user.dart';
import 'package:khotmil/fetch/search_user.dart';
import 'package:khotmil/fetch/start_new_round.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _messageText = '';
  String _detailName = '';
  String _detailRound = '';
  String _detailDeadline = '';
  String _detailColor = '';
  String _detailProgress = '';
  String _detailMyJuz = '';
  String _detailMyProgress = '';

  bool _loadingOverlay = false;
  bool _invitedMember = false;
  Map<String, dynamic> _activeJuz;

  List _apiReturnUsers = [];
  List _usersSelectedForInvite = [];
  bool _searchUserLoading = false;

  TextEditingController _searchUserFormController = TextEditingController();
  TextEditingController _newRoundDeadLineFormController = TextEditingController();

  Future _getMemberAPI;

  Future<void> _renderSelectDate(BuildContext context) async {
    DateTime date = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: date,
      lastDate: DateTime(date.year, date.month + 3),
      helpText: FormCreateGroupEndDate,
    );
    if (picked != null) _newRoundDeadLineFormController.text = (picked.toString()).split(' ')[0];
  }

  void _apiGetDetail() async {
    widget.reloadList();

    await fetchGetSingleGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _loadingOverlay = false;
          _detailProgress = data['group']['progress'].toString();
          _detailMyJuz = data['group']['my_juz'].toString();
          _detailMyProgress = data['group']['my_progress'].toString();
          _detailDeadline = data['group']['end_date'].toString();
          _detailRound = data['group']['round'].toString();
          _getMemberAPI = fetchRoundMember(widget.loginKey, widget.groupId);
        });
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
          _messageText = data[DataMessage];
        });
      } else {
        setState(() {});
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
        _apiGetDetail();
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
        _apiGetDetail();
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

  void _apiUpdateProgress(row) async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchUpdateProgress(widget.loginKey, row['id'], row['juz'], row['progress']).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        _apiGetDetail();
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

  void _apiInviteUser() async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    List uids = [];
    for (var user in _usersSelectedForInvite) {
      uids.add(user[0].toString());
    }

    await fetchInviteUser(widget.loginKey, widget.groupId, uids).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _apiReturnUsers = [];
          _usersSelectedForInvite = [];
          _searchUserFormController.text = '';
        });
        _apiGetDetail();
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

  void _apiSearchUser(value) async {
    setState(() {
      _searchUserLoading = true;
    });

    await fetchSearchUser(widget.loginKey, value).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _apiReturnUsers = data['users'];
          _searchUserLoading = false;
        });
      }
      if (data[DataStatus] == StatusError) {
        setState(() {
          _apiReturnUsers = [];
          _searchUserLoading = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        _apiReturnUsers = [];
        _searchUserLoading = false;
      });
    });
  }

  void _apiStartNewRound() async {
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchStartNewRound(widget.loginKey, widget.groupId, _newRoundDeadLineFormController.text).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        _apiGetDetail();
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

  void _addUid(userData) {
    _searchUserFormController.text = '';
    _usersSelectedForInvite.add(userData);

    setState(() {
      _apiReturnUsers = [];
      _usersSelectedForInvite = [
        ...{..._usersSelectedForInvite}
      ];
    });
  }

  void _removeUid(userData) {
    _usersSelectedForInvite.removeWhere((user) => user == userData);

    setState(() {
      _usersSelectedForInvite = [
        ...{..._usersSelectedForInvite}
      ];
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
  void dispose() {
    _searchUserFormController.dispose();
    _newRoundDeadLineFormController.dispose();
    super.dispose();
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
            Map<int, dynamic> namesInJuz = Map();
            Map<int, dynamic> progressInJuz = Map();
            Map<int, dynamic> myJuz = Map();
            Map<String, dynamic> userWithoutJuz = Map();
            Map<String, dynamic> activeJuz = _activeJuz;

            if (snapshot.connectionState != ConnectionState.done) {
              snapShootLoading = true;
            }

            if (snapshot.hasData) {
              for (var user in snapshot.data['users']) {
                if (user['juz'] == '0') {
                  userWithoutJuz[user['uid']] = user;
                } else {
                  // collect names in a juz
                  if (namesInJuz[int.parse(user['juz'])] == null) namesInJuz[int.parse(user['juz'])] = [];
                  namesInJuz[int.parse(user['juz'])].add(user['name']);

                  // collect progress in a juz
                  if (progressInJuz[int.parse(user['juz'])] == null) progressInJuz[int.parse(user['juz'])] = [];
                  progressInJuz[int.parse(user['juz'])].add(int.parse(user['progress']));

                  // collect current active user juz
                  if (user['isMe']) {
                    myJuz[int.parse(user['juz'])] = user;
                  }
                }
              }
            }

            if (snapshot.hasData && !_invitedMember) {
              for (int i = 1; i < 31; i += 1) {
                // get display mixed progress in a juz
                int totalJuzProgress = 0;
                if (progressInJuz[i] != null) {
                  totalJuzProgress =
                      int.parse((((progressInJuz[i].fold(0, (previous, current) => previous + current)) / (progressInJuz[i].length * 100)) * 100).toStringAsFixed(0));
                }

                // if my juz
                if (myJuz[i] != null) {
                  // assign activeJuz
                  if (activeJuz == null) {
                    activeJuz = Map.from(myJuz[i]);
                    // make sure activeJuz is valid, usualy after update/delete
                  } else if (myJuz[int.parse(activeJuz['juz'])] == null) {
                    activeJuz = Map.from(myJuz[i]);
                  }
                }

                members.add(Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(width: 32.0, child: Text(i.toString())),
                      Expanded(child: Container(padding: EdgeInsets.only(right: 8.0), width: 32.0, child: Text((namesInJuz[i] != null ? namesInJuz[i].join(', ') : '')))),
                      Container(
                          padding: EdgeInsets.only(right: 8.0),
                          width: 110.0,
                          child: Stack(children: [
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                decoration:
                                    BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.blue[100], Colors.blue[300]])),
                                width: (totalJuzProgress / 100) * 110,
                                child: Text('')),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Container(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0), child: Text(totalJuzProgress.toString() + '%'))],
                            )
                          ])),
                      Container(
                          width: 50.0,
                          child: RaisedButton(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(0.0),
                              color: myJuz[i] != null && myJuz[i]['progress'] == '100' ? Colors.redAccent : (myJuz[i] != null ? Colors.grey : Colors.green),
                              onPressed: () {
                                if (myJuz[i] != null && myJuz[i]['progress'] == '100')
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
                                              _apiLeaveRound(myJuz[i]['id']);
                                            },
                                            child: Text(ConfirmLeaveJuzButton),
                                          ),
                                        ],
                                      ));

                                if (myJuz[i] == null)
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
                              child: Text(myJuz[i] != null && myJuz[i]['progress'] == '100' ? ButtonOut : ButtonJoin))),
                    ],
                  ),
                ));
              }
            } else if (snapshot.hasData && _invitedMember) {
              var i = 1;
              for (var user in userWithoutJuz.values) {
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
              // search user
              members.add(Column(
                children: [
                  if (_apiReturnUsers.length > 0)
                    Container(
                      padding: sidePaddingNarrow,
                      child: Wrap(children: [
                        for (var user in _apiReturnUsers)
                          if ((_usersSelectedForInvite.firstWhere((i) => i[0] == user[0], orElse: () => null)) == null)
                            TextButton(onPressed: () => _addUid(user), child: Text('@' + user[1])),
                      ]),
                    ),
                  if (_searchUserLoading) Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                  TextFormField(
                    controller: _searchUserFormController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: sidePaddingNarrow,
                      hintText: FormCreateGroupUids,
                    ),
                    onChanged: (value) {
                      if (value.length >= 3) {
                        _apiSearchUser(value);
                      } else if (_apiReturnUsers.length > 0) {
                        setState(() {
                          _apiReturnUsers = [];
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.0),
                  if (_usersSelectedForInvite.length > 0)
                    Container(
                      padding: sidePaddingNarrow,
                      child: Column(children: [
                        for (var user in _usersSelectedForInvite)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('@' + user[1]),
                              IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => _removeUid(user)),
                            ],
                          ),
                        SizedBox(height: 16.0),
                      ]),
                    ),
                  SizedBox(height: 16.0),
                  RaisedButton(
                    child: Text(InviterButton),
                    onPressed: () => _apiInviteUser(),
                  ),
                ],
              ));
            } else if (snapshot.hasError) {
              snapShootMessage = snapshot.error.toString();
            }

            return Stack(children: [
              Column(
                children: [
                  GroupItem(
                    groupName: _detailName,
                    progress: _detailProgress != '' ? _detailProgress : widget.progress,
                    round: _detailRound != '' ? _detailRound : widget.round,
                    deadline: _detailDeadline,
                    yourJuz: _detailMyJuz != '' ? _detailMyJuz : widget.yourJuz,
                    yourProgress: _detailMyProgress != '' ? _detailMyProgress : widget.yourProgress,
                    groupColor: _detailColor,
                  ),
                  if (int.parse(_detailDeadline) <= int.parse((DateTime.now().millisecondsSinceEpoch / 1000).toStringAsFixed(0)) ||
                      (_detailProgress != '' ? _detailProgress : widget.progress) == '100')
                    Form(
                        key: _formKey,
                        child: Container(
                            padding: sidePadding,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _newRoundDeadLineFormController,
                                    keyboardType: TextInputType.text,
                                    readOnly: true,
                                    onTap: () => _renderSelectDate(context),
                                    decoration: InputDecoration(hintText: FormCreateGroupEndDate, errorStyle: errorTextStyle),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return FormCreateGroupEndDateError;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                RaisedButton(
                                  child: Text(StartNewRound + (int.parse(widget.round) + 1).toString()),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _apiStartNewRound();
                                    }
                                  },
                                ),
                              ],
                            ))),
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
                  if (!_invitedMember)
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
                                              child: Text(sprintf(CurrentJuz, [activeJuz != null ? activeJuz['juz'] : '']),
                                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                            ),
                                            onTap: () {
                                              List keys = myJuz.keys.toList();
                                              keys.sort();

                                              if (keys.length == 1) return;

                                              showDialog(
                                                  context: context,
                                                  child: SimpleDialog(
                                                    title: const Text(SelectEditedJuz),
                                                    children: keys.map((juz) {
                                                      if (myJuz[juz]['isMe']) {
                                                        return SimpleDialogOption(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            setState(() {
                                                              _activeJuz = Map.from(myJuz[juz]);
                                                            });
                                                          },
                                                          child: Text(sprintf(OptionJuz, [juz, myJuz[juz]['progress']])),
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
                                                String newProgress = activeJuz['progress'] == '20' && progress == 20 ? '0' : progress.toString();

                                                activeJuz['progress'] = newProgress;
                                                setState(() {
                                                  _activeJuz = activeJuz;
                                                });
                                              },
                                              child: radio((activeJuz != null ? int.parse(activeJuz['progress']) : 0) >= progress, progress.toString() + '%'),
                                            ))
                                        .toList(),
                                  )
                                ],
                              )),
                              RaisedButton(
                                padding: EdgeInsets.symmetric(vertical: 25.0),
                                child: Text(SubmitText),
                                onPressed: () {
                                  _apiUpdateProgress(activeJuz);
                                },
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
