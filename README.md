Simple shopping list app made in Flutter (work in progress)

## Data flow summary

```
App start
  initState -> _loadItems -> db.query("list") -> Item.map(row) -> _items -> setState -> build

Add
  FAB -> _showAddDialog -> user types -> _addItem(text)
    -> Item(text) -> db.insert -> item.setId(id) -> _items.add -> setState

Edit
  edit button -> _editingIds.add(id) -> setState (TextField becomes writable)
  check button -> _saveItem(item, newText)
    -> Item(newText).setId(id) -> db.update -> _items[index] = updated -> setState

Delete
  remove button -> _deleteItem(item)
    -> db.delete -> _items.removeWhere -> controller.dispose -> setState
```

---

## Verification steps

1. `flutter run` — app starts, spinner appears briefly, then empty list shows
2. Tap FAB, add "milk" — item appears in list
3. Tap FAB, add "eggs" — second item appears
4. Hot restart (`r` in terminal) — both items reload from DB, not lost
5. Tap edit on "milk", change to "butter", tap check — text updates
6. Hot restart — "butter" persists
7. Tap remove on "eggs" — item disappears
8. Hot restart — "eggs" is gone
9. Tap FAB, submit with blank text — nothing is added (button is a no-op while empty)
