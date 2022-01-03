import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Catalog extends StatelessWidget {
  const Catalog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [],
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
