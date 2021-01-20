import 'package:flutter/material.dart';
import 'package:khotmil/constant/helper.dart';
import 'package:khotmil/constant/text.dart';

class GroupItem extends StatelessWidget {
  final String groupName;
  final String progress;
  final String round;
  final String deadline;
  final String yourJuz;
  final String yourProgress;

  GroupItem({Key key, this.groupName, this.progress, this.round, this.deadline, this.yourJuz, this.yourProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(groupName, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.orange, spreadRadius: 6.0, blurRadius: 5.0),
                ]),
                child: Text(progress + '%', style: TextStyle(color: Colors.redAccent, fontSize: 32.0)),
              ),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
                        margin: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(children: [textExtraSmall(GroupRound), textSmall(round)]))),
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
                        margin: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                            children: [textExtraSmall(GroupDeadline), textSmall((DateTime.fromMillisecondsSinceEpoch(int.parse(deadline) * 1000).toString()).split(' ')[0])]))),
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
                        margin: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(children: [
                          textExtraSmall(YourProgress),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [textSmall(LabelJuz + ' ' + (yourJuz == '0' ? '-' : yourJuz)), textSmall(yourProgress + '%')]),
                        ]))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
