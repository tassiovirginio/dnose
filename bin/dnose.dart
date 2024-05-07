import 'dart:io';

// import 'package:shelf_router/shelf_router.dart' as Router;
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_plus/shelf_plus.dart';
import 'package:dnose/Main.dart';

var headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};

var headers2 = {
  'Content-Type': 'text/html',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};

var js_base = """

window.onload = (event) => {
  const processando = document.getElementById("processando");
  processando.innerHTML = "Processando: FALSE";
  
  document.getElementById("resultado").style.visibility = "hidden";
};
      
      function processar(){
      
      document.getElementById("resultado").style.visibility = "hidden";
      
      const processando = document.getElementById("processando");
      processando.innerHTML = "Processando: TRUE";
      document.getElementById("processando").style.backgroundColor = "red";
      
      const path = document.getElementById("path_project");
      console.log(path.value);
      const req = new XMLHttpRequest();
      req.onload = (e) => {
        processando.innerHTML = "Processando: FALSE";
        const resultado = document.getElementById("resultado");
        document.getElementById("resultado").style.visibility = "visible";
        document.getElementById("processando").style.backgroundColor = "green";
        
        console.log("=> " + req.response);
      };
      req.open("GET", "http://localhost:8080/processar?path_project="+path.value, true);
      req.send();
      
      }  
    """;

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  String current = Directory.current.path.toString() + "/resultado.csv";

  app.get('/processando', (Request request) {
    return Response.ok(Vars.processando.toString(), headers: headers);
  });

  app.get('/download', () => File(current));

  app.get('/processar', (Request request) async {
    Vars.processando = true;
    String? path_project = request.url.queryParameters['path_project'];
    processar(path_project!);
    Vars.processando = false;
    return Response.ok("", headers: headers);
  });

  app.get('/', (Request request) {
    var pagina = """
    <html>
    <head>
      <script>
        $js_base
      </script>
    </head>
    <body style='border-collapse: collapse;padding: 0;margin: 0;'>
    <div style='text-align: center;height: 30px; width: 100%; background-color: black; font-size: 22px; color: #eeeeee'>DNose - Dart Test Smell Detector</div>
    <div id='processando' style='background-color: green; color: white;'>Processando: FALSE</div>
    <br>
    <br>
    <form method='get' action='processar'>
      <label>Path Project:</label>
      <input type="text" id='path_project' name="path_project" value='/home/tassio/Desenvolvimento/dart/flutter' style="width: 300px">
      <br>
    </form>
    <button onclick='processar();'>Process</button>
    <br>
    <div>
      <br>
      <a id='resultado' href="/download">Download Result</a>
    </div>
    </body>
    </html>
    """;

    return Response.ok(pagina, headers: headers2);
  });

  return app.call;
}
