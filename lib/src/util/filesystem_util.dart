import 'dart:io';

extension FilesystemEntityExtension on FileSystemEntity {
  bool isFile() => this is File;

  bool isDirectory() => this is Directory;

  bool isLink() => this is Link;

  /// gathers the name of this entry (ie. the name of the file, dir or link)
  String name() {
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    return path.substring(lastSeparator);
  }
}

extension DirectoryExtension on Directory {
  /// creates a file in this dir
  File createNamed(String fileName) {
    final newPath = newFilePath(fileName);
    return File(newPath);
  }

  Directory subdir(String dirname) {
    final newPath = newFilePath(dirname);
    return Directory(newPath);
  }

  /// creates a sub-entry path
  String newFilePath(String named) {
    if (named.isEmpty) throw ArgumentError.value(named);
    if (named.contains(Platform.pathSeparator)) {
      throw ArgumentError.value(named, null, "contains the platformSeperator");
    }

    return "$path${Platform.pathSeparator}$named";
  }

  List<File> listFiles() => FilesystemUtil.listFiles(this);
}

class FilesystemUtil {
  static List<File> listFiles(Directory dir) {
    if (dir.existsSync() == false) return [];

    return dir.listSync().whereType<File>().toList(growable: false);
  }

  /// Join as if the prefix is the directory and name is the enitity name
  static String joinPath({String prefix = "/", String name = ""}) {
    return Directory(prefix).newFilePath(name);
  }
}
