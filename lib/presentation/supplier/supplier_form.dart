import 'package:flutter/material.dart';
import 'package:toko_plastik_rizky/data/db_helper.dart';
import 'package:toko_plastik_rizky/domain/supplier.dart';

class SupplierForm extends StatefulWidget {
  final Supplier? supplier;
  const SupplierForm({super.key, this.supplier});

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameCtrl.text = widget.supplier!.name;
      _phoneCtrl.text = widget.supplier!.phone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final s = Supplier(id: widget.supplier?.id, name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
    if (widget.supplier == null) {
      await db.insertSupplier(s);
    } else {
      await db.updateSupplier(s);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.supplier == null ? 'Tambah Pemasok' : 'Ubah Pemasok')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Telepon (WhatsApp)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                keyboardType: TextInputType.phone,
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
