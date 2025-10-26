import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:toko_plastik_rizky/data/db_helper.dart';
import 'package:toko_plastik_rizky/domain/product.dart';
import 'package:toko_plastik_rizky/domain/supplier.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  const ProductForm({super.key, this.product});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _supplierId;
  String? _imagePath;

  final db = DBHelper();
  List<Supplier> suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    if (widget.product != null) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _skuCtrl.text = p.sku;
      _categoryCtrl.text = p.category;
      _priceCtrl.text = p.price.toString();
      _buyPriceCtrl.text = p.buyPrice?.toString() ?? '';
      _stockCtrl.text = p.stock.toString();
      _descCtrl.text = p.description ?? '';
      _supplierId = p.supplierId;
      _imagePath = p.imagePath;
    }
  }

  Future<void> _loadSuppliers() async {
    final s = await db.getSuppliers();
    setState(() => suppliers = s);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (x == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(x.path)}';
    final saved = await File(x.path).copy('${dir.path}/$fileName');
    setState(() => _imagePath = saved.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prod = Product(
      id: widget.product?.id,
      name: _nameCtrl.text.trim(),
      sku: _skuCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0.0,
      buyPrice: double.tryParse(_buyPriceCtrl.text),
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      imagePath: _imagePath,
      supplierId: _supplierId,
      description: _descCtrl.text.trim(),
    );
    if (widget.product == null) {
      await db.insertProduct(prod);
    } else {
      await db.updateProduct(prod);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _buyPriceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: Text(widget.product == null ? 'Tambah Produk' : 'Ubah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama'), validator: (v) => (v==null||v.trim().isEmpty)?'Wajib diisi':null),
              TextFormField(controller: _skuCtrl, decoration: const InputDecoration(labelText: 'SKU')),
              TextFormField(controller: _categoryCtrl, decoration: const InputDecoration(labelText: 'Kategori')),
              TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Harga Jual'), keyboardType: TextInputType.number),
              TextFormField(controller: _buyPriceCtrl, decoration: const InputDecoration(labelText: 'Harga Beli'), keyboardType: TextInputType.number),
              TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: _supplierId,
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Tanpa pemasok')),
                  ...suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                ],
                onChanged: (v) => setState(() => _supplierId = v),
                decoration: const InputDecoration(labelText: 'Pemasok'),
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  _imagePath != null ? Image.file(File(_imagePath!), width: 100, height: 100, fit: BoxFit.cover) : const SizedBox(width: 100, height: 100, child: Icon(Icons.image)),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.upload), label: const Text('Pilih Gambar')),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Simpan'))),
            ],
          ),
        ),
      ),
    );
  }
}
