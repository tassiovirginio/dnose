import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

class Gift {
  final int id;
  final String name;

  Gift({required this.id, required this.name});

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

void main() {
  group('Gift Test', () {
    test('Gift model test', () {
      final file = File('json/gift_test.json').readAsStringSync();
      final gifts = Gift.fromJson(jsonDecode(file) as Map<String, dynamic>);

      expect(gifts.id, 999);
    });
  });

  group('User Profile Test', () {
    test('User Profile with Mystery Guest', () {
      final userProfile = fetchUserProfile();  // Depende de um usuário "Alice" configurado externamente
      expect(userProfile.name, equals("Alice"));
    });
  });

  group('Database Test', () {
    test('Database query test', () {
      final data = queryDatabase('SELECT * FROM users WHERE id = 1');  // Depende de banco de dados externo
      expect(data.isNotEmpty, true);
    });
  });

  group('API Test', () {
    test('API call test', () {
      final response = callExternalAPI('/users/1');  // Depende de API externa
      expect(response.statusCode, 200);
    });
  });

  group('Good Test', () {
    test('Gift model test without mystery guest', () {
      final testData = '{"id": 999, "name": "Test Gift"}';
      final gifts = Gift.fromJson(jsonDecode(testData) as Map<String, dynamic>);

      expect(gifts.id, 999);
    });
  });
}

UserProfile fetchUserProfile() {
  // Simula a recuperação do perfil de um usuário de um banco de dados externo
  // Aqui, a suposição é de que "Alice" é um usuário existente
  return UserProfile(name: "Alice");
}

class UserProfile {
  final String name;
  UserProfile({required this.name});
}

List<Map<String, dynamic>> queryDatabase(String query) {
  // Simula uma consulta ao banco de dados
  return [{'id': 1, 'name': 'Alice'}];
}

class APIResponse {
  final int statusCode;
  APIResponse({required this.statusCode});
}

APIResponse callExternalAPI(String endpoint) {
  // Simula uma chamada para API externa
  return APIResponse(statusCode: 200);
}
