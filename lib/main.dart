import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/products_page.dart';
import 'pages/cart_page.dart';
import 'pages/manage_products_page.dart';
import 'pages/admin_page.dart';
import 'pages/api_explorer_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce Flutter',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/products': (_) => const ProductsPage(),
        '/cart': (_) => const CartPage(),
        '/manage-products': (_) => const ManageProductsPage(),
        '/admin': (_) => const AdminPage(),
        '/explorer': (_) => const ApiExplorerPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
