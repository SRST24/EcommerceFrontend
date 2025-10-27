import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api.dart';
import '../auth_provider.dart';
import '../models.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});
  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  Future<List<Product>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Product>> _load() async {
    final auth = context.read<AuthProvider>();
    final list = await Api.products(companyId: auth.companyId);
    return list.map((e) => Product.fromJson(e)).toList();
  }

  void _openEditor({Product? product}) {
    showDialog(context: context, builder: (ctx) {
      final nameCtrl = TextEditingController(text: product?.name ?? '');
      final descCtrl = TextEditingController(text: product?.description ?? '');
      final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
      final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
      bool saving = false;
      return StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: Text(product == null ? 'Nuevo producto' : 'Editar producto'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
                TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: saving ? null : () async {
                setS(() => saving = true);
                try {
                  final name = nameCtrl.text.trim();
                  final desc = descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                  final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                  if (product == null) {
                    await Api.createProduct(name: name, description: desc, price: price, stock: stock);
                  } else {
                    await Api.updateProduct(product.id, name: name, description: desc, price: price, stock: stock);
                  }
                  if (context.mounted) Navigator.pop(ctx);
                  setState(() { _future = _load(); });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                } finally {
                  setS(() => saving = false);
                }
              },
              child: Text(saving ? 'Guardando...' : 'Guardar'),
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis productos (Empresa)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEditor(),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Producto demo',
            onPressed: () async {
              try {
                await Api.createProduct(
                  name: 'Producto Demo',
                  description: 'Creado desde botón demo',
                  price: 9.99,
                  stock: 50,
                );
                if (mounted) setState(() { _future = _load(); });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto demo creado')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          )
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
          if (items.isEmpty) return const Center(child: Text('Aún no tienes productos'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('\$${p.price.toStringAsFixed(2)}  •  Stock: ${p.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEditor(product: p)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                      try {
                        await Api.deleteProduct(p.id);
                        setState(() { _future = _load(); });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
