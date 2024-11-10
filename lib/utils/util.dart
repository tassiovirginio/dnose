import 'dart:convert';
import 'dart:io';
import 'package:dnose/main.dart';
import 'package:intl/intl.dart';

import 'package:crypto/crypto.dart';
import 'package:statistics/statistics.dart';

Future<void> main() async {
  // Caminho da pasta que você deseja ler
  // final directoryPath = '/home/tassio/dnose_projects_/conduit/';

  // Cria uma instância de Directory
  // int count = Util.getQtyFilesWithTestSuffix(directoryPath);

  // print('Quantidade de arquivos com sufixo _test.dart: $count');


  print(Util.date("1722036893 -0700"));
}

class Util {
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

  static String MD5(String code) {
    code = code.replaceAll("\n", "").replaceAll("\r", "").replaceAll(" ", "");
    return md5.convert(utf8.encode(code)).toString();
  }

  static String date(String timestamp_gmt) {

    int timestamp = timestamp_gmt.trim().split(" ").first.toInt();
    double gmt = (timestamp_gmt.trim().split(" ").last.toInt())/100;// Timestamp Unix em segundos
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);

    // Ajuste para o fuso horário +0200
    print(gmt.toInt());
    date = date.add(Duration(hours: gmt.toInt()));

    // Formata a data para o formato desejado
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

    return formattedDate;
  }

}
