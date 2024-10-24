import 'dart:io';

Future<void> main() async {
  // Caminho da pasta que você deseja ler
  final directoryPath = '/home/tassio/dnose_projects_/conduit/';

  // Cria uma instância de Directory
  int count = await getQtyFilesWithTestSuffix(directoryPath);

  print('Quantidade de arquivos com sufixo _test.dart: $count');
}

class Util {
  static int getQtyFilesWithTestSuffix(String directoryPath) {
    final directory = Directory(directoryPath);

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
}
