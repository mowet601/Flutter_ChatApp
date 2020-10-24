import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String route = '/chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final textInputController = TextEditingController();
  User loggedInUser;
  String messageText;

  void getLoggedInUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void messageStream() async {
    await for (final snapshot
        in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getLoggedInUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MessagesStreamBuilder(
              loggedInUser: loggedInUser,
            ),
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    decoration: kMessageContainerDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: textInputController,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                            onChanged: (value) {
                              messageText = value;
                            },
                            decoration: kMessageTextFieldDecoration.copyWith(
                              hintStyle: TextStyle(
                                color: Colors.black54,
                              ),
                              hintText: 'Type your message here...',
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            textInputController.clear();
                            _firestore.collection('messages').add({
                              'message': messageText,
                              'sender': loggedInUser.email,
                              'timestamp': Timestamp.now(),
                            });
                          },
                          child: Text(
                            'Send',
                            style: kSendButtonTextStyle.copyWith(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStreamBuilder extends StatelessWidget {
  final User loggedInUser;
  MessagesStreamBuilder({@required this.loggedInUser});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final messages = snapshot.data.docs;
        List<MessageContainer> messageBuilder = [];
        for (var message in messages.reversed) {
          final messageText = message.get('message');
          final messageSender = message.get('sender');
          messageBuilder.add(
            MessageContainer(
              user: messageSender == loggedInUser.email ? true : false,
              messageText: messageText,
              messageSender: messageSender,
            ),
          );
        }
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: ListView(
              reverse: true,
              children: messageBuilder,
            ),
          ),
        );
      },
    );
  }
}

class MessageContainer extends StatelessWidget {
  final String messageText;
  final String messageSender;
  final bool user;
  MessageContainer({
    @required this.messageText,
    @required this.messageSender,
    @required this.user,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$messageSender',
            textAlign: user ? TextAlign.end : TextAlign.start,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
          ),
          Material(
            elevation: 8.0,
            borderRadius: user
                ? BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
            color: user ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              child: Text(
                '$messageText',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 15.0,
                  color: user ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
