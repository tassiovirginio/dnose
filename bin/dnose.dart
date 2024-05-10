import 'dart:io';

import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:dnose/main.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  String resultado = "${Directory.current.path}/resultado.csv";
  String resultado2 = "${Directory.current.path}/resultado2.csv";

  app.get('/download', () => File(resultado));
  app.get('/download2', () => File(resultado2));

  app.get('/', () => File('public/index.html'));

  app.get('/processar', (Request request) async {
    String? path_project = request.url.queryParameters['path_project'];
    processar(path_project!);
    return Response.ok("Processamento concluído");
  });

  return corsHeaders() >> app.call;
}
