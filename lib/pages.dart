import 'package:embed_annotation/embed_annotation.dart';
import 'package:shelf_plus/shelf_plus.dart';

part 'pages.g.dart';

@EmbedStr('/public/about.html')
const aboutHtml = _$about_html;

@EmbedStr('/public/bulma.min.css')
const bulmaMinCss = _$bulma_min_css;

@EmbedStr('/public/chart.js')
const chartJs = _$chart_js;

@EmbedStr('/public/config.html')
const configHtml = _$config_html;

@EmbedStr('/public/config.js')
const configJs = _$config_js;

@EmbedStr('/public/index.html')
const indexHtml = _$index_html;

@EmbedStr('/public/index.js')
const indexJs = _$index_js;

@EmbedBinary('/public/logo.png')
const logoPng = _$logo_png;

@EmbedStr('/public/mining.html')
const miningHtml = _$mining_html;

@EmbedStr('/public/mining.js')
const miningJs = _$mining_js;

@EmbedStr('/public/projects.html')
const projectsHtml = _$projects_html;

@EmbedStr('/public/projects.js')
const projectsJs = _$projects_js;

@EmbedStr('/public/solutions.html')
const solutionsHtml = _$solutions_html;

@EmbedStr('/public/solutions.js')
const solutionsJs = _$solutions_js;

void loadPages(app){
  app.get('/logo.png', () => Response.ok(
    logoPng,
    headers: {'Content-Type': 'image/png'},
  ));

  rPage(app, "/about.html", aboutHtml);
  rCss(app, "/bulma.min.css", bulmaMinCss);
  rJs(app, "/chart.js", chartJs);
  rPage(app, "/config.html", configHtml);
  rJs(app, "/config.js", configJs);
  rPage(app, "/", indexHtml);
  rJs(app, "/index.js", indexJs);
  rPage(app, "/mining.html", miningHtml);
  rJs(app, "/mining.js", miningJs);
  rPage(app, "/projects.html", projectsHtml);
  rJs(app, "/projects.js", projectsJs);
  rPage(app, "/solutions.html", solutionsHtml);
  rJs(app, "/solutions.js", solutionsJs);
}

void rPage(var app, String url, var obj){
  app.get(url, () => Response.ok(
    obj,
    headers: {'Content-Type': 'text/html; charset=utf-8'},
  ));
}

void rCss(var app, String url, var cssContent) {
  app.get(url, () => Response.ok(
    cssContent,
    headers: {'Content-Type': 'text/css; charset=utf-8'},
  ));
}

void rJs(var app, String url, var jsContent) {
  app.get(url, () => Response.ok(
    jsContent,
    headers: {'Content-Type': 'application/javascript; charset=utf-8'},
  ));
}