import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class Home extends StatelessWidget {
  //const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Permission(),
    );
  }
}

class Permission extends StatefulWidget {
  //Permission({Key key}) : super(key: key);

  @override
  _PermissionState createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  final PermissionHandler _permissionHandler = PermissionHandler();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var initializeSettingAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializeSetting =
        new InitializationSettings(initializeSettingAndroid, null);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin
        .initialize(initializeSetting)
        .catchError((error) => {print("Error $error")});
    checkPermissionStatus();

    //requestingPermission();
  }

  Timer _timer;

  void startTimer() {
    int totalSec = sec + min * 60 + hour * 3600;
    int secCount = 0;
    int sec1 = sec;
    bool subHour = true;
    const oneSec = Duration(seconds: 1);

    _timer = new Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (totalSec == secCount) {
          timer.cancel();
          sec = 0;
          hour = 0;
          min = 0;
          deleteContacts();
        } else {
          secCount = secCount + 1;

          sec = (sec1 >= secCount % 60)
              ? sec1 - secCount % 60
              : sec1 - (secCount % 60) + 60;

          if (secCount % 60 - sec1 == 0) {
            min = min - 1;
            if (min < 0) min = 0;
          }

          if (min == 0) {
            print("ROhit");
            if (subHour) {
              subHour = false;
              Timer.periodic(Duration(minutes: 1), (timer) {
                this.min = 59;
                print("MUNJAL");
                this.hour = this.hour - 1;
                if (hour < 0) hour = 0;
                subHour = true;
              });
            }
          }
        }
        //showNotification();
      });
    });
  }

  void checkPermissionStatus() async {
    var permissionstatus = await _permissionHandler
        .checkPermissionStatus(PermissionGroup.contacts);

    if (permissionstatus == PermissionStatus.granted) {
      return;
    } else if (permissionstatus == PermissionStatus.denied) {
      requestingPermission();
    }
  }

  requestingPermission() async {
    var result =
        await _permissionHandler.requestPermissions([PermissionGroup.contacts]);
    print(result.toString());
  }

  void getContacts() async {
    Iterable<Contact> bhalu = await ContactsService.getContacts(query: name);
    if (bhalu == null) {
      print("FAILED");
    } else {
      print(bhalu);
      bhalu.forEach((b) {
        print(b.displayName);
      });
    }
  }

  Contact contact ;
  void addContacts() async {
    Iterable<Item> phones = [
      Item(label: "phones", value: number),
      
    ];
    contact = Contact(givenName: name, phones: phones);

    var result = await ContactsService.addContact(contact);
    if (result != null)
      print("Contact Added");
    else
      print(result.toString());
  }

  void deleteContacts() async {

    Iterable<Contact> test = await ContactsService.getContacts(
      query : name 
    );

    if(test.length > 0){
      Contact delete = test.toList()[0];
      await ContactsService.deleteContact(delete);
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "your", "name", "Description",
        importance: Importance.Max, priority: Priority.High);

      var platformSpecific =
        NotificationDetails(androidPlatformChannelSpecifics, null);

      flutterLocalNotificationsPlugin.show(0, "Deleted Temporary Contact ", "$name : $number", platformSpecific);
    }

    /*Iterable<Item> phones = [
      Item(label: "phones", value: number),
      
    ];

    getContacts();
    Contact contact = new Contact(displayName : name , phones : phones);
    var result = await ContactsService.deleteContact(contact).catchError((error) => print("Error : $error"));
    print("IN DELETE");

    print(result.toString());*/

  }

  Future showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "your", "name", "Description",
        importance: Importance.Max, priority: Priority.High);

    var platformSpecific =
        NotificationDetails(androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.show(
        0,
        "Phone number will be deleted in:",
        "$hour : $min : $sec ",
        platformSpecific);
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final _formkey = GlobalKey<FormState>();
  String name;
  String number;
  String time;
  int hour = 0;
  int min = 0;
  int sec = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text("DelCon"),
        ),
        body: Container(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
          child: Form(
              key: _formkey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      decoration: InputDecoration(hintText: "Enter Name"),
                      onChanged: (value) => this.name = value,
                      validator: (value) =>
                          value.isEmpty ? "Please Enter Name" : null),
                  SizedBox(height: 20.0),
                  TextFormField(
                      decoration:
                          InputDecoration(hintText: "Enter Phone Number"),
                      onChanged: (value) => this.number = value,
                      validator: (value) =>
                          value.isEmpty ? "Please Enter PhoneNumber" : null),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //SizedBox(width:100),
                      Container(
                        width: 50.0,
                        height: 70.0,
                        child: Center(
                          child:
                              Text("$hour", style: TextStyle(fontSize: 30.0)),
                        ),
                        //color: Colors.blue[500],
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: Colors.black, width: 1.0)),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        ":",
                        style: TextStyle(fontSize: 30.0),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Container(
                        width: 50.0,
                        height: 70.0,
                        child: Center(
                          child: Text("$min", style: TextStyle(fontSize: 30.0)),
                        ),
                        //color: Colors.blue[500],
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: Colors.black, width: 1.0)),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        ":",
                        style: TextStyle(fontSize: 30.0),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Container(
                        width: 50.0,
                        height: 70.0,
                        child: Center(
                          child: Text("$sec", style: TextStyle(fontSize: 30.0)),
                        ),
                        //color: Colors.blue[500],
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: Colors.black, width: 1.0)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    onPressed: () {
                      DatePicker.showTimePicker(context,
                          //onChanged: (time) => print(time),
                          onConfirm: (time) {
                        this.time = DateFormat("H:m:s").format(time);

                        setState(() {
                          this.hour = time.hour;
                          this.min = time.minute;
                          this.sec = time.second;
                        });
                      }
                          //this.time = DateFormat("H:m:s").format(time));
                          );
                    },
                    child: Text("TIme Picker"),
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    onPressed: () {
                      if (_formkey.currentState.validate()) {
                        startTimer();
                        addContacts();

                        /*Timer.periodic(Duration(hours: hour , minutes : min , seconds : sec), (timer){
                            deleteContacts();
                        });*/
                      }

                      showNotification();
                    },
                    child: Text("Start"),
                  )
                ],
              )),
        )),
      ),
    );
  }
}
