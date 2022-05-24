// ignore_for_file: await_only_futures, unused_local_variable

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

class JSManager {
  JSManager();
  Map<String, dynamic> rawResult = {};
  dynamic wallet;
  late JavascriptRuntime javascriptRuntime;
  // TODO -  必须注入window对象，否则connect会报错
  Future initApi() async {
    javascriptRuntime = getJavascriptRuntime();
    javascriptRuntime.evaluate("""var window = global = globalThis;""");
    final String nearRawJS =
        await rootBundle.loadString("assets/js/near-api-js.js");
    final jsInit = javascriptRuntime.evaluate(nearRawJS + '');
    print(jsInit);
  }

  /// 错误调用方法
  /// 因为接收到了一个JsEvalResult(Instance of 'Future<dynamic>')无法处理
  wrong1() async {
    final asyncResult = javascriptRuntime.evaluate(r'''
          const { keyStores } = nearApi;
          const keyStore = new keyStores.BrowserLocalStorageKeyStore();
          const config = {
            networkId: "testnet",
            keyStore,
            nodeUrl: "https://rpc.testnet.near.org",
            walletUrl: "https://wallet.testnet.near.org",
            helperUrl: "https://helper.testnet.near.org",
            explorerUrl: "https://explorer.testnet.near.org"
          };
          const near =  nearApi.connect(config);
          near
      ''');
    // 这样处理是不行的
    final result = await asyncResult; // 依然拿不到结果
    final result2 = await asyncResult.rawResult; // 出错，未被捕获，Zone里也没有捕获？
    print([result, result2]);
  }

  // nearApi.connect 前增加await 不支持
  // flutter_js 不支持await 报错 JsEvalResult (SyntaxError: expecting ';'
  //     at <eval>:11
  // )
  wrong2() async {
    final asyncResult = javascriptRuntime.evaluate(r'''
          const { keyStores } = nearApi;
          const keyStore = new keyStores.BrowserLocalStorageKeyStore();
          const config = {
            networkId: "testnet",
            keyStore,
            nodeUrl: "https://rpc.testnet.near.org",
            walletUrl: "https://wallet.testnet.near.org",
            helperUrl: "https://helper.testnet.near.org",
            explorerUrl: "https://explorer.testnet.near.org"
          };
          const near = await  nearApi.connect(config);
          near
      ''');

    print(asyncResult);
  }

  // nearApi.connect 前增加await 不支持  必须移除await 用 evaluateAsync 执行 才可以获取到结果
  // 但又出现新的问题 如何构造WalletConnection 对象
  wrong3() async {
    final asyncResult = await javascriptRuntime.evaluateAsync(r'''
          const { keyStores } = nearApi;
          const keyStore = new keyStores.BrowserLocalStorageKeyStore();
          const config = {
            networkId: "testnet",
            keyStore,
            nodeUrl: "https://rpc.testnet.near.org",
            walletUrl: "https://wallet.testnet.near.org",
            helperUrl: "https://helper.testnet.near.org",
            explorerUrl: "https://explorer.testnet.near.org"
          };
          const near =  nearApi.connect(config);
          near
          // 不支持await 所以这样是不行的
          // const near = await nearApi.connect(config);
          // const wallet = new WalletConnection(near);
          // {near,wallet}
      ''');
    javascriptRuntime.executePendingJob();
    final result = await javascriptRuntime.handlePromise(asyncResult);
    final resultString = result.stringResult;
    print(result);
  }

// 由于wrong3 只好另辟蹊径创建wallet
  wrong4() async {
    final asyncResult = await javascriptRuntime.evaluateAsync(r'''
          const { keyStores } = nearApi;
          const keyStore = new keyStores.BrowserLocalStorageKeyStore();
          const config = {
            networkId: "testnet",
            keyStore,
            nodeUrl: "https://rpc.testnet.near.org",
            walletUrl: "https://wallet.testnet.near.org",
            helperUrl: "https://helper.testnet.near.org",
            explorerUrl: "https://explorer.testnet.near.org"
          };
          const near =   nearApi.connect(config);
          near
      ''');
    javascriptRuntime.executePendingJob();
    final result = await javascriptRuntime.handlePromise(asyncResult);
// 错误    JsEvalResult (SyntaxError: expecting '}'
//     at <eval>:2
// )
    final wallet1 = javascriptRuntime.evaluate('''
          const { WalletConnection } = nearApi;
          const wallet = new WalletConnection($result,);
          // const wallet = new WalletConnection($rawResult);
          return wallet;
          // a
      ''');
// 错误    JsEvalResult (SyntaxError: expecting '}'
//     at <eval>:2
// )
    final wallet2 = javascriptRuntime.evaluate('''
          const { WalletConnection } = nearApi;
          // const wallet = new WalletConnection($result,);
          const wallet = new WalletConnection($rawResult);
          return wallet;
          // a
      ''');
    print(wallet2);
  }

  // 换成异步执行试试 依然报错
  //   JSError (SyntaxError: expecting '}'
  //     at <eval>:2
  // )
  wrong5() async {
    final asyncResult = await javascriptRuntime.evaluateAsync(r'''
          const { keyStores } = nearApi;
          const keyStore = new keyStores.BrowserLocalStorageKeyStore();
          const config = {
            networkId: "testnet",
            keyStore,
            nodeUrl: "https://rpc.testnet.near.org",
            walletUrl: "https://wallet.testnet.near.org",
            helperUrl: "https://helper.testnet.near.org",
            explorerUrl: "https://explorer.testnet.near.org"
          };
          const near =   nearApi.connect(config);
          near
      ''');
    javascriptRuntime.executePendingJob();
    final result = await javascriptRuntime.handlePromise(asyncResult);
    final wallet1Async = await javascriptRuntime.evaluateAsync('''
          const { WalletConnection } = nearApi;
          const wallet = new WalletConnection($result,);
          // const wallet = new WalletConnection($rawResult);
          return wallet;
          // a
      ''');

    javascriptRuntime.executePendingJob();
    final wallet1 = await javascriptRuntime.handlePromise(wallet1Async);
    //   ''');
    print(wallet1);
  }
}
