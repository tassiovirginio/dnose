import 'dart:io';

import 'package:dnose/dnose.dart';
import 'package:dnose/main.dart';
import 'package:dnose/utils/git_utils.dart';
import 'package:dnose/utils/util.dart';
import 'package:git_clone/git_clone.dart' as git;
import 'package:google_generative_ai/google_generative_ai.dart' as ai;
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:properties/properties.dart';

final ip = InternetAddress.anyIPv4;
final port = int.parse(Platform.environment['PORT'] ?? '8080');
final currentPath = Directory.current.path;
final resultado = "$currentPath/resultado.csv";
final resultado2 = "$currentPath/resultado2.csv";
final resultadoMetrics = "$currentPath/resultado_metrics.csv";
final resultadoMetrics2 = "$currentPath/metrics2.csv";
final resultadoDbFile = "$currentPath/resultado.sqlite";
final userFolder = (Platform.isMacOS || Platform.isLinux)
    ? Platform.environment['HOME']!
    : Platform.environment['UserProfile']!;
final folderHome = "$userFolder/dnose_projects";
final filepath = "dnose.properties";

String? apiKeyGemini;
String? apiKeyChatGPT;
String? ollamaModel;

Future<List<String>> listaProjetos() async {
  // List<String> projetosDart = List.empty(growable: true);

  var lista = Directory(folderHome).listSync().toList();

  // for(var d in lista){
  //   final dir = Directory(d.path);
  //   final List<FileSystemEntity> entities = await dir.list().toList();
  //   entities.forEach((element) {
  //     //Só adiciona projetos com pubspec.yaml
  //     if(element.toString().contains("pubspec.yaml")){
  //       print(element);
  //       projetosDart.add(d.path);
  //     }
  //   },);
  // }

  return lista.map((e) => e.path).toList();
}

void main() => shelfRun(
      init,
      defaultEnableHotReload: false,
      defaultBindPort: port,
      defaultBindAddress: ip,
    );

Handler init() {
  DNose.contProcessProject = 0;

  Properties p = Properties.fromFile(filepath);
  apiKeyGemini = p.get('apiKeyGemini');
  apiKeyChatGPT = p.get('apiKeyChatGPT');
  ollamaModel = p.get('ollamaModel');

  var app = Router().plus;
  // app.use(logRequests()); // liga o log
  app.use(corsHeaders()); // liga o cors
  final gemini = ai.GenerativeModel(model: 'gemini-pro', apiKey: apiKeyGemini!);

  var existFolder = Directory(folderHome).existsSync();
  if (existFolder == false) Directory(folderHome).createSync();

  app.get('/list_projects', () => listaProjetos());
  app.get('/getstatistics', () => getStatists());
  app.get('/testsmellsnames', () => DNose.listTestSmellsNames);

  app.post('/solution', (Request request) async {
    String prompt = await request.readAsString();
    prompt = prompt.replaceAll("_", " ");
    String? resp;
    var content = [ai.Content.text(prompt)];
    final response = await gemini.generateContent(content);
    resp = response.text;
    return Response.ok(resp);
  });

  app.post('/solution2', (Request request) async {
    String prompt = await request.readAsString();
    prompt = prompt.replaceAll("_", " ");
    String response = await getChatGptResponse(prompt);
    return Response.ok(response);
  });

  app.post('/solution3', (Request request) async {
    String prompt = await request.readAsString();
    prompt = prompt.replaceAll("_", " ");
    String response = await getOllamaResponse(prompt);
    return Response.ok(response);
  });

  String result1exists() => File(resultado).existsSync().toString();
  app.get('/result1exists', result1exists);

  String currentprojectname() {
    sleep(Duration(seconds: 1));
    var lista = getProjects();
    String projetos = "";

    for (var p in lista) {
      p = p.replaceAll("{", "").replaceAll("}", "");
      if (projetos.isEmpty) {
        projetos = p.split(":")[1].trim();
      } else {
        projetos = projetos + ", " + p.split(":")[1].trim();
      }
    }

    return projetos;

    // var currentprojectname = "NONE";
    // var file = File(resultado);
    // if (file.existsSync()) {
    //   if(file.lengthSync() > 0){
    //     var linhas = file.readAsLinesSync();
    //     if(linhas.length > 1){
    //       currentprojectname = linhas[1].split(";")[0];
    //     }
    //   }
    // }
    // return currentprojectname;
  }

  List<String> getLines() {
    List<String> lista = List<String>.empty(growable: true);
    if (result1exists() == "true") {
      var file = File(resultado);
      return file.readAsLinesSync().sublist(
          1,
          file.readAsLinesSync().length < 300
              ? file.readAsLinesSync().length
              : 300);
    }
    return lista;
  }

  app.get('/getlines100', getLines);

  app.get('/getfiletext', (Request request) async {
    String? pathFile = request.url.queryParameters['path'];
    String? testDescription = request.url.queryParameters['test'];
    DNose dnose = DNose();
    String code = dnose.getCodeTestByDescription(pathFile!, testDescription!);
    code = code.replaceAll(";", ";\n");
    return Response.ok(code);
  });

  String chartData() {
    if (File(resultado2).existsSync()) {
      return File(resultado2).readAsStringSync();
    } else {
      return "";
    }
  }

  app.get('/projectnameatual', currentprojectname);
  app.get('/charts_data', chartData);

  File getResultado1() => File(resultado);
  File getResultado2() => File(resultado2);
  File getResultado3() => File(resultadoMetrics);
  File getResultado4() => File(resultadoMetrics2);

  File getResultadoDbFile() {
    var file = File(resultadoDbFile);
    if (file.existsSync() && file.lengthSync() > 0) {
      return file;
    }
    return file;
  }

  String resultDbExist() {
    var file = File(resultadoDbFile);
    return "${(file.existsSync() && file.lengthSync() > 0)}";
  }

  app.get('/download', getResultado1, use: download());
  app.get('/download2', getResultado2, use: download());
  app.get('/download_metrics', getResultado3, use: download());
  app.get('/download_metrics2', getResultado4, use: download());
  app.get('/download.db', getResultadoDbFile, use: download());
  app.get('/download.db.existe', resultDbExist);
  app.get('/', () => File('public/index.html'));
  app.get('/index.js', () => File('public/index.js'));
  app.get('/projects', () => File('public/projects.html'));
  app.get('/projects.js', () => File('public/projects.js'));
  app.get('/solutions', () => File('public/solutions.html'));
  app.get('/solutions.js', () => File('public/solutions.js'));
  app.get('/mining', () => File('public/mining.html'));
  app.get('/mining.js', () => File('public/mining.js'));
  app.get('/config', () => File('public/config.html'));
  app.get('/config.js', () => File('public/config.js'));
  app.get('/about', () => File('public/about.html'));
  app.get('/bulma.min.css', () => File('public/bulma.min.css'));
  app.get('/logo.png', () => File('public/logo.png'));
  app.get('/chart.js', () => File('public/chart.js'));

  app.get('/processar', (Request request) async {
    String? pathProject = request.url.queryParameters['path_project'];
    await processar(pathProject!);
    return Response.ok("Processamento concluído");
  });

  app.get('/processar_all', (Request request) async {
    await processarAll();
    return Response.ok("Processamento concluído");
  });

  app.get('/clonar', (Request request) async {
    String? url = request.url.queryParameters['url'];
    var projectName = url!.split("/").last.replaceAll(".git", "");
    String caminhoCompleto = "$folderHome/$projectName";
    await git.gitClone(repo: url, directory: caminhoCompleto);
    return Response.ok("Clonagem concluída");
  });

  app.get('/clonar_lote', (Request request) async {
    String? urls = request.url.queryParameters['urls'];
    var lista = urls!.split("|");

    for(var url in lista){
      var projectName = url.split("/").last.replaceAll(".git", "");
      String caminhoCompleto = "$folderHome/$projectName";
      await git.gitClone(repo: url, directory: caminhoCompleto);
      print(projectName);
    }
    
    return Response.ok("Clonagem concluída");
  });

  app.get('/delete', (Request request) async {
    String? path = request.url.queryParameters['path'];
    await Directory(path!).delete(recursive: true);
    return Response.ok("Projeto Excluído");
  });

  app.get('/gerardb', (Request request) async {
    createSqlite();
    return Response.ok("Banco de dados gerado com sucesso!");
  });

  app.get('/qtdbytestsmellbytype', getQtdTestSmellsByType);

  app.get('/qtd_commits', (Request request) async {
    String? path_project = request.url.queryParameters['path_project'];
    final size = Util.getQtyFilesWithTestSuffix(path_project);
    return Response.ok(size.toString());
  });

  app.get('/qtd_progress', () {
    print("Teste");
    int valor = DNose.contProcessProject;
    return Response.ok(valor.toString());
  });

  app.get('/get_branch', (Request request) async {
    String? pathProject = request.url.queryParameters['path_project'];
    String name = await GitUtil.getCurrentBranch(pathProject!);
    return Response.ok(name);
  });

  app.get('/get_qtd_commits', (Request request) async {
    String? pathProject = request.url.queryParameters['path_project'];
    int qtd = await GitUtil.getSizeCommits(pathProject!);
    return Response.ok(qtd.toString());
  });

  app.get(
      '/websocket',
      () => WebSocketSession(
            onOpen: (ws) => ws.send('Hello!'),
            onMessage: (ws, data) => ws.send('You sent me: $data'),
            onClose: (ws) => ws.send('Bye!'),
          ));
  
  app.get(
      '/timenow',
      () => WebSocketSession(
            onOpen: (ws) => ws.send('Iniciando...'),
            onMessage: (ws, data){
              for(int i = 0; i < 10; i++){
                ws.send('contador: $i');
                sleep(Duration(seconds: 1));
              }
              ws.send('You sent me: $data');
            },
            onClose: (ws) => ws.send('Bye!'),
          ));

  return corsHeaders() >> app.call;
}

Future<String> getChatGptResponse(String prompt) async {
  final llm = OpenAI(
    apiKey: apiKeyChatGPT,
    defaultOptions: const OpenAIOptions(temperature: 0.9),
  );
  final LLMResult res = await llm.invoke(
    PromptValue.string(prompt),
  );
  return res.output;
}

Future<String> getOllamaResponse(String prompt) async {
  final llm = Ollama(
      defaultOptions: OllamaOptions(
    model: ollamaModel, //phi3
  ));
  final LLMResult res = await llm.invoke(
    PromptValue.string(prompt),
  );
  return res.output;
}
