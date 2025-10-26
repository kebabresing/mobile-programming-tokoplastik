import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toko_plastik_rizky/data/db_helper.dart';
import 'package:toko_plastik_rizky/domain/supplier.dart';
import 'supplier_form.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final db = DBHelper();
  List<Supplier> suppliers = [];
  Map<int, List> supplierProducts = {};

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    final s = await db.getSuppliers();
    // also load products per supplier for counts
    final Map<int, List> map = {};
    for (final sup in s) {
      final prods = await db.getProductsBySupplier(sup.id!);
      map[sup.id!] = prods;
    }
    setState(() {
      suppliers = s;
      supplierProducts = map;
    });
  }

  Future<void> _deleteSupplier(int id) async {
    await db.deleteSupplier(id);
    await _loadSuppliers();
  }

  Future<void> _openWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/' + phone.replaceAll(RegExp(r'[^0-9]'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final sup = suppliers[index];
          final prods = supplierProducts[sup.id!] ?? [];
          return _ExpandableSupplierCard(
            supplier: sup,
            products: prods.cast(),
            onEdit: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierForm(supplier: sup)));
              _loadSuppliers();
            },
            onDelete: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Hapus Pemasok'),
                  content: const Text('Hapus pemasok ini dan semua produk terkait?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                  ],
                ),
              );
              if (ok == true) await _deleteSupplier(sup.id!);
            },
            onWhatsApp: () => _openWhatsApp(sup.phone),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierForm()));
          _loadSuppliers();
        },
      ),
    );
  }
}

class _ExpandableSupplierCard extends StatefulWidget {
  final Supplier supplier;
  final List products;
  final VoidCallback onWhatsApp;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpandableSupplierCard({required this.supplier, required this.products, required this.onWhatsApp, required this.onEdit, required this.onDelete});

  @override
  State<_ExpandableSupplierCard> createState() => _ExpandableSupplierCardState();
}

class _ExpandableSupplierCardState extends State<_ExpandableSupplierCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final Animation<double> _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  bool _open = false;

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prods = widget.products;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.grey[200], child: Text(widget.supplier.name.isNotEmpty ? widget.supplier.name[0].toUpperCase() : '?')),
            title: Text(widget.supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${widget.supplier.phone} • ${prods.length} produk'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: widget.onWhatsApp, icon: Icon(Icons.message, color: Colors.green)),
                IconButton(onPressed: widget.onEdit, icon: const Icon(Icons.edit)),
                IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
                IconButton(onPressed: _toggle, icon: AnimatedRotation(turns: _open ? 0.5 : 0.0, duration: const Duration(milliseconds: 300), child: const Icon(Icons.expand_more))),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _expand,
            axisAlignment: -1.0,
            child: FadeTransition(
              opacity: _expand,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Column(
                  children: prods.map<Widget>((p) {
                    final name = (p as dynamic).name ?? '-';
                    final sku = (p as dynamic).sku ?? '-';
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_expand),
                      child: ListTile(title: Text(name), subtitle: Text('SKU: $sku')),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
