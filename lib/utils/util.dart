import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart' show DateFormat;

import 'package:crypto/crypto.dart' as crypto;
import 'package:statistics/statistics.dart';
import 'package:dnose/utils/lru_cache.dart';

Future<void> main() async {
  // Caminho da pasta que você deseja ler
  // final directoryPath = '/home/tassio/dnose_projects_/conduit/';

  // Cria uma instância de Directory
  // int count = Util.getQtyFilesWithTestSuffix(directoryPath);

  // print('Quantidade de arquivos com sufixo _test.dart: $count');

  print(Util.date("1722036893 -0700"));
}

class Util {
  // Cache LRU para MD5 com capacidade de 10000 entradas
  static final _md5Cache = LruCache<String, String>(capacity: 10000);

  static int getQtyFilesWithTestSuffix(String? directoryPath) {
    final directory = Directory(directoryPath!);

    try {
      if (directory.existsSync()) {
        final files = directory.listSync(recursive: true);

        return files
            .where((file) => file is File && file.path.endsWith('_test.dart'))
            .length;
      } else {
        return -1;
      }
    } catch (e) {
      return -1;
    }
  }

  static String md5(String code) {
    // Verifica cache primeiro
    final cached = _md5Cache.get(code);
    if (cached != null) {
      return cached;
    }

    // Calcula MD5
    final normalized = code
        .replaceAll("\n", "")
        .replaceAll("\r", "")
        .replaceAll(" ", "");
    final hash = crypto.md5.convert(utf8.encode(normalized)).toString();

    // Armazena no cache
    _md5Cache.set(code, hash);

    return hash;
  }

  /// Limpa o cache de MD5
  static void clearMd5Cache() => _md5Cache.clear();

  /// Retorna o tamanho do cache de MD5
  static int get md5CacheSize => _md5Cache.length;

  static String date(String timestampGmt) {
    int timestamp = timestampGmt.trim().split(" ").first.toInt();
    double gmt =
        (timestampGmt.trim().split(" ").last.toInt()) /
        100; // Timestamp Unix em segundos
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    );

    // Ajuste para o fuso horário +0200
    print(gmt.toInt());
    date = date.add(Duration(hours: gmt.toInt()));

    // Formata a data para o formato desejado
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

    return formattedDate;
  }
}
