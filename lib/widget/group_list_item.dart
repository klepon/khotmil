import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khotmil/constant/assets.dart';
import 'package:khotmil/constant/text.dart';

class WidgetGroupItem extends StatelessWidget {
  final String groupName;
  final String progress;
  final String round;
  final String deadline;
  final String photo;
  final String yourProgress;
  final bool asHeader;
  final Function editGroup;
  final Function deleteInvitation;

  WidgetGroupItem({Key key, this.groupName, this.progress, this.round, this.deadline, this.photo, this.yourProgress, this.asHeader, this.editGroup, this.deleteInvitation})
      : super(key: key);

  final DateFormat formatter = DateFormat('dd-LLL-yy');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: asHeader ? EdgeInsets.zero : EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!asHeader) SizedBox(height: 130.0, width: 65.0),
              if (asHeader) SizedBox(height: 130.0, width: 0.0),
              Expanded(
                  child: Container(
                      padding: asHeader ? EdgeInsets.fromLTRB(142.0, 16.0, 24.0, 8.0) : EdgeInsets.fromLTRB(70.0, 8.0, 16.0, 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: asHeader ? BorderRadius.zero : BorderRadius.only(topRight: Radius.circular(50.0), bottomRight: Radius.circular(50.0)),
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
                            Text(': ' + formatter.format(DateTime.fromMillisecondsSinceEpoch(int.parse(deadline) * 1000)), style: TextStyle(color: Colors.black))
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
            margin: asHeader ? EdgeInsets.only(left: 6.0) : EdgeInsets.zero,
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black, spreadRadius: 0)],
            ),
            child: CircleAvatar(backgroundImage: photo != '' ? NetworkImage(photo) : null, backgroundColor: Colors.white, radius: 60),
          ),
          if (editGroup != null)
            Container(
              padding: EdgeInsets.only(top: 4.0),
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  IconButton(
                    icon: ImageIcon(AssetImage(IconEdit), color: Color(0xFF000000), size: 32.0),
                    tooltip: EditGroup,
                    onPressed: () => editGroup(),
                  ),
                ],
              ),
            ),
          if (deleteInvitation != null)
            Container(
              padding: EdgeInsets.only(top: 8.0),
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  IconButton(
                    tooltip: EditGroup,
                    icon: Icon(Icons.delete_forever),
                    color: Colors.black,
                    iconSize: 32.0,
                    onPressed: () => deleteInvitation(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
