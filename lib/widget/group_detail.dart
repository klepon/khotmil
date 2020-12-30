import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/fetch/delete_group.dart';
import 'package:khotmil/fetch/update_deadline.dart';

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
  final Function reloadList;

  GroupDetail({Key key, this.groupId, this.groupName, this.progress, this.round, this.deadline, this.yourJuz, this.yourProgress, this.groupColor, this.loginKey, this.reloadList})
      : super(key: key);
  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  String deadline = '';
  String _messageText = '';
  bool _loadingOverlay = false;

  TextEditingController endDateFormController = TextEditingController();
  Future<void> _renderSelectDate(BuildContext context) async {
    DateTime date = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context, initialDate: DateTime.fromMillisecondsSinceEpoch(int.parse(deadline) * 1000), firstDate: date, lastDate: DateTime(date.year, date.month + 3));
    if (picked != null) endDateFormController.text = (picked.toString()).split(' ')[0];
  }

  void _apiDeleteGroup() async {
    Navigator.pop(context);
    widget.reloadList(false);
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchDeleteGroup(widget.loginKey, widget.groupId).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        Navigator.pop(context);
        widget.reloadList(true);
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

  void _apiUpdateDeadLine() async {
    if (endDateFormController.text == (DateTime.fromMillisecondsSinceEpoch(int.parse(deadline) * 1000).toString()).split(' ')[0]) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context);
    setState(() {
      _loadingOverlay = true;
      _messageText = '';
    });

    await fetchUpdateDeadline(widget.loginKey, widget.groupId, endDateFormController.text).then((data) {
      if (data[DataStatus] == StatusSuccess) {
        widget.reloadList(true);
        setState(() {
          _loadingOverlay = false;
          deadline = data['deadline'].toString();
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
                  child: Text(progress == '100' ? 'Keluar' : 'Join'))),
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

  @override
  void initState() {
    super.initState();

    setState(() {
      deadline = widget.deadline;
      endDateFormController.text = (DateTime.fromMillisecondsSinceEpoch(int.parse(deadline) * 1000).toString()).split(' ')[0];
    });
  }

  @override
  void dispose() {
    endDateFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(AppTitle),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: DeleteGroup,
                onPressed: () {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text(UpdateDeadline),
                        content: TextFormField(
                          controller: endDateFormController,
                          keyboardType: TextInputType.text,
                          readOnly: true,
                          onTap: () => _renderSelectDate(context),
                        ),
                        actions: [
                          FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(CancelText),
                          ),
                          RaisedButton(
                            color: Colors.greenAccent,
                            onPressed: () {
                              _apiUpdateDeadLine();
                            },
                            child: Text(SubmitText),
                          ),
                        ],
                      ));
                },
              ),
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
              Container(
                padding: sidePadding,
                child: GroupItem(
                  groupName: widget.groupName,
                  progress: widget.progress,
                  round: widget.round,
                  deadline: deadline == '' ? widget.deadline : deadline,
                  yourJuz: widget.yourJuz,
                  yourProgress: widget.yourProgress,
                  groupColor: widget.groupColor,
                ),
              ),
              Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                padding: sidePadding,
                child: Row(
                  children: [
                    Container(padding: verticalPadding, width: 32.0, child: Text('Juz')),
                    Expanded(
                      child: Container(padding: verticalPadding, width: 32.0, child: Text('Nama')),
                    ),
                    Container(padding: verticalPadding, width: 110.0, child: Text('Progres')),
                    Container(padding: verticalPadding, width: 50.0, child: Text('')),
                  ],
                ),
              ),
              Expanded(child: _memberState(context)),
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
        if (_loadingOverlay)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Color(0xaaffffff),
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }
}
