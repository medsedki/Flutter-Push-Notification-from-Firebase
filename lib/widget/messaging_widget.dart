import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterpushnotification/model/massage.dart';

import 'exit_confirmation_dialog.dart';

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];

  void showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.done),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
          //showAlertDialog(notification['title'],notification['body']);
          showDialog(
              context: context, builder: (context) =>
              ExitConfirmationDialog(
                title: notification['title'], body: notification['body'],));
        });

        //Snackbar:
//        final snackbar = SnackBar(
//          content: Text(notification['title'] + ", " + notification['body']),
//          action: SnackBarAction(
//            label: "Go",
//            onPressed: () => null,
//          ),
//        );
//        Scaffold.of(context).showSnackBar(snackbar);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    //for the iOS Device
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) =>
      ListView(
        children: messages.map(buildMessage).toList(),
      );

  Widget buildMessage(Message message) =>
      ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );
}
