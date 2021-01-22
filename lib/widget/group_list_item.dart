import 'package:flutter/material.dart';
import 'package:khotmil/constant/text.dart';

class GroupItem extends StatelessWidget {
  final String groupName;
  final String progress;
  final String round;
  final String deadline;
  final String photo;
  final String yourProgress;

  GroupItem({Key key, this.groupName, this.progress, this.round, this.deadline, this.photo, this.yourProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 130.0, width: 65.0),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.fromLTRB(70.0, 8.0, 16.0, 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(50.0), bottomRight: Radius.circular(50.0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(groupName.toUpperCase(), style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black)),
                          Row(children: [
                            Container(width: 95.0, child: Text(GroupRound, style: TextStyle(color: Colors.black))),
                            Text(': ' + round, style: TextStyle(color: Colors.black))
                          ]),
                          Row(children: [
                            Container(width: 95.0, child: Text(GroupDeadline, style: TextStyle(color: Colors.black))),
                            Text(': ' + (DateTime.fromMillisecondsSinceEpoch(int.parse(deadline) * 1000).toString()).split(' ')[0], style: TextStyle(color: Colors.black))
                          ]),
                          Row(children: [
                            Container(width: 95.0, child: Text(ProgressTotal, style: TextStyle(color: Colors.black))),
                            Text(': ' + progress + '%', style: TextStyle(color: Colors.black))
                          ]),
                          Row(children: [
                            Container(width: 95.0, child: Text(YourProgress, style: TextStyle(color: Colors.black))),
                            Text(': ' + yourProgress + '%', style: TextStyle(color: Colors.black))
                          ])
                        ],
                      )))
            ],
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black, spreadRadius: 0)],
            ),
            child: CircleAvatar(backgroundImage: photo != '' ? NetworkImage(photo) : null, backgroundColor: Colors.white, radius: 60),
          ),
        ],
      ),
    );
  }
}
