import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_shopper/models/cart.dart';

class Cart extends StatelessWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: Theme.of(context).textTheme.headline1,
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.yellow,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _CartList(),
              ),
            ),
            const Divider(height: 4,color: Colors.black,),
            _CartTotal()
          ],
        ),
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  //const _CartList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var itemNameStyle=Theme.of(context).textTheme.headline6;
    // Bu, Cart Modelinin geçerli durumunu alır ve ayrıca CartModel dinleyicileri bilgilendirdiğinde (başka bir deyişle değiştiğinde) Flutter'a bu widget'ı yeniden oluşturmasını söyler.

    var cart = context.watch<CartModel>();

    return ListView.builder(
        itemBuilder: (context,index)=> ListTile(
          leading: const Icon(Icons.done),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: (){
              cart.remove(cart.items[index]);
            },
          ),
          title: Text(
            cart.items[index].name,
            style: itemNameStyle,
          ),
        ),
        itemCount: cart.items.length,
    );
  }
}

class _CartTotal extends StatelessWidget {
  //const _CartTotal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hugeStyle=Theme.of(context).textTheme.headline1!.copyWith(fontSize: 48);
    return SizedBox(
      height: 200,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Bir modelin değişikliğini dinlemenin başka bir yolu da Consumer widget'ını eklemektir. Bu widget otomatik olarak CartModel'idinleyecek ve her değişiklikte oluşturucusunu yeniden çalıştıracaktır. Önemli olan, bu oluşturma yöntemindeki widget'ların geri kalanını yeniden oluşturmamasıdır.
            Consumer<CartModel>(
                builder: (context, cart, child) =>
                    Text('\$${cart.totalPrice}', style: hugeStyle)),
            const SizedBox(width: 24),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buying not supported yet.')));
              },
              style: TextButton.styleFrom(primary: Colors.white),
              child: const Text('BUY'),
            ),
          ],
        ),
      ),
    );
  }
}
