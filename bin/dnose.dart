import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';
import 'package:dnose/main.dart';

var headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  String current = "${Directory.current.path}/resultado.csv";
  String current2 = "${Directory.current.path}/resultado2.csv";

  app.get('/download', () => File(current));
  app.get('/download2', () => File(current2));

  app.get('/', () => File('public/index.html'));

  app.get('/processar', (Request request) async {
    String? path_project = request.url.queryParameters['path_project'];
    processar(path_project!);
    return Response.ok("", headers: headers);
  });

  return app.call;
}
