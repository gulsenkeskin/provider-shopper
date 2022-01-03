import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_shopper/common/theme.dart';
import 'package:provider_shopper/models/cart.dart';
import 'package:provider_shopper/models/catalog.dart';
import 'package:provider_shopper/screens/catalog.dart';
import 'package:provider_shopper/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MultiProvider kullanmak, birden çok nesne sağlarken kullanışlıdır.
    return MultiProvider(
      providers: [
        //Bu örnek uygulamada, Katalog Modeli asla değişmez, bu yüzden basit bir Sağlayıcı
        // yeterli.
        Provider(create: (context) => CatalogModel()),
        //Cart Modeli, Change Notifier Sağlayıcısının kullanılmasını gerektiren bir Change Notifier olarak uygulanır. Ayrıca, Cart Modeli Katalog Modeline bağlıdır, bu nedenle bir Proxy Sağlayıcısına ihtiyaç vardır.
        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
          create: (context) => CartModel(),
          update: (context, catalog, cart) {
            if (cart == null) throw ArgumentError.notNull('cart');
            cart.catalog = catalog;
            return cart;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Provider Demo',
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/':(context)=> const Login(),
          '/catalog':(context)=> const Catalog(),
         // '/cart':(context)=> const Cart(),
        },

      ),
    );
  }
}
