import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class ShoppingItem {
  ShoppingItem({required this.key, required this.text, required this.isEditing});

  final String key;
  String text;
  bool isEditing;
}

String _nextKey() => DateTime.now().microsecondsSinceEpoch.toString();
 
class _HomePageState extends State<HomePage> {  

final List<ShoppingItem> _items = [
  ShoppingItem(key: _nextKey(), text: "", isEditing: true),
];


  Future<void> _addItem() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add item'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('User clicked the add item button'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Column(
              children: List.generate(_items.length, (index) {
                final item = _items[index];  
                
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      key: ValueKey(item.key),
                      mainAxisAlignment: .center,
                      children: [
                        SizedBox(
                          width: 250,
                          child: TextField(
                            readOnly: !item.isEditing,
                            onChanged: (value) {
                              setState(() {
                                item.text = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "New item",
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        if (item.isEditing) ... [
                          IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            if (item.text.trim().isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Text is required for the item'),
                                  actions: <Widget>[
                                  TextButton(
                                    child: const Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                                ),
                              );
                              return;
                            }
                    
                            setState(() {
                              item.isEditing = false;
                    
                              // checks if there is already an empty item in the list 
                              // and stops it from creating more if there is
                              final emptyCount = _items.where((item) => item.text.trim().isEmpty).length;
                              if (emptyCount >= 1) {
                                return; // already have 1 empty item
                              }
                    
                              // otherwise add a new item
                              _items.add(ShoppingItem(key: _nextKey(), text: "", isEditing: true));
                            });
                          },
                        ),
                        ],
                        
                        if (!item.isEditing) ... [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                item.isEditing = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                _items.removeAt(index);
                                if (_items.isEmpty) {
                                  _items.removeAt(index);
                                }
                              });
                            },
                          ),
                        ]
                      ],
                    ),
                  );
                }), 
              ),     
            ],
          ),
        ),
      ),
      /* floatingActionButton: FloatingActionButton.extended(onPressed: _newItem, label: Text('New item', textAlign: .center, style: Theme.of(context).textTheme.bodyLarge, maxLines: 1,),), */
    );
  }
}