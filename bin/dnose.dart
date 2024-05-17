import 'dart:io';

import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:dnose/main.dart';
import 'package:dnose/dnose.dart';
import 'package:git_clone/git_clone.dart' as git;
import 'package:google_generative_ai/google_generative_ai.dart' as ai;

const apiKey = "AIzaSyAeYV6fJV5KjxN8g1Zjlfw0CCeUYtloFjM";

final ip = InternetAddress.anyIPv4;
final port = int.parse(Platform.environment['PORT'] ?? '8080');
void main() => shelfRun(init, defaultBindPort: port, defaultBindAddress: ip);

Handler init() {
  var app = Router().plus;

  final model = ai.GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  var folderHome = "${getFolderUser()}/dnose_projects";
  var existFolder = Directory(folderHome).existsSync();
  if (existFolder == false) Directory(folderHome).createSync();

  List<String> listaProjetos() =>
      Directory(folderHome).listSync().map((d) => d.path).toList();

  app.get('/projects', listaProjetos);

  app.get('/testsmellsnames', () => DNose.listTestSmellsNames);

  app.post('/solution', (Request request) async {
    String prompt = await request.readAsString();
    print(prompt);
    prompt = prompt.replaceAll("_", " ");
    print(prompt);
    var content = [ai.Content.text(prompt)];
    final response = await model.generateContent(content);
    String? r = response.text;
    print(r);
    return Response.ok(r);
  });

  String resultado = "${Directory.current.path}/resultado.csv";
  String resultado2 = "${Directory.current.path}/resultado2.csv";

  String result1exists() => File(resultado).existsSync().toString();
  app.get('/result1exists', result1exists);

  String projectnameatual() {
    var projectNameAtual = "";
    if (result1exists() == "true") {
      var file = File(resultado);
      projectNameAtual = file.readAsLinesSync()[2].split(";")[0];
    }
    return projectNameAtual;
  }

  List<String> get100lines() {
    List<String> lista = List<String>.empty(growable: true);
    if (result1exists() == "true") {
      var file = File(resultado);
      return file.readAsLinesSync().sublist(1,file.readAsLinesSync().length < 300 ? file.readAsLinesSync().length: 300);
    }
    return lista;
  }
  app.get('/getlines100', get100lines);

  app.get('/getfiletext', (Request request) async {
    String? pathFile = request.url.queryParameters['path'];
    String? testDescription = request.url.queryParameters['test'];
    DNose dnose = DNose();
    String code = dnose.getCodeTestByDescription(pathFile!,testDescription!);
    code = code.replaceAll(";", ";\n");
    return Response.ok(code);
  });

  String chartData() => File(resultado2).readAsStringSync();

  app.get('/projectnameatual', projectnameatual);

  app.get('/charts_data', chartData);

  File getResultado1() => File(resultado);
  File getResultado2() => File(resultado2);

  app.get('/download', getResultado1);
  app.get('/download2', getResultado2);

  app.get('/', () => File('public/index.html'));
  app.get('/index.js', () => File('public/index.js'));
  app.get('/projects.html', () => File('public/projects.html'));
  app.get('/projects.js', () => File('public/projects.js'));
  app.get('/solutions.html', () => File('public/solutions.html'));
  app.get('/solutions.js', () => File('public/solutions.js'));
  app.get('/about', () => File('public/about.html'));
  app.get('/bulma.min.css', () => File('public/bulma.min.css'));
  app.get('/logo.png', () => File('public/logo.png'));
  app.get('/chart.js', () => File('public/chart.js'));

  app.get('/processar', (Request request) async {
    String? pathProject = request.url.queryParameters['path_project'];
    processar(pathProject!);
    return Response.ok("Processamento concluído");
  });

  app.get('/clonar', (Request request) async {
    String? url = request.url.queryParameters['url'];
    var projectName = url!.split("/").last.replaceAll(".git", "");
    String caminhoCompleto = "$folderHome/$projectName";
    await git.gitClone(repo: url, directory: caminhoCompleto);
    return Response.ok("Clonagem concluída");
  });

  return corsHeaders() >> app.call;
}

String getFolderUser() => (Platform.isMacOS || Platform.isLinux)
    ? Platform.environment['HOME']!
    : Platform.environment['UserProfile']!;
