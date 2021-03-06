import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpomosh/pages/login_page.dart';
import 'package:vpomosh/pages/root_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/user_agreement_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseConnection.enablePendingPurchases();
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}

class MyApp extends StatefulWidget {

  final SharedPreferences prefs;
  MyApp({this.prefs});

  @override
  _MyAppState createState() => _MyAppState(prefs: this.prefs);
}

class _MyAppState extends State<MyApp> {

  final SharedPreferences prefs;
  _MyAppState({this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'В помощь',


      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF00A2D3),
        accentColor: Color(0xFFC3E5DD),
        colorScheme: Theme.of(context).colorScheme.copyWith(
          secondary: Color(0xFF707070),
        ),
      ),

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru'),
      ],


      home: _handleCurrentScreen(),
      debugShowCheckedModeBanner: false,

      routes: <String, WidgetBuilder>{
        '/root': (BuildContext context) => new RootPage(),
        '/login': (BuildContext context) => new LoginPage(),
      },
    );
  }

  Widget _handleCurrentScreen() {
    bool seen = (prefs.getBool('seen') ?? false);
    if (seen) {
      return new RootPage();
    } else {
      return new UserAgreementPage(prefs: prefs);
    }
  }
}


