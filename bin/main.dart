import 'dart:io';

import 'package:shelf_router/shelf_router.dart' as Router;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:dnose/Main.dart';

void main() async {
  var app = Router.Router();

  app.get('/hello', (Request request) {
    return Response.ok('Hello, World!');
  });

  app.get('/download', (Request request) {
    var file = File("/home/tassio/Desenvolvimento/dart/dnose/resultado.csv");
    return Response.ok('Hello, World!');
  });

  app.get('/processar', (Request request) {
    var path_project = request.url.queryParameters['path_project'];
    processar(path_project!);

    var pagina =
    """
    <html>
    <div style='width: 100%; background-color: black; font-size: 22px; color: #eeeeee'>DNose - Dart Test Smell Detector</div>
    <br>
    <br>
    <h1>Results</h1>
    <br>
    Projeto: $path_project
    <br>
    <a href='file:/home/tassio/Desenvolvimento/dart/dnose/resultado.csv'>Download Result</a>
    </html>
    """;

    return Response.ok(pagina, headers: {'Content-Type': 'text/html'});
  });

  app.get('/', (Request request) {
    var pagina =
    """
    <html>
    <div style='width: 100%; background-color: black; font-size: 22px; color: #eeeeee'>DNose - Dart Test Smell Detector</div>
    <br>
    <br>
    <form method='get' action='processar'>
      <label>Path Project:</label>
      <input type="text" id='path_project' name="path_project" value='/home/tassio/Desenvolvimento/dart/flutter' style="width: 300px">
      <br>
      <br>
      <button type="submit">Submit</button>
    </form>
    </html>
    """;


    return Response.ok(pagina, headers: {'Content-Type': 'text/html'});
  });

  var handler = const Pipeline().addMiddleware(logRequests()).addHandler(app);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on localhost:${server.port}');
}
