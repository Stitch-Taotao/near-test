import 'dart:async';

import 'package:flutter/material.dart';
import 'package:near_test/flutetr_js_test.dart';
import 'package:near_test/flutter_qjs_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(
    () {
      runApp(MyApp());
    },
    (error, stack) {
      print(['未捕获异常', error, stack]);
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Material App Bar'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Text('flutter_js'),
                buildItem('test1', () {
                  final jsM = JSManager();
                  jsM.initApi().then((value) => jsM.wrong1());
                }),
                buildItem('test2', () {
                  final jsM = JSManager();
                  jsM.initApi().then((value) => jsM.wrong2());
                }),
                buildItem('test3', () {
                  final jsM = JSManager();
                  jsM.initApi().then((value) => jsM.wrong3());
                }),
                buildItem('test4', () {
                  final jsM = JSManager();
                  jsM.initApi().then((value) => jsM.wrong4());
                }),
                buildItem('test5', () {
                  final jsM = JSManager();
                  jsM.initApi().then((value) => jsM.wrong5());
                }),
                Text('flutter_qjs'),
                buildItem('test1', () {
                  final qjsM = QJSManager();
                  qjsM.init();
                  qjsM.connect();
                }),
                buildItem('test2', () {
                  final qjsM = QJSManager();
                  qjsM.init();
                  qjsM.connect2();
                }),
              ],
            ),
          )),
    );
  }

  Widget buildItem(String title, VoidCallback callback) {
    return InkWell(
      child: Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            //背景
            color: Colors.white,
            //设置四周边框
            shape: ContinuousRectangleBorder(
              side: BorderSide(
                  width: 1, color: const Color.fromRGBO(58, 66, 142, 1)),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              // border:  Border.all(width: 1, color: Colors.black),
            ),

            //  BoxDecoration(border: Border.all(width: 1,color: Colors.black),borderRadius:BorderRadius.all(Radius.circular(4.0)) ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Icon(Icons.abc)],
          )),
      onTap: callback,
    );
  }
}
