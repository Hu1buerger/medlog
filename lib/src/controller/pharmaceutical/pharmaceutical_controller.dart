import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_filter.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';
import 'package:uuid/uuid.dart';

class PharmaceuticalController with ChangeNotifier {
  /// uid generator using crypto random number generator;
  static const Uuid uuid = Uuid();

  PharmaceuticalController(this.pharmaservice, {this.fetchEnabled = true});

  final Logger _logger = Logger("PharmaceuticalController");
  @visibleForTesting
  final PharmaService pharmaservice;

  late final StreamSubscription<Pharmaceutical> eventsSubscription;

  final List<PharmaceuticalRef> _pharmStore = [];

  final bool fetchEnabled;

  List<Pharmaceutical> get pharmaceuticals => _pharmStore;

  List<String> get tradenames => pharmaceuticals.map((e) => e.tradename).toSet().toList();

  /// creates a new pharmaceutical and adds it to the local knowledgebase.
  ///
  createPharmaceutical(Pharmaceutical p) {
    assert(p is PharmaceuticalRef == false);
    assert(p.documentState == DocumentState.user_created);
    assert(p.isIded == false);

    p = p.cloneAndUpdate(id: _createPharmaID());
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
    // TODO: this dosnt handle if toInsert is a change from remote with a different id (duplication)
    var other = pharmaceuticalByID(toInsert.id);

    if (other != null) {
      // if there is a collison;
      // might / should be a method of Pharmaceutical?
      bool isEqual = other.activeSubstance == toInsert.activeSubstance &&
          other.dosage.toString() == toInsert.dosage.toString() &&
          other.tradename == toInsert.tradename &&
          other.human_known_name == toInsert.human_known_name;

      // no need to update
      if (isEqual && other.documentState == toInsert.documentState) return;

      if (other.documentState == DocumentState.user_created && other.human_known_name != toInsert.human_known_name) {
        // if the pharmaceutical from the store is not servertracked and the humanknown_name dosnt match
        other.cloneAndUpdate(id: _createPharmaID());
        notifyListeners();
        //other is already in the store so no need to insert.
        return;
      }

      if (toInsert.documentState == DocumentState.user_created && other.human_known_name != toInsert.human_known_name) {
        // and the new item is userCreated, we can just change the id
        // aka the user wants to create a new Pharmaceutical
        toInsert.cloneAndUpdate(id: _createPharmaID());
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
        _logger.severe("Unfixable collison of $other and $toInsert while adding", null, StackTrace.current);
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

  Pharmaceutical? pharmaceuticalByNameAndDosage(String tradename, Dosage dose) {
    var p = pharmaceuticals
        .where((element) => element.displayName.startsWith(tradename))
        .where((element) => element.dosage == dose)
        .toList();

    assert(p.length < 2);

    return p.isNotEmpty ? p.first : null;
  }

  List<Pharmaceutical> filter(String query, List<PharmaceuticalFilter> filter) {
    return PharmaceuticalFilter.filter(filter, pharmaceuticals, query);
  }

  bool _isValidPharmaID(String id) {
    // enforce RFC4122 UUIDS, this refuses to validate GUID from microsoft.
    return Uuid.isValidUUID(fromString: id, validationMode: ValidationMode.strictRFC4122);
  }

  String _createPharmaID() {
    return uuid.v4();
  }

  _insert(PharmaceuticalRef p) {
    _pharmStore.add(p);
    p.registered = true;

    _logger.fine("inserted ${p.id} ${p.displayName}");
    notifyListeners();
  }

  /// loads all data from disk and restores the _pharmastore
  Future<void> load() async {
    pharmaservice.enableBacklog();

    var items = await pharmaservice.loadFromDisk();
    items.forEach(addPharmaceutical);

    pharmaservice.clearBacklog();
    pharmaservice.disableBacklog();

    _logger.fine("finished adding all ${items.length}");
    // enable the subscription
    eventsSubscription = pharmaservice.events.listen((event) {
      addPharmaceutical(event);
    });

    if (fetchEnabled) pharmaservice.startRemoteFetch();

    _logger.fine("finished loading all pharmaceuticals with #${items.length}");
    return;
  }

  Future<void> store() async {
    pharmaservice.store(pharmaceuticals);
  }
}
