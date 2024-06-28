import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenThemeConfig {
  final String name;
  final EdenThemeMode mode;

  EdenThemeConfig({required this.name, required this.mode});
}

class EdenThemeTool extends ConsumerWidget {
  const EdenThemeTool({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<EdenThemeConfig> locales = [
      EdenThemeConfig(
          name: context.strings.systemTheme, mode: EdenThemeMode.system),
      EdenThemeConfig(
          name: context.strings.lightTheme, mode: EdenThemeMode.light),
      EdenThemeConfig(
          name: context.strings.darkTheme, mode: EdenThemeMode.dark),
    ];
    return FutureBuilder(
        future: EdenThemeBuilder.getThemeMode(),
        builder: (context, data) {
          if (data.hasData) {
            EdenThemeMode themeMode = data.requireData;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '切换主题',
                            style: context.theme.textTheme.titleMedium,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<EdenThemeMode>(
                            dropdownColor: context.theme.background,
                            items: locales
                                .map(
                                  (e) => DropdownMenuItem<EdenThemeMode>(
                                    value: e.mode,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (type) {
                              if (type != null) {
                                EdenThemeBuilder.changeTheme(context, type);
                              }
                            },
                            value: themeMode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return EdenEmpty.ui;
        });
  }
}
