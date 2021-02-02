import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:intl/intl.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/fetch/member_leave_group.dart';
import 'package:khotmil/fetch/member_self_delete.dart';
import 'package:khotmil/fetch/group_get_single_group.dart';
import 'package:khotmil/fetch/group_invite_user.dart';
import 'package:khotmil/fetch/group_search_user.dart';
import 'package:khotmil/fetch/group_start_new_round.dart';
import 'package:khotmil/fetch/member_update_progress.dart';
import 'package:khotmil/widget/group_edit_group.dart';
import 'package:sprintf/sprintf.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/member_join_round.dart';
import 'package:khotmil/fetch/group_round_member.dart';
import 'package:url_launcher/url_launcher.dart';

import 'group_list_item.dart';

class WidgetGroupDetail extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String progress;
  final String round;
  final String deadline;
  final String yourProgress;
  final String photo;
  final String loginKey;
  final bool owner;
  final bool isInvitation;
  final Function reloadList;

  WidgetGroupDetail(
      {Key key,
      this.groupId,
      this.groupName,
      this.progress,
      this.round,
      this.deadline,
      this.yourProgress,
      this.photo,
      this.loginKey,
      this.owner,
      this.isInvitation,
      this.reloadList})
      : super(key: key);

  @override
  _WidgetGroupDetailState createState() => _WidgetGroupDetailState();
}

class _WidgetGroupDetailState extends State<WidgetGroupDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateFormat formatter = DateFormat('dd-LLL-yyyy');

  String _detailName = '';
  String _detailRound = '';
  String _detailDeadline = '';
  String _detailProgress = '';
  String _detailPhoto = '';
  String _detailMyProgress = '';

  bool _loadingOverlay = false;
  bool _invitedMember = false;

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
    if (picked != null) _newRoundDeadLineFormController.text = formatter.format(picked);
  }

  Future<void> _apiGetDetail() async {
    widget.reloadList();

    await fetchGetSingleGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        setState(() {
          _loadingOverlay = false;
          _detailName = data['group']['name'];
          _detailProgress = data['group']['progress'].toString();
          _detailPhoto = data['group']['photo'];
          _detailMyProgress = data['group']['my_progress'].toString();
          _detailDeadline = data['group']['end_date'].toString();
          _detailRound = data['group']['round'].toString();
          _getMemberAPI = fetchRoundMember(widget.loginKey, widget.groupId);
        });
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      } else {
        setState(() {});
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
    });
  }

  void _apiRejectInvitaion() async {
    Navigator.pop(context);
    setState(() {
      _loadingOverlay = true;
    });

    await fetchLeaveGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        Navigator.pop(context);
        widget.reloadList();
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
    });
  }

  void _apiJoinRound(String juz) async {
    setState(() {
      _loadingOverlay = true;
    });

    await fetchJoinRound(widget.loginKey, widget.groupId, juz).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        _apiGetDetail();
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
    });
  }

  void _apiLeaveRound(String mid) async {
    setState(() {
      _loadingOverlay = true;
    });

    await fetchDeleteMyMember(widget.loginKey, mid).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        _apiGetDetail();
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
    });
  }

  void _apiUpdateProgress(row) async {
    setState(() {
      _loadingOverlay = true;
    });

    await fetchUpdateProgress(widget.loginKey, row['id'], row['juz'].toString(), row['progress'].toString()).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        _apiGetDetail();
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
    });
  }

  void _apiInviteUser() async {
    setState(() {
      _loadingOverlay = true;
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
        });
        modalMessage(context, data[DataMessage]);
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
    });
  }

  void _apiSearchUser(String value, List<String> uids) async {
    setState(() {
      _searchUserLoading = true;
    });

    await fetchSearchUser(widget.loginKey, value, uids).then((data) {
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
    });

    await fetchStartNewRound(widget.loginKey, widget.groupId, _newRoundDeadLineFormController.text).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        _apiGetDetail();
        modalMessage(context, StartNewRoundSuccess);
      } else if (data[DataStatus] == StatusError) {
        setState(() {
          _loadingOverlay = false;
        });
        modalMessage(context, data[DataMessage]);
      }
    }).catchError((onError) {
      setState(() {
        _loadingOverlay = false;
      });
      modalMessage(context, onError.toString());
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

  void _backToList() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _detailName = widget.groupName;
      _detailDeadline = widget.deadline;
      _detailProgress = widget.progress;
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
      appBar: AppBar(title: Text(AppTitle)),
      body: RefreshIndicator(
        onRefresh: () => _apiGetDetail(),
        child: FutureBuilder(
          future: _getMemberAPI,
          builder: (context, snapshot) {
            List<Widget> members = new List<Widget>();
            bool isAdmin = widget.owner;
            bool snapShootLoading = false;
            String snapShootMessage = '';
            Map<int, List<Widget>> namesInJuz = Map();
            Map<int, dynamic> progressInJuz = Map();
            Map<int, dynamic> myJuz = Map();
            Map<String, dynamic> userWithoutJuz = Map();
            List<String> usersIdInGroup = new List<String>();

            if (snapshot.connectionState != ConnectionState.done) {
              snapShootLoading = true;
            }

            if (snapshot.hasData) {
              for (var user in snapshot.data['users']) {
                usersIdInGroup.add(user['uid']);

                if (user['isAdmin']) {
                  isAdmin = true;
                }

                if (user['juz'] == '0' && !user['isMe']) {
                  userWithoutJuz[user['uid']] = user;
                } else {
                  // collect names in a juz
                  if (namesInJuz[int.parse(user['juz'])] == null) {
                    namesInJuz[int.parse(user['juz'])] = new List<Widget>();
                  } else {
                    namesInJuz[int.parse(user['juz'])].add(Text(', ', style: TextStyle(color: Colors.black87)));
                  }

                  namesInJuz[int.parse(user['juz'])].add(GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          child: AlertDialog(
                              scrollable: true,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                      backgroundImage: user['photo'] != '' ? NetworkImage(user['photo']) : AssetImage(AnonImage), backgroundColor: Colors.white, radius: 60),
                                  SizedBox(height: 16.0),
                                  Text(user['fullname'] ?? ''),
                                  if (user['phone'] != '')
                                    FlatButton(
                                        onPressed: () => launch("tel:" + user['phone']),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.phone), Text(user['phone'])])),
                                ],
                              ))),
                      child: Text(user['name'], style: TextStyle(color: Colors.black87, decoration: TextDecoration.underline))));

                  // collect progress in a juz
                  if (progressInJuz[int.parse(user['juz'])] == null) progressInJuz[int.parse(user['juz'])] = [];
                  progressInJuz[int.parse(user['juz'])].add(int.parse(user['progress']));

                  // collect current active user juz, for button color etc
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

                members.add(Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black26))),
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(width: 32.0, alignment: Alignment.center, child: Text(i.toString(), style: TextStyle(color: Colors.black87))),
                      Expanded(
                          child: Container(
                              padding: EdgeInsets.only(right: 8.0),
                              width: 32.0,
                              child: Wrap(
                                children: namesInJuz[i] != null ? namesInJuz[i] : [],
                              ))),
                      Container(
                          padding: EdgeInsets.only(right: 8.0),
                          width: 110.0,
                          child: Stack(children: [
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                // decoration:
                                //     BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.blue[100], Colors.blue[300]])),
                                color: Colors.orange[200],
                                width: (totalJuzProgress / 100) * 110,
                                child: Text('')),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                                    child: Text(totalJuzProgress.toString() + '%', style: TextStyle(color: Colors.black87)))
                              ],
                            )
                          ])),
                      Container(
                          width: 60.0,
                          child: RaisedButton(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(0.0),
                              color: myJuz[i] == null ? Colors.green : Colors.redAccent,
                              onPressed: () {
                                if (myJuz[i] != null)
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      Map<String, dynamic> _updatedProgress = {'id': myJuz[i]['id'], 'juz': i, 'progress': int.parse(myJuz[i]['progress'])};

                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            scrollable: true,
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Html(
                                                  data: sprintf(JuzActionMessage, [i]),
                                                  style: {"*": Style(textAlign: TextAlign.center, fontSize: FontSize(14.0)), "strong": Style(fontSize: FontSize(20.0))},
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [20, 40, 80, 100]
                                                      .map((progress) => GestureDetector(
                                                          onTap: () => setState(() {
                                                                _updatedProgress['progress'] = _updatedProgress['progress'] == 20 && progress == 20 ? 0 : progress;
                                                              }),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets.all(16.0),
                                                                decoration: BoxDecoration(
                                                                    color: (_updatedProgress['progress'] >= progress ? Colors.orange : Colors.white), shape: BoxShape.circle),
                                                              ),
                                                              Text(progress.toString() + '%')
                                                            ],
                                                          )))
                                                      .toList(),
                                                ),
                                                SizedBox(height: 24.0),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    MaterialButton(
                                                      child: Text(SaveText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _apiUpdateProgress(_updatedProgress);
                                                      },
                                                      height: 50.0,
                                                      color: Color(int.parse('0xff2DA310')),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                                    ),
                                                    if (myJuz[i]['progress'] == '100')
                                                      MaterialButton(
                                                        child: Text(ButtonQuitJuz, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              child: AlertDialog(
                                                                scrollable: true,
                                                                content: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Text(sprintf(ConfirmLeaveJuzDesc, [i])),
                                                                    SizedBox(height: 16.0),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                      children: [
                                                                        MaterialButton(
                                                                          child: Text(CancelText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                                                          onPressed: () => Navigator.pop(context),
                                                                          height: 50.0,
                                                                          color: Color(int.parse('0xffC4C4C4')),
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                                                        ),
                                                                        MaterialButton(
                                                                          child: Text(ConfirmLeaveJuzButton, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                            Navigator.pop(context);
                                                                            _apiLeaveRound(myJuz[i]['id']);
                                                                          },
                                                                          height: 50.0,
                                                                          color: Color(int.parse('0xffF30F0F')),
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ));
                                                          //                   },
                                                        },
                                                        height: 50.0,
                                                        color: Color(int.parse('0xffF30F0F')),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                                      ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            actions: [
                                              FlatButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(CancelText),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );

                                if (myJuz[i] == null)
                                  showDialog(
                                      context: context,
                                      child: AlertDialog(
                                        scrollable: true,
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Html(
                                              data: sprintf(ConfirmTakingJuzDesc, [i, formatter.format(DateTime.fromMillisecondsSinceEpoch(int.parse(_detailDeadline) * 1000))]),
                                              style: {
                                                "*": Style(textAlign: TextAlign.center, fontSize: FontSize(14.0)),
                                                "strong": Style(
                                                  fontSize: FontSize(20.0),
                                                ),
                                              },
                                            ),
                                            MaterialButton(
                                              child: Text(ButtonJoin, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _apiJoinRound(i.toString());
                                              },
                                              height: 50.0,
                                              color: Color(int.parse('0xff2DA310')),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          FlatButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(CancelText),
                                          )
                                        ],
                                      ));
                              },
                              child: Text(myJuz[i] == null ? ButtonJoin : ButtonAction))),
                    ],
                  ),
                ));
              }
            } else if (snapshot.hasData && _invitedMember) {
              for (var usfi in _usersSelectedForInvite) {
                usersIdInGroup.add(usfi[0].toString());
              }

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
                        for (var user in _apiReturnUsers) TextButton(onPressed: () => _addUid(user), child: Text('@' + user[1])),
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
                        _apiSearchUser(value, usersIdInGroup);
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
                  MaterialButton(
                    child: Text(InviteButton, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    onPressed: () => setState(() => _apiInviteUser()),
                    height: 50.0,
                    color: Color(int.parse('0xff2DA310')),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                ],
              ));
            } else if (snapshot.hasError) {
              snapShootMessage = snapshot.error.toString();
            }

            return Stack(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // group item banner
                  WidgetGroupItem(
                    groupName: _detailName,
                    progress: _detailProgress != '' ? _detailProgress : widget.progress,
                    round: _detailRound != '' ? _detailRound : widget.round,
                    deadline: _detailDeadline,
                    photo: _detailPhoto != '' ? _detailPhoto : widget.photo,
                    yourProgress: _detailMyProgress != '' ? _detailMyProgress : widget.yourProgress,
                    asHeader: true,
                    leaveGroup: widget.owner
                        ? null
                        : () => showDialog(
                            context: context,
                            child: AlertDialog(
                              scrollable: true,
                              title: Text(widget.isInvitation ? DeleteInvitationWarningTitle : LeaveGroupWarningTitle),
                              content: Text(widget.isInvitation ? DeleteInvitationWarning : LeaveGroupWarning),
                              actions: [
                                FlatButton(onPressed: () => Navigator.pop(context), child: Text(CancelText)),
                                RaisedButton(
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      _apiRejectInvitaion();
                                    },
                                    child: Text(widget.isInvitation ? DeleteInvitationConfirm : LeaveGroupConfirm)),
                              ],
                            )),
                    editGroup: isAdmin
                        ? () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return WidgetEditGroup(
                                groupId: widget.groupId,
                                loginKey: widget.loginKey,
                                backToList: _backToList,
                                reloadList: () => widget.reloadList(),
                                reloadDetail: (name, deadline, photo) {
                                  setState(() {
                                    _detailName = name;
                                    _detailDeadline = deadline;
                                    _detailPhoto = photo;
                                  });
                                },
                              );
                            }))
                        : null,
                  ),

                  // message
                  if (snapShootMessage != '') Container(padding: mainPadding, child: Text(snapShootMessage)),
                  if (members.length == 0)
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (!_invitedMember) Container(padding: mainPadding, child: Text(LoadingMember)),
                      if (_invitedMember) Container(padding: mainPadding, child: Text(AllMemberJoinJuz)),
                    ])),

                  // without juz
                  if (userWithoutJuz.length > 0 && _invitedMember) SizedBox(height: 8.0),
                  if (userWithoutJuz.length > 0 && _invitedMember) Container(padding: sidePadding, child: Text(MemberDidNotJoinJuz)),
                  if (userWithoutJuz.length > 0 && _invitedMember) SizedBox(height: 8.0),
                  if (userWithoutJuz.length > 0 && _invitedMember)
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
                  if (_invitedMember)
                    Expanded(
                        child: SingleChildScrollView(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                                child: Container(padding: sidePadding, child: Column(children: members))))),
                  if (_invitedMember)
                    Container(
                      alignment: Alignment.center,
                      padding: mainPadding,
                      child: MaterialButton(
                        child: Text(BackText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        onPressed: () => setState(() => _invitedMember = false),
                        height: 50.0,
                        color: Color(int.parse('0xffC4C4C4')),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      ),
                    ),

                  // with juz
                  if (members.length > 0 && !_invitedMember)
                    Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                      padding: sidePaddingNarrow,
                      child: Row(
                        children: [
                          Container(padding: verticalPadding, width: 32.0, child: Text(LabelJuz)),
                          Expanded(
                            child: Container(padding: verticalPadding, child: Text(LabelName)),
                          ),
                          Container(padding: verticalPadding, width: 110.0, child: Text(LabelProgress)),
                          Container(padding: verticalPadding, width: 50.0, child: Text(LabelAction)),
                        ],
                      ),
                    ),
                  if (members.length > 0 && !_invitedMember)
                    Expanded(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                            child: Container(color: Colors.white, padding: sidePaddingNarrow, child: Column(children: members))),
                      ),
                    ),

                  // next round and invite button
                  if (isAdmin && !_invitedMember && !widget.isInvitation)
                    Container(
                        padding: mainPadding,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // if (_detailProgress == '100')
                            MaterialButton(
                              child: Text(StartNewRound, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      scrollable: true,
                                      content: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              Text(StartNewRoundMessage, textAlign: TextAlign.center),
                                              SizedBox(height: 16.0),
                                              TextFormField(
                                                textAlign: TextAlign.center,
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
                                              SizedBox(height: 16.0),
                                              MaterialButton(
                                                child: Text(YesText, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                                onPressed: () {
                                                  if (_formKey.currentState.validate()) {
                                                    Navigator.pop(context);
                                                    _apiStartNewRound();
                                                  }
                                                },
                                                height: 50.0,
                                                color: Color(int.parse('0xff2DA310')),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                              ),
                                            ],
                                          )),
                                      actions: [FlatButton(onPressed: () => Navigator.pop(context), child: Text(CancelText))],
                                    ));
                              },
                              height: 40.0,
                              color: Color(int.parse('0xffF30F0F')),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            ),
                            MaterialButton(
                              child: Text(InviteMember, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              onPressed: () => setState(() => _invitedMember = true),
                              height: 40.0,
                              color: Color(int.parse('0xff2DA310')),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            ),
                          ],
                        )),
                ],
              ),
              if (snapShootLoading || _loadingOverlay) loadingOverlay(context)
            ]);
          },
        ),
      ),
    );
  }
}
