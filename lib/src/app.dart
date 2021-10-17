import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/presentation/add_entrys/add_log_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/settings/settings.dart';
import 'package:medlog/src/presentation/stock/view_stock.dart';
import 'package:medlog/src/presentation/view_log/log_view.dart';
import 'package:medlog/src/presentation/view_log/medication_intake_details.dart';

import 'controller/log/log_controller.dart';
import 'controller/pharmaceutical/pharmaceutical_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp(
      {Key? key,
      required this.logController,
      required this.pharmaController,
      required this.stockController})
      : super(key: key);

  final LogController logController;
  final PharmaceuticalController pharmaController;
  final StockController stockController;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        widget.logController.storeLog();
        widget.pharmaController.store();
        widget.stockController.store();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],

      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      theme: ThemeData.dark(),

      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case "/":
              case LogView.routeName:
                return LogView(logController: widget.logController);
              case ViewStock.routeName:
                return ViewStock(stockController: widget.stockController);
              case AddLogEntry.routeName:
                return AddLogEntry(
                  logController: widget.logController,
                  pharmaController: widget.pharmaController,
                  stockController: widget.stockController
                );
              case AddPharmaceutical.route_name:
                return AddPharmaceutical(
                    pharmController: widget.pharmaController);
              case MedicationIntakeDetails.routeName:
                return MedicationIntakeDetails(
                  entry: routeSettings.arguments! as MedicationIntakeEvent,
                  logController: widget.logController,
                );
              case Settings.route_name:
                return Settings(
                  pharmaceuticalController: widget.pharmaController,
                  logController: widget.logController,
                  stockController: widget.stockController,
                );
              default:
                return Text("ILLEGAL ROUTE ${routeSettings.name}");
            }
          },
        );
      },
    );
  }
}
