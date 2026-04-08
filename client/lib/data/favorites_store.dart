import 'package:flutter/foundation.dart';

class FavoritesStore extends ChangeNotifier {
  final Set<String> _ids = {};

  List<String> get ids => _ids.toList(growable: false);
  bool isSaved(String id) => _ids.contains(id);

  void toggle(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
  }

  void remove(String id) {
    _ids.remove(id);
    notifyListeners();
  }

  void clear() {
    _ids.clear();
    notifyListeners();
  }
}
