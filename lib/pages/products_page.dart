import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api.dart';
import '../auth_provider.dart';
import '../models.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  Future<List<Product>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Product>> _load() async {
    final auth = context.read<AuthProvider>();
    final list = await Api.products(companyId: auth.isCompany ? auth.companyId : null);
    return list.map((e) => Product.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          if (auth.isClient) ...[
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              tooltip: 'Carrito demo',
              onPressed: () async {
                try {
                  final list = await Api.products();
                  if (list.isNotEmpty) {
                    final p1 = list.first as Map<String, dynamic>;
                    await Api.addToCart((p1['id'] as num).toInt(), 1);
                    if (list.length > 1) {
                      final p2 = list[1] as Map<String, dynamic>;
                      await Api.addToCart((p2['id'] as num).toInt(), 1);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Carrito demo lleno con 1-2 productos')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay productos disponibles')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed('/cart'),
            ),
          ],
          if (auth.isCompany) IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Administrar productos',
            onPressed: () => Navigator.of(context).pushNamed('/manage-products').then((_) => setState((){_future = _load();})),
          ),
          if (auth.isAdmin) IconButton(
            icon: const Icon(Icons.apartment),
            tooltip: 'Empresas (Admin)',
            onPressed: () => Navigator.of(context).pushNamed('/admin'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async { 
              await auth.logout(); 
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) return Center(child: Text('Error: ${s.error}'));
          final items = s.data!;
          if (items.isEmpty) return const Center(child: Text('Sin productos'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(p.description ?? ''),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\$${p.price.toStringAsFixed(2)}'),
                    Text('Stock: ${p.stock}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                onTap: () async {
                  if (!auth.isClient) return;
                  try {
                    await Api.addToCart(p.id, 1);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agregado al carrito')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
