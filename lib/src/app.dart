import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_log_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/add_stock.dart';
import 'package:medlog/src/presentation/home_page/home_page.dart';
import 'package:medlog/src/presentation/log/medication_intake_details.dart';
import 'package:medlog/src/presentation/settings/settings.dart';
import 'package:medlog/src/presentation/stock/stock_item_detail.dart';
import 'package:medlog/src/repo/log/log_provider.dart';
import 'package:medlog/src/repo/log/log_repo.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/repo/stock/stock_controller.dart';
import 'package:medlog/src/util/store.dart';

/// The Widget that configures your application.
class MedlogApp extends StatefulWidget {
  const MedlogApp(
      {Key? key, required this.logRepo, required this.pharmaRepo, required this.stockRepo, required this.store})
      : super(key: key);

  final LogRepo logRepo;
  final PharmaceuticalRepo pharmaRepo;
  final StockRepo stockRepo;
  final Store store;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<MedlogApp> with WidgetsBindingObserver {
  static final logger = Logger("MedlogApp");

  late final LogProvider logProvider;

  @override
  void initState() {
    logger.fine("initializing state");
    WidgetsBinding.instance!.addObserver(this);
    logProvider = LogProvider(widget.logRepo);
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
      widget.pharmaRepo.store();
      widget.logRepo.store();
      widget.stockRepo.store();

      // all data should now be in the store
      widget.store.flush();
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
                return HomePage(
                  logController: widget.logRepo,
                  stockController: widget.stockRepo,
                );
              case AddLogEntry.routeName:
                return AddLogEntry(
                    logProvider: logProvider, pharmaController: widget.pharmaRepo, stockController: widget.stockRepo);
              case AddPharmaceutical.routeName:
                return AddPharmaceutical(pharmController: widget.pharmaRepo);
              case AddStock.routeName:
                return AddStock(
                  pharmaceuticalController: widget.pharmaRepo,
                  stockController: widget.stockRepo,
                  logProvider: logProvider,
                );
              case MedicationIntakeDetails.routeName:
                return MedicationIntakeDetails(
                  entry: routeSettings.arguments! as MedicationIntakeEvent,
                  logController: widget.logRepo,
                );
              case StockItemDetail.routeName:
                return StockItemDetail(
                  stockItem: routeSettings.arguments! as StockItem,
                  stockController: widget.stockRepo,
                );
              case Settings.route_name:
                return Settings(
                  pharmaceuticalController: widget.pharmaRepo,
                  logProvider: logProvider,
                  logController: widget.logRepo,
                  stockController: widget.stockRepo,
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
