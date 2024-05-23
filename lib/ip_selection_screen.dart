import 'package:flutter/material.dart';

import 'main.dart';


class IPSelectionScreen extends StatefulWidget {
  @override
  _IPSelectionScreenState createState() => _IPSelectionScreenState();
}

class _IPSelectionScreenState extends State<IPSelectionScreen> {
  TextEditingController ipController = TextEditingController();

  void connectToWebSocket(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MainScreen(ipAddress: ipController.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter WebSocket IP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'WebSocket IP'),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => connectToWebSocket(context),
              child: Text("Connect"),
            ),
          ],
        ),
      ),
    );
  }
}
