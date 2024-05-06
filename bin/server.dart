import 'package:shelf_router/shelf_router.dart' as Router;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

class Server{
  main() async {
    var app = Router.Router();

    app.get('/hello', (Request request) {
      return Response.ok('Hello, World!');
    });

    var handler = const Pipeline().addMiddleware(logRequests()).addHandler(app);

    var server = await io.serve(handler, 'localhost', 8080);
    print('Server listening on localhost:${server.port}');
  }
}

