import 'package:flutter/material.dart';
import 'package:medlog/src/analysis/pharma_usage_frequency.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/presentation/home_page.dart';
import 'package:medlog/src/presentation/settings.dart';

class AnalysisView extends StatefulWidget with HomePagePage {
  static const String title = "Statistics";

  AnalysisView({Key? key, required this.provider}) : super(key: key);

  final APIProvider provider;

  @override
  State<StatefulWidget> createState() => _AnalysisViewState();

  @override
  appBar(BuildContext context) {
    return AppBar(
      title: const Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, Settings.route_name);
          },
        ),
      ],
    );
  }

  @override
  Widget? floatingActionButton(BuildContext context) => null;

  @override
  String? tabtitle() => title;
}

class _AnalysisViewState extends State<AnalysisView> {
  @override
  Widget build(BuildContext context) {
    final usageAnalyser = PharmaUsageFrequency(widget.provider);
    final eventsPerPharm = usageAnalyser.usageTimes.entries.toList();

    return ListView.builder(
        itemCount: eventsPerPharm.length,
        itemBuilder: (bc, index) {
          final stat = eventsPerPharm[index];
          final pharmaceutical = stat.key;
          final usageEvents = stat.value;
          final meanDelta = usageAnalyser.meanIntakeDurationForPharm(pharmaceutical);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stat.key.displayName),
              Text("used ${usageEvents.length} times"), //FIXME this is of
              Text("and a mean of ${meanDelta.toString()}"),
              /*charts.ScatterPlotChart([charts.Series(
                id: "usageTimes",
                data: usageEvents,
                domainFn: (dt, _) => dt.hour,
                measureFn: (dt, _) => 1,
              )
              ],
              ),*/
            ],
          );
        });
  }
}
