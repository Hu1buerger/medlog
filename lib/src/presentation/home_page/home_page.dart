import 'package:flutter/material.dart';
import 'package:medlog/src/repo/log/log_repo.dart';
import 'package:medlog/src/repo/stock/stock_controller.dart';
import 'package:medlog/src/presentation/log/log_view.dart';
import 'package:medlog/src/presentation/stock/view_stock.dart';

class HomePage extends StatefulWidget {
  static const String route = "/home";

  final LogRepo logController;
  final StockRepo stockController;

  const HomePage({Key? key, required this.logController, required this.stockController, int? selectPage = 0})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<HomePagePage> pages;

  //TODO: fetch from widget
  int selectedPage = 0;

  @override
  void initState() {
    super.initState();

    pages = [
      LogView(logController: widget.logController),
      StockView(
        stockController: widget.stockController,
      )
    ];
  }

  void selectPage(int i) {
    if (selectedPage == i) return;

    setState(() {
      selectedPage = i;
    });
  }

  Widget buildNavBar() {
    return BottomNavigationBar(
        currentIndex: selectedPage,
        onTap: selectPage,
        items: List.generate(pages.length, (i) {
          var page = pages[i];

          return BottomNavigationBarItem(icon: Icon(Icons.title), label: page.tabtitle());
        }));
  }

  @override
  Widget build(BuildContext context) {
    var homePagePage = pages[selectedPage];

    return Scaffold(
      appBar: homePagePage.appBar(context),
      floatingActionButton: homePagePage.floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: homePagePage,
      bottomNavigationBar: buildNavBar(),
    );
  }
}

mixin HomePagePage on Widget {
  String? tabtitle();

  Widget? floatingActionButton(BuildContext context);

  PreferredSizeWidget? appBar(BuildContext context);
}
