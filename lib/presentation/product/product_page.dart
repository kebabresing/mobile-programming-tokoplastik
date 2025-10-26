import 'dart:io';
import 'package:flutter/material.dart';
import 'package:toko_plastik_rizky/data/db_helper.dart';
import 'package:toko_plastik_rizky/domain/product.dart';
import 'product_form.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final db = DBHelper();
  List<Product> products = [];
  Map<int, String> supplierNames = {};
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await db.getProducts();
    // load supplier names
    final names = <int, String>{};
    for (final prod in p) {
      if (prod.supplierId != null && !names.containsKey(prod.supplierId)) {
        final s = await db.getSupplierById(prod.supplierId!);
        if (s != null) names[prod.supplierId!] = s.name;
      }
    }
    setState(() {
      products = p;
      supplierNames = names;
    });
  }

  Future<void> _delete(int id) async {
    await db.deleteProduct(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: products.isEmpty
            ? const Center(key: ValueKey('empty'), child: Text('Belum ada produk. Tekan + untuk menambah.'))
            : Padding(
                key: const ValueKey('grid'),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280, // cap card width on large/tablet screens
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    // use more square-ish cards so they don't become too tall on wide screens
                    childAspectRatio: 1.0,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final prod = products[index];
                    final selected = prod.id != null && _selected.contains(prod.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (prod.id != null) {
                            if (_selected.contains(prod.id)) {
                              _selected.remove(prod.id);
                            } else {
                              _selected.add(prod.id!);
                            }
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.all(selected ? 6 : 0),
                        child: Material(
                          elevation: selected ? 8 : 2,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.06) : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: AnimatedCrossFade(
                                    firstChild: Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: Icon(Icons.image, size: 48)),
                                    ),
                                    secondChild: prod.imagePath != null
                                        ? Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            color: Colors.grey[200],
                                            child: Image.file(File(prod.imagePath!), fit: BoxFit.cover),
                                          )
                                        : const SizedBox.shrink(),
                                    crossFadeState: prod.imagePath != null ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Rp ${prod.price.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                      const SizedBox(height: 4),
                                      Text('Stok: ${prod.stock} • ${prod.supplierId != null ? supplierNames[prod.supplierId!] ?? '-' : 'Tanpa pemasok'}', style: const TextStyle(fontSize: 12)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => ProductForm(product: prod))); _load(); }, icon: const Icon(Icons.edit)),
                                          IconButton(onPressed: () async { await _delete(prod.id!); }, icon: const Icon(Icons.delete, color: Colors.red)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => ProductForm()));
          _load();
        },
      ),
    );
  }
}
