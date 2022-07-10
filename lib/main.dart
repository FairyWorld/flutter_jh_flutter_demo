// ignore_for_file: unused_import, unnecessary_import

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flustars/flustars.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'package:jhtoast/jhtoast.dart';
import 'jh_common/utils/jh_color_utils.dart';
import 'jh_common/utils/jh_device_utils.dart';
import 'jh_common/utils/jh_storage_utils.dart';
import 'jh_common/utils/jh_screen_utils.dart';
import 'project/configs/project_config.dart';
import 'project/provider/theme_provider.dart';
import 'project/routes/not_found_page.dart';
import 'project/routes/routes.dart';
import 'project/routes/routes_old.dart' as luyou;
import 'project/base_tabbar.dart';
import 'project/login/pages/login_page.dart';
import 'project/new_feature/new_feature_page.dart';
import 'project/model/user_model.dart';

//void main() => runApp(MyApp());

void main() async {
//  debugProfileBuildsEnabled = true;
//  debugPaintLayerBordersEnabled = true;
//  debugProfilePaintsEnabled = true;
//  debugRepaintRainbowEnabled = true;

  /// 确保初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  /// sp初始化
  await SpUtil.getInstance();

  runApp(MyApp());

  if (Platform.isAndroid) {
    print("Android");
  } else if (Platform.isIOS) {
    print("iOS");
  }

  // 透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _currentVersion = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    LogUtils.init();
    HttpUtils.initDio();
    Routes.initRoutes();
    _getPackageInfo(); // 获取设备信息
  }

  @override
  Widget build(BuildContext context) {
    JhScreenUtils.init(context);

    final Widget app = MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (_, ThemeProvider provider, __) {
            return _buildMaterialApp(provider);
          },
        ));

    return OKToast(
//          dismissOtherOnShow: true,
      child: app,
    );
  }

  Widget _buildMaterialApp(ThemeProvider provider) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 多主题切换
      theme: provider.getThemeData(),
      darkTheme: provider.getThemeData(isDarkMode: true),
      themeMode: provider.getThemeMode(),
      // 单一主题
      // theme: ThemeData(
      //   // primarySwatch包含了primaryColor
      //   primarySwatch: JhColorUtils.materialColor(KColors.kThemeColor),
      //   // 主色
      //   primaryColor: KColors.kThemeColor,
      // ),
      home: _switchRootWidget(),
      // 路由
      onGenerateRoute: Routes.router.generator,
      onUnknownRoute: (RouteSettings settings) => MaterialPageRoute(builder: (context) => const NotFoundPage()),
      //        locale: Locale('en','US'),
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        const FallbackCupertinoLocalisationsDelegate()
      ],
      supportedLocales: [
        Locale('zh', 'CN'),
//        Locale('en', 'US'),
      ],
    );
  }

  void _getPackageInfo() async {
    String version = await JhDeviceUtils.version();
    JhAESStorageUtils.saveString(kUserDefault_LastVersion, version);
    print('app version =  $version');
    setState(() {
      _currentVersion = version;
    });
  }

  Widget _switchRootWidget() {
    var lastVersion = JhAESStorageUtils.getString(kUserDefault_LastVersion);
//    print('lastVersion 版本号：$lastVersion');
    if (lastVersion == null || lastVersion == '') {
//      print('首次安装');
      return NewFeaturePage();
    } else {
//      print(oldVersion.compareTo(_currentVersion)); // 字符串 比较大小, 0:相同、1:大于、-1:小于
      if (lastVersion.compareTo(_currentVersion) < 0) {
//        print('新版本安装');
        return NewFeaturePage();
      } else {
//        print('正常启动');
//        userModel model =
//            SpUtil.getObj(kUserDefault_UserInfo, (v) => userModel.fromJson(v));
        var modelJson = JhAESStorageUtils.getModel(kUserDefault_UserInfo);
        if (modelJson != null) {
          UserModel model = UserModel.fromJson(modelJson);
          print('本地取出的 userName:' + model.userName!);
          return BaseTabBar();
        } else {
          return LoginPage();
        }
      }
    }
  }
}

class FallbackCupertinoLocalisationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) => DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}

//void main() => runApp(MyApp());
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      title: 'Welcome to Flutter',
//      home: new Scaffold(
//        appBar: new AppBar(
//          title: new Text('Welcome to Flutter'),
//        ),
//        body: new Center(
//          child: new Text('Hello World'),
//        ),
//      ),
//    );
//  }
//}
