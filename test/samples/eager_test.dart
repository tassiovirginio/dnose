import 'package:test/test.dart';

// Classes de produção
class Flight {
  String number;
  int _mileage = 0;
  bool cancelled = false;

  Flight(this.number);

  void setMileage(int miles) => _mileage = miles;
  int getMileageAsKm() => (_mileage * 1.609).round();
  void cancel() => cancelled = true;
}

class ShoppingCart {
  final List<Item> _items = [];

  void addItem(Item item) => _items.add(item);
  void removeItem(Item item) => _items.remove(item);
  int getItemCount() => _items.length;
  double getTotalPrice() => _items.fold(0.0, (sum, item) => sum + item.price);
}

class Item {
  final double price;
  Item(this.price);
}

class Calculator {
  int add(int a, int b) => a + b;
  int subtract(int a, int b) => a - b;
  int multiply(int a, int b) => a * b;
}

void main() {
  // SMELL 1: 3 métodos do Flight
  test('ET1: Flight operations', () {
    final flight = Flight('AA123');
    flight.setMileage(1122);
    flight.getMileageAsKm();
    flight.cancel();
  });

  // SMELL 2: 4 métodos do ShoppingCart
  test('ET2: Cart operations', () {
    final cart = ShoppingCart();
    cart.addItem(Item(10.0));
    cart.getItemCount();
    cart.getTotalPrice();
    cart.removeItem(Item(10.0));
  });

  // SMELL 3: 3 métodos do Calculator
  test('ET3: Calculator operations', () {
    final calc = Calculator();
    calc.add(2, 3);
    calc.subtract(10, 4);
    calc.multiply(3, 4);
  });

  // SMELL 4: Flight com expects
  test('ET4: Flight with asserts', () {
    final flight = Flight('BB456');
    flight.setMileage(500);
    expect(flight.getMileageAsKm(), greaterThan(0));
    flight.cancel();
  });

  // SMELL 5: Cart com múltiplas operações
  test('ET5: Cart lifecycle', () {
    final cart = ShoppingCart();
    cart.addItem(Item(5.0));
    cart.addItem(Item(10.0));
    cart.removeItem(Item(5.0));
    expect(cart.getTotalPrice(), equals(10.0));
  });

  // SMELL 6: Múltiplos métodos com validações
  test('ET6: Multiple methods validated', () {
    final calc = Calculator();
    expect(calc.add(1, 1), equals(2));
    expect(calc.subtract(5, 3), equals(2));
    expect(calc.multiply(2, 3), equals(6));
  });

  // SMELL 7: Flight completo
  test('ET7: Complete flight test', () {
    final flight = Flight('CC789');
    flight.setMileage(1000);
    final km = flight.getMileageAsKm();
    expect(km, greaterThan(0));
    flight.cancel();
  });

  // VÁLIDOS - NÃO DEVEM SER DETECTADOS

  test('Valid1: Single method', () {
    final calc = Calculator();
    expect(calc.add(2, 3), equals(5));
  });

  test('Valid2: Two methods only', () {
    final flight = Flight('DD111');
    flight.setMileage(100);
    expect(flight.getMileageAsKm(), greaterThan(0));
  });

  test('Valid3: Same method twice', () {
    final calc = Calculator();
    expect(calc.add(1, 1), equals(2));
    expect(calc.add(2, 2), equals(4));
  });
}
