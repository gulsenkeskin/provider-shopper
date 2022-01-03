
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CatalogModel{

  static List<String> itemNames = [
    'Code Smell',
    'Control Flow',
    'Interpreter',
    'Recursion',
    'Sprint',
    'Heisenbug',
    'Spaghetti',
    'Hydra Code',
    'Off-By-One',
    'Scope',
    'Callback',
    'Closure',
    'Automata',
    'Bit Shift',
    'Currying',
  ];

/// Bu örnekte, katalog sonsuzdur ve [öğe Adları] üzerinde döngü yapar.
  Item getById(int id)=> Item(id, itemNames[id % itemNames.length]);

}

/// @immutable => Bir C sınıfına açıklama eklemek için kullanılır. C ve C'nin tüm alt türlerinin değişmez olması gerektiğini belirtir
@immutable
class Item {
  final int id;
  final String name;
  final Color color;
  final int price = 42;

  Item(this.id, this.name):color= Colors.primaries[id % Colors.primaries.length];

  @override
  int get hashCode => id;

  @override
  bool operator==(Object other)=> other is Item  && other.id == id;

}

