import 'package:cached_network_image/cached_network_image.dart';
import 'package:contest_reminder/helper/notificationHepler.dart';
import 'package:flutter/material.dart';
import 'package:contest_reminder/models/contest.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Contest_Page extends StatefulWidget {
  Contest_Page({Key key}) : super(key: key);

  @override
  _Contest_PageState createState() => _Contest_PageState();
}

class _Contest_PageState extends State<Contest_Page> {
  _launchURL(url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // SharedPreferences prefs;
  List<String> list = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  Future<bool> _saveList(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    list = prefs.getStringList("key");
    if (list == null) list = [];
    if (list.contains(value.toString())) {
      print('already');
      return false;
    }

    list.add(value.toString());
    // list = [];
    print(list);
    return await prefs.setStringList("key", list);
  }

  Future<bool> _removeList(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    list = prefs.getStringList("key");
    if (!list.contains(value.toString())) {
      print('nahi hai');
      return false;
    }

    list.remove(value.toString());
    // list = [];
    print(list);
    return await prefs.setStringList("key", list);
  }

  Future<List<String>> getList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("key")) return [];
    setState(() {
      list = prefs.getStringList("key");
    });
    print(list);
    return prefs.getStringList("key");
  }

  String _url =
      "https://clist.by/api/v1/contest/?format=json&username=Shivty&api_key=e1ed3bc32e0283cf13003c6289acfda869ad6384&limit=20000&end__gt=" +
          DateTime.now().add(Duration(hours: -2)).toString() +
          "&filtered=true&order_by=end";
  Contest data;
  // final primary = Colors.black;
  final secondary = Color(0xfff29a94);
  _getList(String url) async {
    var response = await Dio().get(url);

    if (response.statusCode == 200) {
      setState(() {
        allContest = (response.data as Map<String, dynamic>)['objects'];
        // allContest.sort((a,b){a['end'].compareTo(b['end']);});
        isLoading = false;
      });
      // print(res);
      // allContest.add(Contest.fromJson((response.data)));
      print(allContest);
    } else {
      throw Exception('Failed to load Data');
    }
  }

  List<dynamic> allContest;
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getList().then((value) => _getList(_url));
    // _getList(_url);
    for (int i = 0; i < list.length; ++i) {
      bool flag = true;
      for (int j = 0; j < allContest.length; ++j) {
        if (allContest[j]['id'] == list[i]) {
          flag = false;
          break;
        }
      }
      if (flag) list.removeAt(i);
    }
  }

  bool isSort = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Color(0xfff0f0f0),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // IconButton(
                        //   onPressed: () {},
                        //   icon: Icon(
                        //     Icons.menu,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        Text(
                          isSort ? "Subscribe Contests" : "Contests",
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSort = !isSort;
                            });
                          },
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            // color: isSort?Colors.lightBlue:Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : isSort
                        ? list.length == 0
                            ? Center(
                                child: Text("No Subscribe Contest"),
                              )
                            : Container(
                                padding: EdgeInsets.only(top: 105),
                                height: MediaQuery.of(context).size.height,
                                width: double.infinity,
                                child: ListView.builder(
                                    itemCount: allContest.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (DateTime.parse(
                                                  allContest[index]['end'])
                                              .isAfter(DateTime.now()) &&
                                          list.contains(allContest[index]['id']
                                              .toString()))
                                        return buildList(context, index);
                                      else
                                        return Container();
                                    }),
                              )
                        : Container(
                            padding: EdgeInsets.only(top: 105),
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: ListView.builder(
                                itemCount: allContest.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (DateTime.parse(allContest[index]['end'])
                                      .isAfter(DateTime.now()))
                                    return buildList(context, index);
                                  else
                                    return Container();
                                }),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildList(BuildContext context, int index) {
    return InkWell(
      onTap: () => _launchURL(allContest[index]['href']),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.black,
        ),
        width: double.infinity,
        // height: 1,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(50),
                // border: Border.all(width: 3, color: secondary),
                image: DecorationImage(
                    image: CachedNetworkImageProvider("https://clist.by/" +
                        allContest[index]['resource']['icon']),
                    // NetworkImage(),
                    fit: BoxFit.fill),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    allContest[index]['event'],
                    style: TextStyle(
                        // color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.code,
                        color: secondary,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                            allContest[index]['resource']['name']
                                .toString()
                                .split('.com')[0],
                            style: TextStyle(
                                // color: primary,
                                fontSize: 13,
                                letterSpacing: .3)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_alarms,
                        color: secondary,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                          (Duration(seconds: allContest[index]['duration'])
                                      .inHours <=
                                  24
                              ? Duration(seconds: allContest[index]['duration'])
                                      .toString()
                                      .split(':')[0] +
                                  ":" +
                                  Duration(
                                          seconds: allContest[index]
                                              ['duration'])
                                      .toString()
                                      .split(':')[1] +
                                  " hr"
                              : Duration(seconds: allContest[index]['duration'])
                                      .inDays
                                      .toString() +
                                  " Days"),
                          style: TextStyle(
                              // color: primary,
                              fontSize: 13,
                              letterSpacing: .3)),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: secondary,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                          // TimeOfDay(hour: 15, minute: 0).format(context).toString(),

                          TimeOfDay.fromDateTime(
                                      DateTime.parse(allContest[index]['end'])
                                          .add(Duration(hours: 11))
                                          .subtract(Duration(
                                              seconds: allContest[index]
                                                  ['duration']))
                                          .toUtc())
                                  .format(context)
                                  .toString() +
                              " " +
                              DateTime.parse(allContest[index]['end']).add(Duration(hours: 11))
                                  .subtract(Duration(
                                      seconds: allContest[index]['duration']))
                                  .day
                                  .toString() +
                              "-" +
                              DateTime.parse(allContest[index]['end']).add(Duration(hours: 11))
                                  .subtract(Duration(
                                      seconds: allContest[index]['duration']))
                                  .month
                                  .toString() +
                              "-" +
                              DateTime.parse(allContest[index]['end']).add(Duration(hours: 11))
                                  .subtract(Duration(
                                      seconds: allContest[index]['duration']))
                                  .year
                                  .toString()

                          // .toUtc()
                          // .toString().split(':00.000Z')[0],
                          ,
                          style: TextStyle(
                              // color: primary,
                              fontSize: 13,
                              letterSpacing: .3)),
                    ],
                  ),
                ],
              ),
            ),
           DateTime.parse(allContest[index]['end']).add(Duration(hours: 11))
                  .subtract(Duration(seconds: allContest[index]['duration']))
                  .isBefore(DateTime.now())? Text("LIVE",style: TextStyle(color: Colors.red,fontSize: 15),): list.contains(allContest[index]['id'].toString())
                ? IconButton(
                    icon: Icon(Icons.alarm_off, color: Colors.red, size: 30.0),
                    onPressed: () {
                      turnOffNotificationById(flutterLocalNotificationsPlugin,
                          allContest[index]['id']);
                      _removeList(allContest[index]['id']);
                      getList();
                    })
                : IconButton(
                    icon: Icon(Icons.alarm_on, color: Colors.grey, size: 30.0),
                    onPressed: () {
                      if (_saveList(allContest[index]['id']) == false) {
                        return;
                      }
                      scheduleNotification(
                        flutterLocalNotificationsPlugin,
                        allContest[index]['id'],
                        allContest[index]['event'],
                        'Starts in 60 min',
                        DateTime.parse(allContest[index]['end'])
                            .add(Duration(hours: 11))
                            .subtract(Duration(
                                seconds: allContest[index]['duration']))
                            .subtract(Duration(minutes: 60)),
                      );
                      getList();
                    })
          ],
        ),
      ),
    );
  }
}
