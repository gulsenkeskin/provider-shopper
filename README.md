# Provider Kullanım Örneği

![image](https://user-images.githubusercontent.com/63197899/147919173-2bed80e0-0a90-4f36-abe2-316001a214f4.png)


Yalnızca ebeveynlerinin oluşturma yöntemlerinde yeni widget'lar oluşturabildiğiniz için, içeriği değiştirmek istiyorsanız, bunun mycart'ın üst öğesinde veya üstünde yaşaması gerekir.

Flutter'da state'i , onu kullanan widget'ların üzerinde tutmak mantıklıdır.

Flutter'da içeriği her değiştirdiğinizde yeni bir UI öğesi oluşturursunuz. MyCart.updateWith(somethingNew)(Bir yöntem çağrısı) yerine MyCart(contents)(bir kurucu) kullanırsınız. Yeni widget'ları yalnızca ebeveynlerinin oluşturma yöntemlerinde oluşturabilirsiniz.

```
void myTapHandler(BuildContext context) {
  var cartModel = somehowGetMyCartModel(context);
  cartModel.add(item);
}

Widget build(BuildContext context) {
  var cartModel = somehowGetMyCartModel(context);
  return SomeWidget(
     // Sepetin mevcut durumunu kullanarak kullanıcı arayüzünü bir kez oluşturun.   
     // ···
  );
}
```


## ChangeNotifier

ChangeNotifier dinleyicilerine değişiklik bildirimi sağlayan Flutter SDK'da bulunan basit bir sınıftır. Başka bir deyişle, bir şey  ChangeNotifier ise, değişikliklerine abone olabilirsiniz. 

Provider'da , ChangeNotifier (Değişiklik Bildiricisi), uygulama durumunuzu kapsüllemenin bir yoludur. Çok basit uygulamalar için, tek bir ChangeNotifier kullanabilirsiniz. Karmaşık olanlarda, birkaç modele ve dolayısıyla birkaç ChangeNotifier'a sahip olacaksınız. (Changenotifier'ı provider ile birlikte kullanmanıza gerek yoktur, ancak çalışması kolay bir sınıftır.)

Alışveriş uygulaması örneğimizde, sepetin durumunu bir ChangeNotifier'da (Değişiklik Bildiricisinde) yönetmek istiyoruz. Onu genişleten yeni bir sınıf oluşturuyoruz, şöyle:

```
class CartModel extends ChangeNotifier {
  final List<Item> _items = [];
 
 //Sepetteki öğelerin değiştirilemez bir görünümü.
  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);
  
 //Tüm kalemlerin geçerli toplam fiyatı (tüm kalemlerin 42 ABD Doları olduğu varsayılarak)

  int get totalPrice => _items.length * 42;

  // cart from the outside.
  void add(Item item) {
    _items.add(item);
    // Bu çağrı, bu modeli dinleyen widget'lara yeniden oluşturmalarını söyler.
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    // Bu çağrı, bu modeli dinleyen widget'lara yeniden oluşturmalarını söyler.
    notifyListeners();
  }
}
```

ChangeNotifier'a özel olan tek kod notifyListeners() dır. Model, uygulamanızın kullanıcı arayüzünü değiştirebilecek şekilde her değiştiğinde bu yöntemi çağırın. Diğer her şey CartModel'in kendisi ve iş mantığıdır.


ChangeNotifier, flutter:foundation'ın bir parçasıdır ve Flutter'daki herhangi bir üst düzey sınıfa bağlı değildir. Kolayca test edilebilir (bunun için widget testi kullanmanıza bile gerek yoktur). Örneğin, CartModel'in basit bir birim testi:


```
test('adding item increases total cost', () {
  final cart = CartModel();
  final startingPrice = cart.totalPrice;
  cart.addListener(() {
    expect(cart.totalPrice, greaterThan(startingPrice));
  });
  cart.add(Item('Dash'));
});
```

## ChangeNotifierProvider

ChangeNotifierProvider, soyundan gelenlere bir ChangeNotifier örneği sağlayan pencere öğesidir. Provider paketinden gelir.

ChangeNotifierProvider:'ı ona erişmesi gereken widget'ların üzerine nereye koyacağımızı zaten biliyoruz. CartModel söz konusu olduğunda bu, hem MyCart hem de MyCatalog'un üzerinde bir yer anlamına gelir.

ChangeNotifierProvider'ı gereğinden yükseğe yerleştirmek istemezsiniz (çünkü kapsamı kirletmek istemezsiniz). Ancak bizim durumumuzda hem MyCart'ın hem de MyCatalog'un üstünde olan tek pencere öğesi MyApp'dir.

```
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}
```
CartModel'in yeni bir örneğini oluşturan bir oluşturucu tanımladığımızı unutmayın. ChangeNotifierProvider, kesinlikle gerekli olmadıkça CartModel'i yeniden oluşturmayacak kadar akıllıdır. Ayrıca, örneğe artık ihtiyaç duyulmadığında CartModel'de Dispose() işlevini otomatik olarak çağırır.

Birden fazla sınıf sağlamak istiyorsanız, MultiProvider'ı kullanabilirsiniz:

```
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        Provider(create: (context) => SomeOtherClass()),
      ],
      child: const MyApp(),
    ),
  );
}
```


## Consumer

Artık CartModel , uygulamanızdaki widget'lara en üstteki ChangeNotifierProvider  bildirimi aracılığıyla sağlandığından, bunu kullanmaya başlayabiliriz.

Bu, Consumer widget'ı aracılığıyla yapılır.

```
return Consumer<CartModel>(
  builder: (context, cart, child) {
    return Text("Total price: ${cart.totalPrice}");
  },
);
```

Erişmek istediğimiz modelin türünü belirtmeliyiz. Bu durumda, CartModel'i istiyoruz, bu yüzden Consumer<CartModel> yazıyoruz. Jenerik (<CartModel>) belirtmezseniz, sağlayıcı paketi size yardımcı olamaz. sağlayıcı türlere dayanır ve tür olmadan ne istediğinizi bilmez.

Tüketici widget'ının tek gerekli argümanı oluşturucudur. Oluşturucu, ChangeNotifier değiştiğinde çağrılan bir işlevdir. (Başka bir deyişle, modelinizde notifyListeners() öğesini çağırdığınızda, karşılık gelen tüm Tüketici pencere öğelerinin tüm oluşturucu yöntemleri çağrılır.)

Oluşturucu üç argümanla çağrılır. İlki, her derleme yönteminde de aldığınız contextir (bağlamdır).
  
Oluşturucu işlevinin ikinci argümanı, ChangeNotifier örneğidir. En başta istediğimiz buydu. Herhangi bir noktada kullanıcı arayüzünün nasıl görünmesi gerektiğini tanımlamak için modeldeki verileri kullanabilirsiniz.

Üçüncü argüman, optimizasyon için orada olan child'dır. Consumer'ınızın altında model değiştiğinde değişmeyen büyük bir widget alt ağacınız varsa, onu bir kez oluşturabilir ve oluşturucudan geçirebilirsiniz.


```
return Consumer<CartModel>(
  builder: (context, cart, child) => Stack(
    children: [
      // Her seferinde yeniden inşa etmeden burada SomeExpensiveWidget  kullanın.
      if (child != null) child,
      Text("Total price: ${cart.totalPrice}"),
    ],
  ),
  // Build the expensive widget here.
  child: const SomeExpensiveWidget(),
);
  ```

Consumer widget'larınızı ağacın mümkün olduğunca derinlerine yerleştirmek en iyi uygulamadır. Bazı ayrıntılar değişti diye kullanıcı arayüzünün büyük bölümlerini yeniden oluşturmak istemezsiniz.

  ```
return Consumer<CartModel>(
  builder: (context, cart, child) {
    return HumongousWidget(
      // ...
      child: AnotherMonstrousWidget(
        // ...
        child: Text('Total price: ${cart.totalPrice}'),
      ),
    );
  },
);
```


Bunun yerine:

  ```
//Bunu kullan
return HumongousWidget(
  // ...
  child: AnotherMonstrousWidget(
    // ...
    child: Consumer<CartModel>(
      builder: (context, cart, child) {
        return Text('Total price: ${cart.totalPrice}');
      },
    ),
  ),
);
```


## Provider.of

Bazen, kullanıcı arayüzünü değiştirmek için modeldeki verilere gerçekten ihtiyacınız olmaz, ancak yine de ona erişmeniz gerekir. Örneğin, ClearCart düğmesi, kullanıcının sepetteki her şeyi kaldırmasına izin vermek ister. Sepetin içeriğini görüntülemesi gerekmez, sadece clear() yöntemini çağırması gerekir.

Bunun için Consumer<Cart Model> kullanabiliriz, ancak bu israf olur. Çerçeveden (framework) yeniden oluşturulması gerekmeyen bir widget'ı yeniden oluşturmasını istiyoruz.

Bu kullanım durumu için, listen parametresi false olarak ayarlanmış olarak Provider.of'u kullanabiliriz.
  
  `Provider.of<CartModel>(context, listen: false).removeAll();`

Yukarıdaki satırı bir build methodunda kullanmak, notifyListeners çağrıldığında bu pencere öğesinin yeniden oluşturulmasına neden olmaz.
 
 resource: <https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple> 
