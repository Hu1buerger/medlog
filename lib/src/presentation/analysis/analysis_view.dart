import 'package:flutter/material.dart';
import 'package:medlog/src/analysis/pharma_usage_frequency.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
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
    final eventsPerPharm = usageAnalyser.usage.entries.toList();

    return ListView.builder(
      itemCount: eventsPerPharm.length,
      itemBuilder: (bc, index) {
        final stat = eventsPerPharm[index];
        return UsageWidget(stat.key, stat.value);
      },
    );
  }
}

class UsageWidget extends StatelessWidget {
  UsageWidget(this.pharmaceutical, this.usageEvents);

  final Pharmaceutical pharmaceutical;
  final int usageEvents;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pharmaceutical.displayName),
      trailing: Text("used $usageEvents times"),
    );
  }
}