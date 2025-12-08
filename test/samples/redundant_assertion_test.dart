import 'package:test/test.dart';

class ShoppingCart {
  final List<Item> items = [];

  void add(Item item) {
    items.add(item);
  }

  int getTotalItems() {
    return items.length;
  }

  double getTotalPrice() {
    double total = 0;
    for (var item in items) {
      total += item.price;
    }
    return total;
  }
}

class Item {
  final double price;

  Item({required this.price});
}

void main() {
  final cart = ShoppingCart();
  cart.add(Item(price: 10));
  cart.add(Item(price: 20));

  test('RA1: Redundant Assertion Test 01', () {
    expect(cart.getTotalPrice(), equals(30));
    expect(cart.getTotalPrice(), equals(30)); // Redundant
  });

  test('RA2: Redundant Assertion Test 02', () {
    expect(cart.getTotalItems(), equals(2));
    expect(cart.getTotalItems(), equals(2)); // Redundant
  });

  test('RA3: Redundant Assertion Test 03', () {
    expect(cart.getTotalPrice(), equals(30));
    expect(cart.getTotalItems(), equals(2));
    expect(cart.getTotalPrice(), equals(30)); // Redundant
  });

  // Correct examples
  test('Correct: Single Assertion Test 01', () {
    expect(cart.getTotalPrice(), equals(30));
  });

  test('Correct: Single Assertion Test 02', () {
    expect(cart.getTotalItems(), equals(2));
  });
}
