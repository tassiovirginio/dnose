import 'dart:io';

import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:dnose/main.dart';
import 'package:git_clone/git_clone.dart' as git;

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  var folderHome = "${getFolderUser()}/dnose_projects";
  var existFolder = Directory(folderHome).existsSync();
  if (existFolder == false) Directory(folderHome).createSync();

  List<String> listaProjetos() =>
      Directory(folderHome).listSync().map((_) => _.path).toList();

  app.get('/projects', listaProjetos);

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

  String chartData() => File(resultado2).readAsStringSync();

  app.get('/projectnameatual', projectnameatual);

  app.get('/charts_data', chartData);

  File getResultado1() => File(resultado);
  File getResultado2() => File(resultado2);

  app.get('/download', getResultado1);
  app.get('/download2', getResultado2);

  app.get('/', () => File('public/index.html'));
  app.get('/javascript.js', () => File('public/javascript.js'));
  app.get('/projects.html', () => File('public/projects.html'));
  app.get('/javascript2.js', () => File('public/javascript2.js'));
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
