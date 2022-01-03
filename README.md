# Provider Kullanım Örneği

![image](https://user-images.githubusercontent.com/63197899/147919173-2bed80e0-0a90-4f36-abe2-316001a214f4.png)


Yalnızca ebeveynlerinin oluşturma yöntemlerinde yeni widget'lar oluşturabildiğiniz için, içeriği değiştirmek istiyorsanız, bunun mycart'ın üst öğesinde veya üstünde yaşaması gerekir.

Flutter'da state'i , onu kullanan widget'ların üzerinde tutmak mantıklıdır.

Flutter'da içeriği her değiştiğinde yeni bir UI öğesi oluşturursunuz. MyCart.updateWith(somethingNew)(Bir yöntem çağrısı) yerine MyCart(contents)(bir kurucu) kullanırsınız. Yeni widget'ları yalnızca ebeveynlerinin oluşturma yöntemlerinde oluşturabilirsiniz

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

ChangeNotifier dinleyicilerine değişiklik bildirimi sağlayan Flutter SDK'da bulunan basit bir sınıftır. Başka bir deyişle, bir şey a ChangeNotifier ise, değişikliklerine abone olabilirsiniz. 

Sağlayıcı'da (provider), ChangeNotifier (Değişiklik Bildiricisi), uygulama durumunuzu kapsüllemenin bir yoludur. Çok basit uygulamalar için, tek bir ChangeNotifier kullanabilirsiniz. Karmaşık olanlarda, birkaç modele ve dolayısıyla birkaç ChangeNotifier'a sahip olacaksınız. (Changenotifier'ı provider ile birlikte kullanmanıza gerek yoktur, ancak çalışması kolay bir sınıftır.)

Alışveriş uygulaması örneğimizde, sepetin durumunu bir ChangeNotifier da(Değişiklik Bildiricisinde ) yönetmek istiyoruz. Onu genişleten yeni bir sınıf oluşturuyoruz, şöyle:

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
    // This call tells the widgets that are listening to this model to rebuild.
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


ChangeNotifierflutter: foundationFlutter'daki üst düzey sınıfların bir parçasıdır ve bunlara bağlı değildir. Kolayca test edilebilir ( bunun için widget testi kullanmanıza bile gerek yoktur ). Örneğin, işte basit bir birim testi CartModel:


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

ChangeNotifierProvider

ChangeNotifier Sağlayıcısını nereye koyacağımızı zaten biliyoruz: erişmesi gereken widget'ların üstünde. Cart Modeli söz konusu olduğunda, bu hem MyCart hem de mycatalog'un üstünde bir yer anlamına gelir.

Changenotifierprovider'ı gerekenden daha yükseğe yerleştirmek istemezsiniz (çünkü kapsamı kirletmek istemezsiniz). Ancak bizim durumumuzda, hem MyCart hem de MyCatalog'un üstünde bulunan tek widget MyApp'tir.

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
Yeni bir CartModel örneği oluşturan bir oluşturucu tanımladığımızı unutmayın. ChangeNotifierProvider (Bildirim Sağlayıcısını Değiştir), kesinlikle gerekli olmadıkça Sepet Modelini yeniden oluşturmayacak kadar akıllıdır. Ayrıca, örneğe artık ihtiyaç duyulmadığında CartModel'de dispose() öğesini otomatik olarak çağırır.

Birden fazla sınıf sağlamak istiyorsanız, MultiProvider kullanabilirsiniz:

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


Consumer

Artık CartModel , uygulamanızdaki widget'lara en üstteki ChangeNotifierProvider  bildirimi aracılığıyla sağlandığından, bunu kullanmaya başlayabiliriz.

Bu, Consumer widget'ı aracılığıyla yapılır.

```
return Consumer<CartModel>(
  builder: (context, cart, child) {
    return Text("Total price: ${cart.totalPrice}");
  },
);
```

Erişmek istediğimiz modelin türünü belirtmeliyiz. Bu durumda, istiyoruz CartModel, bu yüzden yazıyoruz Consumer<CartModel> generic (<CartModel>) belirtmezseniz, provider paket size yardımcı olamaz. provider türlere dayanır ve tür olmadan ne istediğinizi bilmez.


Consumer widget'ının tek gerekli argümanı oluşturucudur. Oluşturucu, ChangeNotifier  her değiştiğinde çağrılan bir işlevdir. (Başka bir deyişle, modelinizde notifyListeners() öğesini çağırdığınızda, ilgili tüm Consumer widget'larının tüm oluşturucu yöntemleri çağrılır.)

Oluşturucu üç argümanla çağrılır. Birincisi her derleme yönteminde de aldığınız context'dir.

Oluşturucu işlevinin ikinci bağımsız değişkeni, ChangeNotifier(Değişiklik Bildiricisinin) örneğidir. En başta istediğimiz buydu. Kullanıcı arayüzünün herhangi bir noktada nasıl görünmesi gerektiğini tanımlamak için modeldeki verileri kullanabilirsiniz.

Üçüncü argüman, optimizasyon için var olan child'dır. Consumer'ın altında, model değiştiğinde değişmeyen büyük bir widget alt ağacınız varsa, bunu bir kez oluşturabilir ve oluşturucudan alabilirsiniz.


```
return Consumer<CartModel>(
  builder: (context, cart, child) => Stack(
    children: [
    // // Her seferinde yeniden inşa etmeden burada SomeExpensiveWidget  kullanın.
      if (child != null) child,
      Text("Total price: ${cart.totalPrice}"),
    ],
  ),
  // Build the expensive widget here.
  child: const SomeExpensiveWidget(),
);
  ```

ConsumerWidget'larınızı ağacın mümkün olduğunca derinlerine yerleştirmek en iyi uygulamadır . Bir yerlerde bazı ayrıntılar değişti diye kullanıcı arayüzünün büyük bölümlerini yeniden oluşturmak istemezsiniz.


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


Provider.of

Bazen, kullanıcı arayüzünü değiştirmek için modeldeki verilere gerçekten ihtiyacınız yoktur, ancak yine de erişmeniz gerekir. Örneğin, Sepeti Temizle düğmesi kullanıcının her şeyi sepetten kaldırmasına izin vermek ister. Sepetin içeriğini görüntülemesine gerek yok, sadece clear () yöntemini çağırması gerekiyor.

Bunun için Consumer<Cart Model> kullanabiliriz, ancak bu israf olur. Çerçeveden (framework) yeniden oluşturulması gerekmeyen bir widget'ı yeniden oluşturmasını istiyoruz.

Bu kullanım durumu için Provider.of(Sağlayıcıyı) kullanabiliriz -> listen parametresi false olarak ayarlandığında.

  `Provider.of<CartModel>(context, listen: false).removeAll();`

Yukarıdaki satırı bir build methodunda kullanmak, notifyListeners çağrıldığında bu pencere öğesinin yeniden oluşturulmasına neden olmaz.
 
 resource: <https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple> 
