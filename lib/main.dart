import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main () {
  runApp(
    FriendlyChatApp(),
  );
}

final ThemeData kIOSTheme = ThemeData (
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

String _name = 'Bazuu';

class FriendlyChatApp extends StatelessWidget {

  @override
  Widget build (BuildContext context){
    return MaterialApp (
      title: 'Friendly Chat',
      theme: defaultTargetPlatform == TargetPlatform.iOS
        ? kIOSTheme
        : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar : AppBar(
          title: Text('Friendly Chat'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemBuilder: (_,int index) => _messages[index],
                reverse: true,
                itemCount: _messages.length,
              ),
            ),
            Divider(height: 1.0,),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            )
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS // NEW
            ? BoxDecoration(                                 // NEW
          border: Border(                              // NEW
            top: BorderSide(color: Colors.grey[200]), // NEW
          ),                                           // NEW
        )  : null,
      ),
    );
  }

  Widget _buildTextComposer () {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container (
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (String text){
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: _isComposing?_handleSubmitted:null,
                decoration: InputDecoration.collapsed( hintText: 'Send a message'),
                focusNode: _focusNode,
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS ?
                CupertinoButton(
                  child: Text('Send'),
                  onPressed: _isComposing
                      ? () =>  _handleSubmitted(_textController.text)
                      : null,) :
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isComposing ?
                      () =>  _handleSubmitted(_textController.text) : null,
                )
            ),
          ],
        ),
      )
    );
    
  }

  void _handleSubmitted (String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    var message = ChatMessage (
        text : text,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0,message);
    });
    _focusNode.requestFocus();
    message.animationController.forward();
  }

  @override
  void dispose (){
    for (var message in _messages){
      message.animationController.dispose();
    }
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final AnimationController animationController;
  final String text;

  ChatMessage({this.text, this.animationController });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin : EdgeInsets.symmetric(vertical: 10.0),
        child: Row (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(child: Text(_name[0]),),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _name,
                      style : Theme.of(context).textTheme.headline6
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  )
                ]
              ),
            ),
          ],
        )
      ),
    );
  }
}
