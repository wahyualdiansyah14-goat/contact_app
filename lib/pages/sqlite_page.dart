import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/contact.dart';

class SqlitePage extends StatefulWidget {
  const SqlitePage({super.key});

  @override
  State<SqlitePage> createState() => _SqlitePageState();
}

class _SqlitePageState extends State<SqlitePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _db = DatabaseHelper.instance;

  List<Contact> _contacts = [];
  int? _editingId; // null = mode tambah, berisi id = mode edit

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

  Future<void> _loadContacts() async {
    final data = await _db.getContacts();
    setState(() => _contacts = data);
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _editingId = null;
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

    if (_editingId == null) {
      await _db.insertContact(Contact(name: name, phone: phone));
    } else {
      await _db.updateContact(
        Contact(id: _editingId, name: name, phone: phone),
      );
    }

    setState(_clearForm);
    await _loadContacts();
  }

  void _startEdit(Contact c) {
    setState(() {
      _editingId = c.id;
      _nameController.text = c.name;
      _phoneController.text = c.phone;
    });
  }

  Future<void> _delete(int id) async {
    await _db.deleteContact(id);
    if (_editingId == id) setState(_clearForm);
    await _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontak (SQLite)')),
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
                  child: Text(_editingId == null ? 'Tambah' : 'Simpan'),
                ),
                const SizedBox(width: 8),
                if (_editingId != null)
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
                          title: Text(c.name),
                          subtitle: Text(c.phone),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _startEdit(c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(c.id!),
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
