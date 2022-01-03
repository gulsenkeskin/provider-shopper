import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'Welcome',
                   style: Theme.of(context).textTheme.headline1,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Username',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                //Verilen rotayı iterek ve ardından yeni rota animasyonu tamamlandıktan sonra önceki rotayı atarak, verilen bağlamı en sıkı şekilde içine alan gezginin geçerli rotasını değiştirin.
                //Yeni bir rotaya basıldığında mevcut rota içinde devam eden hareketler iptal edilir.
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/catalog');
                },
                child: const Text('ENTER'),
                style: ElevatedButton.styleFrom(
                   primary: Colors.yellow,
                 ),
              )
            ],
          ),
        ),
      ),
    )
  }
}
