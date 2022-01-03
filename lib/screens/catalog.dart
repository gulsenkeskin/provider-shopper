import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_shopper/models/cart.dart';
import 'package:provider_shopper/models/catalog.dart';

class Catalog extends StatelessWidget {
  const Catalog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AppBar(),
          const SliverToBoxAdapter(
              child: SizedBox(
            height: 12,
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => _ListItem(index)),
          )
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  //const _AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        'Catalog',
        style: Theme.of(context).textTheme.headline1,
      ),
      floating: true,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/cart'),
          icon: const Icon(Icons.shopping_cart),
        )
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  final int index;
  const _ListItem(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var item = context.select<CatalogModel, Item>(
      (catalog) => catalog.getByPosition(index),
    );

    var textTheme = Theme.of(context).textTheme.headline6;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 48,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: item.color,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(item.name, style: textTheme),
            ),
            const SizedBox(
              width: 24,
            ),
            _AddButton(item: item),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Item item;
  const _AddButton({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Bağlama.select() yöntemi, bir modelin * parçasındaki* değişiklikleri dinlemenizi sağlar. İlgilendiğiniz parçayı "seçen" (yani döndüren) bir işlev tanımlarsınız ve modelin belirli bir kısmı değişmedikçe sağlayıcı paketi bu widget'ı yeniden oluşturmaz. Bu önemli performans iyileştirmelerine yol açabilir.
    // Bu önemli performans iyileştirmelerine yol açabilir.

    var isInCart = context.select<CartModel, bool>(
      // Burada, yalnızca [öğenin] sepetin içinde olup olmadığıyla ilgileniyoruz.
      (cart) => cart.items.contains(item),
    );

    return TextButton(
      onPressed: isInCart
          ? null
          : () {
              //Öğe sepette değilse, kullanıcının eklemesine izin veririz. Bağlam kullanıyoruz.read() burada, çünkü kullanıcı düğmeye her dokunduğunda geri arama yürütülür. Başka bir deyişle, yapı yönteminin dışında yürütülür.
              var cart = context.read<CartModel>();
              cart.add(item);
            },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).primaryColor;
          }
          return null; // Widget'ın varsayılanına ertele.
        }),
      ),
      child: isInCart
          ? const Icon(
              Icons.check,
              semanticLabel: 'ADDED',
            )
          : const Text('ADD'),
    );
  }
}
