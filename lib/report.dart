import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "database/model/expenditure.dart";
import "dart:collection";
import 'package:ispent/database/database_helper.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:ispent/utilities.dart';
import "package:collection/collection.dart";
import 'package:syncfusion_flutter_charts/charts.dart';

var db = new DatabaseHelper();

///List<charts.Series> seriesList = [];
final bool animate = false;
List<Expenditure> _categoryExpense = [];
var test;
Map<String, double> dataMap = Map();

class Report extends StatefulWidget {
  final int month;
  final int year;
  final int mode;
  final int day;
  Report(
    this.month,
    this.year,
    this.mode,this.day, {
    required Key key,
  }) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  bool toggle = false;
  Map<String, double> dataMap = new Map();
  int chartType = 0;

  double getCategoryAmount(List<Expenditure> source, String categoryName) {
    double totalAmount = 0;
    for (int i = 0; i < source.length; i++) {
      if (source[i].itemName == categoryName) {
        totalAmount = totalAmount + source[i].amount;
      }
    }
    return totalAmount;
  }

  Future<List<Expenditure>> getExpenseList() {
    return db.getExpenses(widget.month, widget.year, widget.mode, 0,widget.day);
  }

  Future<List<Expenditure>> getYearExpense() {
    return db.getExpenses(widget.month, widget.year, 1, 0,widget.day);
  }

  void initState() {
    // Disable animations for image tests.
    super.initState();
    chartType = 0;
  }

  List<ChartData> prepareBarChartData(List<Expenditure> expenses) {
    List<ChartData> lChartData = [];
    int i = 0;
    var groupByMonth =
        expenses.groupListsBy((obj) => obj.entryDate.substring(5, 7));

    groupByMonth.forEach((month, list) {
      double monthTotalExpense = 0.0;
      list.forEach((listItem) {
        // List item
        monthTotalExpense = monthTotalExpense + listItem.amount;
      });
      if (i < 6) {
        lChartData.add(new ChartData(
            getMonthName(month), monthTotalExpense, getColor(month)));
      }
      i++;
    });

    return lChartData;
  }

  Color getColor(String monNumber) {
    Color returnValue = Colors.black;
    switch (monNumber) {
      case "01":
        returnValue = Colors.black;
        break;
      case "02":
        returnValue = Colors.green;
        break;
      case "03":
        returnValue = Colors.red;
        break;
      case "04":
        returnValue = Colors.blue;
        break;
      case "05":
        returnValue = Colors.pink;
        break;
      case "06":
        returnValue = Colors.amber;
        break;
      case "07":
        returnValue = Colors.blueAccent;
        break;
      case "08":
        returnValue = Colors.orange;
        break;
      case "09":
        returnValue = Colors.tealAccent;
        break;
      case "10":
        returnValue = Colors.orange;
        break;
      case "11":
        returnValue = Colors.blueGrey;
        break;
      case "12":
        returnValue = Colors.purpleAccent;
        break;
    }
    return returnValue;
  }

  String getMonthName(String monNumber) {
    String returnValue = "Jan";
    switch (monNumber) {
      case "01":
        returnValue = "Jan";
        break;
      case "02":
        returnValue = "Feb";
        break;
      case "03":
        returnValue = "Mar";
        break;
      case "04":
        returnValue = "Apr";
        break;
      case "05":
        returnValue = "May";
        break;
      case "06":
        returnValue = "Jun";
        break;
      case "07":
        returnValue = "Jul";
        break;
      case "08":
        returnValue = "Aug";
        break;
      case "09":
        returnValue = "Sep";
        break;
      case "10":
        returnValue = "Oct";
        break;
      case "11":
        returnValue = "Nov";
        break;
      case "12":
        returnValue = "Dec";
        break;
    }
    return returnValue;
  }

  Map<String, double> getPieChartData(List<Expenditure> expenses) {
    dataMap = Map();
    _categoryExpense = []; //new List<Expenditure>();
    List<String> categoryList = []; //new List<String>();
    if (expenses.length > 0) {
      for (int i = 0; i < expenses.length; i++) {
        categoryList.add(expenses[i].itemName);
      }
      List<String> distinctCategory =
          LinkedHashSet<String>.from(categoryList).toList();
      for (var j = 0; j < distinctCategory.length; j++) {
        double totalAmount =
            getCategoryAmount(expenses, distinctCategory[j].toString());
        _categoryExpense.add(new Expenditure(
            totalAmount, distinctCategory[j].toString(), "", "", "", 0));
        dataMap.putIfAbsent(distinctCategory[j].toString(), () => totalAmount);
      }
    }
    return dataMap;
  }

  @override
  Widget build(BuildContext context) {
    return _pieChart(context);
  }

  Widget _pieChart(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Scroll to right to see expense by month",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            color: Colors.blueAccent,
                          ),
                        )),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                            // Another fixed-height child.
                            padding: EdgeInsets.only(left: 20, bottom: 40),
                            alignment: Alignment.topLeft,
                            child: new FutureBuilder<List<Expenditure>>(
                                future: getExpenseList(),
                                builder: (context, snapshot) {
                                  // if (snapshot.hasError)
                                  //  return Text("No Records Found");
                                  if (snapshot.hasData) {
                                    var data = snapshot.data;
                                    var dataSeries;
                                    if (data != null) {
                                      dataSeries = getPieChartData(data);
                                    }
                                    if (dataMap.isNotEmpty) {
                                      return new PieChart(
                                        dataMap: dataSeries,
                                        animationDuration:
                                            Duration(milliseconds: 1200),
                                        chartLegendSpacing: 32.0,
                                        chartRadius:
                                            MediaQuery.of(context).size.width /
                                                1.5,
                                        chartValuesOptions: ChartValuesOptions(
                                          showChartValueBackground: true,
                                          showChartValues: true,
                                          showChartValuesInPercentage: true,
                                          showChartValuesOutside: true,
                                          decimalPlaces: 0,
                                        ),
                                        colorList: colorList,
                                        legendOptions: LegendOptions(
                                          showLegendsInRow: false,
                                          // legendPosition: LegendPosition.right,
                                          showLegends: true,
                                          //legendShape: _BoxShape.circle,
                                          legendTextStyle: TextStyle(
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        chartType: ChartType.disc,
                                      );
                                    } else {
                                      return Center(
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Text("")));
                                    }
                                  } else {
                                    return Center(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text("")));
                                  }
                                })),
                        Container(child: _barChart(context)),
                        // Container(child: new SelectionCallbackExample(seriesList)),
                      ],
                    )
                  ])),
        );
      },
    );
  }

  Widget _barChart(BuildContext context) {
    return new FutureBuilder<List<Expenditure>>(
        future: getYearExpense(),
        builder: (context, snapshot) {
          if (snapshot.hasError) Text("");
          var data = snapshot.data;
          List<ChartData> barChartData = [];
          if (data != null) {
            barChartData = prepareBarChartData(data);
          } else {
            barChartData = [];
          }

          if (snapshot.hasData) {
            return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: <Widget>[
                  Center(
                      child: Container(
                          child: SfCartesianChart(
                              title: ChartTitle(
                                text: 'Half yearly expenses',
                                alignment: ChartAlignment.near,
                              ),
                              primaryXAxis: CategoryAxis(
                                  // maximumLabels: 6
                                  ),
                              series: <CartesianSeries>[
                        LineSeries<ChartData, String>(
                            dataSource: barChartData,
                            // Bind the color for all the data points from the data source
                            pointColorMapper: (ChartData data, _) => data.color,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y)
                      ])))
                ]));
          } else {
            return Center(
                child: Align(alignment: Alignment.center, child: Text("")));
          }
        });
  }

  double getWidth() {
    int chartWidth = 0;
    chartWidth = (_categoryExpense.length * 35 + 80);
    return chartWidth.toDouble();
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}
