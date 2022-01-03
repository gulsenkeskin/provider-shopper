
import 'package:flutter/foundation.dart';
import 'package:provider_shopper/models/catalog.dart';

class CartModel extends ChangeNotifier {
  late CatalogModel _catalog;

  //Her öğenin kimliklerini saklar.
  final List<int> _itemIds = [];

  // Güncel katalog. Sayısal kimliklerden öğeler oluşturmak için kullanılır.
  CatalogModel get catalog => _catalog;

  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;

    // Yeni kataloğun bilgi sağlaması durumunda dinleyicileri bilgilendirin
    //bir öncekinden farklı. Örneğin, bir öğenin kullanılabilirliği
    // değişmiş olabilir.
    notifyListeners();
  }

  // Sepetteki öğelerin listesi.
  List<Item> get items => _itemIds.map((id) => _catalog.getById(id)).toList();

  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);

  // Sepete [öğe] ekler. Sepeti dışarıdan değiştirmenin tek yolu budur.
  void add(Item item) {
    _itemIds.add(item.id);
    //Bu satır, [Model] 'e widget'ları yeniden oluşturması gerektiğini söyler
    notifyListeners();
  }

  void remove(Item item) {
    _itemIds.remove(item.id);
    // Bağımlı widget'lara her seferinde yeniden oluşturmalarını söylemeyi unutmayın_
    // modeli değiştiriyorsun.
    notifyListeners();
  }
}
