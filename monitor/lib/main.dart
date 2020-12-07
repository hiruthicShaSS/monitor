import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:crypto/crypto.dart';

import 'package:monitor/chart.dart';
import 'package:monitor/chart.dart';
import 'package:hexcolor/hexcolor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.dark()),
      home: MyHomePage(title: 'Monitor'),
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
  // static const String URL = "https://toxic-cat.herokuapp.com/";
  Map data = new Map();
  double timeSpentOnWork = 0.0, timeSpentOnFun = 0.0;

  List<String> apps = new List();
  List<HexColor> appColors = new List();
  List<String> category = new List();
  List<double> timeSpent = new List();
  List<String> creationTime = new List();
  Map<String, String> icons = new Map();

  Widget _status = Text("Fetching...");

  Future<Map> getData() async {
    // var response = await http.get('${URL}download?file=tracking.json&pass=sha');
    // final Map data = jsonDecode(response.body);
    // // print(data);
    // return data;

    var response = await http.get(
        "https://drive.google.com/uc?export=download&id=1PHdJYxWWb7SrudjOeIDiDvK-gGE1JPvY");
    final Map data = jsonDecode(response.body);

    return data;
  }

  void setUp() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String device =
        "${androidInfo.androidId} ${androidInfo.board} ${androidInfo.brand} ${androidInfo.device} ${androidInfo.display} ${androidInfo.hardware} ${androidInfo.manufacturer} ${androidInfo.model} ${androidInfo.product}";
    var deviceBytes = utf8.encode(device);
    var deviceDigest = sha512.convert(deviceBytes);

    if (deviceDigest.toString() !=
        "3b101badaa76a5a019478f03ba711ebb9ece838b73698a3983f857c0019e68de3b90aa82207cd1a1dd91752396df6824b5d5deca9bb9bb736fe8d524d1a567dd") {
      exit(-1);
    }

    setState(() {
      _status = Text("Fetching...");
    });

    List<Widget> _buildChildren() {
      // Clear the existing array
      apps.clear();
      appColors.clear();
      category.clear();
      timeSpent.clear();
      creationTime.clear();
      icons.clear();

      // Populate the array with new data from server
      data.forEach((key, value) {
        if (key != "lastUpdated") {
          apps.add(value["appName"]);
          appColors.add(HexColor(value["appColor"]));
          category.add(value["category"]);
          timeSpent.add(value["timeSpentOnWork"]);
          creationTime.add(value["creationTime"]);
          icons[value["appName"]] = value["appIcon"];
        }
      });

      int work = 0, fun = 0;
      for (int i = 0; i < apps.length; i++) {
        if (category[i] == "Work") {
          work++;
          timeSpentOnWork += timeSpent[i];
        } else {
          fun++;
          timeSpentOnFun += timeSpent[i];
        }
      }
      timeSpentOnWork /= work;
      timeSpentOnFun /= fun;

      return new List<Widget>.generate(apps.length, (index) {
        return InkWell(
          child: Card(
            color: (category[index] == "Work")
                ? Colors.green[900]
                : Colors.blueAccent[700],
            child: ListTile(
              leading: Image.network(icons[apps[index]]),
              title: Container(
                child: Row(
                  children: [
                    Text(apps[index]),
                    Spacer(),
                    Column(
                      children: [
                        Text(
                          "${timeSpent[index].toInt()} min's",
                          style: TextStyle(color: Colors.amberAccent),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            "Created @ ${creationTime[index]}",
                            style: TextStyle(
                              fontSize: 10.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            print(creationTime[index]);
          },
        );
      });
    }

    data = await getData();

    setState(() {
      _status = Text("Fetching...");
      _status = Column(
        children: _buildChildren(),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.replay_outlined),
            color: Colors.red[400],
            onPressed: () => setUp(),
          ),
        ],
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red,
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width / 0.2,
            child: Center(
                child: Column(
              children: [
                Text(
                  "Time spent on Fun: ${timeSpentOnFun.toStringAsPrecision(3)} min's",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 25.0,
                  ),
                ),
                Text(
                  "Time spent on Work: ${timeSpentOnWork.toStringAsPrecision(3)} min's",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 25.0,
                  ),
                ),
                Text("Last updated: ${data["lastUpdated"]}"),
              ],
            )),
          ),
          SizedBox(height: 10.0),
          Divider(
            thickness: 3.0,
            color: Colors.black,
          ),
          SizedBox(height: 10.0),
          Center(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _status,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Plotter(apps: apps, timeSpent: timeSpentappColors: appColors,)),
          );
        },
        tooltip: 'Plot graph',
        child: Icon(Icons.poll_outlined),
        splashColor: Colors.black,
      ),
    );
  }
}
