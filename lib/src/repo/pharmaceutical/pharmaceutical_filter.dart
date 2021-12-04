import 'package:flutter/material.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

//TODO: test this one...
//  this can be the substance, dosage, tradename...
class PharmaceuticalFilter {
  static final Map<String, String Function(Pharmaceutical)> _valueRetriever = {
    "Name": (Pharmaceutical p) => p.displayName,
    "Substance": (p) => p.activeSubstance ?? "",
    "Dosage": (p) => p.dosage.toString(),
  };

  /// filters [pharmaceutical] with [filter] and includes all matches that any filter matches on
  static List<Pharmaceutical> filter(
      List<PharmaceuticalFilter> filter, List<Pharmaceutical> pharmaceutical, String query) {
    var result = <Pharmaceutical>[];

    for (var p in pharmaceutical) {
      bool match = false;
      for (var f in filter) {
        //as for now we dont know if the query is [filter[0] && ...] || [filter[0] || ...]
        // therefore we treat it as a inclusive query
        match |= f.isMatch(p: p, query: query);
      }

      if (match) result.add(p);
    }

    return result;
  }

  static List<PharmaceuticalFilter> all() {
    return List.generate(
        _valueRetriever.length, (index) => PharmaceuticalFilter(matcher: _valueRetriever.keys.toList()[index]));
  }

  @visibleForTesting
  PharmaceuticalFilter.test({required this.negate}) : matcher = "";

  PharmaceuticalFilter({required this.matcher, this.negate = false}) : assert(_valueRetriever.keys.contains(matcher));

  /// the matcher that shall be used for this filter
  final String matcher;

  /// a match will be inverted
  bool negate;

  /// flag for needing a full match
  final bool partialMatch = true;

  /// the filter says that [p] is a match
  bool isMatch({required Pharmaceutical p, required String query}) {
    final valueRetriever = _valueRetriever[matcher]!;
    final fieldValue = valueRetriever(p);

    return stringIsMatch(fieldValue, query);
  }

  @visibleForTesting
  bool stringIsMatch(String value, String query) {
    return partialMatch ? stringPartialMatch(value, query) : stringFullMatch(value, query);
  }

  @visibleForTesting
  bool stringPartialMatch(String value, String query) {
    bool match = value.toLowerCase().contains(query.toLowerCase());
    return match ^ negate;
  }

  @visibleForTesting
  bool stringFullMatch(String value, String query) {
    bool match = query.toLowerCase() == value.toLowerCase();
    return match ^ negate; // negate ? !match : match
  }
}
