import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'eden_queue_util.dart';

export 'package:permission_handler/permission_handler.dart';

typedef OnPermissionTips = String Function(Permission permission);

class EdenPermissionUtil {
  static const String _kPermissionQueueKey = 'eden_permission_queue';

  static Function(String)? showTips;

  static const List<Permission> _kAndroidGroup = <Permission>[
    Permission.camera,
    Permission.contacts,
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse,
    Permission.microphone,
    Permission.phone,
    Permission.sensors,
    Permission.sms,
    Permission.speech,
    Permission.storage,
    Permission.ignoreBatteryOptimizations,
    Permission.notification,
    Permission.accessMediaLocation,
    Permission.activityRecognition,
    Permission.unknown,
    Permission.manageExternalStorage,
    Permission.systemAlertWindow,
    Permission.requestInstallPackages,
    Permission.accessNotificationPolicy,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.nearbyWifiDevices,
    Permission.photos,
    Permission.videos,
    Permission.audio,
    Permission.scheduleExactAlarm,
    Permission.sensorsAlways,
    Permission.calendarWriteOnly,
    Permission.calendarFullAccess,
  ];

  static const List<Permission> _kIosGroup = <Permission>[
    Permission.camera,
    Permission.contacts,
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse,
    Permission.mediaLibrary,
    Permission.microphone,
    Permission.photos,
    Permission.photosAddOnly,
    Permission.reminders,
    Permission.sensors,
    Permission.speech,
    Permission.notification,
    Permission.unknown,
    Permission.bluetooth,
    Permission.appTrackingTransparency,
    Permission.criticalAlerts,
    Permission.calendarWriteOnly,
    Permission.calendarFullAccess,
  ];

  static List<Permission> _devicePermissions(List<Permission> permissions) {
    final List<Permission> temp = <Permission>[];
    if (Platform.isAndroid) {
      for (var value in permissions) {
        if (_kAndroidGroup.contains(value)) {
          temp.add(value);
        }
      }
    } else if (Platform.isIOS) {
      for (var value in permissions) {
        if (_kIosGroup.contains(value)) {
          temp.add(value);
        }
      }
    }
    return temp;
  }

  /// 检测是否授予权限组的权限
  /// [permissions] 权限组
  /// [tips] 是否支持吐丝，默认吐丝
  static Future<bool> checkGroup(
    List<Permission> permissions, {
    OnPermissionTips? tips,
  }) async {
    bool granted = true;
    permissions = _devicePermissions(permissions);
    for (Permission permission in permissions) {
      final PermissionStatus status = await permission.status;
      if (status != PermissionStatus.granted) {
        granted = false;
        if (tips != null) {
          showTips?.call(tips.call(permission));
        }
        break;
      }
    }
    return Future<bool>.value(granted);
  }

  /// 检测是否授予权限
  /// [permission] 所需的权限
  /// [tips] 提示
  static Future<bool> check(
    Permission permission, {
    OnPermissionTips? tips,
  }) async {
    return checkGroup(<Permission>[permission], tips: tips);
  }

  /// 注册权限组
  /// [permissions] 所需注册的权限组
  /// [isPermanentlyDenied] android 如果是询问是否toast,不获取
  static Future<bool> requestGroup(
    List<Permission> permissions, {
    bool isPermanentlyDenied = false,
    OnPermissionTips? tips,
  }) async {
    final Completer<bool> completer = Completer<bool>();
    EdenQueueUtil.get(_kPermissionQueueKey).addTask(() async {
      await realRequest(
        permissions,
        isPermanentlyDenied: isPermanentlyDenied,
        tips: tips,
      ).then(completer.complete).catchError(completer.completeError);
    });
    return completer.future;
  }

  static Future<bool> request(
    Permission permission, {
    OnPermissionTips? tips,
  }) async {
    return requestGroup(
      <Permission>[permission],
      tips: tips,
    );
  }

  static Future<bool> realRequest(
    List<Permission> permissions, {
    bool isPermanentlyDenied = false,
    OnPermissionTips? tips,
  }) async {
    permissions = _devicePermissions(permissions);

    List<Permission> perList = permissions;

    final List<Permission> temp = <Permission>[];
    bool granted = true;
    for (Permission permission in perList) {
      final PermissionStatus status = await permission.status;
      if (status.isPermanentlyDenied && isPermanentlyDenied) {
        if (tips != null) {
          showTips?.call(tips.call(permission));
        }
        granted = false;
      } else if (!status.isGranted) {
        temp.add(permission);
      }
    }
    perList = temp;

    if (perList.isEmpty) {
      return Future<bool>.value(granted);
    }

    final Map<Permission, PermissionStatus> group = await perList.request();
    for (Permission permission in group.keys) {
      final PermissionStatus? status = group[permission];
      if (Platform.isIOS) {
        if (status != PermissionStatus.granted) {
          if (status == PermissionStatus.limited) {
            granted = true;
          } else {
            granted = false;
            if (tips != null) {
              showTips?.call(tips.call(permission));
            }
          }
        }
      } else {
        if (status != PermissionStatus.granted) {
          granted = false;
          if (tips != null) {
            showTips?.call(tips.call(permission));
          }
          break;
        }
      }
    }
    return Future<bool>.value(granted);
  }

  /// 获取相册权限
  static Future<bool> requestStorage(
      {String Function(Permission)? tips}) async {
    return requestGroup(
      [
        if (Platform.isAndroid) ...[
          if (await getAndroidVersion() > 32) ...[
            Permission.photos,
            Permission.videos,
            Permission.audio,
          ] else ...[
            Permission.storage
          ]
        ],
        if (Platform.isIOS) Permission.photos,
      ],
      tips: tips,
    );
  }

  /// 获取Android系统版本号
  static Future<int> getAndroidVersion() async {
    final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    final int sdkInt = androidInfo.version.sdkInt;
    return sdkInt;
  }

  static void openPermissionSettings() {
    openAppSettings();
  }
}
