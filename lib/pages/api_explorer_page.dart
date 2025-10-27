import 'dart:convert';
import 'package:flutter/material.dart';
import '../api.dart';

class ApiExplorerPage extends StatefulWidget {
  const ApiExplorerPage({super.key});
  @override
  State<ApiExplorerPage> createState() => _ApiExplorerPageState();
}

class _ApiExplorerPageState extends State<ApiExplorerPage> {
  String output = '';

  void _setOut(Object data) {
    setState(() {
      try { output = const JsonEncoder.withIndent('  ').convert(data); }
      catch (_) { output = data.toString(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorador de Endpoints')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              children: [
                const ListTile(title: Text('AUTH')),
                ListTile(title: const Text('POST /auth/register (Cliente)'), onTap: () async {
                  try { await Api.register('cliente.demo@demo.com', 'Demo123!'); _setOut({'ok': true}); } catch (e) { _setOut({'error': e.toString()}); }
                }),
                ListTile(title: const Text('POST /auth/login (Admin demo)'), onTap: () async {
                  try { final r = await Api.login('admin@ecom.com', 'Admin123!'); _setOut(r); } catch (e) { _setOut({'error': e.toString()}); }
                }),
                const Divider(),
                const ListTile(title: Text('PRODUCTS')),
                ListTile(title: const Text('GET /products'), onTap: () async { try { _setOut(await Api.products()); } catch (e) { _setOut({'error': e.toString()}); } }),
                ListTile(title: const Text('GET /products/{id}'), onTap: () async { try { _setOut(await Api.getProduct(1)); } catch (e) { _setOut({'error': e.toString()}); } }),
                ListTile(title: const Text('POST /products (Empresa)'), onTap: () async { try { _setOut(await Api.createProduct(name:'Demo', description:'Prod', price:10, stock:5)); } catch (e) { _setOut({'error': e.toString()}); } }),
                const Divider(),
                const ListTile(title: Text('ORDERS (Cliente)')),
                ListTile(title: const Text('GET /orders/cart'), onTap: () async { try { _setOut(await Api.getCart()); } catch (e) { _setOut({'error': e.toString()}); } }),
                ListTile(title: const Text('POST /orders/cart/items'), onTap: () async { try { _setOut(await Api.addToCart(1,1)); } catch (e) { _setOut({'error': e.toString()}); } }),
                ListTile(title: const Text('POST /orders/cart/checkout'), onTap: () async { try { _setOut(await Api.checkout()); } catch (e) { _setOut({'error': e.toString()}); } }),
                const Divider(),
                const ListTile(title: Text('COMPANIES (Admin)')),
                ListTile(title: const Text('GET /companies'), onTap: () async { try { _setOut(await Api.companies()); } catch (e) { _setOut({'error': e.toString()}); } }),
                ListTile(title: const Text('GET /companies/{id}'), onTap: () async { try { _setOut(await Api.getCompany(1)); } catch (e) { _setOut({'error': e.toString()}); } }),
                ListTile(title: const Text('POST /companies'), onTap: () async { try { _setOut(await Api.createCompany('Desde Explorer')); } catch (e) { _setOut({'error': e.toString()}); } }),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(child: SelectableText(output.isEmpty ? 'Toca un endpoint para probarlo.' : output)),
            ),
          ),
        ],
      ),
    );
  }
}
