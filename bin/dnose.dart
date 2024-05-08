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
  document.getElementById("resultado2").style.visibility = "hidden";
  document.getElementById("loading").style.visibility = "hidden";
};
      
      function processar(){
      
      document.getElementById("resultado").style.visibility = "hidden";
      document.getElementById("resultado2").style.visibility = "hidden";
      document.getElementById("loading").style.visibility = "visible";
      
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
        document.getElementById("resultado2").style.visibility = "visible";
        document.getElementById("loading").style.visibility = "hidden";
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
  String current2 = Directory.current.path.toString() + "/resultado2.csv";

  app.get('/download', () => File(current));
  app.get('/download2', () => File(current2));

  app.get('/processar', (Request request) async {
    String? path_project = request.url.queryParameters['path_project'];
    processar(path_project!);
    return Response.ok("", headers: headers);
  });

  app.get('/', (Request request) {
    var pagina = """
    <html>
    <head>
      <style>
      .window{
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -50px;
            margin-left: -50px;
            width: 100px;
            height: 100px;
        }
        .loading {
            display: block;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            }
      </style>
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
      <input type="text" id='path_project' name="path_project" value='/home/tassio/Desenvolvimento/repo.git/dnose' style="width: 300px">
      <br>
    </form>
    <button onclick='processar();'>Process</button>
    <br>
    <div>
      <br>
      <a id='resultado' href="/download">Download Result 1</a>
      <a id='resultado2' href="/download2">Download Result 2</a>
    </div>
    <div class="loading" id="loading">
      <div class='window'>
          Carregando...
      </div>
    </div>
    </body>
    </html>
    """;

    return Response.ok(pagina, headers: headers2);
  });

  return app.call;
}
