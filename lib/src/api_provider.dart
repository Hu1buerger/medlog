import 'package:medlog/src/repo/log/log_repo.dart';
import 'package:medlog/src/repo/provider.dart';
import 'package:medlog/src/util/backupmanager.dart';
import 'package:medlog/src/util/repo_adapter.dart';
import 'package:medlog/src/util/store.dart';

class APIProvider {
  late final Store store;
  late final RepoAdapter repoAdapter;

  @Deprecated("see logProvider for more")
  late final LogRepo logRepo;
  late final LogProvider logProvider;
  late final StockRepo stockRepository;
  late final PharmaceuticalRepo pharmaRepo;

  Future defaultInit() async {
    store = (await backupmanager()).createStore();

    repoAdapter = RepoAdapter(store);
    pharmaRepo = PharmaceuticalRepo(repoAdapter);
    logRepo = LogRepo(repoAdapter, pharmaRepo);
    logProvider = LogProvider(logRepo);
    stockRepository = StockRepo(repoAdapter, pharmaRepo);

    repoAdapter.registerShutdownHook((_) => pharmaRepo.store());
    repoAdapter.registerShutdownHook((_) => logRepo.store());
    repoAdapter.registerShutdownHook((_) => stockRepository.store());

    assert(repoAdapter.shutdownHook.length == 3);

    await store.load();
    await pharmaRepo.load();
    await logRepo.load();
    await stockRepository.load();
  }
}
