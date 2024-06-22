import 'dart:io';

class GitSubmodule {
  final String submodule;
  final String path;
  final String url;
  final String branch;

  GitSubmodule({
    required this.submodule,
    required this.path,
    required this.url,
    required this.branch,
  });

  static List<GitSubmodule> get() {
    var file = File('.gitmodules');
    if (file.existsSync()) {
      List<GitSubmodule> gitSubmodules = [];
      var contents = file.readAsStringSync();
      var regex = RegExp(
          r'\[submodule "([^"]+)"\]\s+path = (.+)\s+url = (.+)\s+branch = (.+)');
      var matches = regex.allMatches(contents);
      for (var match in matches) {
        var submodule = match.group(1);
        var path = match.group(2);
        var url = match.group(3);
        var branch = match.group(4);
        if (submodule != null &&
            path != null &&
            url != null &&
            branch != null) {
          gitSubmodules.add(
            GitSubmodule(
              submodule: submodule,
              path: path,
              url: url,
              branch: branch,
            ),
          );
        }
      }
      return gitSubmodules;
    }
    return [];
  }

  @override
  String toString() {
    return 'GitSubmodule{submodule: $submodule, path: $path, url: $url, branch: $branch}';
  }
}
