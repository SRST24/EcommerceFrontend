import 'package:flutter/material.dart';
import '../api.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final list = await Api.companies();
    return list.cast<Map<String, dynamic>>();
  }

  void _openCompanyEditor({Map<String, dynamic>? company}) {
    showDialog(
        context: context,
        builder: (ctx) {
          final nameCtrl = TextEditingController(text: company?['name'] ?? '');
          bool saving = false;
          return StatefulBuilder(builder: (ctx, setS) {
            return AlertDialog(
              title: Text(company == null ? 'Nueva empresa' : 'Editar empresa'),
              content: TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setS(() => saving = true);
                          try {
                            if (company == null) {
                              await Api.createCompany(nameCtrl.text.trim());
                            } else {
                              await Api.updateCompany(
                                  (company['id'] as num).toInt(),
                                  nameCtrl.text.trim());
                            }
                            if (context.mounted) Navigator.pop(ctx);
                            setState(() {
                              _future = _load();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
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

  void _openCreateCompanyUser(int companyId) {
    showDialog(
        context: context,
        builder: (ctx) {
          final emailCtrl = TextEditingController();
          final passCtrl = TextEditingController();
          bool saving = false;
          return StatefulBuilder(builder: (ctx, setS) {
            return AlertDialog(
              title: const Text('Crear usuario Empresa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email')),
                  TextField(
                      controller: passCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setS(() => saving = true);
                          try {
                            await Api.createCompanyUser(companyId,
                                emailCtrl.text.trim(), passCtrl.text);
                            if (context.mounted) Navigator.pop(ctx);
                            setState(() {
                              _future = _load();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          } finally {
                            setS(() => saving = false);
                          }
                        },
                  child: Text(saving ? 'Creando...' : 'Crear'),
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
        title: const Text('Empresas (Admin)'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_business),
              onPressed: () => _openCompanyEditor()),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (s.hasError) return Center(child: Text('Error: ${s.error}'));
          final items = s.data!;
          if (items.isEmpty) return const Center(child: Text('Sin empresas'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final comp = items[i];
              return ListTile(
                title: Text(comp['name']?.toString() ?? 'Empresa'),
                subtitle: Text('ID: ${comp['id']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.person_add),
                        tooltip: 'Crear usuario Empresa',
                        onPressed: () => _openCreateCompanyUser(
                            (comp['id'] as num).toInt())),
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openCompanyEditor(company: comp)),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            await Api.deleteCompany(
                                (comp['id'] as num).toInt());
                            setState(() {
                              _future = _load();
                            });
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')));
                            }
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
