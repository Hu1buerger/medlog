import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';
import 'package:medlog/src/repo/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_filter.dart';
import 'package:uuid/uuid.dart';

class PharmaceuticalRepo with ChangeNotifier {
  /// uid generator using crypto random number generator;
  static const Uuid _uuid = Uuid();

  PharmaceuticalRepo(PharmaService pharmaservice, {this.fetchEnabled = true})
      : _pharmaservice = pharmaservice;

  final Logger _logger = Logger("PharmaceuticalRepo");

  @visibleForTesting
  PharmaService get pharmaservice => _pharmaservice;

  List<Pharmaceutical> get pharmaceuticals => _pharmaStore;

  final PharmaService _pharmaservice;

  // ignore: unused_field
  late final StreamSubscription<Pharmaceutical> _eventsSubscription;

  final List<PharmaceuticalRef> _pharmaStore = [];

  @visibleForTesting
  final bool fetchEnabled;

  /// loads all data from disk and restores the _pharmastore
  Future<void> load() async {
    pharmaservice.enableBacklog();

    var items = await pharmaservice.loadFromDisk();
    items.forEach(addPharmaceutical);

    pharmaservice.clearBacklog();
    pharmaservice.disableBacklog();

    _logger.fine("finished adding all ${items.length}");
    // enable the subscription
    _eventsSubscription = pharmaservice.events.listen((event) {
      addPharmaceutical(event);
    });

    if (fetchEnabled) pharmaservice.startRemoteFetch();

    _logger.fine("finished loading all pharmaceuticals with #${items.length}");
    return;
  }

  Future<void> store() async {
    pharmaservice.store(pharmaceuticals);
  }

  Map<String, List<Map<String, dynamic>>> jsonKV() {
    return _pharmaservice.toJsonArray(pharmaceuticals);
  }

  void startRemoteFetch() {
    _logger.info("enabling fetch");
    pharmaservice.startRemoteFetch();
  }

  /// creates a new pharmaceutical and adds it to the local knowledgebase.
  createPharmaceutical(Pharmaceutical p) {
    assert(p is PharmaceuticalRef == false);
    assert(p.documentState == DocumentState.user_created);
    assert(p.isIded == false);

    p = p.cloneAndUpdate(id: createPharmaID());
    addPharmaceutical(p);
  }

  Pharmaceutical getTrackedInstance(Pharmaceutical p) {
    List<Pharmaceutical> matches;
    // non user_created instances can assure that the id is unique
    if (p.documentState != DocumentState.user_created) {
      // get match by id
      matches = pharmaceuticals.where((element) => element.id == p.id).toList();
      assert(matches.length < 2);
    } else {
      //TODO: matching for retrieval should be firstly done by id and only later by equality.
      // THis is a result of allowing the condtion of same uuid (even though quite unlikely)
      matches = pharmaceuticals
          .where((element) =>
              element.human_known_name == p.human_known_name &&
              element.dosage == p.dosage &&
              element.tradename == p.tradename &&
              element.activeSubstance == p.activeSubstance)
          .toList();
    }

    assert(matches.length == 1);
    assert(matches.single is PharmaceuticalRef);

    return matches.single;
  }

  /// adds a already known pharmaceutical back to the store
  ///
  /// inserting takes an amortized constant time
  /// if checking for duplicates is necessary the worst case runtime should be O(N) where N is the length of known pharmaceuticals
  @visibleForTesting
  void addPharmaceutical(Pharmaceutical pharmaceutical) {
    assert(pharmaceutical.isIded);

    if (pharmaceutical is PharmaceuticalRef == false) {
      pharmaceutical = PharmaceuticalRef.toRef(pharmaceutical);
    }

    if (pharmaceutical.activeSubstance == "Naproxen") {
      //TODO: update on remote and remove. THis is only for testing...
      print("updating naproxen to 0.5");
      pharmaceutical.cloneAndUpdate(smallestPartialUnit: 0.5);
    }

    var toInsert = pharmaceutical as PharmaceuticalRef;
    // the id is set so it is either already tracked or from the server

    var other = pharmaceuticalByID(toInsert.id);

    if (other != null) {
      /*
      * TODO: dosnt handle if toInsert is a change from remote with a different id (duplication)
      *
      * Desc:
      * Currently versioning of the pharmaceuticals is problematic.
      * Semantic versioning, or numeric versioning is impossible, bcs only oneway communication is automated
      */

      // if there is a collison;
      // might / should be a method of Pharmaceutical?
      bool isEqual = other.activeSubstance == toInsert.activeSubstance &&
          other.dosage.toString() == toInsert.dosage.toString() &&
          other.tradename == toInsert.tradename &&
          other.human_known_name == toInsert.human_known_name;

      // no need to update
      if (isEqual && other.documentState == toInsert.documentState) return;

      if (other.documentState == DocumentState.user_created &&
          other.human_known_name != toInsert.human_known_name) {
        // if the pharmaceutical from the store is not servertracked and the humanknown_name dosnt match
        other.cloneAndUpdate(id: createPharmaID());
        notifyListeners();
        //other is already in the store so no need to insert.
        return;
      }

      if (toInsert.documentState == DocumentState.user_created &&
          other.human_known_name != toInsert.human_known_name) {
        // and the new item is userCreated, we can just change the id
        // aka the user wants to create a new Pharmaceutical
        toInsert.cloneAndUpdate(id: createPharmaID());
        _insert(toInsert);
        return;
      }

      //assert(toInsert.documentState != DocumentState.user_created && other.documentState != DocumentState.user_created);
      //no easy fix is possible

      if (toInsert.documentState.isHeavier(other.documentState)) {
        //toInsert is has more authority, so it will be the data
        (other as PharmaceuticalRef).ref = toInsert.ref;
        notifyListeners();
        return;
      }

      if (other.documentState == toInsert.documentState) {
        //maybe the pharmaceutical should track a versionID
        //collision and no change in documentState.
        // or the remote is always right
        _logger.severe(
            "Unfixable collison of $other and $toInsert while adding",
            null,
            StackTrace.current);
        //throw StateError("unfixable collision of $other and $toInsert while adding");
      }

      _logger.fine("refusing to downgrade item from $other to $toInsert");
    } else {
      _insert(toInsert);
    }
  }

  // might use optional instead of nullable type
  Pharmaceutical? pharmaceuticalByID(String id) {
    assert(_isValidPharmaID(id));
    var results = pharmaceuticals.where((element) => element.id == id).toList();
    assert(results.length < 2);

    return results.isEmpty ? null : results.single;
  }

  List<Pharmaceutical> filter(String query, List<PharmaceuticalFilter> filter) {
    return PharmaceuticalFilter.filter(filter, pharmaceuticals, query);
  }

  bool _isValidPharmaID(String id) {
    // enforce RFC4122 UUIDS, this refuses to validate GUID from microsoft.
    return Uuid.isValidUUID(
        fromString: id, validationMode: ValidationMode.strictRFC4122);
  }

  @visibleForTesting
  static String createPharmaID() {
    return _uuid.v4();
  }

  _insert(PharmaceuticalRef p) {
    _pharmaStore.add(p);
    p.registered = true;

    _logger.fine("inserted ${p.id} ${p.displayName}");
    notifyListeners();
  }
}
