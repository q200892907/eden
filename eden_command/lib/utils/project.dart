import 'dart:io';

class FlutterProjects {
  static List<Directory> getProjects() {
    Directory currentDir = Directory.current;
    List<FileSystemEntity> contents =
        currentDir.listSync(recursive: false, followLinks: false);

    List<Directory> projects = [];
    for (var entity in contents) {
      if (entity is Directory) {
        // String projectName = entity.path.split(Platform.pathSeparator).last;
        if (File('${entity.path}/pubspec.yaml').existsSync()) {
          projects.add(entity);
        }
      }
    }
    return projects;
  }

  static String getProjectName(Directory dir) {
    return dir.path.split(Platform.pathSeparator).last;
  }
}
