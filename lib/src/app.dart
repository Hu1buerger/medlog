import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_log_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/add_stock.dart';
import 'package:medlog/src/presentation/home_page.dart';
import 'package:medlog/src/presentation/log/medication_intake_details.dart';
import 'package:medlog/src/presentation/settings.dart';
import 'package:medlog/src/presentation/stock/stock_item_detail.dart';

/// The Widget that configures your application.
class MedlogApp extends StatefulWidget {
  const MedlogApp({Key? key, required this.provider}) : super(key: key);

  final APIProvider provider;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<MedlogApp> with WidgetsBindingObserver {
  static final logger = Logger("MedlogApp");

  late final APIProvider provider = widget.provider;

  @override
  void initState() {
    logger.fine("initializing state");
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    logger.fine("disposing of state");
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    logger.fine("state: $state");
    if (state == AppLifecycleState.paused) {
      // store all data once the app gets disposed of
      logger.info("writing the apps state back to the disk");

      //FIXME: hook all repos to the adapter
      widget.provider.repoAdapter.execShutdownHooks();
      // all data should now be in the store
      widget.provider.store.flush();
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

      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData.dark(),

      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case "/":
              case HomePage.route:
                return HomePage(provider: widget.provider);
              case AddLogEntry.routeName:
                return AddLogEntry(provider: widget.provider);
              case AddPharmaceutical.routeName:
                return AddPharmaceutical(provider: widget.provider);
              case AddStock.routeName:
                return AddStock(provider: widget.provider);
              case MedicationIntakeDetails.routeName:
                return MedicationIntakeDetails(
                    entry: routeSettings.arguments! as MedicationIntakeEvent, provider: widget.provider);
              case StockItemDetail.routeName:
                return StockItemDetail(stockItem: routeSettings.arguments! as StockItem, provider: widget.provider);
              case Settings.route_name:
                return Settings(provider: widget.provider);
              default:
                return Text("ILLEGAL ROUTE ${routeSettings.name}");
            }
          },
        );
      },
    );
  }
}
