import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/screens/admins/admin_provider.dart';
import 'package:viraeshop_admin/screens/customers/customer_provider.dart';
import 'package:viraeshop_admin/screens/messages_screen/users_screen.dart';
import 'package:viraeshop_admin/screens/products/bulk_edit_provider.dart';
import 'package:viraeshop_admin/screens/products/product_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/adverts/adverts_bloc.dart';
import 'package:viraeshop_bloc/category/category_bloc.dart';
import 'package:viraeshop_bloc/customers/barrel.dart';
import 'package:viraeshop_bloc/expense/expense_bloc.dart';
import 'package:viraeshop_bloc/items/barrel.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_bloc/products/barrel.dart';
import 'package:viraeshop_bloc/return/return_bloc.dart';
import 'package:viraeshop_bloc/shops/barrel.dart';
import 'package:viraeshop_bloc/supplier_invoice/supplier_invoice_bloc.dart';
import 'package:viraeshop_bloc/suppliers/barrel.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/shops_model.dart';
import 'package:viraeshop_admin/reusable_widgets/shopping_cart.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';
import 'package:viraeshop_admin/screens/agent_products.dart';
import 'package:viraeshop_admin/screens/admins/allusers.dart';
import 'package:viraeshop_admin/screens/architect_products.dart';
import 'package:viraeshop_admin/screens/general_products.dart';
import 'package:viraeshop_admin/screens/login_page.dart';
import 'package:viraeshop_admin/screens/notification/notification_screen.dart';
import 'package:viraeshop_admin/screens/products_screen.dart';
import 'package:viraeshop_admin/screens/splash_screen.dart';
import 'package:viraeshop_api/apiCalls/admins.dart';
import 'package:viraeshop_api/apiCalls/adverts.dart';
import 'package:viraeshop_api/apiCalls/category.dart';
import 'package:viraeshop_api/apiCalls/customers.dart';
import 'package:viraeshop_api/apiCalls/expense.dart';
import 'package:viraeshop_api/apiCalls/orders.dart';
import 'package:viraeshop_api/apiCalls/products.dart';
import 'package:viraeshop_api/apiCalls/return.dart';
import 'package:viraeshop_api/apiCalls/shops.dart';
import 'package:viraeshop_api/apiCalls/supplier_invoice.dart';
import 'package:viraeshop_api/apiCalls/suppliers.dart';
import 'package:viraeshop_api/apiCalls/tokens.dart';
import 'package:viraeshop_api/apiCalls/transactions.dart';
import 'components/styles/colors.dart';
import 'components/styles/text_styles.dart';
import 'reusable_widgets/hive/cart_model.dart';
import 'screens/general_provider.dart';
import 'screens/home_screen.dart';
import 'configs/configs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/orders/order_configs.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:viraeshop_bloc/notifications/notifications_bloc.dart';
import 'package:viraeshop_api/apiCalls/notifications.dart';
import 'package:viraeshop_bloc/adverts/advert_cubit.dart';
import 'package:viraeshop_bloc/tokens/tokens_bloc.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'apmplify_configs/amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (kDebugMode) {
    print('User granted permission: ${settings.authorizationStatus}');
  }
// for ios notification priority
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
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
  await Hive.openBox('subCategory');
  await Hive.openBox('newAdmin');
  await Hive.openBox('customer');
  await Hive.openBox(productsBox);
  await Hive.openBox<Cart>('cart');
  await Hive.openBox('cartDetails');
  await Hive.openBox('shops');
  await Hive.openBox('suppliers');
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
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BulkEditProvider(),
        ),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider(
          create: (BuildContext context) => AdminBloc(
            adminCalls: AdminCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => AdvertsBloc(
            advertCalls: AdvertCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => AdvertCubit(),
        ),
        BlocProvider(
          create: (BuildContext context) => CustomersBloc(
            customerCalls: CustomerCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => CategoryBloc(
            categoryCalls: CategoryCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => ExpenseBloc(
            expenseCalls: ExpenseCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => ReturnBloc(
            returnCalls: ReturnCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => SupplierInvoiceBloc(
            supplierInvoiceCalls: SupplierInvoiceCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => OrderItemsBloc(
            orderCalls: const OrderCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => OrdersBloc(
            orderCalls: const OrderCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => ProductsBloc(
            productCalls: const ProductCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => ShopsBloc(
            shopCalls: ShopCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => SuppliersBloc(
            supplierCalls: SupplierCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => TransactionsBloc(
            transactionCalls: const TransactionCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => NotificationsBloc(
            notificationCalls: NotificationCalls(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => TokensBloc(
            tokenCalls: TokenCalls(),
          ),
        ),
      ], child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    _configureAmplify();
    super.initState();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      final storage = AmplifyStorageS3();
      await Amplify.addPlugins([auth, storage]);
      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget!),
        maxWidth: 1200,
        minWidth: 450,
        defaultScale: true,
        breakpoints: [
          const ResponsiveBreakpoint.resize(450, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(800, name: TABLET),
          const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          const ResponsiveBreakpoint.autoScale(1200, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
        ],
        background: Container(
          color: kBackgroundColor,
        ),
      ),
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          color: kBackgroundColor,
          elevation: 0.0,
          titleTextStyle: kAppBarTitleTextStyle,
        ),
      ),
      //home: const OrderProducts(),
      initialRoute: SplashScreen.path,
      routes: {
        SplashScreen.path: (context) => const SplashScreen(),
        HomeScreen.path: (context) => const HomeScreen(),
        UsersMessagesScreen.path: (context) => UsersMessagesScreen(),
        GeneralProducts.path: (context) => const GeneralProducts(),
        AgentProducts.agentProducts: (context) => const AgentProducts(),
        ArchitectProducts.architectProducts: (context) =>
            const ArchitectProducts(),
        Products.productsPath: (context) => const Products(),
        LoginPage.path: (context) => const LoginPage(),
        TransactionDetails.path: (context) => const TransactionDetails(),
        ShoppingCart.path: (context) => const ShoppingCart(),
        NotificationScreen.path: (context) => const NotificationScreen(),
        AllUserScreen.path: (context) => const AllUserScreen(),
      },
    );
  }
}
