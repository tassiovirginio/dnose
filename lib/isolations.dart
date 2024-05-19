import 'dart:io';
import 'dart:isolate';
// import 'dart:async';

void readFile(SendPort sendPort) async {
  // Cria um ReceivePort para receber a mensagem do isolate principal
  ReceivePort receivePort = ReceivePort();
  
  // Envia o SendPort do receivePort de volta para o isolate principal
  sendPort.send(receivePort.sendPort);
  
  // Escuta por mensagens do isolate principal
  await for (var message in receivePort) {
    String filePath = message[0];
    SendPort replyPort = message[1];
    
    try {
      // Lê o conteúdo do arquivo
      String content = await File(filePath).readAsString();
      replyPort.send({'filePath': filePath, 'content': content, 'error': null});
    } catch (e) {
      // Em caso de erro, envia o erro de volta
      replyPort.send({'filePath': filePath, 'content': null, 'error': e.toString()});
    }
  }
}

void main() async {
  List<String> filePaths = ['/home/tassio/Desenvolvimento/dart/dnose/resultado2.csv', '/home/tassio/Desenvolvimento/dart/dnose/resultado2.csv'];
  
  // Lista de ReceivePorts para receber as respostas dos isolates
  List<ReceivePort> receivePorts = [];
  
  for (String filePath in filePaths) {
    ReceivePort receivePort = ReceivePort();
    receivePorts.add(receivePort);
    
    // Cria um novo isolate para cada arquivo
    Isolate.spawn(readFile, receivePort.sendPort);
    
    // Obtém o SendPort do isolate criado
    SendPort isolateSendPort = await receivePort.first;
    
    // Envia o caminho do arquivo para o isolate
    ReceivePort responsePort = ReceivePort();
    isolateSendPort.send([filePath, responsePort.sendPort]);
    
    // Escuta a resposta do isolate
    responsePort.listen((response) {
      if (response['error'] != null) {
        print('Erro ao ler ${response['filePath']}: ${response['error']}');
      } else {
        print('Conteúdo de ${response['filePath']}:\n${response['content']}');
      }
    });
  }
}
