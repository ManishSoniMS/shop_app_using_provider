import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screen/screen.dart';
import 'screen/splash/splash_screen.dart';
import '/app_router.dart';
import '/helper/custom_route.dart';
import '/providers/providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (BuildContext context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (BuildContext context) => Products(),
          update: (context, auth, previousProducts) => previousProducts!
            ..update(
              auth.token,
              auth.userID,
              previousProducts.items,
            ),
        ),
        ChangeNotifierProvider<Cart>(
          /// Initializing the Provider
          /// alternate 1 ChangeNotifierProvider() ⭐ preferred
          /// when initializing the app
          create: (BuildContext context) => Cart(),

          /// alternate 2 ChangeNotifierProvider.value()
          // value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (BuildContext context) => Orders(),
          update: (context, auth, previousOrder) => previousOrder!
            ..update(auth.token, auth.userID, previousOrder.orders),
        )
      ],
      child: Consumer<Auth>(
        builder: (context, authToken, _) => MaterialApp(
          title: "Shop App",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: "Lato",
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransition(),
              TargetPlatform.iOS: CustomPageTransition(),
            }),
          ),
          home: authToken.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: authToken.tryAutoLogIn(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          onGenerateRoute: AppRouter().onGenerateRoute,
        ),
      ),
    );
  }
}

/// add error handling
