// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(code) => "The service is abnormal-Err.${code}";

  static String m1(code) => "The network connection is abnormal-Err.${code}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aiChat": MessageLookupByLibrary.simpleMessage("AI Chat"),
        "appName": MessageLookupByLibrary.simpleMessage("Eden"),
        "automatic": MessageLookupByLibrary.simpleMessage("Automatic"),
        "canLoadingText":
            MessageLookupByLibrary.simpleMessage("Release to load more"),
        "clickToTryAgain":
            MessageLookupByLibrary.simpleMessage("Click to try again"),
        "community": MessageLookupByLibrary.simpleMessage("Community"),
        "darkTheme": MessageLookupByLibrary.simpleMessage("Dark"),
        "failedText": MessageLookupByLibrary.simpleMessage("Load Failed"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "httpCodeError": m0,
        "httpParamsError":
            MessageLookupByLibrary.simpleMessage("Parameter abnormality"),
        "httpParseError":
            MessageLookupByLibrary.simpleMessage("Parsing exceptions"),
        "httpStatusCodeError": m1,
        "httpTimeout": MessageLookupByLibrary.simpleMessage("Network anomaly"),
        "idleText": MessageLookupByLibrary.simpleMessage("Pull up Load more"),
        "lightTheme": MessageLookupByLibrary.simpleMessage("Light"),
        "loadingText": MessageLookupByLibrary.simpleMessage("Loading..."),
        "music": MessageLookupByLibrary.simpleMessage("Music"),
        "noDataText": MessageLookupByLibrary.simpleMessage("No more data"),
        "personage": MessageLookupByLibrary.simpleMessage("Personage"),
        "play": MessageLookupByLibrary.simpleMessage("Play"),
        "remote": MessageLookupByLibrary.simpleMessage("Remote"),
        "sound": MessageLookupByLibrary.simpleMessage("Sound"),
        "systemTheme": MessageLookupByLibrary.simpleMessage("System"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
        "touch": MessageLookupByLibrary.simpleMessage("Touch")
      };
}
