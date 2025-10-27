import 'package:flutter/material.dart';
import '../api.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic>? cart;
  bool loading = true;
  String? error;

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final c = await Api.getCart();
      setState(() { cart = c; });
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = (cart?['items'] as List<dynamic>? ?? const []);
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : items.isEmpty
                  ? const Center(child: Text('Carrito vacío'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final it = items[i] as Map<String, dynamic>;
                        final product = it['product'] as Map<String, dynamic>?;
                        return ListTile(
                          title: Text(product?['name'] ?? 'Producto'),
                          subtitle: Text('Cant: ${it['quantity']}  •  \$${(it['unitPrice'] as num).toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              try {
                                await Api.removeCartItem((it['id'] as num).toInt());
                                await _load();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: items.isEmpty ? null : () async {
            try {
              final res = await Api.checkout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${res['message']} (ID: ${res['orderId']})')));
              }
              await _load();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Confirmar pedido'),
        ),
      ),
    );
  }
}
