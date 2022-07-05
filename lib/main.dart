import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:viraeshop_admin/animation_testing.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/shops_model.dart';
import 'package:viraeshop_admin/reusable_widgets/shopping_cart.dart';
import 'package:viraeshop_admin/reusable_widgets/transaction_details.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';
import 'package:viraeshop_admin/screens/advert/advert_screen.dart';
import 'package:viraeshop_admin/screens/agent_products.dart';
import 'package:viraeshop_admin/screens/architect_products.dart';
import 'package:viraeshop_admin/screens/bloc/product_bloc.dart';
import 'package:viraeshop_admin/screens/customers/customer_request.dart';
import 'package:viraeshop_admin/screens/general_products.dart';
import 'package:viraeshop_admin/screens/login_page.dart';
import 'package:viraeshop_admin/screens/messages_screen/messages.dart';
import 'package:viraeshop_admin/screens/non_inventory_product.dart';
import 'package:viraeshop_admin/screens/notification/notification_screen.dart';
import 'package:viraeshop_admin/screens/orders/order_info.dart';
import 'package:viraeshop_admin/screens/products_screen.dart';
import 'package:viraeshop_admin/screens/shops.dart';
import 'package:viraeshop_admin/screens/splash_screen.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'components/styles/colors.dart';
import 'components/styles/text_styles.dart';
import 'reusable_widgets/hive/cart_model.dart';
import 'reusable_widgets/non_inventory_items.dart';
import 'screens/done_screen.dart';
import 'screens/general_provider.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'configs/configs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/orders/order_configs.dart';
import 'screens/transaction_screen.dart';
import 'screens/user_transaction_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  if (messaging.isSupported()) {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
// for ios notification priority
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // channel.description,
              icon: android.smallIcon,
              // other properties...
            ),
          ));
    }
  });
  Hive.registerAdapter<Cart>(CartAdapter());
  Hive.registerAdapter<Shop>(ShopAdapter());
  await Hive.initFlutter();
  await Hive.openBox('adminInfo');
  await Hive.openBox('category');
  await Hive.openBox('newAdmin');
  await Hive.openBox('customer');
  await Hive.openBox(productsBox);
  await Hive.openBox<Cart>('cart');
  await Hive.openBox('cartDetails');
  await Hive.openBox('shops');
  await Hive.openBox<Shop>('shopList');
  await Hive.openBox('images');
  await Hive.openBox('orderItems');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Configs(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderConfigs(),
        ),
        ChangeNotifierProvider(
          create: (context) => AdsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => GeneralProvider(),
        ),
      ],
      child: BlocProvider(
          create: (BuildContext context) => ProductBloc(GeneralCrud()),
          child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget!),
        maxWidth: 1200,
        minWidth: 450,
        defaultScale: true,
        breakpoints: [
          ResponsiveBreakpoint.resize(450, name: MOBILE),
          ResponsiveBreakpoint.autoScale(800, name: TABLET),
          ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          ResponsiveBreakpoint.autoScale(1200, name: DESKTOP),
          ResponsiveBreakpoint.autoScale(2460, name: "4K"),
        ],
        background: Container(
          color: kBackgroundColor,
        ),
      ),
      theme: ThemeData.light().copyWith(
        backgroundColor: kBackgroundColor,
        appBarTheme: AppBarTheme(
          color: kBackgroundColor,
          elevation: 0.0,
          titleTextStyle: kAppBarTitleTextStyle,
        ),
      ),
      //home: AnimationTest(),
      initialRoute: SplashScreen.path,
      routes: {
        SplashScreen.path: (context) => SplashScreen(),
        HomeScreen.path: (context) => HomeScreen(),
        GeneralProducts.path: (context) => GeneralProducts(),
        AgentProducts.agentProducts: (context) => AgentProducts(),
        ArchitectProducts.architectProducts: (context) => ArchitectProducts(),
        Products.productsPath: (context) => Products(),
        LoginPage.path: (context) => LoginPage(),
        TransactionDetails.path: (context) => TransactionDetails(),
        ShoppingCart.path: (context) => ShoppingCart(),
        NotificationScreen.path: (context) => NotificationScreen(),
      },
    );
  }
}
