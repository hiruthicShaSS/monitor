import "package:flutter/material.dart";
import 'package:pie_chart/pie_chart.dart';

class Plotter extends StatefulWidget {
  List apps;
  List timeSpent;
  Plotter({Key key, @required this.apps, @required this.timeSpent})
      : super(key: key);

  @override
  _PlotterState createState() => _PlotterState();
}

class _PlotterState extends State<Plotter> {
  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = new Map();
    for (int i = 0; i < widget.apps.length; i++) {
      dataMap[widget.apps[i]] = widget.timeSpent[i];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Graph"),
        centerTitle: true,
      ),
      body: (dataMap.isEmpty) ? Container(child: Text("No data available."),) : Container(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            alignment: Alignment.center,
            child: PieChart(
              dataMap: dataMap,
              animationDuration: Duration(seconds: 1),
              chartLegendSpacing: 32,
              chartRadius: MediaQuery.of(context).size.width / 1.2,
              // colorList: [],
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: "App Usage",
              legendOptions: LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.bottom,
                showLegends: true,
                legendTextStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
