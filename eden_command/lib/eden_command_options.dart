import 'entities/publish_config.dart';

class EdenCommandOptions {
  const EdenCommandOptions({
    this.publishConfig = const PublishConfig(),
  });
  final PublishConfig publishConfig;

  factory EdenCommandOptions.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> publishConfig = json['publish'] ?? {};
    return EdenCommandOptions(
      publishConfig: PublishConfig.fromJson(publishConfig),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publish': publishConfig.toJson(),
    };
  }

  @override
  String toString() {
    return 'ZhiyaCommandOptions{publish: $publishConfig}';
  }
}
