// ignore_for_file: prefer_final_locals, unused_local_variable

import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';

class QJSManager {
  FlutterQjs? engine;
  init() {
    engine = FlutterQjs(
      // moduleHandler: (String module)  {
      //   return
      //     "assets/js/" + module.replaceFirst(RegExp(r".js$"), "") + ".js";
      // },
      stackSize: 1024 * 1024, // change stack size here.
    );
    engine?.dispatch();
  }
// 依旧是无法处理wallet 的创建
  connect() async {
    engine?.evaluate("""var window = global = globalThis;""");
    String nearRawJS = await rootBundle.loadString("assets/js/near-api-js.js");
    final jsInit = engine?.evaluate(nearRawJS + '');
    print(jsInit);
    final near = await engine?.evaluate(r'''
        const { keyStores,WalletConnection } = nearApi;
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
        // const wallet = new WalletConnection(near);
        // {near,wallet}
        near
      ''');
    // TypeError: cannot read property 'getItem' of undefined
    final wallet = engine?.evaluate(r'''
      const wallet = new WalletConnection(near);
      wallet   
    ''');
    print(near);
  }

/// 添加await同样会出错
/// SyntaxError: expecting ','
  connect2() async {
    engine?.evaluate("""var window = global = globalThis;""");
    String nearRawJS = await rootBundle.loadString("assets/js/near-api-js.js");
    final jsInit = engine?.evaluate(nearRawJS + '');
    print(jsInit);
    final near = await engine?.evaluate(r'''
        const { keyStores,WalletConnection } = nearApi;
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
        const wallet = new WalletConnection(await near);
        near
      ''');
    print(near);
  }
}
