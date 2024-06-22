# Eden

## Flutter版本

基于Flutter当前最新稳定版本3.22.+进行开发

## 目录结构

- lib(主目录)
    - config(配置信息等)
    - pages(页面-功能)
    - plugin(插件初始化)
    - providers(全局状态管理)
    - router(路由表，go_router生成)
    - utils(功能封装库)
    - webview(网页组件)
    - widgets(功能组件封装，如倒计时)
- eden_command(命令行工具)
- eden_icons(图标库)
- eden_internet_connection_checker(网络变化监听)
- eden_intl(国际化)
- eden_logger(log库)
- eden_database(数据库)
- eden_service(基础服务封装，用于接口等服务)
- eden_uikit(组件规范)
- eden_utils(通用工具)

## 主要三方库

- 屏幕适配
    1. **[flutter_screenutil](https://pub.flutter-io.cn/packages/flutter_screenutil)**(屏幕尺寸适配)
- 多语言(**[intl_utils](https://pub.flutter-io.cn/packages/intl_utils)**)
- 状态管理(**[flutter_riverpod](https://pub.flutter-io.cn/packages/flutter_riverpod)**)
- Json转Entity
    1. **[json_serializable](https://pub.flutter-io.cn/packages/json_serializable)**
    2. **[freezed](https://pub.flutter-io.cn/packages/freezed)**
- 路由(**[go_router](https://pub.flutter-io.cn/packages/go_router)**)
- 本地存储
    1. **[objectbox](https://pub.flutter-io.cn/packages/objectbox)**
    2. **[shared_preferences](https://pub.flutter-io.cn/packages/shared_preferences)**
- 网络请求(**[retrofit](https://pub.flutter-io.cn/packages/retrofit)**)

# 环境配置

1. 安装 **[FVM](https://fvm.app/documentation/getting-started/installation)**
2. 配置Flutter/Dart环境变量
3. 安装 **[Fastlane](https://fastlane.tools/)** 
4. 配置iOS开发证书及描述文件

```shell 
cd ios
fastlane match_all
```

6. 安装zhiya命令工具

```shell
dart pub global activate --source path eden_command
```

7. 执行首次项目配置，用于读取项目所需git子库

```shell
eden config -g
```

# 其他的一些常用eden命令

## 打包命令

* 执行以下命令检查一些必要的库

```shell
eden publish -c
```

* 执行以下命令进行打包

```shell
eden publish 
```

> 命令期间会进行一些选择，按需选择即可<br>
> iOS/android会自动上传蒲公英分发平台<br>
> windows/macos/linux前往publishFile查看<br>
> windows/macos/linux需使用对应平台机器进行打包<br>

## 常用命令

* build_runner，通常用于生成实体/路由等

```shell
eden -b 
```

```shell
flutter pub run build_runner build --delete-conflicting-outputs
```

* app icon更新

```shell
eden create -i
```

```shell
dart run icons_launcher:create  
```

* zhiya icons 更新

```shell
eden create -z
```

> 执行命令前需更新eden_icons/iconfont文件下的文件到最新

* Flutter命令清理操作

```shell
eden -c
```

* Eden命令pub get操作

```shell
eden -g
```

* Eden命令升级

```shell
eden -u
```

* 更新/创建EdenVersion文件

```shell
eden create --eden_version

```