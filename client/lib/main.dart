import 'package:curtains_client/connection.dart';
import 'package:curtains_client/discovery.dart';
import 'package:flutter/material.dart';

Connection connection = new Connection();
LocalHubDiscovery hubDiscovery = new LocalHubDiscovery();

void main() async {
  runApp(MyApp());
  var hubAddress = await hubDiscovery.discoverAddress();
  print("Found address at: " + hubAddress);
  connection.start(hubAddress);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curtains',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(key: GlobalKey(), title: 'Curtains'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _currentSliderValue = 0;

  void _sendMessage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(
                Icons.sensor_window_rounded,
                size: 48,
              ),
              title: Slider(
                value: _currentSliderValue,
                min: -1.0,
                max: 1.0,
                divisions: 40,
                label: _currentSliderValue.round().toString() + " Percent",
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                    connection.sendSpeed(_currentSliderValue);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
