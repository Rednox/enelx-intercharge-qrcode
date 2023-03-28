import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:rich_clipboard/rich_clipboard.dart';

void main() {
  runApp(const EnelXInterchargeQrCode());
}

class EnelXInterchargeQrCode extends StatelessWidget {
  const EnelXInterchargeQrCode({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enel X Intercharge QR Code',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
      ),
      home: const QRCodeSelectPage(
          title: 'Intercharge QR Code Converter for Enel X App'),
    );
  }
}

class QRCodeSelectPage extends StatefulWidget {
  const QRCodeSelectPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<QRCodeSelectPage> createState() => _QRCodeSelectPageState();
}

class _QRCodeSelectPageState extends State<QRCodeSelectPage> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;
  String evseId = "";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                    context: context,
                    onCode: (code) {
                      setState(() {
                        this.code = code;
                        if (this.code is String) {
                          evseId = extractEvseId(this.code);
                          final RichClipboardData data = RichClipboardData(
                            text: evseId,
                            html: '<html><body>$evseId</body></html>',
                          );
                          RichClipboard.setData(data).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("EVSE ID copied to clipboard")));
                          });
                        }
                      });
                    });
              },
              child: const Text("Scan Intercharge QR Code"),
            ),
            const Spacer(),
            SelectableText(evseId),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String extractEvseId(String? code) {
    final evseIdRegExp =
        RegExp(r'([A-Za-z]{2})(\*?)([A-Za-z0-9]{3})\*?(E[A-Za-z0-9\*]{1,30})');
    // final countryCodeRegExp = RegExp(r'^\[:\.\]$');
    // final operatorIdRegExp = RegExp(r'^\[:\.\]$');
    // final idRegExp = RegExp(r'^\[:\.\]$');
    String countryCode = "";
    String? seperator;
    String operatorId = "";
    String id = "";
    if (code is String) {
      final match = evseIdRegExp.firstMatch(code);
      if (match?.group(0) is String) {
        countryCode = match!.group(1)!;
        seperator = match.group(2);
        operatorId = match.group(3)!;
        id = match.group(4)!;

        return operatorId +
            countryCode +
            enelxSeperator(seperator) +
            operatorId +
            enelxSeperator(seperator) +
            replaceEnelXSeperatorFromId(id);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No EVSE ID found!")));
      }
    }
    return "";
  }

  String enelxSeperator(String? seperator) {
    return seperator is String ? "S" : "";
  }

  String replaceEnelXSeperatorFromId(String id) {
    return id.replaceAll(RegExp(r'\*'), "S");
  }
}
