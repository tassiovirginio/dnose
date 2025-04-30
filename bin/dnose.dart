import 'dart:io';

import 'package:dnose/dnose_core.dart';
import 'package:dnose/main.dart';
import 'package:dnose/utils/git_utils.dart';
import 'package:dnose/utils/util.dart';
import 'package:dnose/pages.dart';
import 'package:git_clone/git_clone.dart' as git;
import 'package:google_generative_ai/google_generative_ai.dart' as ai;
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:dotenv/dotenv.dart';
import 'package:intl/intl.dart';

final ip = InternetAddress.anyIPv4;
final port = int.parse(Platform.environment['PORT'] ?? '8080');

final userFolder = (Platform.isMacOS || Platform.isLinux)
    ? Platform.environment['HOME']!
    : Platform.environment['UserProfile']!;
final Directory dirUser = Directory(userFolder);
final Directory dirDNose = Directory("${dirUser.path}/.dnose");
final Directory dirProjects = Directory("${dirDNose.path}/projects");
final Directory dirResults = Directory("${dirDNose.path}/results");

final resultado = "${dirResults.path}/resultado.csv";
final resultado2 = "${dirResults.path}/resultado2.csv";
final resultadoMetrics = "${dirResults.path}/resultado_metrics.csv";
final resultadoMetrics2 = "${dirResults.path}/metrics2.csv";
final resultadoDbFile = "${dirResults.path}/resultado.sqlite";

Future<List<String>> listaProjetos() async {
  var list = dirProjects.listSync().toList();
  return list.map((e) => e.path).toList();
}

void main() async{
  print(
      '''
  ██████╗ ███╗   ██╗ ██████╗ ███████╗███████╗
  ██╔══██╗████╗  ██║██╔═══██╗██╔════╝██╔════╝
  ██║  ██║██╔██╗ ██║██║   ██║███████╗█████╗  
  ██║  ██║██║╚██╗██║██║   ██║╚════██║██╔══╝  
  ██████╔╝██║ ╚████║╚██████╔╝███████║███████╗
  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝
  '''
  );
  await shelfRun(
    init,
    defaultEnableHotReload: false,
    defaultBindPort: port,
    defaultBindAddress: ip,
  );
  print("open -> http://127.0.0.1:$port");
}

Handler init() {
  // print('Versão do Dart: ${Platform.version}');

  DNoseCore.contProcessProject = 0;

  //criando diretorios
  if(dirDNose.existsSync() == false) dirDNose.createSync();
  if(dirProjects.existsSync() == false) dirProjects.createSync();
  if(dirResults.existsSync() == false) dirResults.createSync();

  DotEnv env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKeyGemini = env['API_KEY_GEMINI'] ?? 'AIzaSyAeYV6fJV5KjxN8g1Zjlfw0CCeUYtloFjM';
  final apiKeyChatGPT = env['API_KEY_CHATGPT'] ?? 'sk-proj-ASl8dAsovhX3OAq6AGvGT3BlbkFJV9MB869wapMddLlRvLDa';
  final ollamaModel = env['OLLAMA_MODEL'] ?? 'llama3';

  // print("API_KEY_GEMINI: $apiKeyGemini");
  // print("API_KEY_CHATGPT: $apiKeyChatGPT");
  // print("OLLAMA_MODEL: $ollamaModel");

  var app = Router().plus;
  app.use(corsHeaders()); // liga o cors

  //carregar as páginas no sistema
  loadPages(app);

  final gemini = ai.GenerativeModel(model: 'gemini-pro', apiKey: apiKeyGemini);

  var existFolder = dirProjects.existsSync();
  if (existFolder == false) dirProjects.createSync();

  var existFolder2 = dirResults.existsSync();
  if (existFolder2 == false) dirResults.createSync();

  app.get('/list_projects', () => listaProjetos());
  app.get('/getstatistics', () => getStatists());
  app.get('/testsmellsnames', () => DNoseCore.listTestSmellsNames);

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
    String response = await getChatGptResponse(prompt,apiKeyChatGPT);
    return Response.ok(response);
  });

  app.post('/solution3', (Request request) async {
    String prompt = await request.readAsString();
    prompt = prompt.replaceAll("_", " ");
    String response = await getOllamaResponse(prompt, ollamaModel);
    return Response.ok(response);
  });

  String result1exists() => File(resultado).existsSync().toString();
  app.get('/result1exists', result1exists);

  String currentProjectName() {
    sleep(Duration(seconds: 1));
    var lista = getProjects();
    String projetos = "";

    for (var p in lista) {
      p = p.replaceAll("{", "").replaceAll("}", "");
      if (projetos.isEmpty) {
        projetos = p.split(":")[1].trim();
      } else {
        projetos = "$projetos, ${p.split(":")[1].trim()}";
      }
    }

    return projetos;
  }

  List<String> getLines() {
    List<String> lista = List<String>.empty(growable: true);
    if (result1exists() == "true") {
      var file = File(resultado);
      return file.readAsLinesSync().sublist(
        1,
        file.readAsLinesSync().length < 300
            ? file.readAsLinesSync().length
            : 300,
      );
    }
    return lista;
  }

  app.get('/getlines100', getLines);

  app.get('/getfiletext', (Request request) async {
    String? pathFile = request.url.queryParameters['path'];
    String? testDescription = request.url.queryParameters['test'];
    DNoseCore dnose = DNoseCore();
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

  String qtdFilesTests() {
    return getSizeTestFiles().toString();
  }

  String chartDataTestSmellsSentiments() {
    if (File(resultadoDbFile).existsSync() == false) return "";
    final db = sqlite3.open(resultadoDbFile);

    final ResultSet result = db.select('''
      SELECT testsmell, SUM(score) AS total_score
      FROM testsmells
      WHERE score < 0
      GROUP BY testsmell
      ORDER BY total_score ASC;
    ''');

    db.dispose();

    if (result.isEmpty) {
      return 'Nenhum dado de score encontrado para os test smells.';
    }

    final buffer = StringBuffer();
    for (final row in result) {
      final smell = row['testsmell'];
      final score = row['total_score'];
      buffer.writeln('$smell;$score');
    }

    return buffer.toString();
  }

  String chartDataAuthorSentiment() {
    if (File(resultadoDbFile).existsSync() == false) return "";
    final db = sqlite3.open(resultadoDbFile);

    final ResultSet result = db.select('''
      SELECT author, SUM(score) AS total_score
      FROM testsmells
      GROUP BY author
      ORDER BY total_score ASC
      LIMIT 10;
    ''');

    db.dispose();

    if (result.isEmpty) {
      return 'Nenhum dado de score encontrado.';
    }

    final buffer = StringBuffer();
    for (final row in result) {
      final autor = row['author'];
      final score = row['total_score'];
      buffer.writeln('$autor;$score');
    }

    return buffer.toString();
  }

  String listAuthorStartEnd() {
    if (File(resultadoDbFile).existsSync() == false) return "";
    final db = sqlite3.open(resultadoDbFile);

    final ResultSet result = db.select('''
      SELECT 
        project,
        author,
        MIN(date) AS start_date,
        MAX(date) AS end_date,
        CAST(julianday(SUBSTR(MAX(date), 1, 19)) - julianday(SUBSTR(MIN(date), 1, 19)) AS INTEGER) as dias
      FROM commits
      GROUP BY project, author
      ORDER BY dias desc;
    ''');

    db.dispose();

    if (result.isEmpty) {
      return 'Nenhum dado de score encontrado.';
    }

    final buffer = StringBuffer();
    for (final row in result) {
      try {
        final project = row['project'];
        final author = row['author'];
        final start_date = row['start_date'];
        final end_date = row['end_date'];
        final dias = row['dias'];
        buffer.writeln('$project;$author;$start_date;$end_date;$dias');
      }finally{
        continue;
      }
    }

    return buffer.toString();
  }




  String listAuthorQtdCommit() {
    if (File(resultadoDbFile).existsSync() == false) return "";
    final db = sqlite3.open(resultadoDbFile);

    final ResultSet result = db.select('''
      SELECT 
        project,
        author,
        count(1) as qtd
      FROM commits
      GROUP BY project, author
      ORDER BY qtd desc;
    ''');

    db.dispose();

    if (result.isEmpty) {
      return 'Nenhum dado de score encontrado.';
    }

    final buffer = StringBuffer();
    for (final row in result) {
      final project = row['project'];
      final author = row['author'];
      final qtd = row['qtd'];
      buffer.writeln('$project;$author;$qtd');
    }

    return buffer.toString();
  }

  String chartDataAuthor() {
    if (File(resultadoDbFile).existsSync() == false) return "";
    final db = sqlite3.open(resultadoDbFile);

    final ResultSet result = db.select('''
      SELECT author, COUNT(*) AS total_testsmells
      FROM testsmells
      GROUP BY author
      ORDER BY total_testsmells DESC
      LIMIT 15;
    ''');

    db.dispose();

    if (result.isEmpty) {
      return 'Nenhum test smell encontrado.';
    }

    final buffer = StringBuffer();
    for (final row in result) {
      buffer.writeln('${row['author']};${row['total_testsmells']}');
    }

    return buffer.toString();
  }

  app.get('/projectnameatual', currentProjectName);
  app.get('/charts_data', chartData);
  app.get('/charts_data_author', chartDataAuthor);
  app.get('/charts_data_author_sentiment', chartDataAuthorSentiment);
  app.get('/charts_data_testsmells_sentiments', chartDataTestSmellsSentiments);
  app.get('/qtd_test_files', qtdFilesTests);

  app.get('/list_author_start_end', listAuthorStartEnd);
  app.get('/list_author_qtd_commit', listAuthorQtdCommit);

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
    String caminhoCompleto = "${dirProjects.path}/$projectName";
    await git.gitClone(repo: url, directory: caminhoCompleto);
    return Response.ok("Clonagem concluída");
  });

  app.get('/clonar_lote', (Request request) async {
    String? urls = request.url.queryParameters['urls'];
    var lista = urls!.split("|");

    for (var url in lista) {
      var projectName = url.split("/").last.replaceAll(".git", "");
      String caminhoCompleto = "${dirProjects.path}/$projectName";
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

  app.get('/qtdbytestsmellbytype', getQtdTestSmellsByType);

  app.get('/qtd_commits', (Request request) async {
    String? pathProject = request.url.queryParameters['path_project'];
    final size = Util.getQtyFilesWithTestSuffix(pathProject);
    return Response.ok(size.toString());
  });

  app.get('/qtd_progress', () {
    int valor = DNoseCore.contProcessProject;
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
    ),
  );

  app.get(
    '/timenow',
    () => WebSocketSession(
      onOpen: (ws) => ws.send('Iniciando...'),
      onMessage: (ws, data) {
        for (int i = 0; i < 10; i++) {
          ws.send('contador: $i');
          sleep(Duration(seconds: 1));
        }
        ws.send('You sent me: $data');
      },
      onClose: (ws) => ws.send('Bye!'),
    ),
  );

  return corsHeaders() >> app.call;
}

Future<String> getChatGptResponse(String prompt, apiKeyChatGPT) async {
  final llm = OpenAI(
    apiKey: apiKeyChatGPT,
    defaultOptions: const OpenAIOptions(temperature: 0.9),
  );
  final LLMResult res = await llm.invoke(PromptValue.string(prompt));
  return res.output;
}

Future<String> getOllamaResponse(String prompt, ollamaModel) async {
  final llm = Ollama(
    defaultOptions: OllamaOptions(
      model: ollamaModel, //phi3
    ),
  );
  final LLMResult res = await llm.invoke(PromptValue.string(prompt));
  return res.output;
}

