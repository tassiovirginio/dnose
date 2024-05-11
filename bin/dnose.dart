import 'dart:io';
import 'dart:io' show Platform, stdout;

import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:dnose/main.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  var folderHome = getFolderUser() + "/dnose_projects";
  var existFolder = Directory(folderHome).existsSync();
  print("existeFolder: $existFolder");
  if(existFolder == false){
    Directory(folderHome).createSync();
  }

  List<String> listaProjetos = List.empty(growable: true);
  Directory(folderHome).listSync().forEach((element) {
    listaProjetos.add(element.path);
  });

  app.get('/projects', () => listaProjetos);

  String resultado = "${Directory.current.path}/resultado.csv";
  String resultado2 = "${Directory.current.path}/resultado2.csv";

  bool result1exists = File(resultado).existsSync();
  app.get('/result1exists', () => result1exists.toString());

  var projectNameAtual = "";
  if(result1exists){
    var file = File(resultado);
    projectNameAtual = file.readAsLinesSync()[2].split(";")[0];
  }

  app.get('/projectnameatual', () => projectNameAtual);

  app.get('/download', () => File(resultado));
  app.get('/download2', () => File(resultado2));

  app.get('/', () => File('public/index.html'));
  app.get('/bulma.min.css', () => File('public/bulma.min.css'));
  app.get('/logo.png', () => File('public/logo.png'));

  app.get('/processar', (Request request) async {
    String? path_project = request.url.queryParameters['path_project'];
    processar(path_project!);
    return Response.ok("Processamento concluído");
  });

  return corsHeaders() >> app.call;
}

String getFolderUser(){
  String os = Platform.operatingSystem;
  String? home = "";
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    home = envVars['HOME'];
  } else if (Platform.isLinux) {
    home = envVars['HOME'];
  } else if (Platform.isWindows) {
    home = envVars['UserProfile'];
  }
  return home!;
}
