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
    //Ba??lama.select() y??ntemi, bir modelin * par??as??ndaki* de??i??iklikleri dinlemenizi sa??lar. ??lgilendi??iniz par??ay?? "se??en" (yani d??nd??ren) bir i??lev tan??mlars??n??z ve modelin belirli bir k??sm?? de??i??medik??e sa??lay??c?? paketi bu widget'?? yeniden olu??turmaz. Bu ??nemli performans iyile??tirmelerine yol a??abilir.
    // Bu ??nemli performans iyile??tirmelerine yol a??abilir.

    var isInCart = context.select<CartModel, bool>(
      // Burada, yaln??zca [????enin] sepetin i??inde olup olmad??????yla ilgileniyoruz.
      (cart) => cart.items.contains(item),
    );

    return TextButton(
      onPressed: isInCart
          ? null
          : () {
              //????e sepette de??ilse, kullan??c??n??n eklemesine izin veririz. Ba??lam kullan??yoruz.read() burada, ????nk?? kullan??c?? d????meye her dokundu??unda geri arama y??r??t??l??r. Ba??ka bir deyi??le, yap?? y??nteminin d??????nda y??r??t??l??r.
              var cart = context.read<CartModel>();
              cart.add(item);
            },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).primaryColor;
          }
          return null; // Widget'??n varsay??lan??na ertele.
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
