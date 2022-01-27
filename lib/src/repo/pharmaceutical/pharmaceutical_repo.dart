import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_filter.dart';
import 'package:medlog/src/repo/provider.dart';
import 'package:medlog/src/util/repo_adapter.dart';
import 'package:medlog/src/util/store.dart';
import 'package:uuid/uuid.dart';

class PharmaceuticalRepo with ChangeNotifier {
  /// uid generator using crypto random number generator;
  static const String storageKey = "pharmaceuticals";
  static const Uuid _uuid = Uuid();

  PharmaceuticalRepo(this.repoAdapter, {this.fetchEnabled = true});

  final Logger _logger = Logger("PharmaceuticalRepo");

  final RepoAdapter repoAdapter;

  final List<PharmaceuticalRef> _pharmaStore = [];

  List<Pharmaceutical> get pharmaceuticals => _pharmaStore;

  @visibleForTesting
  final bool fetchEnabled;

  /// loads all data from disk and restores the _pharmastore
  Future<void> load() async {
    var items =
        repoAdapter.loadListOrDefault<Json, Pharmaceutical>(storageKey, (Json p0) => Pharmaceutical.fromJson(p0), []);

    items.forEach(addPharmaceutical);
    _logger.fine("finished adding all ${items.length}");

    //FIXME if (fetchEnabled) pharmaservice.startRemoteFetch();

    _logger.fine("finished loading all pharmaceuticals with #${items.length}");
    return;
  }

  store() {
    _logger.info("storing ${_pharmaStore.length} pharmaceuticals");
    repoAdapter.storeList(storageKey, _pharmaStore, (Pharmaceutical p) => p.toJson());
  }

  void startRemoteFetch() {
    _logger.info("enabling fetch");
    throw UnimplementedError();
    //pharmaservice.startRemoteFetch();
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
    List<Pharmaceutical> matches = [];

    if (p.isIded) {
      matches = pharmaceuticals.where((element) => element.id == p.id).toList();
      assert(matches.length < 2);
    }
    // non user_created instances can assure that the id is unique
    else if (p.documentState != DocumentState.user_created) {
      // get match by id
      matches = pharmaceuticals.where((element) => element.id == p.id).toList();
      assert(matches.length < 2);
    } else {
      //TODO: matching for retrieval should be firstly done by id and only later by equality.
      // THis is a result of allowing the condtion of same uuid (even though quite unlikely)
      assert(false);
      /*matches = pharmaceuticals
          .where((element) =>
              element.human_known_name == p.human_known_name &&
              element.dosage == p.dosage &&
              element.tradename == p.tradename &&
              element.activeSubstance == p.activeSubstance)
          .toList();*/
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

      //TODO:
      throw UnimplementedError("todo add eventual consistency");
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
    return Uuid.isValidUUID(fromString: id, validationMode: ValidationMode.strictRFC4122);
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
