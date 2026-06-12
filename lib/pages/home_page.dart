import "package:flutter/material.dart";
import "package:shoppinglist_app/database_helper.dart";
import "package:shoppinglist_app/models/item.dart";



class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {


final DatabaseHelper _db = DatabaseHelper();
List<Item> _items = [];
final Set<int?> _editingIds = {};
final Map<int?, TextEditingController> _controllers = {};
bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadItems() async {
    final rows = await _db.query("list");
    setState(() {
      _items = rows.map((row) => Item.map(row)).toList();
      for (final item in _items) {
        _controllers[item.id] = TextEditingController(text: item.text);
      }
      _loading = false;
    });
  }

  Future<void> _addItem(String text) async {
    final item = Item(text);
    final id = await _db.insert("list", item);
    item.setId(id);
    setState(() {
      _items.add(item);
      _controllers[item.id] = TextEditingController(text: item.text);
    });
  }

  Future<void> _saveItem(Item item, String newText) async {
    final updated = Item(newText);
    updated.setId(item.id!);
    await _db.update("list", updated);
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      _items[index] = updated;
      _controllers[item.id]!.text = newText;
      _editingIds.remove(item.id);
    });
  }

  Future<void> _deleteItem(Item item) async {
    await _db.delete("list", item);
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
      _controllers[item.id]?.dispose();
      _controllers.remove(item.id);
      _editingIds.remove(item.id);
    });
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Item text'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
              _addItem(text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEmptyError() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Text is required for the item'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Center(
              child: Column(
                children: [
                  Column(
                    children: _items.map((item) {
                      final isEditing = _editingIds.contains(item.id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          key: ValueKey(item.id),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextField(
                                readOnly: !isEditing,
                                controller: _controllers[item.id],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Item',
                                ),
                              ),
                            ),
                            const SizedBox(width: 25),
                            if (isEditing) ...[
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  final text = _controllers[item.id]!.text.trim();
                                  if (text.isEmpty) {
                                    _showEmptyError();
                                    return;
                                  }
                                  _saveItem(item, text);
                                },
                              ),
                            ],
                            if (!isEditing) ...[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    setState(() => _editingIds.add(item.id)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _deleteItem(item),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddDialog,
      child: const Icon(Icons.add),
    ),
  );
  }
}