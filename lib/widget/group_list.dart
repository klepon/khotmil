import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/widget/group_detail.dart';

import 'group_item.dart';

class GroupList extends StatefulWidget {
  final String name;
  GroupList({Key key, this.name}) : super(key: key);
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  Widget _groupList(context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Container(
          padding: mainPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlatButton(
                padding: EdgeInsets.all(0.00),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return GroupDetail(groupName: 'Nurul Hikmah', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '1', yourProgress: '50%', groupColor: 'ff0000');
                  }));
                },
                child: GroupItem(groupName: 'Nurul Hikmah', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '1', yourProgress: '50%', groupColor: 'ff0000'),
              ),
              FlatButton(
                padding: EdgeInsets.all(0.00),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return GroupDetail(
                        groupName: 'Nurul Hikmah dengan nama panajang',
                        progress: '60%',
                        round: '1',
                        deadline: '21 Feb 2021',
                        yourJuz: '29',
                        yourProgress: '80%',
                        groupColor: 'ffffff');
                  }));
                },
                child: GroupItem(
                    groupName: 'Nurul Hikmah dengan nama panajang', progress: '60%', round: '1', deadline: '21 Feb 2021', yourJuz: '29', yourProgress: '80%', groupColor: 'ffffff'),
              ),
              FlatButton(
                padding: EdgeInsets.all(0.00),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return GroupDetail(groupName: 'Nurul Hikmah', progress: '75%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: '66dd33');
                  }));
                },
                child: GroupItem(groupName: 'Nurul Hikmah', progress: '75%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: '66dd33'),
              ),
              GroupItem(groupName: 'not link', progress: '50%', round: '2', deadline: '21 jan 2021', yourJuz: '28', yourProgress: '50%', groupColor: '666666'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: '66dd33'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
              GroupItem(groupName: 'not link', progress: '80%', round: '2', deadline: '21 jan 2021', yourJuz: '29', yourProgress: '50%', groupColor: 'ff0000'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: mainPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(WelcomeMessage), Text(widget.name)]),
                SizedBox(height: 8.0),
                Text(YourGroup, style: bold),
              ],
            ),
          ),
          Expanded(child: _groupList(context)),
          Container(
            padding: mainPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(onPressed: () => {}, child: Text(CreateGroup), color: Colors.redAccent),
                RaisedButton(
                  onPressed: () => {},
                  child: Text(JoinGroup),
                ),
              ],
            ),
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
