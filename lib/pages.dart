import 'package:embed_annotation/embed_annotation.dart';
import 'package:shelf_plus/shelf_plus.dart';

part 'pages.g.dart';

@EmbedStr('../public/about.html')
const about_html = _$about_html;

@EmbedStr('../public/bulma.min.css')
const bulma_min_css = _$bulma_min_css;

@EmbedStr('../public/chart.js')
const chart_js = _$chart_js;

@EmbedStr('../public/config.html')
const config_html = _$config_html;

@EmbedStr('../public/config.js')
const config_js = _$config_js;

@EmbedStr('../public/index.html')
const index_html = _$index_html;

@EmbedStr('../public/index.js')
const index_js = _$index_js;

@EmbedBinary('../public/logo.png')
const logo_png = _$logo_png;

@EmbedStr('../public/mining.html')
const mining_html = _$mining_html;

@EmbedStr('../public/mining.js')
const mining_js = _$mining_js;

@EmbedStr('../public/projects.html')
const projects_html = _$projects_html;

@EmbedStr('../public/projects.js')
const projects_js = _$projects_js;

@EmbedStr('../public/solutions.html')
const solutions_html = _$solutions_html;

@EmbedStr('../public/solutions.js')
const solutions_js = _$solutions_js;

void loadPages(app){
  app.get('/logo.png', () => Response.ok(
    logo_png,
    headers: {'Content-Type': 'image/png'},
  ));

  rPage(app, "/about.html", about_html);
  rCss(app, "/bulma.min.css", bulma_min_css);
  rJs(app, "/chart.js", chart_js);
  rPage(app, "/config.html", config_html);
  rJs(app, "/config.js", config_js);
  rPage(app, "/", index_html);
  rJs(app, "/index.js", index_js);
  rPage(app, "/mining.html", mining_html);
  rJs(app, "/mining.js", mining_js);
  rPage(app, "/projects.html", projects_html);
  rJs(app, "/projects.js", projects_js);
  rPage(app, "/solutions.html", solutions_html);
  rJs(app, "/solutions.js", solutions_js);
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