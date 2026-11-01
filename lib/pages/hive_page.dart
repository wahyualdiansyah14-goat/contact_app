import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HivePage extends StatefulWidget {
  const HivePage({super.key});

  @override
  State<HivePage> createState() => _HivePageState();
}

class _HivePageState extends State<HivePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final Box _box = Hive.box('contacts_box');

  List<Map<String, dynamic>> _contacts = [];
  dynamic _editingKey; // null = mode tambah, berisi key = mode edit

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // READ: ambil semua data dari box
  void _loadContacts() {
    final data = _box.keys.map((key) {
      final value = Map<String, dynamic>.from(_box.get(key));
      value['key'] = key;
      return value;
    }).toList();
    setState(() => _contacts = data.reversed.toList());
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _editingKey = null;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan nomor tidak boleh kosong')),
      );
      return;
    }

    final data = {'name': name, 'phone': phone};

    if (_editingKey == null) {
      await _box.add(data); // CREATE
    } else {
      await _box.put(_editingKey, data); // UPDATE
    }

    setState(_clearForm);
    _loadContacts();
  }

  void _startEdit(Map<String, dynamic> c) {
    setState(() {
      _editingKey = c['key'];
      _nameController.text = c['name'];
      _phoneController.text = c['phone'];
    });
  }

  Future<void> _delete(dynamic key) async {
    await _box.delete(key); // DELETE
    if (_editingKey == key) setState(_clearForm);
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontak (Hive)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _save,
                  child: Text(_editingKey == null ? 'Tambah' : 'Simpan'),
                ),
                const SizedBox(width: 8),
                if (_editingKey != null)
                  TextButton(
                    onPressed: () => setState(_clearForm),
                    child: const Text('Batal'),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(child: Text('Belum ada kontak'))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, i) {
                        final c = _contacts[i];
                        return ListTile(
                          title: Text(c['name']),
                          subtitle: Text(c['phone']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _startEdit(c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(c['key']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
